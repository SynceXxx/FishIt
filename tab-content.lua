-- SynceHub - Tab Content Module
-- Berisi semua UI Tabs dan Elements
local Window = _G.SynceHub.Window
local Reg = _G.SynceHub.Reg
local GetHumanoid = _G.SynceHub.GetHumanoid
local GetHRP = _G.SynceHub.GetHRP
local DEFAULT_SPEED = _G.SynceHub.DEFAULT_SPEED
local DEFAULT_JUMP = _G.SynceHub.DEFAULT_JUMP

local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game.Players.LocalPlayer

-- ============================================
-- 👤 PLAYER TAB
-- ============================================
local player = Window:Tab({
    Title = "Player",
    Icon = "user",
    Locked = false,
})

-- Get Initial Values
local InitialHumanoid = GetHumanoid()
local currentSpeed = DEFAULT_SPEED
local currentJump = DEFAULT_JUMP

if InitialHumanoid then
    currentSpeed = InitialHumanoid.WalkSpeed
    currentJump = InitialHumanoid.JumpPower
end

-- ============================================
-- MOVEMENT SECTION
-- ============================================
local movement = player:Section({
    Title = "Movement",
    TextSize = 20,
})

-- WalkSpeed Slider
local SliderSpeed = Reg("Walkspeed", movement:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = {
        Min = 16,
        Max = 200,
        Default = currentSpeed,
    },
    Callback = function(value)
        local speedValue = tonumber(value)
        if speedValue and speedValue >= 0 then
            local Humanoid = GetHumanoid()
            if Humanoid then
                Humanoid.WalkSpeed = speedValue
            end
        end
    end,
}))

-- JumpPower Slider
local SliderJump = Reg("slidjump", movement:Slider({
    Title = "JumpPower",
    Step = 1,
    Value = {
        Min = 50,
        Max = 200,
        Default = currentJump,
    },
    Callback = function(value)
        local jumpValue = tonumber(value)
        if jumpValue and jumpValue >= 50 then
            local Humanoid = GetHumanoid()
            if Humanoid then
                Humanoid.JumpPower = jumpValue
            end
        end
    end,
}))

-- Reset Movement Button
local reset = movement:Button({
    Title = "Reset Movement",
    Icon = "rotate-ccw",
    Locked = false,
    Callback = function()
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid.WalkSpeed = DEFAULT_SPEED
            Humanoid.JumpPower = DEFAULT_JUMP
            SliderSpeed:Set(DEFAULT_SPEED)
            SliderJump:Set(DEFAULT_JUMP)
            Window:Notify({
                Title = "Movement Direset",
                Content = "WalkSpeed & JumpPower Reset to default",
                Duration = 3,
                Icon = "check",
            })
        end
    end
})

-- Freeze Player Toggle
local freezeplr = Reg("frezee", movement:Toggle({
    Title = "Freeze Player",
    Desc = "Membekukan karakter di posisi saat ini (Anti-Push).",
    Value = false,
    Callback = function(state)
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = state
            
            if state then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.Velocity = Vector3.new(0, 0, 0)
                
                Window:Notify({ 
                    Title = "Player Frozen", 
                    Content = "Posisi dikunci (Anchored).", 
                    Duration = 2, 
                    Icon = "lock" 
                })
            else
                Window:Notify({ 
                    Title = "Player Unfrozen", 
                    Content = "Gerakan kembali normal.", 
                    Duration = 2, 
                    Icon = "unlock" 
                })
            end
        else
            Window:Notify({ Title = "Error", Content = "HumanoidRootPart tidak ditemukan.", Duration = 3, Icon = "alert-triangle" })
        end
    end
}))

-- ============================================
-- ABILITIES SECTION
-- ============================================
local ability = player:Section({
    Title = "Abilities",
    TextSize = 20,
})

-- Infinite Jump Toggle
local InfinityJumpConnection = nil
local infjump = Reg("infj", ability:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(state)
        if state then
            Window:Notify({ Title = "Infinite Jump ON!", Duration = 3, Icon = "check" })
            InfinityJumpConnection = UserInputService.JumpRequest:Connect(function()
                local Humanoid = GetHumanoid()
                if Humanoid and Humanoid.Health > 0 then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            Window:Notify({ Title = "Infinite Jump OFF!", Duration = 3, Icon = "check" })
            if InfinityJumpConnection then
                InfinityJumpConnection:Disconnect()
                InfinityJumpConnection = nil
            end
        end
    end
}))

-- NoClip Toggle
local noclipConnection = nil
local isNoClipActive = false
local noclip = Reg("nclip", ability:Toggle({
    Title = "No Clip",
    Value = false,
    Callback = function(state)
        isNoClipActive = state
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        if state then
            Window:Notify({ Title = "No Clip ON!", Duration = 3, Icon = "check" })
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if isNoClipActive and character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            Window:Notify({ Title = "No Clip OFF!", Duration = 3, Icon = "x" })
            if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end

            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
}))

-- Fly Mode Toggle
local flyConnection = nil
local isFlying = false
local flySpeed = 60
local bodyGyro, bodyVel
local flytog = Reg("flym", ability:Toggle({
    Title = "Fly Mode",
    Value = false,
    Callback = function(state)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")

        if state then
            Window:Notify({ Title = "Fly Mode ON!", Duration = 3, Icon = "check" })
            isFlying = true

            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 9e4
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.CFrame = humanoidRootPart.CFrame
            bodyGyro.Parent = humanoidRootPart

            bodyVel = Instance.new("BodyVelocity")
            bodyVel.Velocity = Vector3.zero
            bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVel.Parent = humanoidRootPart

            local cam = workspace.CurrentCamera
            local moveDir = Vector3.zero
            local jumpPressed = false

            UserInputService.JumpRequest:Connect(function()
                if isFlying then jumpPressed = true task.delay(0.2, function() jumpPressed = false end) end
            end)

            flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not isFlying or not humanoidRootPart or not bodyGyro or not bodyVel then return end
                
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
            Window:Notify({ Title = "Fly Mode OFF!", Duration = 3, Icon = "x" })
            isFlying = false

            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            if bodyVel then bodyVel:Destroy() bodyVel = nil end
        end
    end
}))

-- Walk on Water Toggle (FIXED VERSION)
local walkOnWaterConnection = nil
local isWalkOnWater = false
local waterPlatform = nil

local walkon = Reg("walkwat", ability:Toggle({
    Title = "Walk on Water",
    Value = false,
    Callback = function(state)
        if state then
            Window:Notify({ Title = "Walk on Water ON!", Duration = 3, Icon = "check" })
            isWalkOnWater = true
            
            if not waterPlatform then
                waterPlatform = Instance.new("Part")
                waterPlatform.Name = "WaterPlatform"
                waterPlatform.Anchored = true
                waterPlatform.CanCollide = true
                waterPlatform.Transparency = 1
                waterPlatform.Size = Vector3.new(15, 1, 15)
                waterPlatform.Parent = workspace
            end

            if walkOnWaterConnection then walkOnWaterConnection:Disconnect() end

            walkOnWaterConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local character = LocalPlayer.Character
                if not isWalkOnWater or not character then return end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                if not waterPlatform or not waterPlatform.Parent then
                    waterPlatform = Instance.new("Part")
                    waterPlatform.Name = "WaterPlatform"
                    waterPlatform.Anchored = true
                    waterPlatform.CanCollide = true
                    waterPlatform.Transparency = 1
                    waterPlatform.Size = Vector3.new(15, 1, 15)
                    waterPlatform.Parent = workspace
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
            Window:Notify({ Title = "Walk on Water OFF!", Duration = 3, Icon = "x" })
            isWalkOnWater = false
            if walkOnWaterConnection then walkOnWaterConnection:Disconnect() walkOnWaterConnection = nil end
            if waterPlatform then waterPlatform:Destroy() waterPlatform = nil end
        end
    end
}))

print("[SynceHub] Player Tab Loaded!")

-- SynceHub - Tab Content Module (Part 2)
-- Other Section & ESP System
local Window = _G.SynceHub.Window
local Reg = _G.SynceHub.Reg
local GetHRP = _G.SynceHub.GetHRP

local LocalPlayer = game.Players.LocalPlayer

-- ============================================
-- OTHER SECTION (Player Tab)
-- ============================================
local other = player:Section({
    Title = "Other",
    TextSize = 20,
})

-- Hide Username System Variables
local isHideActive = false
local hideConnection = nil
local customName = ".gg/SynceHub"
local customLevel = "Lvl. 969"

-- Custom Fake Name Input
local custname = Reg("cfakennme", other:Input({
    Title = "Custom Fake Name",
    Desc = "Nama samaran yang akan muncul di atas kepala player.",
    Value = customName,
    Placeholder = "Hidden User",
    Icon = "user-x",
    Callback = function(text)
        customName = text
    end
}))

-- Custom Fake Level Input
local custlvl = Reg("cfkelvl", other:Input({
    Title = "Custom Fake Level",
    Desc = "Level samaran (misal: 'Lvl. 100' atau 'Max').",
    Value = customLevel,
    Placeholder = "Lvl. 999",
    Icon = "bar-chart-2",
    Callback = function(text)
        customLevel = text
    end
}))

-- Hide All Usernames Toggle (Streamer Mode)
local hideusn = Reg("hideallusr", other:Toggle({
    Title = "Hide All Usernames (Streamer Mode)",
    Value = false,
    Callback = function(state)
        isHideActive = state
        
        pcall(function()
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not state)
        end)

        if state then
            Window:Notify({ Title = "Hide Name ON", Content = "Nama & Level disamarkan.", Duration = 3, Icon = "eye-off" })
            
            if hideConnection then hideConnection:Disconnect() end
            hideConnection = game:GetService("RunService").RenderStepped:Connect(function()
                for _, plr in ipairs(game.Players:GetPlayers()) do
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
            Window:Notify({ Title = "Hide Name OFF", Content = "Tampilan dikembalikan.", Duration = 3, Icon = "eye" })
            
            if hideConnection then 
                hideConnection:Disconnect() 
                hideConnection = nil 
            end
            
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr.Character then
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hum then hum.DisplayName = plr.DisplayName end
                end
            end
        end
    end
}))

-- ============================================
-- PLAYER ESP SYSTEM
-- ============================================
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local STUD_TO_M = 0.28
local espEnabled = false
local espConnections = {}

local function removeESP(targetPlayer)
    if not targetPlayer then return end
    local data = espConnections[targetPlayer]
    if data then
        if data.distanceConn then pcall(function() data.distanceConn:Disconnect() end) end
        if data.charAddedConn then pcall(function() data.charAddedConn:Disconnect() end) end
        if data.billboard and data.billboard.Parent then pcall(function() data.billboard:Destroy() end) end
        espConnections[targetPlayer] = nil
    else
        if targetPlayer.Character then
            for _, v in ipairs(targetPlayer.Character:GetChildren()) do
                if v.Name == "SynceHubESP" and v:IsA("BillboardGui") then pcall(function() v:Destroy() end) end
            end
        end
    end
end

local function createESP(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or targetPlayer == LocalPlayer then return end

    removeESP(targetPlayer)
    local char = targetPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not hrp then return end

    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = "SynceHubESP"
    BillboardGui.Adornee = hrp
    BillboardGui.Size = UDim2.new(0, 140, 0, 40)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.StudsOffset = Vector3.new(0, 2.6, 0)
    BillboardGui.Parent = char

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.Parent = BillboardGui

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Parent = Frame
    NameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    NameLabel.Position = UDim2.new(0, 0, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = tostring(targetPlayer.DisplayName or targetPlayer.Name)
    NameLabel.TextColor3 = Color3.fromRGB(255, 230, 230)
    NameLabel.TextStrokeTransparency = 0.7
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextScaled = true

    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Parent = Frame
    DistanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
    DistanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.Text = "0.0 m"
    DistanceLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
    NameLabel.TextStrokeTransparency = 0.85
    DistanceLabel.Font = Enum.Font.GothamSemibold
    DistanceLabel.TextScaled = true

    espConnections[targetPlayer] = { billboard = BillboardGui }

    local distanceConn = runService.RenderStepped:Connect(function()
        if not espEnabled or not hrp or not hrp.Parent then removeESP(targetPlayer) return end
        local localChar = LocalPlayer.Character
        local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if localHRP then
            local distStuds = (localHRP.Position - hrp.Position).Magnitude
            local distMeters = distStuds * STUD_TO_M
            DistanceLabel.Text = string.format("%.1f m", distMeters)
        end
    end)
    espConnections[targetPlayer].distanceConn = distanceConn

    local charAddedConn = targetPlayer.CharacterAdded:Connect(function()
        task.wait(0.8)
        if espEnabled then createESP(targetPlayer) end
    end)
    espConnections[targetPlayer].charAddedConn = charAddedConn
end

-- Player ESP Toggle
local espplay = Reg("esp", other:Toggle({
    Title = "Player ESP",
    Value = false,
    Callback = function(state)
        espEnabled = state
        if state then
            Window:Notify({ Title = "ESP Aktif", Duration = 3, Icon = "eye" })
            for _, plr in ipairs(players:GetPlayers()) do
                if plr ~= LocalPlayer then createESP(plr) end
            end
            espConnections["playerAddedConn"] = players.PlayerAdded:Connect(function(plr)
                task.wait(1)
                if espEnabled then createESP(plr) end
            end)
            espConnections["playerRemovingConn"] = players.PlayerRemoving:Connect(function(plr)
                removeESP(plr)
            end)
        else
            Window:Notify({ Title = "ESP Nonaktif", Content = "Semua marker ESP dihapus.", Duration = 3, Icon = "eye-off" })
            for plr, _ in pairs(espConnections) do
                if plr and typeof(plr) == "Instance" then removeESP(plr) end
            end
            if espConnections["playerAddedConn"] then espConnections["playerAddedConn"]:Disconnect() end
            if espConnections["playerRemovingConn"] then espConnections["playerRemovingConn"]:Disconnect() end
            espConnections = {}
        end
    end
}))

-- Reset Character Button
local respawnin = other:Button({
    Title = "Reset Character (In Place)",
    Icon = "refresh-cw",
    Callback = function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if not character or not hrp or not humanoid then
            Window:Notify({ Title = "Gagal Reset", Content = "Karakter tidak ditemukan!", Duration = 3, Icon = "x" })
            return
        end

        local lastPos = hrp.Position

        Window:Notify({ Title = "Reset Character...", Content = "Respawning di posisi yang sama...", Duration = 2, Icon = "rotate-cw" })
        humanoid:TakeDamage(999999)

        LocalPlayer.CharacterAdded:Wait()
        task.wait(0.5)
        local newChar = LocalPlayer.Character
        local newHRP = newChar:WaitForChild("HumanoidRootPart", 5)

        if newHRP then
            newHRP.CFrame = CFrame.new(lastPos + Vector3.new(0, 3, 0))
            Window:Notify({ Title = "Character Reset Sukses!", Content = "Kamu direspawn di posisi yang sama ✅", Duration = 3, Icon = "check" })
        else
            Window:Notify({ Title = "Gagal Reset", Content = "HumanoidRootPart baru tidak ditemukan.", Duration = 3, Icon = "x" })
        end
    end
})

print("[SynceHub] Player Tab - Other Section Loaded!")

-- SynceHub - Tab Content Module (Part 3)
-- Fishing Tab - Auto Fishing Systems
local Window = _G.SynceHub.Window
local Reg = _G.SynceHub.Reg
local GetHRP = _G.SynceHub.GetHRP
local GetRemote = _G.SynceHub.GetRemote
local TeleportToLookAt = _G.SynceHub.TeleportToLookAt
local FishingAreas = _G.SynceHub.FishingAreas
local AreaNames = _G.SynceHub.AreaNames
local RPath = _G.SynceHub.RPath

local RepStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer

-- ============================================
-- 🎣 FISHING TAB
-- ============================================
local farm = Window:Tab({
    Title = "Fishing",
    Icon = "fish",
    Locked = false,
})

-- Variabel Global untuk Auto Fishing
local legitAutoState = false
local normalInstantState = false
local blatantInstantState = false

local normalLoopThread = nil
local blatantLoopThread = nil

local normalEquipThread = nil
local blatantEquipThread = nil
local legitEquipThread = nil

local NormalInstantSlider = nil

-- Variabel Fishing Area
local isTeleportFreezeActive = false
local freezeToggle = nil
local selectedArea = nil
local savedPosition = nil

-- Get Fishing Remotes
local RE_EquipToolFromHotbar = GetRemote(RPath, "RE/EquipToolFromHotbar")
local RF_ChargeFishingRod = GetRemote(RPath, "RF/ChargeFishingRod")
local RF_RequestFishingMinigameStarted = GetRemote(RPath, "RF/RequestFishingMinigameStarted")
local RE_FishingCompleted = GetRemote(RPath, "RE/FishingCompleted")
local RF_CancelFishingInputs = GetRemote(RPath, "RF/CancelFishingInputs")
local RF_UpdateAutoFishingState = GetRemote(RPath, "RF/UpdateAutoFishingState")

-- Check if Fishing Remotes are available
local function checkFishingRemotes(silent)
    local remotes = { RE_EquipToolFromHotbar, RF_ChargeFishingRod, RF_RequestFishingMinigameStarted,
                      RE_FishingCompleted, RF_CancelFishingInputs, RF_UpdateAutoFishingState }
    for _, remote in ipairs(remotes) do
        if not remote then
            if not silent then
                Window:Notify({ Title = "Remote Error!", Content = "Remote Fishing tidak ditemukan!", Duration = 5, Icon = "x" })
            end
            return false
        end
    end
    return true
end

-- Disable Other Auto Fishing Modes
local function disableOtherModes(currentMode)
    pcall(function()
        local toggleLegit = farm:GetElementByTitle("Auto Fish (Legit)")
        local toggleNormal = farm:GetElementByTitle("Normal Instant Fish")
        local toggleBlatant = farm:GetElementByTitle("Instant Fishing (Blatant)")

        if currentMode ~= "legit" and legitAutoState then 
            legitAutoState = false
            if toggleLegit and toggleLegit.Set then toggleLegit:Set(false) end
            if legitClickThread then task.cancel(legitClickThread) legitClickThread = nil end
            if legitEquipThread then task.cancel(legitEquipThread) legitEquipThread = nil end
        end
        if currentMode ~= "normal" and normalInstantState then 
            normalInstantState = false
            if toggleNormal and toggleNormal.Set then toggleNormal:Set(false) end
            if normalLoopThread then task.cancel(normalLoopThread) normalLoopThread = nil end
            if normalEquipThread then task.cancel(normalEquipThread) normalEquipThread = nil end
        end
        if currentMode ~= "blatant" and blatantInstantState then 
            blatantInstantState = false
            if toggleBlatant and toggleBlatant.Set then toggleBlatant:Set(false) end
            if blatantLoopThread then task.cancel(blatantLoopThread) blatantLoopThread = nil end
            if blatantEquipThread then task.cancel(blatantEquipThread) blatantEquipThread = nil end
        end
    end)
    
    if currentMode ~= "legit" then
        pcall(function() if RF_UpdateAutoFishingState then RF_UpdateAutoFishingState:InvokeServer(false) end end)
    end
end

-- ============================================
-- AUTO FISHING LEGIT MODE
-- ============================================
local FishingController = require(RepStorage:WaitForChild("Controllers").FishingController)
local AutoFishingController = require(RepStorage:WaitForChild("Controllers").AutoFishingController)

local AutoFishState = {
    IsActive = false,
    MinigameActive = false
}

local SPEED_LEGIT = 0.05
local legitClickThread = nil

local function performClick()
    if FishingController then
        FishingController:RequestFishingMinigameClick()
        task.wait(SPEED_LEGIT)
    end
end

-- Hook FishingRodStarted
local originalRodStarted = FishingController.FishingRodStarted
FishingController.FishingRodStarted = function(self, arg1, arg2)
    originalRodStarted(self, arg1, arg2)

    if AutoFishState.IsActive and not AutoFishState.MinigameActive then
        AutoFishState.MinigameActive = true

        if legitClickThread then
            task.cancel(legitClickThread)
        end

        legitClickThread = task.spawn(function()
            while AutoFishState.IsActive and AutoFishState.MinigameActive do
                performClick()
            end
        end)
    end
end

-- Hook FishingStopped
local originalFishingStopped = FishingController.FishingStopped
FishingController.FishingStopped = function(self, arg1)
    originalFishingStopped(self, arg1)

    if AutoFishState.MinigameActive then
        AutoFishState.MinigameActive = false
    end
end

local function ensureServerAutoFishingOn()
    local replionClient = require(RepStorage:WaitForChild("Packages").Replion).Client
    local replionData = replionClient:WaitReplion("Data", 5)

    local UpdateAutoFishingRemote = GetRemote(RPath, "RF/UpdateAutoFishingState")

    if UpdateAutoFishingRemote then
        pcall(function()
            UpdateAutoFishingRemote:InvokeServer(true)
        end)
    end
end

local function ToggleAutoClick(shouldActivate)
    if not FishingController or not AutoFishingController then
        Window:Notify({ Title = "Error", Content = "Gagal memuat Fishing Controllers.", Duration = 4, Icon = "x" })
        return
    end
    
    AutoFishState.IsActive = shouldActivate

    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local fishingGui = playerGui:FindFirstChild("Fishing") and playerGui.Fishing:FindFirstChild("Main")
    local chargeGui = playerGui:FindFirstChild("Charge") and playerGui.Charge:FindFirstChild("Main")

    if shouldActivate then
        pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
        ensureServerAutoFishingOn()
        
        if fishingGui then fishingGui.Visible = false end
        if chargeGui then chargeGui.Visible = false end

        Window:Notify({ Title = "Auto Fish Legit ON!", Content = "Auto-Equip Protection Active.", Duration = 3, Icon = "check" })
    else
        if legitClickThread then
            task.cancel(legitClickThread)
            legitClickThread = nil
        end
        AutoFishState.MinigameActive = false
        
        if fishingGui then fishingGui.Visible = true end
        if chargeGui then chargeGui.Visible = true end

        Window:Notify({ Title = "Auto Fish Legit OFF!", Duration = 3, Icon = "x" })
    end
end

-- ============================================
-- AUTO FISHING UI SECTION
-- ============================================
local autofish = farm:Section({
    Title = "Auto Fishing",
    TextSize = 20,
    FontWeight = Enum.FontWeight.SemiBold,
})

-- Legit Click Speed Slider
local slidlegit = Reg("klikd", autofish:Slider({
    Title = "Legit Click Speed (Delay)",
    Step = 0.01,
    Value = { Min = 0.01, Max = 0.5, Default = SPEED_LEGIT },
    Callback = function(value)
        local newSpeed = tonumber(value)
        if newSpeed and newSpeed >= 0.01 then
            SPEED_LEGIT = newSpeed
        end
    end
}))

-- Auto Fish Legit Toggle
local toglegit = Reg("legit", autofish:Toggle({
    Title = "Auto Fish (Legit)",
    Value = false,
    Callback = function(state)
        if not checkFishingRemotes() then return false end
        disableOtherModes("legit")
        legitAutoState = state
        ToggleAutoClick(state)

        if state then
            if legitEquipThread then task.cancel(legitEquipThread) end
            legitEquipThread = task.spawn(function()
                while legitAutoState do
                    pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
                    task.wait(0.1)
                end
            end)
        else
            if legitEquipThread then task.cancel(legitEquipThread) legitEquipThread = nil end
        end
    end
}))

farm:Divider()

-- Normal Instant Fishing
local normalCompleteDelay = 1.50

NormalInstantSlider = Reg("normalslid", autofish:Slider({
    Title = "Normal Complete Delay",
    Step = 0.05,
    Value = { Min = 0.5, Max = 5.0, Default = normalCompleteDelay },
    Callback = function(value) normalCompleteDelay = tonumber(value) end
}))

local function runNormalInstant()
    if not normalInstantState then return end
    if not checkFishingRemotes(true) then normalInstantState = false return end
    
    local timestamp = os.time() + os.clock()
    pcall(function() RF_ChargeFishingRod:InvokeServer(timestamp) end)
    pcall(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.630452165, 0.99647927980797) end)
    
    task.wait(normalCompleteDelay)
    
    pcall(function() RE_FishingCompleted:FireServer() end)
    task.wait(0.3)
    pcall(function() RF_CancelFishingInputs:InvokeServer() end)
end

local normalins = Reg("tognorm", autofish:Toggle({
    Title = "Normal Instant Fish",
    Value = false,
    Callback = function(state)
        if not checkFishingRemotes() then return end
        disableOtherModes("normal")
        normalInstantState = state
        
        if state then
            normalLoopThread = task.spawn(function()
                while normalInstantState do
                    runNormalInstant()
                    task.wait(0.1) 
                end
            end)

            if normalEquipThread then task.cancel(normalEquipThread) end
            normalEquipThread = task.spawn(function()
                while normalInstantState do
                    pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
                    task.wait(0.1)
                end
            end)
            
            Window:Notify({ Title = "Auto Fish ON", Content = "Auto-Equip Protection Active.", Duration = 3, Icon = "fish" })
        else
            if normalLoopThread then task.cancel(normalLoopThread) normalLoopThread = nil end
            if normalEquipThread then task.cancel(normalEquipThread) normalEquipThread = nil end
            
            pcall(function() RE_EquipToolFromHotbar:FireServer(0) end)
            Window:Notify({ Title = "Auto Fish OFF", Duration = 3, Icon = "x" })
        end
    end
}))

print("[SynceHub] Fishing Tab - Auto Fishing Loaded!")

-- SynceHub - Tab Content Module (Part 4)
-- Blatant Fishing & Fishing Areas
-- ============================================
-- BLATANT INSTANT FISHING
-- ============================================
local blatant = farm:Section({ Title = "Blatant Mode", TextSize = 20 })

local completeDelay = 3.055
local cancelDelay = 0.3
local loopInterval = 1.715

_G.SynceHub_BlatantActive = false

-- Logic Killer: Lumpuhkan Controller
task.spawn(function()
    local S1, FishingController = pcall(function() return require(game:GetService("ReplicatedStorage").Controllers.FishingController) end)
    if S1 and FishingController then
        local Old_Charge = FishingController.RequestChargeFishingRod
        local Old_Cast = FishingController.SendFishingRequestToServer
        
        FishingController.RequestChargeFishingRod = function(...)
            if _G.SynceHub_BlatantActive then return end 
            return Old_Charge(...)
        end
        FishingController.SendFishingRequestToServer = function(...)
            if _G.SynceHub_BlatantActive then return false, "Blocked by SynceHub" end
            return Old_Cast(...)
        end
    end
end)

-- Remote Killer: Blokir Komunikasi
local mt = getrawmetatable(game)
local old_namecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if _G.SynceHub_BlatantActive and not checkcaller() then
        if method == "InvokeServer" and (self.Name == "RequestFishingMinigameStarted" or self.Name == "ChargeFishingRod" or self.Name == "UpdateAutoFishingState") then
            return nil 
        end
        if method == "FireServer" and self.Name == "FishingCompleted" then
            return nil
        end
    end
    return old_namecall(self, ...)
end)
setreadonly(mt, true)

-- UI & Notification Suppressor
local function SuppressGameVisuals(active)
    local Succ, TextController = pcall(function() return require(game.ReplicatedStorage.Controllers.TextNotificationController) end)
    if Succ and TextController then
        if active then
            if not TextController._OldDeliver then TextController._OldDeliver = TextController.DeliverNotification end
            TextController.DeliverNotification = function(self, data)
                if data and data.Text and (string.find(tostring(data.Text), "Auto Fishing") or string.find(tostring(data.Text), "Reach Level")) then
                    return 
                end
                return TextController._OldDeliver(self, data)
            end
        elseif TextController._OldDeliver then
            TextController.DeliverNotification = TextController._OldDeliver
            TextController._OldDeliver = nil
        end
    end

    if active then
        task.spawn(function()
            local RunService = game:GetService("RunService")
            local CollectionService = game:GetService("CollectionService")
            local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
            
            local InactiveColor = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("ff5d60")), 
                ColorSequenceKeypoint.new(1, Color3.fromHex("ff2256"))
            })

            while _G.SynceHub_BlatantActive do
                local targets = {}
                
                for _, btn in ipairs(CollectionService:GetTagged("AutoFishingButton")) do
                    table.insert(targets, btn)
                end
                
                if #targets == 0 then
                    local btn = PlayerGui:FindFirstChild("Backpack") and PlayerGui.Backpack:FindFirstChild("AutoFishingButton")
                    if btn then table.insert(targets, btn) end
                end

                for _, btn in ipairs(targets) do
                    local grad = btn:FindFirstChild("UIGradient")
                    if grad then
                        grad.Color = InactiveColor
                    end
                end
                
                RunService.RenderStepped:Wait()
            end
        end)
    end
end

-- UI Config Inputs
local LoopIntervalInput = Reg("blatantint", blatant:Input({
    Title = "Blatant Interval", Value = tostring(loopInterval), Icon = "fast-forward", Type = "Input", Placeholder = "1.58",
    Callback = function(input)
        local newInterval = tonumber(input)
        if newInterval and newInterval >= 0.5 then loopInterval = newInterval end
    end
}))

local CompleteDelayInput = Reg("blatantcom", blatant:Input({
    Title = "Complete Delay", Value = tostring(completeDelay), Icon = "loader", Type = "Input", Placeholder = "2.75",
    Callback = function(input)
        local newDelay = tonumber(input)
        if newDelay and newDelay >= 0.5 then completeDelay = newDelay end
    end
}))

local CancelDelayInput = Reg("blatantcanc", blatant:Input({
    Title = "Cancel Delay", Value = tostring(cancelDelay), Icon = "clock", Type = "Input", Placeholder = "0.3",
    Callback = function(input)
        local newDelay = tonumber(input)
        if newDelay and newDelay >= 0.1 then cancelDelay = newDelay end
    end
}))

local function runBlatantInstant()
    if not blatantInstantState then return end
    if not checkFishingRemotes(true) then blatantInstantState = false return end

    task.spawn(function()
        local startTime = os.clock()
        local timestamp = os.time() + os.clock()
        
        pcall(function() RF_ChargeFishingRod:InvokeServer(timestamp) end)
        task.wait(0.001)
        pcall(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.6379699707, 0.99647927980797) end)
        
        local completeWaitTime = completeDelay - (os.clock() - startTime)
        if completeWaitTime > 0 then task.wait(completeWaitTime) end
        
        pcall(function() RE_FishingCompleted:FireServer() end)
        task.wait(cancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
    end)
end

local togblat = Reg("blatantt", blatant:Toggle({
    Title = "Instant Fishing (Blatant)",
    Value = false,
    Callback = function(state)
        if not checkFishingRemotes() then return end
        disableOtherModes("blatant")
        blatantInstantState = state
        _G.SynceHub_BlatantActive = state
        
        SuppressGameVisuals(state)
        
        if state then
            if RF_UpdateAutoFishingState then
                pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end)
            end
            task.wait(0.5)
            if RF_UpdateAutoFishingState then
                pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end)
            end
            if RF_UpdateAutoFishingState then
                pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end)
            end

            blatantLoopThread = task.spawn(function()
                while blatantInstantState do
                    runBlatantInstant()
                    task.wait(loopInterval)
                end
            end)

            if blatantEquipThread then task.cancel(blatantEquipThread) end
            blatantEquipThread = task.spawn(function()
                while blatantInstantState do
                    pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
                    task.wait(0.1) 
                end
            end)
            
            Window:Notify({ Title = "Blatant Mode ON", Duration = 3, Icon = "zap" })
        else
            if RF_UpdateAutoFishingState then
                pcall(function() RF_UpdateAutoFishingState:InvokeServer(false) end)
            end

            if blatantLoopThread then task.cancel(blatantLoopThread) blatantLoopThread = nil end
            if blatantEquipThread then task.cancel(blatantEquipThread) blatantEquipThread = nil end
            
            Window:Notify({ Title = "Stopped", Duration = 2 })
        end
    end
}))

farm:Divider()

-- ============================================
-- FISHING AREA SECTION
-- ============================================
local areafish = farm:Section({
    Title = "Fishing Area",
    TextSize = 20,
})

-- Choose Area Dropdown
local choosearea = areafish:Dropdown({
    Title = "Choose Area",
    Values = AreaNames,
    AllowNone = true,
    Value = nil,
    Callback = function(option)
        selectedArea = option
    end
})

-- Teleport & Freeze Toggle
local freezeToggle = areafish:Toggle({
    Title = "Teleport & Freeze at Area (Fix Server Lag)",
    Desc = "Teleport -> Tunggu Sync Server -> Freeze.",
    Value = false,
    Callback = function(state)
        isTeleportFreezeActive = state
        
        local hrp = GetHRP()
        if not hrp then
            if freezeToggle and freezeToggle.Set then freezeToggle:Set(false) end
            return
        end

        if state then
            if not selectedArea then
                Window:Notify({ Title = "Aksi Gagal", Content = "Pilih Area dulu di Dropdown!", Duration = 3, Icon = "alert-triangle" })
                if freezeToggle and freezeToggle.Set then freezeToggle:Set(false) end
                return
            end
            
            local areaData = (selectedArea == "Custom: Saved" and savedPosition) or FishingAreas[selectedArea]

            if not areaData or not areaData.Pos or not areaData.Look then
                Window:Notify({ Title = "Aksi Gagal", Duration = 3, Icon = "alert-triangle" })
                if freezeToggle and freezeToggle.Set then freezeToggle:Set(false) end
                return
            end
            
            hrp.Anchored = false
            TeleportToLookAt(areaData.Pos, areaData.Look)
            
            Window:Notify({ Title = "Syncing Zone...", Content = "Menahan posisi agar server membaca lokasi baru...", Duration = 1.5, Icon = "wifi" })
            
            local startTime = os.clock()
            while (os.clock() - startTime) < 1.5 and isTeleportFreezeActive do
                if hrp then
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    hrp.CFrame = CFrame.new(areaData.Pos, areaData.Pos + areaData.Look) * CFrame.new(0, 0.5, 0)
                end
                game:GetService("RunService").Heartbeat:Wait()
            end
            
            if isTeleportFreezeActive and hrp then
                hrp.Anchored = true
                Window:Notify({ Title = "Ready to Fish", Content = "Posisi dikunci & Zona terupdate.", Duration = 2, Icon = "check" })
            end
            
        else
            if hrp then hrp.Anchored = false end
            Window:Notify({ Title = "Unfrozen", Content = "Gerakan kembali normal.", Duration = 2, Icon = "unlock" })
        end
    end
})

-- Teleport to Chosen Area Button
local teleto = areafish:Button({
    Title = "Teleport to Choosen Area",
    Icon = "corner-down-right",
    Callback = function()
        if not selectedArea then
            Window:Notify({ Title = "Teleport Gagal", Content = "Pilih Area dulu di Dropdown.", Duration = 3, Icon = "alert-triangle" })
            return
        end

        local areaData = (selectedArea == "Custom: Saved" and savedPosition) or FishingAreas[selectedArea]
        
        if not areaData or not areaData.Pos or not areaData.Look then
            Window:Notify({ Title = "Teleport Gagal", Duration = 3, Icon = "alert-triangle" })
            return
        end

        if isTeleportFreezeActive and freezeToggle then
            freezeToggle:Set(false)
            task.wait(0.1)
        end
        
        TeleportToLookAt(areaData.Pos, areaData.Look)
    end
})

farm:Divider()

-- Save Current Position Button
local savepos = areafish:Button({
    Title = "Save Current Position",
    Icon = "map-pin",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            savedPosition = {
                Pos = hrp.Position,
                Look = hrp.CFrame.LookVector
            }
            FishingAreas["Custom: Saved"] = savedPosition
            Window:Notify({
                Title = "Posisi Disimpan!",
                Duration = 3,
                Icon = "save",
            })
        else
            Window:Notify({ Title = "Gagal Simpan", Duration = 3, Icon = "x" })
        end
    end
})

-- Teleport to SAVED Position Button
local teletosave = areafish:Button({
    Title = "Teleport to SAVED Pos",
    Icon = "navigation",
    Callback = function()
        if not savedPosition then
            Window:Notify({ Title = "Teleport Gagal", Content = "Belum ada posisi yang disimpan.", Duration = 3, Icon = "alert-triangle" })
            return
        end
        
        local areaData = savedPosition
        
        if isTeleportFreezeActive and freezeToggle then
            freezeToggle:Set(false)
            task.wait(0.1)
        end
        
        TeleportToLookAt(areaData.Pos, areaData.Look)
    end
})

print("[SynceHub] Fishing Tab - Blatant & Areas Loaded!")

-- SynceHub - Tab Content Module (Part 5 - FINAL)
-- Automatic Tab - Auto Sell & Auto Favorite System
local Window = _G.SynceHub.Window
local Reg = _G.SynceHub.Reg
local GetPlayerDataReplion = _G.SynceHub.GetPlayerDataReplion
local GetFishNameAndRarity = _G.SynceHub.GetFishNameAndRarity
local GetItemMutationString = _G.SynceHub.GetItemMutationString
local GetRemote = _G.SynceHub.GetRemote
local RPath = _G.SynceHub.RPath

local RepStorage = game:GetService("ReplicatedStorage")
local ItemUtility = require(RepStorage:WaitForChild("Shared"):WaitForChild("ItemUtility", 10))
local TierUtility = require(RepStorage:WaitForChild("Shared"):WaitForChild("TierUtility", 10))

-- ============================================
-- ⚙️ AUTOMATIC TAB
-- ============================================
local automatic = Window:Tab({
    Title = "Automatic",
    Icon = "loader",
    Locked = false,
})

-- Get Fish Count Helper
local function GetFishCount()
    local replion = GetPlayerDataReplion()
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

-- ============================================
-- AUTO SELL SYSTEM (UNIFIED)
-- ============================================
local sellall = automatic:Section({ Title = "Autosell Fish", TextSize = 20 })

local RF_SellAllItems = GetRemote(RPath, "RF/SellAllItems", 5)

local autoSellMethod = "Delay"
local autoSellValue = 50
local autoSellState = false
local autoSellThread = nil

-- Unified Auto Sell Loop
local function RunAutoSellLoop()
    if autoSellThread then task.cancel(autoSellThread) end
    
    autoSellThread = task.spawn(function()
        while autoSellState do
            if autoSellMethod == "Delay" then
                if RF_SellAllItems then
                    pcall(function() RF_SellAllItems:InvokeServer() end)
                end
                task.wait(math.max(autoSellValue, 1))

            elseif autoSellMethod == "Count" then
                local currentCount = GetFishCount()
                
                if currentCount >= autoSellValue then
                    if RF_SellAllItems then
                        pcall(function() RF_SellAllItems:InvokeServer() end)
                        Window:Notify({ Title = "Auto Sell", Content = "Menjual " .. currentCount .. " items.", Duration = 2, Icon = "dollar-sign" })
                        task.wait(2)
                    end
                end
                task.wait(1)
            end
        end
    end)
end

-- Method Dropdown
local inputElement

local dropMethod = sellall:Dropdown({
    Title = "Select Method",
    Values = {"Delay", "Count"},
    Value = "Delay",
    Multi = false,
    AllowNone = false,
    Callback = function(val)
        autoSellMethod = val
        
        if inputElement then
            if val == "Delay" then
                inputElement:SetTitle("Sell Delay (Seconds)")
                inputElement:SetPlaceholder("e.g. 50")
            else
                inputElement:SetTitle("Sell at Item Count")
                inputElement:SetPlaceholder("e.g. 100")
            end
        end
        
        if autoSellState then
            RunAutoSellLoop()
        end
    end
})

-- Value Input
inputElement = Reg("sellval", sellall:Input({
    Title = "Sell Delay (Seconds)",
    Value = tostring(autoSellValue),
    Placeholder = "50",
    Icon = "hash",
    Callback = function(text)
        local num = tonumber(text)
        if num then
            autoSellValue = num
        end
    end
}))

-- Current Fish Count Display
local CurrentCountDisplay = sellall:Paragraph({ Title = "Current Fish Count: 0", Icon = "package" })
task.spawn(function() 
    while true do 
        if CurrentCountDisplay and GetPlayerDataReplion() then 
            local count = GetFishCount() 
            CurrentCountDisplay:SetTitle("Current Fish Count: " .. tostring(count)) 
        end 
        task.wait(1) 
    end 
end)

-- Auto Sell Toggle
local togSell = Reg("tsell", sellall:Toggle({
    Title = "Enable Auto Sell",
    Desc = "Menjalankan auto sell sesuai metode di atas.",
    Value = false,
    Callback = function(state)
        autoSellState = state
        if state then
            if not RF_SellAllItems then
                Window:Notify({ Title = "Error", Content = "Remote Sell tidak ditemukan.", Duration = 3, Icon = "x" })
                return false
            end
            
            local msg = (autoSellMethod == "Delay") and ("Setiap " .. autoSellValue .. " detik.") or ("Saat jumlah >= " .. autoSellValue)
            Window:Notify({ Title = "Auto Sell ON (" .. autoSellMethod .. ")", Content = msg, Duration = 3, Icon = "check" })
            RunAutoSellLoop()
        else
            Window:Notify({ Title = "Auto Sell OFF", Duration = 3, Icon = "x" })
            if autoSellThread then task.cancel(autoSellThread) autoSellThread = nil end
        end
    end
}))

-- ============================================
-- AUTO FAVORITE/UNFAVORITE SYSTEM
-- ============================================
local favsec = automatic:Section({ Title = "Auto Favorite / Unfavorite", TextSize = 20 })

local autoFavoriteState = false
local autoFavoriteThread = nil
local autoUnfavoriteState = false
local autoUnfavoriteThread = nil
local selectedRarities = {}
local selectedItemNames = {}
local selectedMutations = {}

local RE_FavoriteItem = GetRemote(RPath, "RE/FavoriteItem")

-- Get All Item Names from ReplicatedStorage
local function getAutoFavoriteItemOptions()
    local itemNames = {}
    local itemsContainer = RepStorage:FindFirstChild("Items")

    if not itemsContainer then
        return {"(Kontainer 'Items' di ReplicatedStorage Tidak Ditemukan)"}
    end

    for _, itemObject in ipairs(itemsContainer:GetChildren()) do
        local itemName = itemObject.Name
        
        if type(itemName) == "string" and #itemName >= 3 then
            local prefix = itemName:sub(1, 3)
            
            if prefix ~= "!!!" then
                table.insert(itemNames, itemName)
            end
        end
    end

    table.sort(itemNames)
    
    if #itemNames == 0 then
        return {"(Kontainer 'Items' Kosong atau Semua Item '!!!')"}
    end
    
    return itemNames
end

local allItemNames = getAutoFavoriteItemOptions()

-- Get Items to Favorite
local function GetItemsToFavorite()
    local replion = GetPlayerDataReplion()
    if not replion or not ItemUtility or not TierUtility then return {} end

    local success, inventoryData = pcall(function() return replion:GetExpect("Inventory") end)
    if not success or not inventoryData or not inventoryData.Items then return {} end

    local itemsToFavorite = {}
    
    local isRarityFilterActive = #selectedRarities > 0
    local isNameFilterActive = #selectedItemNames > 0
    local isMutationFilterActive = #selectedMutations > 0

    if not (isRarityFilterActive or isNameFilterActive or isMutationFilterActive) then
        return {}
    end

    for _, item in ipairs(inventoryData.Items) do
        if item.IsFavorite or item.Favorited then continue end
        
        local itemUUID = item.UUID
        if typeof(itemUUID) ~= "string" or itemUUID:len() < 10 then continue end
        
        local name, rarity = GetFishNameAndRarity(item)
        local mutationFilterString = GetItemMutationString(item)
        
        local isMatch = false

        if isRarityFilterActive and table.find(selectedRarities, rarity) then
            isMatch = true
        end

        if not isMatch and isNameFilterActive and table.find(selectedItemNames, name) then
            isMatch = true
        end

        if not isMatch and isMutationFilterActive and table.find(selectedMutations, mutationFilterString) then
            isMatch = true
        end

        if isMatch then
            table.insert(itemsToFavorite, itemUUID)
        end
    end

    return itemsToFavorite
end

-- Get Items to Unfavorite
local function GetItemsToUnfavorite()
    local replion = GetPlayerDataReplion()
    if not replion or not ItemUtility or not TierUtility then return {} end

    local success, inventoryData = pcall(function() return replion:GetExpect("Inventory") end)
    if not success or not inventoryData or not inventoryData.Items then return {} end

    local itemsToUnfavorite = {}
    
    for _, item in ipairs(inventoryData.Items) do
        if not (item.IsFavorite or item.Favorited) then
            continue
        end
        local itemUUID = item.UUID
        if typeof(itemUUID) ~= "string" or itemUUID:len() < 10 then
            continue
        end
        
        local name, rarity = GetFishNameAndRarity(item)
        local mutationFilterString = GetItemMutationString(item)
        
        local passesRarity = #selectedRarities > 0 and table.find(selectedRarities, rarity)
        local passesName = #selectedItemNames > 0 and table.find(selectedItemNames, name)
        local passesMutation = #selectedMutations > 0 and table.find(selectedMutations, mutationFilterString)
        
        local isTargetedForUnfavorite = passesRarity or passesName or passesMutation
        
        if isTargetedForUnfavorite then
            table.insert(itemsToUnfavorite, itemUUID)
        end
    end

    return itemsToUnfavorite
end

-- Set Favorite State
local function SetItemFavoriteState(itemUUID, isFavorite)
    if not RE_FavoriteItem then return false end
    pcall(function() RE_FavoriteItem:FireServer(itemUUID) end)
    return true
end

-- Auto Favorite Loop
local function RunAutoFavoriteLoop()
    if autoFavoriteThread then task.cancel(autoFavoriteThread) end
    
    autoFavoriteThread = task.spawn(function()
        local waitTime = 1
        local actionDelay = 0.5
        
        while autoFavoriteState do
            local itemsToFavorite = GetItemsToFavorite()
            
            if #itemsToFavorite > 0 then
                Window:Notify({ Title = "Auto Favorite", Content = string.format("Mem-favorite %d item...", #itemsToFavorite), Duration = 1, Icon = "star" })
                for _, itemUUID in ipairs(itemsToFavorite) do
                    SetItemFavoriteState(itemUUID, true)
                    task.wait(actionDelay)
                end
            end
            
            task.wait(waitTime)
        end
    end)
end

-- Auto Unfavorite Loop
local function RunAutoUnfavoriteLoop()
    if autoUnfavoriteThread then task.cancel(autoUnfavoriteThread) end
    
    autoUnfavoriteThread = task.spawn(function()
        local waitTime = 1
        local actionDelay = 0.5
        
        while autoUnfavoriteState do
            local itemsToUnfavorite = GetItemsToUnfavorite()
            
            if #itemsToUnfavorite > 0 then
                Window:Notify({ Title = "Auto Unfavorite", Content = string.format("Menghapus favorite dari %d item...", #itemsToUnfavorite), Duration = 1, Icon = "x" })
                for _, itemUUID in ipairs(itemsToUnfavorite) do
                    SetItemFavoriteState(itemUUID, false)
                    task.wait(actionDelay)
                end
            end
            
            task.wait(waitTime)
        end
    end)
end

-- UI Elements
local RarityDropdown = Reg("drer", favsec:Dropdown({
    Title = "by Rarity",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"},
    Multi = true, AllowNone = true, Value = false,
    Callback = function(values) selectedRarities = values or {} end
}))

local ItemNameDropdown = Reg("dtem", favsec:Dropdown({
    Title = "by Item Name",
    Values = allItemNames,
    Multi = true, AllowNone = true, Value = false,
    Callback = function(values) selectedItemNames = values or {} end
}))

local MutationDropdown = Reg("dmut", favsec:Dropdown({
    Title = "by Mutation",
    Values = {"Shiny", "Gemstone", "Corrupt", "Galaxy", "Holographic", "Ghost", "Lightning", "Fairy Dust", "Gold", "Midnight", "Radioactive", "Stone", "Albino", "Sandy", "Acidic", "Disco", "Frozen", "Noob"},
    Multi = true, AllowNone = true, Value = false,
    Callback = function(values) selectedMutations = values or {} end
}))

-- Auto Favorite Toggle
local togglefav = Reg("tvav", favsec:Toggle({
    Title = "Enable Auto Favorite",
    Value = false,
    Callback = function(state)
        autoFavoriteState = state
        if state then
            if autoUnfavoriteState then
                autoUnfavoriteState = false
                local unfavToggle = automatic:GetElementByTitle("Enable Auto Unfavorite")
                if unfavToggle and unfavToggle.Set then unfavToggle:Set(false) end
                if autoUnfavoriteThread then task.cancel(autoUnfavoriteThread) autoUnfavoriteThread = nil end
            end

            if not GetPlayerDataReplion() or not ItemUtility or not TierUtility then 
                Window:Notify({ Title = "Error", Content = "Gagal memuat data.", Duration = 3, Icon = "x" }) 
                return false 
            end
            
            Window:Notify({ Title = "Auto Favorite ON!", Duration = 3, Icon = "check" })
            RunAutoFavoriteLoop()
        else
            Window:Notify({ Title = "Auto Favorite OFF!", Duration = 3, Icon = "x" })
            if autoFavoriteThread then task.cancel(autoFavoriteThread) autoFavoriteThread = nil end
        end
    end
}))

-- Auto Unfavorite Toggle
local toggleunfav = Reg("tunfa", favsec:Toggle({
    Title = "Enable Auto Unfavorite",
    Value = false,
    Callback = function(state)
        autoUnfavoriteState = state
        if state then
            if autoFavoriteState then
                autoFavoriteState = false
                local favToggle = automatic:GetElementByTitle("Enable Auto Favorite")
                if favToggle and favToggle.Set then favToggle:Set(false) end
                if autoFavoriteThread then task.cancel(autoFavoriteThread) autoFavoriteThread = nil end
            end

            if not GetPlayerDataReplion() or not ItemUtility or not TierUtility then 
                Window:Notify({ Title = "Error", Content = "Gagal memuat data.", Duration = 3, Icon = "x" }) 
                return false 
            end
            
            Window:Notify({ Title = "Auto Unfavorite ON!", Duration = 3, Icon = "check" })
            RunAutoUnfavoriteLoop()
        else
            Window:Notify({ Title = "Auto Unfavorite OFF!", Duration = 3, Icon = "x" })
            if autoUnfavoriteThread then task.cancel(autoUnfavoriteThread) autoUnfavoriteThread = nil end
        end
    end
}))

print("[SynceHub] Automatic Tab Loaded!")
print("[SynceHub] All Tabs Successfully Loaded!")
print("================================================")
print("       🎉 SYNCEHUB FULLY INITIALIZED 🎉        ")
print("================================================")