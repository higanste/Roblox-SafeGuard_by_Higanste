# 🛡️ Roblox SafeGuard AI - The Bypass Hunter

> **The most aggressive, context-aware AI moderation system for Roblox.**
> 
> Created with ❤️ by **@Higanste**
> [🐦 Twitter/X](https://x.com/higanste) | [📺 YouTube](https://www.youtube.com/@higanste)

---

## ⚡ Why SafeGuard AI?

Traditional filters are easily bypassed. **SafeGuard AI** uses Groq's Llama 3.1 to understand the **context** and **intent** behind a message. It doesn't just look for words; it looks for **behavior**.

- 🤖 **Behavioral Analysis**: Catches grooming attempts and predatory behavior.
- 🔍 **Bypass Hunter**: Detects `d.i.z.z.y`, `snp`, `insta`, and 1000+ leetspeak variations.
- ⏱️ **Zero Latency**: Built on Vercel Edge for maximum speed.
- 📊 **Scale Ready**: Auto-rotates between 50+ Groq keys for massive games.

---

## 📖 Quick Start & Deployment Guide

### 1. The 1-Click Deployment
1. **Fork this Repository**: Click the 'Fork' button at the top of this page to copy it to your GitHub account.
2. **Connect to Vercel**:
   - Log in to [Vercel](https://vercel.com).
   - Click **"Add New Project"**.
   - Select your **Roblox-SafeGuard** repository.
   - **IMPORTANT**: Paste your Environment Variables during the setup (see below).

### 2. Required API Keys
You will need to add these as "Environment Variables" in Vercel:

| Key Name | Where to get it |
|----------|-----------------|
| `GROQ_KEY_1` | [console.groq.com](https://console.groq.com) |
| `DISCORD_BOT_TOKEN` | [Discord Developer Portal](https://discord.com/developers/applications) |
| `DISCORD_CHANNEL_ID` | Right-click your log channel in Discord |

### 3. Roblox Studio Integration
1. Enable **HTTP Requests** in Game Settings → Security.
2. Copy these files into your game:
   - `roblox/SafeGuardAI.luau` → ModuleScript in **ServerScriptService**.
   - `roblox/SafeGuardConfig.luau` → ModuleScript in **ServerScriptService**.
   - `roblox/SafeGuardServer.server.luau` → Script in **ServerScriptService**.
   - `roblox/SafeGuardClient.client.luau` → LocalScript in **StarterPlayerScripts**.
3. **Set your URL**: Open `SafeGuardConfig` and paste your final Vercel URL.

---

## 🤖 MASTER AI SETUP PROMPT (100% Automated)

Want the AI to do all the work? Copy and paste this prompt into your AI assistant (Cursor, Antigravity, or Copilot):

> "Help me set up **Roblox SafeGuard AI** by **@Higanste**. 
> 1. Clone the repo from `https://github.com/higanste/Roblox-SafeGuard_by_Higanste`.
> 2. Ask me interactively for my Discord Bot Token, Channel ID, and Groq API keys (ask if I have more keys!).
> 3. Create my `.env` file automatically.
> 4. Help me deploy to Vercel and then update `SafeGuardConfig.luau` with the final URL.
> 5. Tell me exactly where to paste each script in Roblox Studio. 
> Let's go!"

---


## 📺 Tutorial & Support
**Full Tutorial Video Coming Soon on YouTube!** 
Subscribe to [@Higanste on YouTube](https://www.youtube.com/@higanste) so you don't miss it.

Found a bug? 
Reach out on **Twitter/X**: [@Higanste](https://x.com/higanste)

---

## 🤝 Contributing
Found a new bypass? Submit a Pull Request! help us keep the Roblox community safe for everyone.

---

## 📄 License
MIT License - Created by **@Higanste**
"SafeGuard AI - The Bypass Hunter" is open-source and free to use.

🛡️ *"Protecting the future of play."*
