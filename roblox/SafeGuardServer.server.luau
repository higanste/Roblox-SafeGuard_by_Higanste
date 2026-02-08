--[[
    ============================================
    🛡️ SAFEGUARD AI - SERVER SCRIPT
    Made with ❤️ for the Roblox community by @Higanste
    ============================================
    
    This is the main script that initializes SafeGuard AI.
    
    📦 SETUP:
    1. Put SafeGuardAI and SafeGuardConfig in ServerScriptService
    2. Put this Script in ServerScriptService
    3. Configure your Vercel URL in SafeGuardConfig
    4. Enable HttpService in Game Settings → Security
    
    That's it! SafeGuard AI will now protect your game.
]]

local ServerScriptService = game:GetService("ServerScriptService")

-- Require the SafeGuard AI module
local SafeGuardAI = require(ServerScriptService:WaitForChild("SafeGuardAI"))

-- Initialize the system
SafeGuardAI.init()

print("🛡️ SafeGuard AI is now protecting your game!")
