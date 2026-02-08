--[[
    ============================================
    🛡️ SAFEGUARD AI - MAIN MODULE
    Made with ❤️ for the Roblox community by @Higanste
    ============================================
    
    The most aggressive, context-aware AI moderation system for Roblox.
    
    FEATURES:
    ✅ AI-powered message analysis (Groq Llama 3.1)
    ✅ Bypass detection (leetspeak, symbols, off-platform)
    ✅ Grooming behavior detection
    ✅ 3-Second chat cooldown
    ✅ Strike system (Warning → 24hr mute → Permanent ban)
    ✅ Discord webhook logging
    
    SETUP:
    1. Put this ModuleScript in ServerScriptService
    2. Put SafeGuardConfig in the same location
    3. Edit SafeGuardConfig with your Vercel URL
    4. Enable HttpService in Game Settings
    5. Add a Script that requires this module
    
    ⚠️ IMPORTANT: This script ONLY runs on the server!
]]

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get config
local Config = require(script.Parent:FindFirstChild("SafeGuardConfig") or script.Parent.Parent:FindFirstChild("SafeGuardConfig"))

-- DataStore for strikes
local StrikeStore = DataStoreService:GetDataStore(Config.DATASTORE_NAME)

-- ============================================
-- MODULE
-- ============================================

local SafeGuardAI = {}
SafeGuardAI.__index = SafeGuardAI

-- Store player cooldowns and data
local playerCooldowns = {} -- {[userId] = lastMessageTime}
local playerStrikes = {}   -- {[userId] = {strikes = 0, mutedUntil = 0, banned = false}}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function debugPrint(...)
    if Config.DEBUG_MODE then
        print("[SafeGuard DEBUG]", ...)
    end
end

local function formatTime(seconds: number): string
    if seconds >= 3600 then
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        return string.format("%dh %dm", hours, mins)
    elseif seconds >= 60 then
        local mins = math.floor(seconds / 60)
        local secs = seconds % 60
        return string.format("%dm %ds", mins, secs)
    else
        return string.format("%ds", seconds)
    end
end

-- ============================================
-- DATA PERSISTENCE
-- ============================================

function SafeGuardAI.loadPlayerData(player: Player)
    local userId = player.UserId
    
    -- Try to load from DataStore
    local success, data = pcall(function()
        return StrikeStore:GetAsync("player_" .. userId)
    end)
    
    if success and data then
        playerStrikes[userId] = data
        debugPrint("Loaded data for", player.Name, "- Strikes:", data.strikes)
    else
        -- New player or error
        playerStrikes[userId] = {
            strikes = 0,
            mutedUntil = 0,
            banned = false
        }
    end
    
    -- Initialize cooldown
    playerCooldowns[userId] = 0
end

function SafeGuardAI.savePlayerData(player: Player)
    local userId = player.UserId
    local data = playerStrikes[userId]
    
    if not data then return end
    
    local success, err = pcall(function()
        StrikeStore:SetAsync("player_" .. userId, data)
    end)
    
    if not success then
        warn("[SafeGuard] Failed to save data for", player.Name, "-", err)
    else
        debugPrint("Saved data for", player.Name)
    end
end

-- ============================================
-- MODERATION API
-- ============================================

function SafeGuardAI.moderateMessage(player: Player, message: string): (string, string?, boolean)
    -- Returns: verdict, warningMessage, shouldBlock
    
    local apiUrl = Config.API_URL .. "/api/moderate"
    
    local requestBody = {
        message = message,
        playerId = tostring(player.UserId),
        playerName = player.Name,
        playerDisplayName = player.DisplayName,
        strikeCount = playerStrikes[player.UserId] and playerStrikes[player.UserId].strikes or 0
    }
    
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = apiUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(requestBody)
        })
    end)
    
    if not success then
        warn("[SafeGuard] API request failed:", response)
        return "SAFE", nil, false -- Allow message on API failure
    end
    
    if response.StatusCode ~= 200 then
        warn("[SafeGuard] API returned status:", response.StatusCode)
        return "SAFE", nil, false
    end
    
    local data = HttpService:JSONDecode(response.Body)
    return data.verdict, data.warningMessage, data.verdict ~= "SAFE"
end

-- ============================================
-- STRIKE SYSTEM
-- ============================================

function SafeGuardAI.applyStrike(player: Player, verdict: string)
    local userId = player.UserId
    local data = playerStrikes[userId]
    
    if not data then
        data = {strikes = 0, mutedUntil = 0, banned = false}
        playerStrikes[userId] = data
    end
    
    local displayName = player.DisplayName or player.Name
    
    if verdict == "GROOMING" then
        -- IMMEDIATE permanent ban - no warnings
        data.strikes = 99
        data.banned = true
        
        -- Send warning to all players
        SafeGuardAI.sendSystemMessage(
            string.format(Config.MESSAGES.GROOMING, displayName)
        )
        
        debugPrint("GROOMING DETECTED - Permanent ban for", player.Name)
        
    elseif verdict == "STRIKE_3" then
        -- Permanent ban
        data.strikes = 3
        data.banned = true
        
        SafeGuardAI.sendSystemMessage(
            string.format(Config.MESSAGES.STRIKE_3, displayName)
        )
        
    elseif verdict == "STRIKE_2" then
        -- 24-hour mute
        if data.strikes < 2 then
            data.strikes = 2
        end
        data.mutedUntil = os.time() + Config.STRIKE_2_DURATION
        
        SafeGuardAI.sendSystemMessage(
            string.format(Config.MESSAGES.STRIKE_2, displayName)
        )
        
    elseif verdict == "STRIKE_1" then
        -- Warning
        if data.strikes < 1 then
            data.strikes = 1
        else
            -- Already has warnings, escalate
            data.strikes = data.strikes + 1
            
            if data.strikes >= 3 then
                -- Escalate to permanent ban
                data.banned = true
                SafeGuardAI.sendSystemMessage(
                    string.format(Config.MESSAGES.STRIKE_3, displayName)
                )
            elseif data.strikes >= 2 then
                -- Escalate to 24hr mute
                data.mutedUntil = os.time() + Config.STRIKE_2_DURATION
                SafeGuardAI.sendSystemMessage(
                    string.format(Config.MESSAGES.STRIKE_2, displayName)
                )
            end
        end
        
        -- Show warning if not escalated
        if data.strikes == 1 then
            SafeGuardAI.sendSystemMessage(
                string.format(Config.MESSAGES.STRIKE_1, displayName)
            )
        end
    end
    
    -- Save immediately
    SafeGuardAI.savePlayerData(player)
end

-- ============================================
-- CHAT FUNCTIONS
-- ============================================

function SafeGuardAI.canPlayerChat(player: Player): (boolean, string?)
    local userId = player.UserId
    local data = playerStrikes[userId]
    
    if not data then
        return true, nil
    end
    
    -- Check permanent ban
    if data.banned then
        return false, Config.MESSAGES.BANNED
    end
    
    -- Check temporary mute
    if data.mutedUntil > os.time() then
        local remaining = data.mutedUntil - os.time()
        return false, string.format(Config.MESSAGES.MUTED, formatTime(remaining))
    end
    
    -- Check cooldown
    local lastMessage = playerCooldowns[userId] or 0
    local elapsed = os.time() - lastMessage
    
    if elapsed < Config.CHAT_COOLDOWN then
        local remaining = Config.CHAT_COOLDOWN - elapsed
        return false, string.format(Config.MESSAGES.COOLDOWN, remaining)
    end
    
    return true, nil
end

function SafeGuardAI.sendSystemMessage(message: string)
    -- Send a system message to all players via TextChatService
    local generalChannel = TextChatService:FindFirstChild("TextChannels")
        and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    
    if generalChannel then
        generalChannel:DisplaySystemMessage(message)
    else
        -- Fallback: Create a system message
        debugPrint("System message:", message)
    end
end

function SafeGuardAI.sendPrivateMessage(player: Player, message: string)
    -- Send a message only to one player
    -- This uses a RemoteEvent if you have one set up
    local remoteEvent = ReplicatedStorage:FindFirstChild("SafeGuardMessage")
    
    if remoteEvent then
        remoteEvent:FireClient(player, message)
    else
        debugPrint("Private message to", player.Name, ":", message)
    end
end

-- ============================================
-- MAIN CHAT HANDLER
-- ============================================

function SafeGuardAI.onPlayerChatted(player: Player, message: string): boolean
    -- Returns: true if message should be blocked
    
    local userId = player.UserId
    
    -- Check if player can chat
    local canChat, reason = SafeGuardAI.canPlayerChat(player)
    
    if not canChat then
        SafeGuardAI.sendPrivateMessage(player, reason)
        return true -- Block message
    end
    
    -- Update cooldown
    playerCooldowns[userId] = os.time()
    
    -- Send to AI for moderation
    local verdict, warningMessage, shouldBlock = SafeGuardAI.moderateMessage(player, message)
    
    debugPrint("Message from", player.Name, "- Verdict:", verdict)
    
    -- Apply strike if needed
    if verdict ~= "SAFE" then
        SafeGuardAI.applyStrike(player, verdict)
        return true -- Block the message
    end
    
    return false -- Allow message
end

-- ============================================
-- INITIALIZATION
-- ============================================

function SafeGuardAI.init()
    print("============================================")
    print("🛡️ SafeGuard AI v1.0.0")
    print("Made with ❤️ by @Higanste")
    print("============================================")
    
    -- Validate config
    if Config.API_URL == "YOUR_VERCEL_URL_HERE" then
        warn("⚠️ [SafeGuard] Please set your Vercel URL in SafeGuardConfig!")
        return
    end
    
    -- Create RemoteEvent for private messages if it doesn't exist
    if not ReplicatedStorage:FindFirstChild("SafeGuardMessage") then
        local remote = Instance.new("RemoteEvent")
        remote.Name = "SafeGuardMessage"
        remote.Parent = ReplicatedStorage
    end
    
    -- Hook into TextChatService (modern chat system)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.OnIncomingMessage = function(message)
            -- This is called for UI customization, not filtering
            -- Actual filtering happens in SendingMessage
        end
        
        -- Hook into SendingMessage for filtering
        local function setupChannel(channel)
            channel.ShouldDeliverCallback = function(textChatMessage, targetTextSource)
                if not textChatMessage.TextSource then
                    return true -- System message
                end
                
                local player = Players:GetPlayerByUserId(textChatMessage.TextSource.UserId)
                if not player then
                    return true
                end
                
                -- Check if player can chat
                local canChat, _ = SafeGuardAI.canPlayerChat(player)
                return canChat
            end
        end
        
        -- Setup existing channels
        local textChannels = TextChatService:FindFirstChild("TextChannels")
        if textChannels then
            for _, channel in ipairs(textChannels:GetChildren()) do
                if channel:IsA("TextChannel") then
                    setupChannel(channel)
                end
            end
        end
        
        print("✅ [SafeGuard] Connected to TextChatService")
    end
    
    -- Player connection handlers
    Players.PlayerAdded:Connect(function(player)
        SafeGuardAI.loadPlayerData(player)
        debugPrint("Player joined:", player.Name)
        
        -- Hook into player's chat
        player.Chatted:Connect(function(message)
            SafeGuardAI.onPlayerChatted(player, message)
        end)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        SafeGuardAI.savePlayerData(player)
        
        -- Cleanup
        playerCooldowns[player.UserId] = nil
        playerStrikes[player.UserId] = nil
        
        debugPrint("Player left:", player.Name)
    end)
    
    -- Handle players already in game (for Studio testing)
    for _, player in ipairs(Players:GetPlayers()) do
        SafeGuardAI.loadPlayerData(player)
        
        player.Chatted:Connect(function(message)
            SafeGuardAI.onPlayerChatted(player, message)
        end)
    end
    
    print("✅ [SafeGuard] Initialized successfully!")
    print("📡 API Endpoint:", Config.API_URL)
    print("⏱️ Chat Cooldown:", Config.CHAT_COOLDOWN, "seconds")
    print("============================================")
end

return SafeGuardAI
