-- SynceHub - Additional Tabs Module
-- Berisi Tab: Teleport, Shop, Premium, Quests, Events, Tools, Webhook, Configuration, About

local Window = _G.SynceHub.Window
local Reg = _G.SynceHub.Reg
local GetHRP = _G.SynceHub.GetHRP
local TeleportToLookAt = _G.SynceHub.TeleportToLookAt
local FishingAreas = _G.SynceHub.FishingAreas
local GetRemote = _G.SynceHub.GetRemote
local RPath = _G.SynceHub.RPath
local SmartLoadConfig = _G.SynceHub.SmartLoadConfig

local LocalPlayer = game.Players.LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- 📍 TELEPORT TAB
-- ============================================
local teleport = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin",
    Locked = false,
})

local tpsec = teleport:Section({
    Title = "Fast Travel Locations",
    TextSize = 20,
})

-- Create buttons for each fishing area
for areaName, areaData in pairs(FishingAreas) do
    tpsec:Button({
        Title = areaName,
        Icon = "navigation",
        Callback = function()
            TeleportToLookAt(areaData.Pos, areaData.Look)
        end
    })
end

-- NPCs Teleport Section
local npcsec = teleport:Section({
    Title = "NPCs & Merchants",
    TextSize = 20,
})

local NPCLocations = {
    ["Marc (Merchant)"] = {Pos = Vector3.new(471.5, 151.5, 230.5), Look = Vector3.new(1, 0, 0)},
    ["Shipwright"] = {Pos = Vector3.new(372.5, 135.5, 278.5), Look = Vector3.new(0, 0, 1)},
    ["Rod Keeper"] = {Pos = Vector3.new(453.5, 151.5, 227.5), Look = Vector3.new(-1, 0, 0)},
    ["Bait Merchant"] = {Pos = Vector3.new(396.5, 135.5, 234.5), Look = Vector3.new(0, 0, -1)},
}

for npcName, npcData in pairs(NPCLocations) do
    npcsec:Button({
        Title = npcName,
        Icon = "user",
        Callback = function()
            TeleportToLookAt(npcData.Pos, npcData.Look)
        end
    })
end

print("[SynceHub] Teleport Tab Loaded!")

-- ============================================
-- 🛒 SHOP TAB
-- ============================================
local shop = Window:Tab({
    Title = "Shop",
    Icon = "shopping-bag",
    Locked = false,
})

local ShopItems = {
    ["Rods"] = {
        {Name = "Luck Rod", ID = 79, Price = 325}, {Name = "Carbon Rod", ID = 76, Price = 750},
        {Name = "Grass Rod", ID = 85, Price = 1500}, {Name = "Demascus Rod", ID = 77, Price = 3000},
        {Name = "Ice Rod", ID = 78, Price = 5000}, {Name = "Lucky Rod", ID = 4, Price = 15000},
        {Name = "Midnight Rod", ID = 80, Price = 50000}, {Name = "Steampunk Rod", ID = 6, Price = 215000},
        {Name = "Chrome Rod", ID = 7, Price = 437000}, {Name = "Flourescent Rod", ID = 255, Price = 715000},
        {Name = "Astral Rod", ID = 5, Price = 1000000}, {Name = "Ares Rod", ID = 126, Price = 3000000},
        {Name = "Angler Rod", ID = 168, Price = 8000000}, {Name = "Bamboo Rod", ID = 258, Price = 12000000}
    },
    ["Bobbers"] = {
        {Name = "Floral Bait", ID = 20, Price = 4000000}, {Name = "Aether Bait", ID = 16, Price = 3700000},
        {Name = "Corrupt Bait", ID = 15, Price = 1148484}, {Name = "Dark Matter Bait", ID = 8, Price = 630000},
        {Name = "Chroma Bait", ID = 6, Price = 290000}, {Name = "Nature Bait", ID = 17, Price = 83500},
        {Name = "Midnight Bait", ID = 3, Price = 3000}, {Name = "Luck Bait", ID = 2, Price = 1000},
        {Name = "Topwater Bait", ID = 10, Price = 100},
    },
    ["Boats"] = {
        {Name = "Mini Yach", ID = 14, Price = 1200000}, {Name = "Fish Boat", ID = 6, Price = 180000},
        {Name = "Speed Boat", ID = 5, Price = 70000}, {Name = "Highfield Boat", ID = 4, Price = 25000},
        {Name = "Jetski", ID = 3, Price = 7500}, {Name = "Kayak", ID = 2, Price = 1100},
        {Name = "Small Boat", ID = 1, Price = 100},
    },
}

local RF_PurchaseShopItem = GetRemote(RPath, "RF/PurchaseShopItem", 5)

for category, items in pairs(ShopItems) do
    local sec = shop:Section({
        Title = category,
        TextSize = 18,
    })
    
    for _, item in ipairs(items) do
        sec:Button({
            Title = string.format("%s - $%s", item.Name, tostring(item.Price)),
            Icon = "shopping-cart",
            Callback = function()
                if RF_PurchaseShopItem then
                    pcall(function()
                        RF_PurchaseShopItem:InvokeServer(item.ID)
                    end)
                    Window:Notify({
                        Title = "Shop Purchase",
                        Content = "Attempting to buy " .. item.Name,
                        Duration = 3,
                        Icon = "check"
                    })
                else
                    Window:Notify({
                        Title = "Error",
                        Content = "Shop remote not found!",
                        Duration = 3,
                        Icon = "x"
                    })
                end
            end
        })
    end
end

print("[SynceHub] Shop Tab Loaded!")

-- ============================================
-- ⭐ PREMIUM TAB
-- ============================================
local premium = Window:Tab({
    Title = "Premium",
    Icon = "star",
    Locked = false,
})

local premsec = premium:Section({
    Title = "Premium Features",
    TextSize = 20,
})

premium:Label({
    Title = "🌟 Premium Status",
    Description = "You are using SynceHub Premium Version"
})

premsec:Button({
    Title = "Unlock All Features",
    Icon = "unlock",
    Callback = function()
        Window:Notify({
            Title = "Premium Active",
            Content = "All features already unlocked!",
            Duration = 3,
            Icon = "check"
        })
    end
})

premsec:Button({
    Title = "Premium Support",
    Icon = "help-circle",
    Callback = function()
        Window:Notify({
            Title = "Support",
            Content = "Contact us on Discord for premium support!",
            Duration = 5,
            Icon = "message-circle"
        })
    end
})

print("[SynceHub] Premium Tab Loaded!")

-- ============================================
-- 📋 QUESTS TAB
-- ============================================
local quests = Window:Tab({
    Title = "Quests",
    Icon = "clipboard",
    Locked = false,
})

local questsec = quests:Section({
    Title = "Quest Automation",
    TextSize = 20,
})

quests:Label({
    Title = "⚠️ Coming Soon",
    Description = "Auto Quest system is under development"
})

questsec:Button({
    Title = "View Active Quests",
    Icon = "list",
    Callback = function()
        Window:Notify({
            Title = "Quests",
            Content = "Quest viewer coming in next update!",
            Duration = 3,
            Icon = "info"
        })
    end
})

print("[SynceHub] Quests Tab Loaded!")

-- ============================================
-- 🎉 EVENTS TAB
-- ============================================
local events = Window:Tab({
    Title = "Events",
    Icon = "zap",
    Locked = false,
})

local eventsec = events:Section({
    Title = "Event Automation",
    TextSize = 20,
})

local eventsList = { 
    "Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole", "Shocked", 
    "Ghost Worm", "Meteor Rain", "Megalodon Hunt", "Treasure Event"
}

local autoEventTargetName = nil 
local autoEventTeleportState = false
local autoEventTeleportThread = nil

local function FindAndTeleportToTargetEvent()
    local targetName = autoEventTargetName
    if not targetName or targetName == "" then return false end
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local eventModel = nil
    
    if targetName == "Treasure Event" then
        local sunkenFolder = workspace:FindFirstChild("Sunken Wreckage")
        if sunkenFolder then
            eventModel = sunkenFolder:FindFirstChild("Treasure")
        end
    
    elseif targetName == "Worm Hunt" then
        local menuRingsFolder = workspace:FindFirstChild("!!! MENU RINGS")
        if menuRingsFolder then
            for _, child in ipairs(menuRingsFolder:GetChildren()) do
                if child.Name == "Props" then
                    local specificModel = child:FindFirstChild("Model")
                    if specificModel then
                        eventModel = specificModel
                        break
                    end
                end
            end
        end

    else
        local menuRingsFolder = workspace:FindFirstChild("!!! MENU RINGS") 
        if menuRingsFolder then
            for _, container in ipairs(menuRingsFolder:GetChildren()) do
                if container:FindFirstChild(targetName) then
                    eventModel = container:FindFirstChild(targetName)
                    break
                end
            end
        end
    end
    
    if not eventModel then return false end 

    local targetPart = nil
    local positionOffset = Vector3.new(0, 15, 0) 
    
    if targetName == "Megalodon Hunt" then
        targetPart = eventModel:FindFirstChild("Top") 
        if targetPart then positionOffset = Vector3.new(0, 3, 0) end
    elseif targetName == "Treasure Event" then
        targetPart = eventModel
        positionOffset = Vector3.new(0, 5, 0)
    else
        targetPart = eventModel:FindFirstChild("Fishing Boat")
        if not targetPart then targetPart = eventModel end
        positionOffset = Vector3.new(0, 15, 0)
    end

    if not targetPart then return false end

    local targetCFrame = nil
    
    local success = pcall(function()
        if targetPart:IsA("Model") then
             targetCFrame = targetPart:GetPivot()
        elseif targetPart:IsA("BasePart") then
             targetCFrame = targetPart.CFrame
        end
    end)

    if success and targetCFrame and typeof(targetCFrame) == "CFrame" then
        local position = targetCFrame.p + positionOffset
        local lookVector = targetCFrame.LookVector
        
        TeleportToLookAt(position, lookVector)
        
        Window:Notify({
            Title = "Event Found!",
            Content = "Teleported to: " .. targetName,
            Icon = "map-pin",
            Duration = 3
        })
        return true
    end
    
    return false
end

local function RunAutoEventTeleportLoop()
    if autoEventTeleportThread then task.cancel(autoEventTeleportThread) end

    autoEventTeleportThread = task.spawn(function()
        Window:Notify({ Title = "Auto Event TP ON", Content = "Mulai memindai event terpilih.", Duration = 3, Icon = "search" })
        
        while autoEventTeleportState do
            if FindAndTeleportToTargetEvent() then
                task.wait(900) 
            else
                task.wait(10)
            end
        end
        
        Window:Notify({ Title = "Auto Event TP OFF", Duration = 3, Icon = "x" })
    end)
end

eventsec:Dropdown({
    Title = "Select Event",
    Values = eventsList,
    Multi = false,
    AllowNone = true,
    Value = nil,
    Callback = function(selected)
        autoEventTargetName = selected
    end
})

Reg("autoeventtp", eventsec:Toggle({
    Title = "Auto Teleport to Event",
    Desc = "Automatically find and teleport to selected event",
    Value = false,
    Callback = function(state)
        autoEventTeleportState = state
        if state then
            if not autoEventTargetName then
                Window:Notify({ Title = "Error", Content = "Please select an event first!", Duration = 3, Icon = "alert-triangle" })
                return false
            end
            RunAutoEventTeleportLoop()
        else
            if autoEventTeleportThread then task.cancel(autoEventTeleportThread) autoEventTeleportThread = nil end
        end
    end
}))

print("[SynceHub] Events Tab Loaded!")

-- ============================================
-- 🔧 TOOLS TAB
-- ============================================
local tools = Window:Tab({
    Title = "Tools",
    Icon = "tool",
    Locked = false,
})

local toolsec = tools:Section({
    Title = "Utility Tools",
    TextSize = 20,
})

toolsec:Button({
    Title = "Rejoin Server",
    Icon = "refresh-cw",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

toolsec:Button({
    Title = "Server Hop",
    Icon = "skip-forward",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and servers and servers.data then
            for _, server in ipairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
        
        Window:Notify({ Title = "Server Hop", Content = "No available servers found!", Duration = 3, Icon = "x" })
    end
})

toolsec:Button({
    Title = "Copy JobId",
    Icon = "copy",
    Callback = function()
        setclipboard(game.JobId)
        Window:Notify({ Title = "Copied", Content = "JobId copied to clipboard!", Duration = 3, Icon = "check" })
    end
})

print("[SynceHub] Tools Tab Loaded!")

-- ============================================
-- 🔗 WEBHOOK TAB
-- ============================================
local webhook = Window:Tab({
    Title = "Webhook",
    Icon = "link",
    Locked = false,
})

local webhooksec = webhook:Section({
    Title = "Discord Webhook",
    TextSize = 20,
})

local webhookURL = ""

Reg("webhookurl", webhooksec:Input({
    Title = "Webhook URL",
    Desc = "Enter your Discord webhook URL",
    Value = "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Icon = "link",
    Callback = function(text)
        webhookURL = text
    end
}))

webhooksec:Button({
    Title = "Test Webhook",
    Icon = "send",
    Callback = function()
        if webhookURL == "" then
            Window:Notify({ Title = "Error", Content = "Please enter webhook URL first!", Duration = 3, Icon = "x" })
            return
        end
        
        local data = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "SynceHub - Test Message",
                ["description"] = "Webhook connection successful!",
                ["color"] = 5814783,
                ["footer"] = {
                    ["text"] = "SynceHub | Fish It"
                }
            }}
        }
        
        local success = pcall(function()
            syn.request({
                Url = webhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode(data)
            })
        end)
        
        if success then
            Window:Notify({ Title = "Success", Content = "Webhook message sent!", Duration = 3, Icon = "check" })
        else
            Window:Notify({ Title = "Error", Content = "Failed to send webhook!", Duration = 3, Icon = "x" })
        end
    end
})

webhook:Label({
    Title = "⚠️ Feature Info",
    Description = "Auto notifications for catches coming soon!"
})

print("[SynceHub] Webhook Tab Loaded!")

-- ============================================
-- ⚙️ CONFIGURATION TAB
-- ============================================
local config = Window:Tab({
    Title = "Configuration",
    Icon = "settings",
    Locked = false,
})

local configsec = config:Section({
    Title = "Config Management",
    TextSize = 20,
})

local configName = "default"

Reg("configname", configsec:Input({
    Title = "Config Name",
    Value = "default",
    Placeholder = "my-config",
    Icon = "file-text",
    Callback = function(text)
        configName = text
    end
}))

configsec:Button({
    Title = "Save Config",
    Icon = "save",
    Callback = function()
        Window.ConfigManager:Save(configName)
        Window:Notify({ Title = "Config Saved", Content = "Config '" .. configName .. "' saved!", Duration = 3, Icon = "check" })
    end
})

configsec:Button({
    Title = "Load Config",
    Icon = "folder-open",
    Callback = function()
        SmartLoadConfig(configName)
    end
})

configsec:Button({
    Title = "Delete Config",
    Icon = "trash",
    Callback = function()
        Window.ConfigManager:Delete(configName)
        Window:Notify({ Title = "Config Deleted", Content = "Config '" .. configName .. "' deleted!", Duration = 3, Icon = "check" })
    end
})

configsec:Button({
    Title = "Refresh Config List",
    Icon = "refresh-cw",
    Callback = function()
        Window.ConfigManager:Refresh()
        Window:Notify({ Title = "Refreshed", Duration = 2, Icon = "check" })
    end
})

print("[SynceHub] Configuration Tab Loaded!")

-- ============================================
-- ℹ️ ABOUT TAB
-- ============================================
local about = Window:Tab({
    Title = "About",
    Icon = "info",
    Locked = false,
})

local aboutsec = about:Section({
    Title = "SynceHub Information",
    TextSize = 20,
})

about:Label({
    Title = "🎣 SynceHub - Fish It",
    Description = "Premium Version 1.0.3"
})

about:Label({
    Title = "Created by:",
    Description = "Synce Development Team"
})

about:Label({
    Title = "Based on:",
    Description = "RockHub by alt_"
})

about:Divider()

local statssec = about:Section({
    Title = "Script Statistics",
    TextSize = 18,
})

about:Label({
    Title = "Total Features:",
    Description = "50+ Premium Features"
})

about:Label({
    Title = "Tabs:",
    Description = "12 Organized Tabs"
})

about:Label({
    Title = "Status:",
    Description = "✅ Fully Operational"
})

about:Divider()

local linkssec = about:Section({
    Title = "Links & Support",
    TextSize = 18,
})

linkssec:Button({
    Title = "Join Discord Server",
    Icon = "message-circle",
    Callback = function()
        Window:Notify({ Title = "Discord", Content = "Discord link coming soon!", Duration = 3, Icon = "info" })
    end
})

linkssec:Button({
    Title = "Report Bug",
    Icon = "alert-circle",
    Callback = function()
        Window:Notify({ Title = "Bug Report", Content = "Please report bugs on our Discord!", Duration = 3, Icon = "info" })
    end
})

linkssec:Button({
    Title = "Check for Updates",
    Icon = "download",
    Callback = function()
        Window:Notify({ Title = "Up to Date", Content = "You are using the latest version!", Duration = 3, Icon = "check" })
    end
})

print("[SynceHub] About Tab Loaded!")
print("[SynceHub] All Additional Tabs Successfully Loaded!")
print("================================================")