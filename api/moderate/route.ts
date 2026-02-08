/**
 * ============================================
 * 🛡️ ROBLOX SAFEGUARD AI - MODERATION API
 * 
 * Created by @Higanste | Open Source
 * Twitter/X: https://x.com/higanste
 * YouTube: https://www.youtube.com/@higanste
 * ============================================
 * 
 * This Edge Function analyzes chat messages for:
 * - Bypassed slurs and profanity
 * - Off-platform contact attempts (Discord, Snapchat, etc.)
 * - Grooming/predatory behavior
 * - Leetspeak and symbol substitutions
 */

export const config = {
    runtime: 'edge',
};

// ============================================
// TYPES
// ============================================

interface ModerateRequest {
    message: string;
    playerId: string;
    playerName: string;
    playerDisplayName?: string;
    strikeCount?: number;
}

interface ModerateResponse {
    verdict: 'SAFE' | 'STRIKE_1' | 'STRIKE_2' | 'STRIKE_3' | 'GROOMING';
    reason: string;
    warningMessage?: string;
    shouldLog: boolean;
}

interface GroqMessage {
    role: 'system' | 'user' | 'assistant';
    content: string;
}

// ============================================
// MULTI-KEY ROTATION SYSTEM
// ============================================

/**
 * Dynamically scans ALL environment variables for GROQ_KEY_*
 * This allows devs to add 50+ keys for massive games!
 */
function getAllGroqKeys(): string[] {
    const keys: string[] = [];

    // Scan all env vars for keys starting with GROQ_KEY
    for (const [key, value] of Object.entries(process.env)) {
        if (key.startsWith('GROQ_KEY') && value) {
            keys.push(value);
        }
    }

    if (keys.length === 0) {
        console.error('❌ No GROQ_KEY_* environment variables found!');
    }

    return keys;
}

// Round-robin key index (persists across requests in edge runtime)
let currentKeyIndex = 0;

/**
 * Gets the next API key using round-robin rotation
 */
function getNextGroqKey(): string | null {
    const keys = getAllGroqKeys();

    if (keys.length === 0) {
        return null;
    }

    const key = keys[currentKeyIndex % keys.length];
    currentKeyIndex++;

    return key;
}

// ============================================
// THE BYPASS HUNTER - AI SYSTEM PROMPT
// ============================================

const SAFEGUARD_SYSTEM_PROMPT = `You are SafeGuard AI, an aggressive moderation system for Roblox games. Your job is to protect children from harmful content, predatory behavior, and platform violations.

## YOUR MISSION
Analyze each chat message and return a JSON verdict. You must catch BYPASSES - creative ways players try to evade filters.

## DETECTION CATEGORIES

### 1. OFF-PLATFORM CONTACT (SEVERE - These are often grooming attempts!)
Players try to move conversations off Roblox. CATCH THESE BYPASSES:
- Discord: "dizzy", "disc", "d!sc0rd", "dyscord", "dc", "discor", "dis cord"
- Snapchat: "snap", "sc", "snapch@t", "snp", "add my snap"
- Instagram: "insta", "ig", "!nstagram", "insta gram"
- TikTok: "tt", "t!kt0k", "tik tok"
- WhatsApp: "wa", "wh@tsapp", "whats app"
- Phone numbers: ANY sequence of 7-10 digits, even with spaces/symbols

### 2. LEETSPEAK & SYMBOL BYPASSES
Common letter substitutions to bypass filters:
- a→@, 4    i→!, 1, |    e→3    s→$, 5    o→0
- Using dots/spaces: "f.u.c.k", "n i g g a", "b_i_t_c_h"
- Reversed words: "kcuf", "teehcnam"
- Phonetic: "fawk", "phuck", "shyt"

### 3. SLUR BYPASSES (ZERO TOLERANCE)
ANY variation of racial/ethnic slurs, including:
- N-word with symbols: "n!gga", "n1gg3r", "niqqer", "n.i" 
- Other slurs with substitutions
- Coded language for hate speech

### 4. GROOMING BEHAVIOR (IMMEDIATE STRIKE 3)
IMMEDIATE PERMANENT BAN for ANY of these patterns:
- Age questions: "how old are you", "what's your age", "asl", "a/s/l", "are you 12"
- Personal info requests: "where do you live", "what school", "are you home alone"
- Contact requests: "add me", "dm me", "message me privately"
- Photo requests: "send pic", "show yourself", "what do you look like"
- Meeting requests: "want to meet", "let's hang out irl"
- Gift/money offers: "I'll give you robux if...", "want free stuff"
- Isolation tactics: "don't tell your parents", "this is our secret"
- Compliments + contact: "you're cute, add my snap"

### 5. GENERAL TOXICITY
- Severe insults, death threats
- Encouraging self-harm
- Targeted harassment

## RESPONSE FORMAT
You MUST respond with ONLY a JSON object, no other text:

{
  "verdict": "SAFE" | "STRIKE_1" | "STRIKE_2" | "STRIKE_3" | "GROOMING",
  "reason": "Brief explanation of why",
  "confidence": 0.0-1.0
}

## VERDICT GUIDELINES
- SAFE: Message is appropriate for Roblox
- STRIKE_1: Minor offense (mild toxicity, minor bypass attempt)
- STRIKE_2: Moderate offense (clear bypass, off-platform mention)
- STRIKE_3: Severe offense (slurs, serious harassment)
- GROOMING: ANY predatory behavior → IMMEDIATE action, do NOT give warnings first

## IMPORTANT RULES
1. When in doubt about grooming, choose GROOMING verdict. Children's safety > false positives.
2. Off-platform contact attempts are ALWAYS at least STRIKE_2.
3. Any message combining personal questions + contact requests is GROOMING.
4. Be aggressive - if it looks suspicious, it probably is.
5. Consider context: "how old is that game" is fine, "how old are you" is not.

Remember: You are the last line of defense protecting children. Be vigilant.`;

// ============================================
// DISCORD BOT LOGGING
// ============================================

async function logToDiscord(
    playerId: string,
    playerName: string,
    message: string,
    verdict: string,
    reason: string
): Promise<void> {
    const botToken = process.env.DISCORD_BOT_TOKEN;
    const channelId = process.env.DISCORD_CHANNEL_ID;

    if (!botToken || !channelId) {
        console.warn('⚠️ DISCORD_BOT_TOKEN or DISCORD_CHANNEL_ID not set, skipping log');
        return;
    }

    const colors: Record<string, number> = {
        SAFE: 0x00ff00,      // Green
        STRIKE_1: 0xffff00,  // Yellow
        STRIKE_2: 0xff8c00,  // Orange
        STRIKE_3: 0xff0000,  // Red
        GROOMING: 0x8b0000,  // Dark Red
    };

    const emojis: Record<string, string> = {
        SAFE: '✅',
        STRIKE_1: '⚠️',
        STRIKE_2: '🚨',
        STRIKE_3: '🔴',
        GROOMING: '🚨🚨🚨 PREDATOR ALERT 🚨🚨🚨',
    };

    const embed = {
        title: `${emojis[verdict]} ${verdict}`,
        color: colors[verdict] || 0x808080,
        fields: [
            {
                name: '👤 Player',
                value: `**${playerName}**\nID: \`${playerId}\``,
                inline: true,
            },
            {
                name: '💬 Message',
                value: `\`\`\`${message.substring(0, 500)}\`\`\``,
                inline: false,
            },
            {
                name: '📋 Reason',
                value: reason,
                inline: false,
            },
            {
                name: '🔗 Quick Actions',
                value: `[View Profile](https://www.roblox.com/users/${playerId}/profile)`,
                inline: true,
            },
        ],
        timestamp: new Date().toISOString(),
        footer: {
            text: '🛡️ SafeGuard AI by @Higanste | x.com/higanste',
        },
    };

    // For GROOMING verdicts, add urgent warning
    if (verdict === 'GROOMING') {
        embed.fields.push({
            name: '⚠️ IMMEDIATE ACTION REQUIRED',
            value: 'This player has been **PERMANENTLY BANNED** from chat. Review the message and consider reporting to Roblox.',
            inline: false,
        });
    }

    try {
        // Send message via Discord Bot API (not webhook)
        await fetch(`https://discord.com/api/v10/channels/${channelId}/messages`, {
            method: 'POST',
            headers: {
                'Authorization': `Bot ${botToken}`,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                embeds: [embed],
            }),
        });
    } catch (error) {
        console.error('Failed to log to Discord:', error);
    }
}

// ============================================
// GROQ API CALL
// ============================================

async function callGroqAPI(message: string, apiKey: string): Promise<ModerateResponse> {
    const messages: GroqMessage[] = [
        { role: 'system', content: SAFEGUARD_SYSTEM_PROMPT },
        { role: 'user', content: `Analyze this Roblox chat message:\n\n"${message}"` },
    ];

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${apiKey}`,
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            model: 'llama-3.1-8b-instant',
            messages,
            temperature: 0.1,  // Low temp for consistent moderation
            max_tokens: 200,
            response_format: { type: 'json_object' },
        }),
    });

    if (!response.ok) {
        const error = await response.text();
        throw new Error(`Groq API error: ${response.status} - ${error}`);
    }

    const data = await response.json();
    const content = data.choices?.[0]?.message?.content;

    if (!content) {
        throw new Error('No response from Groq');
    }

    try {
        const parsed = JSON.parse(content);

        // Generate appropriate warning message
        let warningMessage: string | undefined;

        switch (parsed.verdict) {
            case 'STRIKE_1':
                warningMessage = `⚠️ Hey, please be respectful to others! This is your first warning.`;
                break;
            case 'STRIKE_2':
                warningMessage = `🚨 Your chat has been disabled for 24 hours due to repeated violations.`;
                break;
            case 'STRIKE_3':
                warningMessage = `🔴 Your chat has been permanently disabled. You may appeal this decision.`;
                break;
            case 'GROOMING':
                warningMessage = `🚨 ALERT: Predatory behavior detected. Your account has been flagged and this incident has been logged. Attempting to contact minors in this way is a CRIME.`;
                break;
        }

        return {
            verdict: parsed.verdict || 'SAFE',
            reason: parsed.reason || 'No reason provided',
            warningMessage,
            shouldLog: parsed.verdict !== 'SAFE',
        };
    } catch {
        console.error('Failed to parse Groq response:', content);
        return {
            verdict: 'SAFE',
            reason: 'Parse error - defaulting to safe',
            shouldLog: false,
        };
    }
}

// ============================================
// MAIN HANDLER
// ============================================

export default async function handler(request: Request): Promise<Response> {
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
        return new Response(null, {
            status: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type',
            },
        });
    }

    // Only accept POST
    if (request.method !== 'POST') {
        return new Response(JSON.stringify({ error: 'Method not allowed' }), {
            status: 405,
            headers: { 'Content-Type': 'application/json' },
        });
    }

    try {
        const body: ModerateRequest = await request.json();

        // Validate required fields
        if (!body.message || !body.playerId || !body.playerName) {
            return new Response(JSON.stringify({
                error: 'Missing required fields: message, playerId, playerName'
            }), {
                status: 400,
                headers: { 'Content-Type': 'application/json' },
            });
        }

        // Get API key with rotation
        const apiKey = getNextGroqKey();

        if (!apiKey) {
            return new Response(JSON.stringify({
                error: 'No API keys configured. Add GROQ_KEY_1, GROQ_KEY_2, etc. to environment.'
            }), {
                status: 500,
                headers: { 'Content-Type': 'application/json' },
            });
        }

        // Quick pre-check for obviously safe messages
        const quickSafePatterns = /^(hi|hello|hey|gg|nice|cool|thanks|ty|np|lol|lmao|bruh|ok|okay|yes|no|maybe|idk)$/i;
        if (quickSafePatterns.test(body.message.trim())) {
            return new Response(JSON.stringify({
                verdict: 'SAFE',
                reason: 'Common safe phrase',
                shouldLog: false,
            }), {
                status: 200,
                headers: { 'Content-Type': 'application/json' },
            });
        }

        // Call Groq for AI analysis
        const result = await callGroqAPI(body.message, apiKey);

        // Log to Discord if needed
        if (result.shouldLog) {
            // Don't await - fire and forget to keep response fast
            logToDiscord(
                body.playerId,
                body.playerDisplayName || body.playerName,
                body.message,
                result.verdict,
                result.reason
            ).catch(console.error);
        }

        return new Response(JSON.stringify(result), {
            status: 200,
            headers: { 'Content-Type': 'application/json' },
        });

    } catch (error) {
        console.error('Moderation error:', error);

        // On error, default to SAFE to avoid blocking legitimate chat
        return new Response(JSON.stringify({
            verdict: 'SAFE',
            reason: 'System error - defaulting to safe',
            shouldLog: false,
            error: error instanceof Error ? error.message : 'Unknown error',
        }), {
            status: 200, // Return 200 even on error so Roblox doesn't break
            headers: { 'Content-Type': 'application/json' },
        });
    }
}
