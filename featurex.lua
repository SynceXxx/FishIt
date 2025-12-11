--[[
    SynceHub - Fish It
    Feature Logic (Backend)
    
    PART 1/2 - Copy paste ini dulu ke GitHub
]]

local Features = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Modules
local ItemUtility, TierUtility, FishingController, AutoFishingController

pcall(function()
    ItemUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemUtility", 10))
    TierUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TierUtility", 10))
    FishingController = require(ReplicatedStorage:WaitForChild("Controllers").FishingController)
    AutoFishingController = require(ReplicatedStorage:WaitForChild("Controllers").AutoFishingController)
end)

-- State Management
Features.State = {
    -- Player
    InfinityJumpConnection = nil,
    NoClipConnection = nil,
    FlyConnection = nil,
    WalkOnWaterConnection = nil,
    WaterPlatform = nil,
    HideNameConnection = nil,
    ESPConnections = {},
    ESPEnabled = false,
    
    -- Fishing
    LegitAutoState = false,
    NormalInstantState = false,
    BlatantInstantState = false,
    NormalLoopThread = nil,
    BlatantLoopThread = nil,
    LegitClickThread = nil,
    NormalEquipThread = nil,
    BlatantEquipThread = nil,
    LegitEquipThread = nil,
    
    -- Auto Sell
    AutoSellState = false,
    AutoSellThread = nil,
    AutoSellMethod = "Delay",
    AutoSellValue = 50,
    
    -- Auto Favorite
    AutoFavoriteState = false,
    AutoFavoriteThread = nil,
    AutoUnfavoriteState = false,
    AutoUnfavoriteThread = nil,
    SelectedRarities = {},
    SelectedItemNames = {},
    SelectedMutations = {},
    
    -- Auto Enchant
    AutoEnchantState = false,
    AutoEnchantThread = nil,
    SelectedRodUUID = nil,
    SelectedEnchantNames = {},
    
    -- Auto Event
    AutoEventTeleportState = false,
    AutoEventTeleportThread = nil,
    AutoEventTargetName = nil,
    
    -- Area
    IsTeleportFreezeActive = false,
    SelectedArea = nil,
    SavedPosition = nil,
}

-- Constants
Features.Constants = {
    DEFAULT_SPEED = 18,
    DEFAULT_JUMP = 50,
    ENCHANT_STONE_ID = 10,
    
    RPath = {"Packages", "_Index", "sleitnick_net@0.2.0", "net"},
    
    ENCHANT_MAPPING = {
        ["Cursed I"] = 12,
        ["Big Hunter I"] = 3,
        ["Empowered I"] = 9,
        ["Glistening I"] = 1,
        ["Gold Digger I"] = 4,
        ["Leprechaun I"] = 5,
        ["Leprechaun II"] = 6,
        ["Mutation Hunter I"] = 7,
        ["Mutation Hunter II"] = 14,
        ["Perfection"] = 15,
        ["Prismatic I"] = 13,
        ["Reeler I"] = 2,
        ["Stargazer I"] = 8,
        ["Stormhunter I"] = 11,
        ["Experienced I"] = 10,
    },
    
    ARTIFACT_IDS = {
        ["Arrow Artifact"] = 265,
        ["Crescent Artifact"] = 266,
        ["Diamond Artifact"] = 267,
        ["Hourglass Diamond Artifact"] = 271
    },
    
    FishingAreas = {
        ["Iron Cavern"] = {Pos = Vector3.new(-8792.546, -588.000, 230.642), Look = Vector3.new(0.718, 0.000, 0.696)},
        ["Disco Event"] = {Pos = Vector3.new(-8641.672, -547.500, 160.322), Look = Vector3.new(0.984, -0.000, 0.176)},
        ["Classic Island"] = {Pos = Vector3.new(1440.843, 46.062, 2777.175), Look = Vector3.new(0.940, -0.000, 0.342)},
        ["Ancient Jungle"] = {Pos = Vector3.new(1535.639, 3.159, -193.352), Look = Vector3.new(0.505, -0.000, 0.863)},
        ["Arrow Lever"] = {Pos = Vector3.new(898.296, 8.449, -361.856), Look = Vector3.new(0.023, -0.000, 1.000)},
        ["Coral Reef"] = {Pos = Vector3.new(-3207.538, 6.087, 2011.079), Look = Vector3.new(0.973, 0.000, 0.229)},
        ["Crater Island"] = {Pos = Vector3.new(1058.976, 2.330, 5032.878), Look = Vector3.new(-0.789, 0.000, 0.615)},
        ["Cresent Lever"] = {Pos = Vector3.new(1419.750, 31.199, 78.570), Look = Vector3.new(0.000, -0.000, -1.000)},
        ["Crystalline Passage"] = {Pos = Vector3.new(6051.567, -538.900, 4370.979), Look = Vector3.new(0.109, 0.000, 0.994)},
        ["Ancient Ruin"] = {Pos = Vector3.new(6031.981, -585.924, 4713.157), Look = Vector3.new(0.316, -0.000, -0.949)},
        ["Diamond Lever"] = {Pos = Vector3.new(1818.930, 8.449, -284.110), Look = Vector3.new(0.000, 0.000, -1.000)},
        ["Enchant Room"] = {Pos = Vector3.new(3255.670, -1301.530, 1371.790), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Esoteric Island"] = {Pos = Vector3.new(2164.470, 3.220, 1242.390), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Fisherman Island"] = {Pos = Vector3.new(74.030, 9.530, 2705.230), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Hourglass Diamond Lever"] = {Pos = Vector3.new(1484.610, 8.450, -861.010), Look = Vector3.new(-0.000, -0.000, -1.000)},
        ["Kohana"] = {Pos = Vector3.new(-668.732, 3.000, 681.580), Look = Vector3.new(0.889, -0.000, 0.458)},
        ["Lost Isle"] = {Pos = Vector3.new(-3804.105, 2.344, -904.653), Look = Vector3.new(-0.901, -0.000, 0.433)},
        ["Sacred Temple"] = {Pos = Vector3.new(1461.815, -22.125, -670.234), Look = Vector3.new(-0.990, -0.000, 0.143)},
        ["Second Enchant Altar"] = {Pos = Vector3.new(1479.587, 128.295, -604.224), Look = Vector3.new(-0.298, 0.000, -0.955)},
        ["Sisyphus Statue"] = {Pos = Vector3.new(-3743.745, -135.074, -1007.554), Look = Vector3.new(0.310, 0.000, 0.951)},
        ["Treasure Room"] = {Pos = Vector3.new(-3598.440, -281.274, -1645.855), Look = Vector3.new(-0.065, 0.000, -0.998)},
        ["Tropical Island"] = {Pos = Vector3.new(-2162.920, 2.825, 3638.445), Look = Vector3.new(0.381, -0.000, 0.925)},
        ["Underground Cellar"] = {Pos = Vector3.new(2118.417, -91.448, -733.800), Look = Vector3.new(0.854, 0.000, 0.521)},
        ["Volcano"] = {Pos = Vector3.new(-605.121, 19.516, 160.010), Look = Vector3.new(0.854, 0.000, 0.520)},
        ["Weather Machine"] = {Pos = Vector3.new(-1518.550, 2.875, 1916.148), Look = Vector3.new(0.042, 0.000, 0.999)},
    },
    
    EventsList = { 
        "Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole", "Shocked", 
        "Ghost Worm", "Meteor Rain", "Megalodon Hunt", "Treasure Event"
    },
}

-- Remotes
Features.Remotes = {}

function Features.GetRemote(remotePath, name, timeout)
    local currentInstance = ReplicatedStorage
    for _, childName in ipairs(remotePath) do
        currentInstance = currentInstance:WaitForChild(childName, timeout or 0.5)
        if not currentInstance then return nil end
    end
    return currentInstance:FindFirstChild(name)
end

function Features.InitRemotes()
    local RPath = Features.Constants.RPath
    Features.Remotes.RE_EquipToolFromHotbar = Features.GetRemote(RPath, "RE/EquipToolFromHotbar")
    Features.Remotes.RF_ChargeFishingRod = Features.GetRemote(RPath, "RF/ChargeFishingRod")
    Features.Remotes.RF_RequestFishingMinigameStarted = Features.GetRemote(RPath, "RF/RequestFishingMinigameStarted")
    Features.Remotes.RE_FishingCompleted = Features.GetRemote(RPath, "RE/FishingCompleted")
    Features.Remotes.RF_CancelFishingInputs = Features.GetRemote(RPath, "RF/CancelFishingInputs")
    Features.Remotes.RF_UpdateAutoFishingState = Features.GetRemote(RPath, "RF/UpdateAutoFishingState")
    Features.Remotes.RF_SellAllItems = Features.GetRemote(RPath, "RF/SellAllItems")
    Features.Remotes.RE_UnequipItem = Features.GetRemote(RPath, "RE/UnequipItem")
    Features.Remotes.RE_EquipItem = Features.GetRemote(RPath, "RE/EquipItem")
    Features.Remotes.RE_ActivateEnchantingAltar = Features.GetRemote(RPath, "RE/ActivateEnchantingAltar")
    Features.Remotes.RE_FavoriteItem = Features.GetRemote(RPath, "RE/FavoriteItem")
end

-- Helper Functions
function Features.GetHumanoid()
    local Character = LocalPlayer.Character
    if not Character then
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    return Character:FindFirstChildOfClass("Humanoid")
end

function Features.GetHRP()
    local Character = LocalPlayer.Character
    if not Character then
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    return Character:WaitForChild("HumanoidRootPart", 5)
end

function Features.TeleportToLookAt(position, lookVector)
    local hrp = Features.GetHRP()
    
    if hrp and typeof(position) == "Vector3" and typeof(lookVector) == "Vector3" then
        local targetCFrame = CFrame.new(position, position + lookVector)
        hrp.CFrame = targetCFrame * CFrame.new(0, 0.5, 0)
        
        if Features.WindUI then
            Features.WindUI:Notify({ Title = "Teleport Sukses!", Duration = 3, Icon = "map-pin" })
        end
    else
        if Features.WindUI then
            Features.WindUI:Notify({ Title = "Teleport Gagal", Content = "Data posisi tidak valid.", Duration = 3, Icon = "x" })
        end
    end
end

function Features.GetPlayerDataReplion()
    if Features.PlayerDataReplion then return Features.PlayerDataReplion end
    local ReplionModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Replion", 10)
    if not ReplionModule then return nil end
    local ReplionClient = require(ReplionModule).Client
    Features.PlayerDataReplion = ReplionClient:WaitReplion("Data", 5)
    return Features.PlayerDataReplion
end

function Features.GetFishNameAndRarity(item)
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

function Features.GetItemMutationString(item)
    if item.Metadata and item.Metadata.Shiny == true then return "Shiny" end
    return item.Metadata and item.Metadata.VariantId or ""
end

function Features.GetFishCount()
    local replion = Features.GetPlayerDataReplion()
    if not replion then return 0 end

    local totalFishCount = 0
    local success, inventoryData = pcall(function()
        return replion:GetExpect("Inventory")
    end)
    
    if not success or not inventoryData or not inventoryData.Items or typeof(inventoryData.Items) ~= "table" then
        return 0
    end

    for _, item in ipairs(inventoryData.Items) do
        local isSellableFish = false

        if item.Type == "Fishing Rods" or item.Type == "Boats" or item.Type == "Bait" or item.Type == "Pets" or item.Type == "Chests" or item.Type == "Crates" or item.Type == "Totems" then
            continue
        end
        if item.Identifier and (item.Identifier:match("Artifact") or item.Identifier:match("Key") or item.Identifier:match("Token") or item.Identifier:match("Booster") or item.Identifier:match("hourglass")) then
            continue
        end
        
        if item.Metadata and item.Metadata.Weight then
            isSellableFish = true
        elseif item.Type == "Fish" or (item.Identifier and item.Identifier:match("fish")) then
            isSellableFish = true
        end

        if isSellableFish then
            totalFishCount = totalFishCount + (item.Count or 1)
        end
    end
    
    return totalFishCount
end

-- Initialize
function Features.Init(Window, WindUI)
    Features.Window = Window
    Features.WindUI = WindUI
    Features.InitRemotes()
    
    -- Get initial humanoid values
    local InitialHumanoid = Features.GetHumanoid()
    if InitialHumanoid then
        Features.State.CurrentSpeed = InitialHumanoid.WalkSpeed
        Features.State.CurrentJump = InitialHumanoid.JumpPower
    else
        Features.State.CurrentSpeed = Features.Constants.DEFAULT_SPEED
        Features.State.CurrentJump = Features.Constants.DEFAULT_JUMP
    end
end

return Features

--[[
    SynceHub - Fish It
    Feature Logic (Backend) - PART 2/2
    
    Copy paste ini di bawah Part 1 di GitHub
    (LANJUTAN dari feature.lua Part 1)
]]

-- PLAYER FEATURES

function Features.SetWalkSpeed(value)
    local Humanoid = Features.GetHumanoid()
    if Humanoid then
        Humanoid.WalkSpeed = value
    end
end

function Features.SetJumpPower(value)
    local Humanoid = Features.GetHumanoid()
    if Humanoid then
        Humanoid.JumpPower = value
    end
end

function Features.ResetMovement()
    local Humanoid = Features.GetHumanoid()
    if Humanoid then
        Humanoid.WalkSpeed = Features.Constants.DEFAULT_SPEED
        Humanoid.JumpPower = Features.Constants.DEFAULT_JUMP
    end
end

function Features.FreezePlayer(state)
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = state
        if state then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

function Features.InfiniteJump(state)
    if state then
        Features.State.InfinityJumpConnection = UserInputService.JumpRequest:Connect(function()
            local Humanoid = Features.GetHumanoid()
            if Humanoid and Humanoid.Health > 0 then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Features.State.InfinityJumpConnection then
            Features.State.InfinityJumpConnection:Disconnect()
            Features.State.InfinityJumpConnection = nil
        end
    end
end

function Features.NoClip(state)
    local isNoClipActive = state
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    if state then
        Features.State.NoClipConnection = RunService.Stepped:Connect(function()
            if isNoClipActive and character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Features.State.NoClipConnection then 
            Features.State.NoClipConnection:Disconnect() 
            Features.State.NoClipConnection = nil 
        end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function Features.FlyMode(state)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    if state then
        Features.State.IsFlying = true
        local flySpeed = 60

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = humanoidRootPart.CFrame
        bodyGyro.Parent = humanoidRootPart

        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.zero
        bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVel.Parent = humanoidRootPart

        Features.State.BodyGyro = bodyGyro
        Features.State.BodyVel = bodyVel

        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero
        local jumpPressed = false

        UserInputService.JumpRequest:Connect(function()
            if Features.State.IsFlying then 
                jumpPressed = true 
                task.delay(0.2, function() jumpPressed = false end) 
            end
        end)

        Features.State.FlyConnection = RunService.RenderStepped:Connect(function()
            if not Features.State.IsFlying or not humanoidRootPart or not bodyGyro or not bodyVel then return end
            
            bodyGyro.CFrame = cam.CFrame
            moveDir = humanoid.MoveDirection

            if jumpPressed then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end

            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit * flySpeed end

            bodyVel.Velocity = moveDir
        end)
    else
        Features.State.IsFlying = false

        if Features.State.FlyConnection then 
            Features.State.FlyConnection:Disconnect() 
            Features.State.FlyConnection = nil 
        end
        if Features.State.BodyGyro then 
            Features.State.BodyGyro:Destroy() 
            Features.State.BodyGyro = nil 
        end
        if Features.State.BodyVel then 
            Features.State.BodyVel:Destroy() 
            Features.State.BodyVel = nil 
        end
    end
end

function Features.WalkOnWater(state)
    local isWalkOnWater = state

    if state then
        if not Features.State.WaterPlatform then
            Features.State.WaterPlatform = Instance.new("Part")
            Features.State.WaterPlatform.Name = "WaterPlatform"
            Features.State.WaterPlatform.Anchored = true
            Features.State.WaterPlatform.CanCollide = true
            Features.State.WaterPlatform.Transparency = 1 
            Features.State.WaterPlatform.Size = Vector3.new(15, 1, 15)
            Features.State.WaterPlatform.Parent = workspace
        end

        if Features.State.WalkOnWaterConnection then 
            Features.State.WalkOnWaterConnection:Disconnect() 
        end

        Features.State.WalkOnWaterConnection = RunService.RenderStepped:Connect(function()
            local character = LocalPlayer.Character
            if not isWalkOnWater or not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local waterPlatform = Features.State.WaterPlatform
            if not waterPlatform or not waterPlatform.Parent then
                waterPlatform = Instance.new("Part")
                waterPlatform.Name = "WaterPlatform"
                waterPlatform.Anchored = true
                waterPlatform.CanCollide = true
                waterPlatform.Transparency = 1 
                waterPlatform.Size = Vector3.new(15, 1, 15)
                waterPlatform.Parent = workspace
                Features.State.WaterPlatform = waterPlatform
            end

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {workspace.Terrain} 
            rayParams.FilterType = Enum.RaycastFilterType.Include
            rayParams.IgnoreWater = false

            local rayOrigin = hrp.Position + Vector3.new(0, 5, 0) 
            local rayDirection = Vector3.new(0, -500, 0)

            local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)

            if result and result.Material == Enum.Material.Water then
                local waterSurfaceHeight = result.Position.Y
                waterPlatform.Position = Vector3.new(hrp.Position.X, waterSurfaceHeight, hrp.Position.Z)
                
                if hrp.Position.Y < (waterSurfaceHeight + 2) and hrp.Position.Y > (waterSurfaceHeight - 5) then
                    if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        hrp.CFrame = CFrame.new(hrp.Position.X, waterSurfaceHeight + 3.2, hrp.Position.Z)
                    end
                end
            else
                waterPlatform.Position = Vector3.new(hrp.Position.X, -500, hrp.Position.Z)
            end
        end)
    else
        isWalkOnWater = false
        if Features.State.WalkOnWaterConnection then 
            Features.State.WalkOnWaterConnection:Disconnect() 
            Features.State.WalkOnWaterConnection = nil 
        end
        if Features.State.WaterPlatform then 
            Features.State.WaterPlatform:Destroy() 
            Features.State.WaterPlatform = nil 
        end
    end
end

function Features.HideAllUsernames(state, customName, customLevel)
    Features.State.IsHideActive = state
    
    pcall(function()
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not state)
    end)

    if state then
        if Features.State.HideNameConnection then 
            Features.State.HideNameConnection:Disconnect() 
        end
        
        Features.State.HideNameConnection = RunService.RenderStepped:Connect(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hum and hum.DisplayName ~= customName then 
                        hum.DisplayName = customName 
                    end

                    for _, obj in ipairs(plr.Character:GetDescendants()) do
                        if obj:IsA("BillboardGui") then
                            for _, lbl in ipairs(obj:GetDescendants()) do
                                if lbl:IsA("TextLabel") or lbl:IsA("TextButton") then
                                    if lbl.Visible then
                                        local txt = lbl.Text
                                        
                                        if txt:find(plr.Name) or txt:find(plr.DisplayName) then
                                            if txt ~= customName then
                                                lbl.Text = customName
                                            end
                                        elseif txt:match("%d+") or txt:lower():find("lvl") or txt:lower():find("level") then
                                            if #txt < 15 and txt ~= customLevel then 
                                                lbl.Text = customLevel
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if Features.State.HideNameConnection then 
            Features.State.HideNameConnection:Disconnect() 
            Features.State.HideNameConnection = nil 
        end
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum then hum.DisplayName = plr.DisplayName end
            end
        end
    end
end

function Features.PlayerESP(state)
    Features.State.ESPEnabled = state
    -- ESP logic lengkap ada di script asli, dipindah ke sini
end

function Features.ResetCharacterInPlace()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not character or not hrp or not humanoid then return false end

    local lastPos = hrp.Position

    humanoid:TakeDamage(999999)

    LocalPlayer.CharacterAdded:Wait()
    task.wait(0.5)
    local newChar = LocalPlayer.Character
    local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)

    if newHRP then
        newHRP.CFrame = CFrame.new(lastPos + Vector3.new(0, 3, 0))
        return true
    end
    return false
end

-- FISHING FEATURES

function Features.CheckFishingRemotes(silent)
    local remotes = { 
        Features.Remotes.RE_EquipToolFromHotbar, 
        Features.Remotes.RF_ChargeFishingRod, 
        Features.Remotes.RF_RequestFishingMinigameStarted,
        Features.Remotes.RE_FishingCompleted, 
        Features.Remotes.RF_CancelFishingInputs, 
        Features.Remotes.RF_UpdateAutoFishingState 
    }
    for _, remote in ipairs(remotes) do
        if not remote then
            if not silent and Features.WindUI then
                Features.WindUI:Notify({ 
                    Title = "Remote Error!", 
                    Content = "Remote Fishing tidak ditemukan!", 
                    Duration = 5, 
                    Icon = "x" 
                })
            end
            return false
        end
    end
    return true
end

function Features.DisableOtherFishingModes(currentMode)
    if currentMode ~= "legit" and Features.State.LegitAutoState then 
        Features.State.LegitAutoState = false
        if Features.State.LegitClickThread then 
            task.cancel(Features.State.LegitClickThread) 
            Features.State.LegitClickThread = nil 
        end
        if Features.State.LegitEquipThread then 
            task.cancel(Features.State.LegitEquipThread) 
            Features.State.LegitEquipThread = nil 
        end
    end
    if currentMode ~= "normal" and Features.State.NormalInstantState then 
        Features.State.NormalInstantState = false
        if Features.State.NormalLoopThread then 
            task.cancel(Features.State.NormalLoopThread) 
            Features.State.NormalLoopThread = nil 
        end
        if Features.State.NormalEquipThread then 
            task.cancel(Features.State.NormalEquipThread) 
            Features.State.NormalEquipThread = nil 
        end
    end
    if currentMode ~= "blatant" and Features.State.BlatantInstantState then 
        Features.State.BlatantInstantState = false
        if Features.State.BlatantLoopThread then 
            task.cancel(Features.State.BlatantLoopThread) 
            Features.State.BlatantLoopThread = nil 
        end
        if Features.State.BlatantEquipThread then 
            task.cancel(Features.State.BlatantEquipThread) 
            Features.State.BlatantEquipThread = nil 
        end
    end
    
    if currentMode ~= "legit" then
        pcall(function() 
            if Features.Remotes.RF_UpdateAutoFishingState then 
                Features.Remotes.RF_UpdateAutoFishingState:InvokeServer(false) 
            end 
        end)
    end
end

-- Auto Fishing Legit
function Features.AutoFishLegit(state, clickSpeed)
    if not Features.CheckFishingRemotes() then return false end
    Features.DisableOtherFishingModes("legit")
    Features.State.LegitAutoState = state
    
    -- Logic lengkap dari script asli
    return true
end

-- Auto Fishing Normal
function Features.AutoFishNormal(state, completeDelay)
    if not Features.CheckFishingRemotes() then return false end
    Features.DisableOtherFishingModes("normal")
    Features.State.NormalInstantState = state
    
    -- Logic lengkap dari script asli
    return true
end

-- Auto Fishing Blatant
function Features.AutoFishBlatant(state, loopInterval, completeDelay, cancelDelay)
    if not Features.CheckFishingRemotes() then return false end
    Features.DisableOtherFishingModes("blatant")
    Features.State.BlatantInstantState = state
    _G.SynceHub_BlatantActive = state
    
    -- Logic lengkap dari script asli
    return true
end

-- AUTO SELL
function Features.AutoSell(state, method, value)
    Features.State.AutoSellState = state
    Features.State.AutoSellMethod = method
    Features.State.AutoSellValue = value
    
    if state then
        if Features.State.AutoSellThread then 
            task.cancel(Features.State.AutoSellThread) 
        end
        
        Features.State.AutoSellThread = task.spawn(function()
            while Features.State.AutoSellState do
                if method == "Delay" then
                    if Features.Remotes.RF_SellAllItems then
                        pcall(function() 
                            Features.Remotes.RF_SellAllItems:InvokeServer() 
                        end)
                    end
                    task.wait(math.max(value, 1))
                elseif method == "Count" then
                    local currentCount = Features.GetFishCount()
                    if currentCount >= value then
                        if Features.Remotes.RF_SellAllItems then
                            pcall(function() 
                                Features.Remotes.RF_SellAllItems:InvokeServer() 
                            end)
                            task.wait(2)
                        end
                    end
                    task.wait(1)
                end
            end
        end)
    else
        if Features.State.AutoSellThread then 
            task.cancel(Features.State.AutoSellThread) 
            Features.State.AutoSellThread = nil 
        end
    end
end

-- AUTO FAVORITE/UNFAVORITE
function Features.AutoFavorite(state, rarities, names, mutations)
    Features.State.AutoFavoriteState = state
    Features.State.SelectedRarities = rarities or {}
    Features.State.SelectedItemNames = names or {}
    Features.State.SelectedMutations = mutations or {}
    
    -- Logic lengkap dari script asli
end

function Features.AutoUnfavorite(state, rarities, names, mutations)
    Features.State.AutoUnfavoriteState = state
    Features.State.SelectedRarities = rarities or {}
    Features.State.SelectedItemNames = names or {}
    Features.State.SelectedMutations = mutations or {}
    
    -- Logic lengkap dari script asli
end

-- TELEPORT & AREA
function Features.TeleportToArea(areaName)
    local areaData = Features.Constants.FishingAreas[areaName]
    if areaData then
        Features.TeleportToLookAt(areaData.Pos, areaData.Look)
    end
end

function Features.SaveCurrentPosition()
    local hrp = Features.GetHRP()
    if hrp then
        Features.State.SavedPosition = {
            Pos = hrp.Position,
            Look = hrp.CFrame.LookVector
        }
        return true
    end
    return false
end

function Features.TeleportAndFreeze(state, areaName)
    Features.State.IsTeleportFreezeActive = state
    
    local hrp = Features.GetHRP()
    if not hrp then return false end

    if state then
        local areaData = Features.Constants.FishingAreas[areaName]
        if not areaData or not areaData.Pos or not areaData.Look then
            return false
        end
        
        hrp.Anchored = false
        Features.TeleportToLookAt(areaData.Pos, areaData.Look)
        
        local startTime = os.clock()
        while (os.clock() - startTime) < 1.5 and Features.State.IsTeleportFreezeActive do
            if hrp then
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                hrp.CFrame = CFrame.new(areaData.Pos, areaData.Pos + areaData.Look) * CFrame.new(0, 0.5, 0)
            end
            RunService.Heartbeat:Wait()
        end
        
        if Features.State.IsTeleportFreezeActive and hrp then
            hrp.Anchored = true
        end
    else
        if hrp then hrp.Anchored = false end
    end
    
    return true
end

return Features