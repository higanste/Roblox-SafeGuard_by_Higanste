# 🛡️ Roblox SafeGuard AI

> **The most aggressive, context-aware AI moderation system for Roblox.**
> 
> Created by **@Higanste** | [X (Twitter)](https://x.com/higanste) | [YouTube](https://www.youtube.com/@higanste)

![SafeGuard AI Banner](https://img.shields.io/badge/SafeGuard-AI%20Powered-blue?style=for-the-badge&logo=roblox)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Vercel](https://img.shields.io/badge/Backend-Vercel%20Edge-black?style=for-the-badge&logo=vercel)

---

## ⚡ Features

- 🤖 **AI-Powered Moderation**: uses Groq's Llama 3.1 to understand intent.
- 🔍 **Bypass Detection**: catches leetspeak, symbols, off-platform attempts.
- 🚨 **Grooming Detection**: immediate permanent ban on predatory behavior.
- ⏱️ **3-Second Cooldown**: rate limiting shown directly in chat placeholder.
- 📊 **Strike System**: Warning → 24hr mute → Permanent ban.
- 📢 **Discord Bot Logging**: Branded moderation alerts sent to your server.
- ♾️ **Infinite API Scaling**: Add 50+ Groq keys for massive games.

---

## 📖 Step-By-Step Setup Tutorial

### 1. Backend Setup (Vercel)
1. **Clone the repo**: `git clone https://github.com/YOUR-USERNAME/roblox-safeguard-ai.git`
2. **Setup Groq**:
   - Go to [console.groq.com](https://console.groq.com)
   - Create an account and generate an API key.
   - Copy the key (`gsk_...`).
3. **Setup Discord Bot**:
   - Go to [Discord Developer Portal](https://discord.com/developers/applications).
   - "New Application" → Name it "SafeGuard AI".
   - "Bot" → "Reset Token" → **Copy this token**.
   - Scroll down to "Privileged Gateway Intents" and enable **Message Content Intent**.
   - "OAuth2" → "URL Generator" → Select `bot` + `Send Messages` → Copy URL and invite bot to your server.
   - Right-click your log channel in Discord → **Copy Channel ID**.
4. **Deploy to Vercel**:
   - Install Vercel CLI: `npm i -g vercel`
   - Run `vercel` in the project folder.
   - Set these Environment Variables in the Vercel Dashboard:
     - `GROQ_KEY_1`: Your Groq API key.
     - `DISCORD_BOT_TOKEN`: Your Discord Bot token.
     - `DISCORD_CHANNEL_ID`: Your Discord channel ID.
   - Copy your **Deployment URL** (e.g. `https://safe-guard.vercel.app`).

### 2. Roblox Studio Setup
1. **Enable HttpService**: Game Settings → Security → **Allow HTTP Requests**.
2. **Add Scripts**:
   - Copy `roblox/SafeGuardAI.luau` to a **ModuleScript** in `ServerScriptService` named `SafeGuardAI`.
   - Copy `roblox/SafeGuardConfig.luau` to a **ModuleScript** in `ServerScriptService` named `SafeGuardConfig`.
   - Copy `roblox/SafeGuardServer.server.luau` to a **Script** in `ServerScriptService`.
   - Copy `roblox/SafeGuardClient.client.luau` to a **LocalScript** in `StarterPlayerScripts`.
3. **Configure**: Open `SafeGuardConfig` and paste your Vercel URL in `Config.API_URL`.

---

## 🤖 VS Code AI Prompt (Auto-Setup)

Copy and paste this prompt into your VS Code AI (Copilot/Cursor/Antigravity) to help you set up this project instantly:

```text
Help me set up the Roblox SafeGuard AI project by @Higanste. 
1. Check the .env.example file and help me create a .env file.
2. Tell me where I need to paste my Groq API Key and Discord Bot Token.
3. Explain how to deploy this to Vercel using the terminal.
4. Once deployed, show me exactly which files I need to copy into Roblox Studio and where they go.
5. Remind me to update SafeGuardConfig.luau with my final Vercel URL.
Make it easy for a beginner to follow!
```

---

## 📺 Tutorial Video
**Coming Soon!** Subscribe to [Higanste on YouTube](https://www.youtube.com/@higanste) for the full video guide.

---

## 🐞 Bugs & Support
Found an issue? Need help? 
- 🐦 **Twitter/X**: [@Higanste](https://x.com/higanste)
- 📺 **YouTube**: [@Higanste](https://www.youtube.com/@higanste)

---

## 🤝 Contributing
Feel free to fork and submit PRs to improve the bypass detection!

---

## 📄 License
MIT License - Developed with ❤️ by **@Higanste**
