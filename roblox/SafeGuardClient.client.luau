--[[
    ============================================
    🛡️ SAFEGUARD AI - CLIENT HANDLER
    Made with ❤️ for the Roblox community by @Higanste
    ============================================
    
    This LocalScript handles:
    - Receiving private warning messages from the server
    - Updating the chat cooldown timer in the placeholder
    
    📦 SETUP:
    Put this LocalScript in StarterPlayerScripts
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- Configuration (should match server config)
local CHAT_COOLDOWN = 3
local DEFAULT_PLACEHOLDER = "Type here to chat..."

-- State
local lastChatTime = 0
local isCooldownActive = false

-- ============================================
-- COOLDOWN TIMER
-- ============================================

local function updateChatPlaceholder(text: string)
    -- Try to find the chat input bar and update placeholder
    -- This works with TextChatService (modern chat)
    
    local chatInputBar = TextChatService:FindFirstChild("ChatInputBarConfiguration")
    
    if chatInputBar then
        -- Modern TextChatService
        chatInputBar.PlaceholderText = text
    else
        -- Fallback: Try legacy chat system
        local chatGui = player.PlayerGui:FindFirstChild("Chat")
        if chatGui then
            local inputBox = chatGui:FindFirstChild("ChatBar", true)
            if inputBox and inputBox:IsA("TextBox") then
                inputBox.PlaceholderText = text
            end
        end
    end
end

local function startCooldownTimer()
    if isCooldownActive then return end
    
    isCooldownActive = true
    lastChatTime = tick()
    
    -- Update placeholder with countdown
    task.spawn(function()
        for countdown = CHAT_COOLDOWN, 1, -1 do
            updateChatPlaceholder(string.format("⏳ %d...", countdown))
            task.wait(1)
        end
        
        updateChatPlaceholder(DEFAULT_PLACEHOLDER)
        isCooldownActive = false
    end)
end

-- ============================================
-- MESSAGE HANDLING
-- ============================================

local function showWarningNotification(message: string)
    -- Show a notification for warnings
    StarterGui:SetCore("SendNotification", {
        Title = "🛡️ SafeGuard AI";
        Text = message;
        Duration = 5;
    })
end

-- Wait for RemoteEvent
local safeguardMessage = ReplicatedStorage:WaitForChild("SafeGuardMessage", 10)

if safeguardMessage then
    safeguardMessage.OnClientEvent:Connect(function(message)
        showWarningNotification(message)
    end)
end

-- ============================================
-- CHAT HOOKS
-- ============================================

-- Hook into chat to trigger cooldown timer
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    local textChannels = TextChatService:FindFirstChild("TextChannels")
    
    if textChannels then
        local generalChannel = textChannels:FindFirstChild("RBXGeneral")
        
        if generalChannel then
            -- This fires when the player sends a message
            generalChannel.MessageReceived:Connect(function(textChatMessage)
                if textChatMessage.TextSource and 
                   textChatMessage.TextSource.UserId == player.UserId then
                    -- Player sent a message, start cooldown
                    startCooldownTimer()
                end
            end)
        end
    end
else
    -- Legacy chat system
    player.Chatted:Connect(function(message)
        startCooldownTimer()
    end)
end

print("✅ [SafeGuard Client] Initialized!")
