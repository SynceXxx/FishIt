-- SynceHub - Features Module
-- Berisi semua fungsi helper dan utilities

local WindUI = _G.SynceHub.Window
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game.Players.LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- SMART CONFIG SYSTEM
-- ============================================
local BaseFolder = "WindUI/SynceHub/config/"

function _G.SynceHub.SmartLoadConfig(configName)
    local ElementRegistry = _G.SynceHub.ElementRegistry
    local path = BaseFolder .. configName .. ".json"
    
    if not isfile(path) then 
        WindUI:Notify({ Title = "Gagal Load", Content = "File tidak ditemukan: " .. configName, Duration = 3, Icon = "x" })
        return 
    end

    local content = readfile(path)
    local success, decodedData = pcall(function() return HttpService:JSONDecode(content) end)

    if not success or not decodedData then 
        WindUI:Notify({ Title = "Gagal Load", Content = "File JSON rusak/kosong.", Duration = 3, Icon = "alert-triangle" })
        return 
    end

    local realData = decodedData
    if decodedData["__elements"] then
        realData = decodedData["__elements"]
    end

    local changeCount = 0
    local foundCount = 0

    for _ in pairs(ElementRegistry) do foundCount = foundCount + 1 end
    print("------------------------------------------------")
    print("[SmartLoad] Target Config: " .. configName)
    print("[SmartLoad] Elemen terdaftar di Script: " .. foundCount)

    for id, itemData in pairs(realData) do
        local element = ElementRegistry[id]
        
        if element then
            local finalValue = itemData
            
            if type(itemData) == "table" and itemData.value ~= nil then
                finalValue = itemData.value
            end

            local currentVal = element.Value
            local isDifferent = false
            
            if type(finalValue) == "table" then
                isDifferent = true 
            elseif currentVal ~= finalValue then
                isDifferent = true
            end

            if isDifferent then
                pcall(function() 
                    element:Set(finalValue) 
                end)
                changeCount = changeCount + 1
                
                if changeCount % 10 == 0 then task.wait() end
            end
        end
    end

    print("[SmartLoad] Selesai. Total Update: " .. changeCount)
    print("------------------------------------------------")

    WindUI:Notify({ 
        Title = "Config Loaded", 
        Content = string.format("Updated: %d settings", changeCount), 
        Duration = 3, 
        Icon = "check" 
    })
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

-- Item Utility & Tier Utility
local ItemUtility = require(RepStorage:WaitForChild("Shared"):WaitForChild("ItemUtility", 10))
local TierUtility = require(RepStorage:WaitForChild("Shared"):WaitForChild("TierUtility", 10))

-- Default Movement Values
_G.SynceHub.DEFAULT_SPEED = 18
_G.SynceHub.DEFAULT_JUMP = 50

-- Get Humanoid
function _G.SynceHub.GetHumanoid()
    local Character = LocalPlayer.Character
    if not Character then
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    return Character:FindFirstChildOfClass("Humanoid")
end

-- Get HumanoidRootPart
function _G.SynceHub.GetHRP()
    local Character = LocalPlayer.Character
    if not Character then
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    return Character:WaitForChild("HumanoidRootPart", 5)
end

-- Remote Path Configuration
_G.SynceHub.RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"}

-- Get Remote Function
function _G.SynceHub.GetRemote(remotePath, name, timeout)
    local currentInstance = RepStorage
    for _, childName in ipairs(remotePath) do
        currentInstance = currentInstance:WaitForChild(childName, timeout or 0.5)
        if not currentInstance then return nil end
    end
    return currentInstance:FindFirstChild(name)
end

-- Teleport Function
function _G.SynceHub.TeleportToLookAt(position, lookVector)
    local hrp = _G.SynceHub.GetHRP()
    
    if hrp and typeof(position) == "Vector3" and typeof(lookVector) == "Vector3" then
        local targetCFrame = CFrame.new(position, position + lookVector)
        hrp.CFrame = targetCFrame * CFrame.new(0, 0.5, 0)
        
        WindUI:Notify({ Title = "Teleport Sukses!", Duration = 3, Icon = "map-pin" })
    else
        WindUI:Notify({ Title = "Teleport Gagal", Content = "Data posisi tidak valid.", Duration = 3, Icon = "x" })
    end
end

-- Get Player Data Replion
local PlayerDataReplion = nil
function _G.SynceHub.GetPlayerDataReplion()
    if PlayerDataReplion then return PlayerDataReplion end
    local ReplionModule = RepStorage:WaitForChild("Packages"):WaitForChild("Replion", 10)
    if not ReplionModule then return nil end
    local ReplionClient = require(ReplionModule).Client
    PlayerDataReplion = ReplionClient:WaitReplion("Data", 5)
    return PlayerDataReplion
end

-- Get Fish Name and Rarity
function _G.SynceHub.GetFishNameAndRarity(item)
    local name = item.Identifier or "Unknown"
    local rarity = item.Metadata and item.Metadata.Rarity or "COMMON"
    local itemID = item.Id

    local itemData = nil

    if ItemUtility and itemID then
        pcall(function()
            itemData = ItemUtility:GetItemData(itemID)
            if not itemData then
                local numericID = tonumber(item.Id) or tonumber(item.Identifier)
                if numericID then
                    itemData = ItemUtility:GetItemData(numericID)
                end
            end
        end)
    end

    if itemData and itemData.Data and itemData.Data.Name then
        name = itemData.Data.Name
    end

    if item.Metadata and item.Metadata.Rarity then
        rarity = item.Metadata.Rarity
    elseif itemData and itemData.Probability and itemData.Probability.Chance and TierUtility then
        local tierObj = nil
        pcall(function()
            tierObj = TierUtility:GetTierFromRarity(itemData.Probability.Chance)
        end)

        if tierObj and tierObj.Name then
            rarity = tierObj.Name
        end
    end

    return name, rarity
end

-- Get Item Mutation String
function _G.SynceHub.GetItemMutationString(item)
    if item.Metadata and item.Metadata.Shiny == true then return "Shiny" end
    return item.Metadata and item.Metadata.VariantId or ""
end

-- Censor Name (For Privacy)
function _G.SynceHub.CensorName(name)
    if not name or type(name) ~= "string" or #name < 1 then
        return "N/A" 
    end
    
    if #name <= 3 then
        return name
    end

    local prefix = name:sub(1, 3)
    local censureLength = #name - 3
    local censorString = string.rep("*", censureLength)
    
    return prefix .. censorString
end

-- ============================================
-- ANTI-AFK SYSTEM
-- ============================================
pcall(function()
    local player = game:GetService("Players").LocalPlayer
    
    for i, v in pairs(getconnections(player.Idled)) do
        if v.Disable then
            v:Disable()
            print("[SynceHub Anti-AFK] ON")
        end
    end
end)

-- ============================================
-- FISHING AREAS DATA
-- ============================================
_G.SynceHub.FishingAreas = {
    ["Iron Cavern"] = {Pos = Vector3.new(-8792.546, -588.000, 230.642), Look = Vector3.new(0.718, 0.000, 0.696)},
    ["Disco Event"] = {Pos = Vector3.new(-8641.672, -547.500, 160.322), Look = Vector3.new(0.984, -0.000, 0.176)},
    ["Classic Island"] = {Pos = Vector3.new(1440.843, 46.062, 2777.175), Look = Vector3.new(0.940, -0.000, 0.342)},
    ["Ancient Jungle"] = {Pos = Vector3.new(1535.639, 3.159, -193.352), Look = Vector3.new(0.505, -0.000, 0.863)},
    ["Arrow Lever"] = {Pos = Vector3.new(898.296, 8.449, -361.856), Look = Vector3.new(0.023, -0.000, 1.000)},
    ["Coral Reef"] = {Pos = Vector3.new(-3207.538, 6.087, 2011.079), Look = Vector3.new(0.973, 0.000, 0.229)},
    ["Crater Island"] = {Pos = Vector3.new(1058.976, 2.330, 5032.878), Look = Vector3.new(-0.789, 0.000, 0.615)},
    ["Enchant Room"] = {Pos = Vector3.new(3255.670, -1301.530, 1371.790), Look = Vector3.new(-0.000, -0.000, -1.000)},
    ["Kohana"] = {Pos = Vector3.new(-668.732, 3.000, 681.580), Look = Vector3.new(0.889, -0.000, 0.458)},
    ["Lost Isle"] = {Pos = Vector3.new(-3804.105, 2.344, -904.653), Look = Vector3.new(-0.901, -0.000, 0.433)},
    ["Tropical Island"] = {Pos = Vector3.new(-2162.920, 2.825, 3638.445), Look = Vector3.new(0.381, -0.000, 0.925)},
    ["Volcano"] = {Pos = Vector3.new(-605.121, 19.516, 160.010), Look = Vector3.new(0.854, 0.000, 0.520)},
}

_G.SynceHub.AreaNames = {}
for name, _ in pairs(_G.SynceHub.FishingAreas) do
    table.insert(_G.SynceHub.AreaNames, name)
end

print("[SynceHub] Features Module Loaded!")