--[[
    ============================================
    🛡️ SAFEGUARD AI - CONFIGURATION
    Made with ❤️ for the Roblox community by @Higanste
    ============================================
    
    📝 SETUP INSTRUCTIONS:
    1. Deploy the backend to Vercel first
    2. Copy your Vercel URL here (e.g., https://your-project.vercel.app)
    3. Put this ModuleScript in ServerScriptService
    
    ⚠️ IMPORTANT: Enable HttpService in Game Settings!
    Game Settings → Security → Allow HTTP Requests → ON
]]

local Config = {}

-- ============================================
-- 🔧 YOUR SETTINGS (EDIT THESE!)
-- ============================================

-- Your Vercel deployment URL (no trailing slash!)
-- Example: "https://roblox-safeguard.vercel.app"
Config.API_URL = "YOUR_VERCEL_URL_HERE"

-- Cooldown between messages (in seconds)
Config.CHAT_COOLDOWN = 3

-- Enable debug prints in output
Config.DEBUG_MODE = false

-- ============================================
-- ⚡ STRIKE SETTINGS
-- ============================================

-- How long should Strike 2 (chat mute) last? (in seconds)
-- Default: 24 hours = 86400 seconds
Config.STRIKE_2_DURATION = 86400

-- DataStore name for storing player strikes
Config.DATASTORE_NAME = "SafeGuardAI_Strikes"

-- ============================================
-- 💬 WARNING MESSAGES
-- ============================================

Config.MESSAGES = {
    -- Strike 1: Warning
    STRIKE_1 = "⚠️ [SafeGuard] Hey %s, please be respectful to others! This is your first warning.",
    
    -- Strike 2: 24hr mute
    STRIKE_2 = "🚨 [SafeGuard] %s, your chat has been disabled for 24 hours due to repeated violations.",
    
    -- Strike 3: Permanent ban
    STRIKE_3 = "🔴 [SafeGuard] %s, your chat has been permanently disabled. You may appeal in our Discord.",
    
    -- Grooming detection (IMMEDIATE action)
    GROOMING = "🚨 [SafeGuard] ALERT: Predatory behavior detected from %s. This incident has been logged and reported.",
    
    -- Cooldown message
    COOLDOWN = "⏳ Wait %d seconds...",
    
    -- Chat muted message
    MUTED = "🔇 Your chat is currently disabled. Time remaining: %s",
    
    -- Permanently banned message  
    BANNED = "🔴 Your chat is permanently disabled. Appeal in our Discord server.",
}

-- ============================================
-- 🎨 UI SETTINGS (for the cooldown timer)
-- ============================================

-- Show countdown in chat placeholder
Config.SHOW_COOLDOWN_IN_PLACEHOLDER = true

-- Default placeholder text when can chat
Config.DEFAULT_PLACEHOLDER = "Type here to chat..."

return Config
