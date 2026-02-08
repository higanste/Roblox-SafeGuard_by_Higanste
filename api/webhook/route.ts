/**
 * ============================================
 * 🛡️ SAFEGUARD AI - WEBHOOK HANDLER
 * 
 * Created by @Higanste | Open Source
 * Twitter/X: https://x.com/higanste
 * YouTube: https://www.youtube.com/@higanste
 * ============================================
 * 
 * This endpoint can be used for:
 * - Receiving admin actions from Discord (approve/deny appeals)
 * - Health checks
 * - Manual moderation commands
 */

export const config = {
    runtime: 'edge',
};

interface WebhookPayload {
    action: 'approve_appeal' | 'deny_appeal' | 'health_check';
    playerId?: string;
    playerName?: string;
    reason?: string;
    adminId?: string;
}

export default async function handler(request: Request): Promise<Response> {
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
        return new Response(null, {
            status: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type',
            },
        });
    }

    // Health check endpoint
    if (request.method === 'GET') {
        return new Response(JSON.stringify({
            status: 'ok',
            service: 'SafeGuard AI',
            version: '1.0.0',
            author: '@Higanste',
            timestamp: new Date().toISOString(),
        }), {
            status: 200,
            headers: { 'Content-Type': 'application/json' },
        });
    }

    // Handle POST requests
    if (request.method !== 'POST') {
        return new Response(JSON.stringify({ error: 'Method not allowed' }), {
            status: 405,
            headers: { 'Content-Type': 'application/json' },
        });
    }

    try {
        const body: WebhookPayload = await request.json();

        switch (body.action) {
            case 'health_check':
                return new Response(JSON.stringify({
                    status: 'healthy',
                    message: '🛡️ SafeGuard AI is running!',
                }), {
                    status: 200,
                    headers: { 'Content-Type': 'application/json' },
                });

            case 'approve_appeal':
                // In a full implementation, this would update a database
                console.log(`✅ Appeal APPROVED for player ${body.playerId} by admin ${body.adminId}`);

                // Send notification to Discord
                await notifyAppealResult(body.playerId!, body.playerName!, 'APPROVED', body.reason);

                return new Response(JSON.stringify({
                    success: true,
                    message: `Appeal approved for ${body.playerName}`,
                    playerId: body.playerId,
                }), {
                    status: 200,
                    headers: { 'Content-Type': 'application/json' },
                });

            case 'deny_appeal':
                console.log(`❌ Appeal DENIED for player ${body.playerId} by admin ${body.adminId}`);

                await notifyAppealResult(body.playerId!, body.playerName!, 'DENIED', body.reason);

                return new Response(JSON.stringify({
                    success: true,
                    message: `Appeal denied for ${body.playerName}`,
                    playerId: body.playerId,
                }), {
                    status: 200,
                    headers: { 'Content-Type': 'application/json' },
                });

            default:
                return new Response(JSON.stringify({
                    error: 'Unknown action',
                    validActions: ['approve_appeal', 'deny_appeal', 'health_check'],
                }), {
                    status: 400,
                    headers: { 'Content-Type': 'application/json' },
                });
        }
    } catch (error) {
        console.error('Webhook error:', error);
        return new Response(JSON.stringify({
            error: 'Internal server error',
            message: error instanceof Error ? error.message : 'Unknown error',
        }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        });
    }
}

/**
 * Sends appeal result notification to Discord using Bot API
 */
async function notifyAppealResult(
    playerId: string,
    playerName: string,
    result: 'APPROVED' | 'DENIED',
    reason?: string
): Promise<void> {
    const botToken = process.env.DISCORD_BOT_TOKEN;
    const channelId = process.env.DISCORD_CHANNEL_ID;

    if (!botToken || !channelId) {
        console.warn('⚠️ DISCORD_BOT_TOKEN or DISCORD_CHANNEL_ID not set');
        return;
    }

    const isApproved = result === 'APPROVED';

    const embed = {
        title: isApproved ? '✅ Appeal Approved' : '❌ Appeal Denied',
        color: isApproved ? 0x00ff00 : 0xff0000,
        fields: [
            {
                name: '👤 Player',
                value: `**${playerName}**\nID: \`${playerId}\``,
                inline: true,
            },
            {
                name: '📋 Result',
                value: isApproved
                    ? 'Chat privileges have been restored.'
                    : 'Ban remains in effect.',
                inline: false,
            },
        ],
        timestamp: new Date().toISOString(),
        footer: {
            text: '🛡️ SafeGuard AI by @Higanste | x.com/higanste',
        },
    };

    if (reason) {
        embed.fields.push({
            name: '💬 Admin Note',
            value: reason,
            inline: false,
        });
    }

    try {
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
        console.error('Failed to send Discord notification:', error);
    }
}

