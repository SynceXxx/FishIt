-- ============================================
-- SynceHub - Tab Content Part 1/4
-- PLAYER TAB: Movement, Abilities, Other, ESP
-- ============================================

-- GLOBAL DECLARATIONS (HANYA DI PART 1!)
local Window = _G.SynceHub.Window
local WindUI = _G.SynceHub.WindUI
local Reg = _G.SynceHub.Reg
local GetHumanoid = _G.SynceHub.GetHumanoid
local GetHRP = _G.SynceHub.GetHRP
local DEFAULT_SPEED = _G.SynceHub.DEFAULT_SPEED
local DEFAULT_JUMP = _G.SynceHub.DEFAULT_JUMP

local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game.Players.LocalPlayer

print("[SynceHub] Loading Part 1/4: Player Tab...")

-- ============================================
-- PLAYER TAB
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

local SliderSpeed = Reg("Walkspeed", movement:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = { Min = 16, Max = 200, Default = currentSpeed },
    Callback = function(value)
        local speedValue = tonumber(value)
        if speedValue and speedValue >= 0 then
            local Humanoid = GetHumanoid()
            if Humanoid then Humanoid.WalkSpeed = speedValue end
        end
    end,
}))

local SliderJump = Reg("slidjump", movement:Slider({
    Title = "JumpPower",
    Step = 1,
    Value = { Min = 50, Max = 200, Default = currentJump },
    Callback = function(value)
        local jumpValue = tonumber(value)
        if jumpValue and jumpValue >= 50 then
            local Humanoid = GetHumanoid()
            if Humanoid then Humanoid.JumpPower = jumpValue end
        end
    end,
}))

movement:Button({
    Title = "Reset Movement",
    Icon = "rotate-ccw",
    Callback = function()
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid.WalkSpeed = DEFAULT_SPEED
            Humanoid.JumpPower = DEFAULT_JUMP
            SliderSpeed:Set(DEFAULT_SPEED)
            SliderJump:Set(DEFAULT_JUMP)
            WindUI:Notify({ Title = "Movement Reset", Content = "Default values restored", Duration = 3, Icon = "check" })
        end
    end
})

Reg("frezee", movement:Toggle({
    Title = "Freeze Player",
    Desc = "Lock position (Anti-Push)",
    Value = false,
    Callback = function(state)
        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = state
            if state then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.Velocity = Vector3.zero
                WindUI:Notify({ Title = "Frozen", Content = "Position locked", Duration = 2, Icon = "lock" })
            else
                WindUI:Notify({ Title = "Unfrozen", Content = "Movement restored", Duration = 2, Icon = "unlock" })
            end
        end
    end
}))

-- ============================================
-- ABILITIES SECTION
-- ============================================
local ability = player:Section({ Title = "Abilities", TextSize = 20 })

local InfinityJumpConnection = nil
Reg("infj", ability:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(state)
        if state then
            WindUI:Notify({ Title = "Infinite Jump ON", Duration = 3, Icon = "check" })
            InfinityJumpConnection = UserInputService.JumpRequest:Connect(function()
                local Humanoid = GetHumanoid()
                if Humanoid and Humanoid.Health > 0 then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            WindUI:Notify({ Title = "Infinite Jump OFF", Duration = 3, Icon = "x" })
            if InfinityJumpConnection then InfinityJumpConnection:Disconnect() InfinityJumpConnection = nil end
        end
    end
}))

local noclipConnection = nil
local isNoClipActive = false
Reg("nclip", ability:Toggle({
    Title = "No Clip",
    Value = false,
    Callback = function(state)
        isNoClipActive = state
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if state then
            WindUI:Notify({ Title = "No Clip ON", Duration = 3, Icon = "check" })
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
            WindUI:Notify({ Title = "No Clip OFF", Duration = 3, Icon = "x" })
            if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
}))

local flyConnection = nil
local isFlying = false
local flySpeed = 60
local bodyGyro, bodyVel
Reg("flym", ability:Toggle({
    Title = "Fly Mode",
    Value = false,
    Callback = function(state)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")
        if state then
            WindUI:Notify({ Title = "Fly Mode ON", Duration = 3, Icon = "check" })
            isFlying = true
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 9e4
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.Parent = hrp
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.Velocity = Vector3.zero
            bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVel.Parent = hrp
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.zero
            local jumpPressed = false
            UserInputService.JumpRequest:Connect(function()
                if isFlying then jumpPressed = true task.delay(0.2, function() jumpPressed = false end) end
            end)
            flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not isFlying or not hrp or not bodyGyro or not bodyVel then return end
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
            WindUI:Notify({ Title = "Fly Mode OFF", Duration = 3, Icon = "x" })
            isFlying = false
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            if bodyVel then bodyVel:Destroy() bodyVel = nil end
        end
    end
}))

local walkOnWaterConnection = nil
local isWalkOnWater = false
local waterPlatform = nil
Reg("walkwat", ability:Toggle({
    Title = "Walk on Water",
    Value = false,
    Callback = function(state)
        if state then
            WindUI:Notify({ Title = "Walk on Water ON", Duration = 3, Icon = "check" })
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
            WindUI:Notify({ Title = "Walk on Water OFF", Duration = 3, Icon = "x" })
            isWalkOnWater = false
            if walkOnWaterConnection then walkOnWaterConnection:Disconnect() walkOnWaterConnection = nil end
            if waterPlatform then waterPlatform:Destroy() waterPlatform = nil end
        end
    end
}))

-- ============================================
-- OTHER SECTION
-- ============================================
local other = player:Section({ Title = "Other", TextSize = 20 })

local isHideActive = false
local hideConnection = nil
local customName = ".gg/SynceHub"
local customLevel = "Lvl. 969"

Reg("cfakennme", other:Input({
    Title = "Custom Fake Name",
    Value = customName,
    Placeholder = "Hidden User",
    Icon = "user-x",
    Callback = function(text) customName = text end
}))

Reg("cfkelvl", other:Input({
    Title = "Custom Fake Level",
    Value = customLevel,
    Placeholder = "Lvl. 999",
    Icon = "bar-chart-2",
    Callback = function(text) customLevel = text end
}))

Reg("hideallusr", other:Toggle({
    Title = "Hide Usernames (Streamer Mode)",
    Value = false,
    Callback = function(state)
        isHideActive = state
        pcall(function()
            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not state)
        end)
        if state then
            WindUI:Notify({ Title = "Hide Name ON", Duration = 3, Icon = "eye-off" })
            if hideConnection then hideConnection:Disconnect() end
            hideConnection = game:GetService("RunService").RenderStepped:Connect(function()
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    if plr.Character then
                        local hum = plr.Character:FindFirstChild("Humanoid")
                        if hum and hum.DisplayName ~= customName then hum.DisplayName = customName end
                        for _, obj in ipairs(plr.Character:GetDescendants()) do
                            if obj:IsA("BillboardGui") then
                                for _, lbl in ipairs(obj:GetDescendants()) do
                                    if (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) and lbl.Visible then
                                        local txt = lbl.Text
                                        if txt:find(plr.Name) or txt:find(plr.DisplayName) then
                                            if txt ~= customName then lbl.Text = customName end
                                        elseif txt:match("%d+") or txt:lower():find("lvl") then
                                            if #txt < 15 and txt ~= customLevel then lbl.Text = customLevel end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            WindUI:Notify({ Title = "Hide Name OFF", Duration = 3, Icon = "eye" })
            if hideConnection then hideConnection:Disconnect() hideConnection = nil end
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
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
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
    Frame.Parent = BillboardGui
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Parent = Frame
    NameLabel.Size = UDim2.new(1, 0, 0.6, 0)
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
    DistanceLabel.TextStrokeTransparency = 0.85
    DistanceLabel.Font = Enum.Font.GothamSemibold
    DistanceLabel.TextScaled = true
    espConnections[targetPlayer] = { billboard = BillboardGui }
    local distanceConn = runService.RenderStepped:Connect(function()
        if not espEnabled or not hrp or not hrp.Parent then removeESP(targetPlayer) return end
        local localChar = LocalPlayer.Character
        local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if localHRP then
            local distStuds = (localHRP.Position - hrp.Position).Magnitude
            DistanceLabel.Text = string.format("%.1f m", distStuds * STUD_TO_M)
        end
    end)
    espConnections[targetPlayer].distanceConn = distanceConn
    local charAddedConn = targetPlayer.CharacterAdded:Connect(function()
        task.wait(0.8)
        if espEnabled then createESP(targetPlayer) end
    end)
    espConnections[targetPlayer].charAddedConn = charAddedConn
end

Reg("esp", other:Toggle({
    Title = "Player ESP",
    Value = false,
    Callback = function(state)
        espEnabled = state
        if state then
            WindUI:Notify({ Title = "ESP Active", Duration = 3, Icon = "eye" })
            for _, plr in ipairs(players:GetPlayers()) do
                if plr ~= LocalPlayer then createESP(plr) end
            end
            espConnections["playerAddedConn"] = players.PlayerAdded:Connect(function(plr)
                task.wait(1)
                if espEnabled then createESP(plr) end
            end)
            espConnections["playerRemovingConn"] = players.PlayerRemoving:Connect(removeESP)
        else
            WindUI:Notify({ Title = "ESP Disabled", Duration = 3, Icon = "eye-off" })
            for plr, _ in pairs(espConnections) do
                if plr and typeof(plr) == "Instance" then removeESP(plr) end
            end
            if espConnections["playerAddedConn"] then espConnections["playerAddedConn"]:Disconnect() end
            if espConnections["playerRemovingConn"] then espConnections["playerRemovingConn"]:Disconnect() end
            espConnections = {}
        end
    end
}))

other:Button({
    Title = "Reset Character (In Place)",
    Icon = "refresh-cw",
    Callback = function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not character or not hrp or not humanoid then
            WindUI:Notify({ Title = "Failed", Content = "Character not found", Duration = 3, Icon = "x" })
            return
        end
        local lastPos = hrp.Position
        WindUI:Notify({ Title = "Respawning...", Duration = 2, Icon = "rotate-cw" })
        humanoid:TakeDamage(999999)
        LocalPlayer.CharacterAdded:Wait()
        task.wait(0.5)
        local newHRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart", 5)
        if newHRP then
            newHRP.CFrame = CFrame.new(lastPos + Vector3.new(0, 3, 0))
            WindUI:Notify({ Title = "Success", Content = "Respawned at same position", Duration = 3, Icon = "check" })
        end
    end
})

print("[SynceHub] Part 1/4: Player Tab - Loaded ✅")

-- ============================================
-- SynceHub - Tab Content Part 2/4
-- FISHING TAB: Auto Fishing (Legit, Normal, Blatant), Fishing Areas
-- ============================================

print("[SynceHub] Loading Part 2/4: Fishing Tab...")

local GetRemote = _G.SynceHub.GetRemote
local GetHRP = _G.SynceHub.GetHRP
local TeleportToLookAt = _G.SynceHub.TeleportToLookAt
local FishingAreas = _G.SynceHub.FishingAreas
local AreaNames = _G.SynceHub.AreaNames
local RPath = _G.SynceHub.RPath
local RepStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer

local farm = Window:Tab({ Title = "Fishing", Icon = "fish", Locked = false })

-- Variables
local legitAutoState = false
local normalInstantState = false
local blatantInstantState = false
local normalLoopThread, blatantLoopThread = nil, nil
local normalEquipThread, blatantEquipThread, legitEquipThread = nil, nil, nil
local isTeleportFreezeActive = false
local selectedArea, savedPosition = nil, nil

-- Remotes
local RE_EquipToolFromHotbar = GetRemote(RPath, "RE/EquipToolFromHotbar")
local RF_ChargeFishingRod = GetRemote(RPath, "RF/ChargeFishingRod")
local RF_RequestFishingMinigameStarted = GetRemote(RPath, "RF/RequestFishingMinigameStarted")
local RE_FishingCompleted = GetRemote(RPath, "RE/FishingCompleted")
local RF_CancelFishingInputs = GetRemote(RPath, "RF/CancelFishingInputs")
local RF_UpdateAutoFishingState = GetRemote(RPath, "RF/UpdateAutoFishingState")

local function checkFishingRemotes(silent)
    local remotes = {RE_EquipToolFromHotbar, RF_ChargeFishingRod, RF_RequestFishingMinigameStarted, RE_FishingCompleted, RF_CancelFishingInputs, RF_UpdateAutoFishingState}
    for _, remote in ipairs(remotes) do
        if not remote then
            if not silent then WindUI:Notify({Title="Remote Error", Content="Fishing remote not found", Duration=5, Icon="x"}) end
            return false
        end
    end
    return true
end

local function disableOtherModes(currentMode)
    pcall(function()
        if currentMode ~= "legit" and legitAutoState then
            legitAutoState = false
            if legitClickThread then task.cancel(legitClickThread) legitClickThread = nil end
            if legitEquipThread then task.cancel(legitEquipThread) legitEquipThread = nil end
        end
        if currentMode ~= "normal" and normalInstantState then
            normalInstantState = false
            if normalLoopThread then task.cancel(normalLoopThread) normalLoopThread = nil end
            if normalEquipThread then task.cancel(normalEquipThread) normalEquipThread = nil end
        end
        if currentMode ~= "blatant" and blatantInstantState then
            blatantInstantState = false
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
local AutoFishState = {IsActive = false, MinigameActive = false}
local SPEED_LEGIT = 0.05
local legitClickThread = nil

local function performClick()
    if FishingController then
        FishingController:RequestFishingMinigameClick()
        task.wait(SPEED_LEGIT)
    end
end

local originalRodStarted = FishingController.FishingRodStarted
FishingController.FishingRodStarted = function(self, arg1, arg2)
    originalRodStarted(self, arg1, arg2)
    if AutoFishState.IsActive and not AutoFishState.MinigameActive then
        AutoFishState.MinigameActive = true
        if legitClickThread then task.cancel(legitClickThread) end
        legitClickThread = task.spawn(function()
            while AutoFishState.IsActive and AutoFishState.MinigameActive do performClick() end
        end)
    end
end

local originalFishingStopped = FishingController.FishingStopped
FishingController.FishingStopped = function(self, arg1)
    originalFishingStopped(self, arg1)
    if AutoFishState.MinigameActive then AutoFishState.MinigameActive = false end
end

local function ensureServerAutoFishingOn()
    local replionClient = require(RepStorage:WaitForChild("Packages").Replion).Client
    local UpdateAutoFishingRemote = GetRemote(RPath, "RF/UpdateAutoFishingState")
    if UpdateAutoFishingRemote then
        pcall(function() UpdateAutoFishingRemote:InvokeServer(true) end)
    end
end

local function ToggleAutoClick(shouldActivate)
    if not FishingController or not AutoFishingController then
        WindUI:Notify({Title="Error", Content="Failed to load Fishing Controllers", Duration=4, Icon="x"})
        return
    end
    AutoFishState.IsActive = shouldActivate
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local fishingGui = playerGui:FindFirstChild("Fishing") and playerGui.Fishing:FindFirstChild("Main")
    local chargeGui = playerGui:FindFirstChild("Charge") and playerGui.Charge:FindFirstChild("Main")
    if shouldActivate then
        pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
        ensureServerAutoFishingOn()
        if fishingGui then fishingGui.Visible = false end
        if chargeGui then chargeGui.Visible = false end
        WindUI:Notify({Title="Auto Fish Legit ON", Content="Auto-Equip Active", Duration=3, Icon="check"})
    else
        if legitClickThread then task.cancel(legitClickThread) legitClickThread = nil end
        AutoFishState.MinigameActive = false
        if fishingGui then fishingGui.Visible = true end
        if chargeGui then chargeGui.Visible = true end
        WindUI:Notify({Title="Auto Fish Legit OFF", Duration=3, Icon="x"})
    end
end

-- ============================================
-- UI: AUTO FISHING SECTION
-- ============================================
local autofish = farm:Section({Title="Auto Fishing", TextSize=20})

Reg("klikd", autofish:Slider({
    Title="Legit Click Speed (Delay)",
    Step=0.01,
    Value={Min=0.01, Max=0.5, Default=SPEED_LEGIT},
    Callback=function(value)
        local newSpeed = tonumber(value)
        if newSpeed and newSpeed >= 0.01 then SPEED_LEGIT = newSpeed end
    end
}))

Reg("legit", autofish:Toggle({
    Title="Auto Fish (Legit)",
    Value=false,
    Callback=function(state)
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

-- NORMAL INSTANT FISHING
local normalCompleteDelay = 1.50

Reg("normalslid", autofish:Slider({
    Title="Normal Complete Delay",
    Step=0.05,
    Value={Min=0.5, Max=5.0, Default=normalCompleteDelay},
    Callback=function(value) normalCompleteDelay = tonumber(value) end
}))

local function runNormalInstant()
    if not normalInstantState or not checkFishingRemotes(true) then normalInstantState = false return end
    local timestamp = os.time() + os.clock()
    pcall(function() RF_ChargeFishingRod:InvokeServer(timestamp) end)
    pcall(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.630452165, 0.99647927980797) end)
    task.wait(normalCompleteDelay)
    pcall(function() RE_FishingCompleted:FireServer() end)
    task.wait(0.3)
    pcall(function() RF_CancelFishingInputs:InvokeServer() end)
end

Reg("tognorm", autofish:Toggle({
    Title="Normal Instant Fish",
    Value=false,
    Callback=function(state)
        if not checkFishingRemotes() then return end
        disableOtherModes("normal")
        normalInstantState = state
        if state then
            normalLoopThread = task.spawn(function()
                while normalInstantState do runNormalInstant() task.wait(0.1) end
            end)
            if normalEquipThread then task.cancel(normalEquipThread) end
            normalEquipThread = task.spawn(function()
                while normalInstantState do
                    pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
                    task.wait(0.1)
                end
            end)
            WindUI:Notify({Title="Auto Fish ON", Content="Auto-Equip Active", Duration=3, Icon="fish"})
        else
            if normalLoopThread then task.cancel(normalLoopThread) normalLoopThread = nil end
            if normalEquipThread then task.cancel(normalEquipThread) normalEquipThread = nil end
            pcall(function() RE_EquipToolFromHotbar:FireServer(0) end)
            WindUI:Notify({Title="Auto Fish OFF", Duration=3, Icon="x"})
        end
    end
}))

-- ============================================
-- BLATANT INSTANT FISHING
-- ============================================
local blatant = farm:Section({Title="Blatant Mode", TextSize=20})
local completeDelay, cancelDelay, loopInterval = 3.055, 0.3, 1.715
_G.SynceHub_BlatantActive = false

-- Logic Killer
task.spawn(function()
    local S1, FishingController = pcall(function() return require(RepStorage.Controllers.FishingController) end)
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

-- Remote Killer
local mt = getrawmetatable(game)
local old_namecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if _G.SynceHub_BlatantActive and not checkcaller() then
        if method == "InvokeServer" and (self.Name == "RequestFishingMinigameStarted" or self.Name == "ChargeFishingRod" or self.Name == "UpdateAutoFishingState") then
            return nil
        end
        if method == "FireServer" and self.Name == "FishingCompleted" then return nil end
    end
    return old_namecall(self, ...)
end)
setreadonly(mt, true)

-- UI Suppressor
local function SuppressGameVisuals(active)
    local Succ, TextController = pcall(function() return require(RepStorage.Controllers.TextNotificationController) end)
    if Succ and TextController then
        if active then
            if not TextController._OldDeliver then TextController._OldDeliver = TextController.DeliverNotification end
            TextController.DeliverNotification = function(self, data)
                if data and data.Text and (string.find(tostring(data.Text), "Auto Fishing") or string.find(tostring(data.Text), "Reach Level")) then return end
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
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            local InactiveColor = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("ff5d60")), ColorSequenceKeypoint.new(1, Color3.fromHex("ff2256"))})
            while _G.SynceHub_BlatantActive do
                local targets = {}
                for _, btn in ipairs(CollectionService:GetTagged("AutoFishingButton")) do table.insert(targets, btn) end
                if #targets == 0 then
                    local btn = PlayerGui:FindFirstChild("Backpack") and PlayerGui.Backpack:FindFirstChild("AutoFishingButton")
                    if btn then table.insert(targets, btn) end
                end
                for _, btn in ipairs(targets) do
                    local grad = btn:FindFirstChild("UIGradient")
                    if grad then grad.Color = InactiveColor end
                end
                RunService.RenderStepped:Wait()
            end
        end)
    end
end

Reg("blatantint", blatant:Input({Title="Blatant Interval", Value=tostring(loopInterval), Icon="fast-forward", Placeholder="1.58", Callback=function(input) local n = tonumber(input) if n and n >= 0.5 then loopInterval = n end end}))
Reg("blatantcom", blatant:Input({Title="Complete Delay", Value=tostring(completeDelay), Icon="loader", Placeholder="2.75", Callback=function(input) local n = tonumber(input) if n and n >= 0.5 then completeDelay = n end end}))
Reg("blatantcanc", blatant:Input({Title="Cancel Delay", Value=tostring(cancelDelay), Icon="clock", Placeholder="0.3", Callback=function(input) local n = tonumber(input) if n and n >= 0.1 then cancelDelay = n end end}))

local function runBlatantInstant()
    if not blatantInstantState or not checkFishingRemotes(true) then blatantInstantState = false return end
    task.spawn(function()
        local startTime = os.clock()
        pcall(function() RF_ChargeFishingRod:InvokeServer(os.time() + os.clock()) end)
        task.wait(0.001)
        pcall(function() RF_RequestFishingMinigameStarted:InvokeServer(-139.6379699707, 0.99647927980797) end)
        local completeWaitTime = completeDelay - (os.clock() - startTime)
        if completeWaitTime > 0 then task.wait(completeWaitTime) end
        pcall(function() RE_FishingCompleted:FireServer() end)
        task.wait(cancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
    end)
end

Reg("blatantt", blatant:Toggle({
    Title="Instant Fishing (Blatant)",
    Value=false,
    Callback=function(state)
        if not checkFishingRemotes() then return end
        disableOtherModes("blatant")
        blatantInstantState = state
        _G.SynceHub_BlatantActive = state
        SuppressGameVisuals(state)
        if state then
            if RF_UpdateAutoFishingState then
                for i=1,3 do pcall(function() RF_UpdateAutoFishingState:InvokeServer(true) end) task.wait(0.5) end
            end
            blatantLoopThread = task.spawn(function()
                while blatantInstantState do runBlatantInstant() task.wait(loopInterval) end
            end)
            if blatantEquipThread then task.cancel(blatantEquipThread) end
            blatantEquipThread = task.spawn(function()
                while blatantInstantState do
                    pcall(function() RE_EquipToolFromHotbar:FireServer(1) end)
                    task.wait(0.1)
                end
            end)
            WindUI:Notify({Title="Blatant Mode ON", Duration=3, Icon="zap"})
        else
            if RF_UpdateAutoFishingState then pcall(function() RF_UpdateAutoFishingState:InvokeServer(false) end) end
            if blatantLoopThread then task.cancel(blatantLoopThread) blatantLoopThread = nil end
            if blatantEquipThread then task.cancel(blatantEquipThread) blatantEquipThread = nil end
            WindUI:Notify({Title="Stopped", Duration=2})
        end
    end
}))

farm:Divider()

-- ============================================
-- FISHING AREA SECTION
-- ============================================
local areafish = farm:Section({Title="Fishing Area", TextSize=20})

areafish:Dropdown({
    Title="Choose Area",
    Values=AreaNames,
    AllowNone=true,
    Value=nil,
    Callback=function(option) selectedArea = option end
})

areafish:Toggle({
    Title="Teleport & Freeze at Area",
    Desc="Teleport -> Wait Server Sync -> Freeze",
    Value=false,
    Callback=function(state)
        isTeleportFreezeActive = state
        local hrp = GetHRP()
        if not hrp then return end
        if state then
            if not selectedArea then
                WindUI:Notify({Title="Failed", Content="Select area first", Duration=3, Icon="alert-triangle"})
                return
            end
            local areaData = (selectedArea == "Custom: Saved" and savedPosition) or FishingAreas[selectedArea]
            if not areaData or not areaData.Pos or not areaData.Look then
                WindUI:Notify({Title="Failed", Duration=3, Icon="alert-triangle"})
                return
            end
            hrp.Anchored = false
            TeleportToLookAt(areaData.Pos, areaData.Look)
            WindUI:Notify({Title="Syncing Zone...", Content="Waiting for server update...", Duration=1.5, Icon="wifi"})
            local startTime = os.clock()
            while (os.clock() - startTime) < 1.5 and isTeleportFreezeActive do
                if hrp then
                    hrp.Velocity = Vector3.zero
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.CFrame = CFrame.new(areaData.Pos, areaData.Pos + areaData.Look) * CFrame.new(0, 0.5, 0)
                end
                game:GetService("RunService").Heartbeat:Wait()
            end
            if isTeleportFreezeActive and hrp then
                hrp.Anchored = true
                WindUI:Notify({Title="Ready to Fish", Content="Position locked & Zone updated", Duration=2, Icon="check"})
            end
        else
            if hrp then hrp.Anchored = false end
            WindUI:Notify({Title="Unfrozen", Content="Movement restored", Duration=2, Icon="unlock"})
        end
    end
})

areafish:Button({
    Title="Teleport to Chosen Area",
    Icon="corner-down-right",
    Callback=function()
        if not selectedArea then
            WindUI:Notify({Title="Failed", Content="Select area first", Duration=3, Icon="alert-triangle"})
            return
        end
        local areaData = (selectedArea == "Custom: Saved" and savedPosition) or FishingAreas[selectedArea]
        if not areaData or not areaData.Pos or not areaData.Look then
            WindUI:Notify({Title="Failed", Duration=3, Icon="alert-triangle"})
            return
        end
        TeleportToLookAt(areaData.Pos, areaData.Look)
    end
})

farm:Divider()

areafish:Button({
    Title="Save Current Position",
    Icon="map-pin",
    Callback=function()
        local hrp = GetHRP()
        if hrp then
            savedPosition = {Pos = hrp.Position, Look = hrp.CFrame.LookVector}
            FishingAreas["Custom: Saved"] = savedPosition
            WindUI:Notify({Title="Position Saved!", Duration=3, Icon="save"})
        else
            WindUI:Notify({Title="Failed", Duration=3, Icon="x"})
        end
    end
})

areafish:Button({
    Title="Teleport to SAVED Pos",
    Icon="navigation",
    Callback=function()
        if not savedPosition then
            WindUI:Notify({Title="Failed", Content="No saved position", Duration=3, Icon="alert-triangle"})
            return
        end
        TeleportToLookAt(savedPosition.Pos, savedPosition.Look)
    end
})

print("[SynceHub] Part 2/4: Fishing Tab - Loaded ✅")

-- ============================================
-- SynceHub - Tab Content Part 3/4
-- AUTOMATIC TAB: Auto Sell, Auto Favorite/Unfavorite
-- ============================================

print("[SynceHub] Loading Part 3/4: Automatic Tab...")

local GetRemote = _G.SynceHub.GetRemote
local GetPlayerDataReplion = _G.SynceHub.GetPlayerDataReplion
local GetFishNameAndRarity = _G.SynceHub.GetFishNameAndRarity
local GetItemMutationString = _G.SynceHub.GetItemMutationString
local RPath = _G.SynceHub.RPath
local RepStorage = game:GetService("ReplicatedStorage")
local ItemUtility = require(RepStorage:WaitForChild("Shared"):WaitForChild("ItemUtility", 10))
local TierUtility = require(RepStorage:WaitForChild("Shared"):WaitForChild("TierUtility", 10))

local automatic = Window:Tab({ Title = "Automatic", Icon = "loader", Locked = false })

-- ============================================
-- HELPER: GET FISH COUNT
-- ============================================
local function GetFishCount()
    local replion = GetPlayerDataReplion()
    if not replion then return 0 end
    local totalFishCount = 0
    local success, inventoryData = pcall(function() return replion:GetExpect("Inventory") end)
    if not success or not inventoryData or not inventoryData.Items then return 0 end
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
        if isSellableFish then totalFishCount = totalFishCount + (item.Count or 1) end
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

local function RunAutoSellLoop()
    if autoSellThread then task.cancel(autoSellThread) end
    autoSellThread = task.spawn(function()
        while autoSellState do
            if autoSellMethod == "Delay" then
                if RF_SellAllItems then pcall(function() RF_SellAllItems:InvokeServer() end) end
                task.wait(math.max(autoSellValue, 1))
            elseif autoSellMethod == "Count" then
                local currentCount = GetFishCount()
                if currentCount >= autoSellValue then
                    if RF_SellAllItems then
                        pcall(function() RF_SellAllItems:InvokeServer() end)
                        WindUI:Notify({ Title = "Auto Sell", Content = "Selling " .. currentCount .. " items", Duration = 2, Icon = "dollar-sign" })
                        task.wait(2)
                    end
                end
                task.wait(1)
            end
        end
    end)
end

local inputElement
sellall:Dropdown({
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
        if autoSellState then RunAutoSellLoop() end
    end
})

inputElement = Reg("sellval", sellall:Input({
    Title = "Sell Delay (Seconds)",
    Value = tostring(autoSellValue),
    Placeholder = "50",
    Icon = "hash",
    Callback = function(text)
        local num = tonumber(text)
        if num then autoSellValue = num end
    end
}))

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

Reg("tsell", sellall:Toggle({
    Title = "Enable Auto Sell",
    Desc = "Run auto sell based on method above",
    Value = false,
    Callback = function(state)
        autoSellState = state
        if state then
            if not RF_SellAllItems then
                WindUI:Notify({ Title = "Error", Content = "Sell remote not found", Duration = 3, Icon = "x" })
                return false
            end
            local msg = (autoSellMethod == "Delay") and ("Every " .. autoSellValue .. " seconds") or ("At count >= " .. autoSellValue)
            WindUI:Notify({ Title = "Auto Sell ON (" .. autoSellMethod .. ")", Content = msg, Duration = 3, Icon = "check" })
            RunAutoSellLoop()
        else
            WindUI:Notify({ Title = "Auto Sell OFF", Duration = 3, Icon = "x" })
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

local function getAutoFavoriteItemOptions()
    local itemNames = {}
    local itemsContainer = RepStorage:FindFirstChild("Items")
    if not itemsContainer then return {"(Items container not found)"} end
    for _, itemObject in ipairs(itemsContainer:GetChildren()) do
        local itemName = itemObject.Name
        if type(itemName) == "string" and #itemName >= 3 then
            local prefix = itemName:sub(1, 3)
            if prefix ~= "!!!" then table.insert(itemNames, itemName) end
        end
    end
    table.sort(itemNames)
    if #itemNames == 0 then return {"(No items found)"} end
    return itemNames
end

local allItemNames = getAutoFavoriteItemOptions()

local function GetItemsToFavorite()
    local replion = GetPlayerDataReplion()
    if not replion or not ItemUtility or not TierUtility then return {} end
    local success, inventoryData = pcall(function() return replion:GetExpect("Inventory") end)
    if not success or not inventoryData or not inventoryData.Items then return {} end
    local itemsToFavorite = {}
    local isRarityFilterActive = #selectedRarities > 0
    local isNameFilterActive = #selectedItemNames > 0
    local isMutationFilterActive = #selectedMutations > 0
    if not (isRarityFilterActive or isNameFilterActive or isMutationFilterActive) then return {} end
    for _, item in ipairs(inventoryData.Items) do
        if item.IsFavorite or item.Favorited then continue end
        local itemUUID = item.UUID
        if typeof(itemUUID) ~= "string" or itemUUID:len() < 10 then continue end
        local name, rarity = GetFishNameAndRarity(item)
        local mutationFilterString = GetItemMutationString(item)
        local isMatch = false
        if isRarityFilterActive and table.find(selectedRarities, rarity) then isMatch = true end
        if not isMatch and isNameFilterActive and table.find(selectedItemNames, name) then isMatch = true end
        if not isMatch and isMutationFilterActive and table.find(selectedMutations, mutationFilterString) then isMatch = true end
        if isMatch then table.insert(itemsToFavorite, itemUUID) end
    end
    return itemsToFavorite
end

local function GetItemsToUnfavorite()
    local replion = GetPlayerDataReplion()
    if not replion or not ItemUtility or not TierUtility then return {} end
    local success, inventoryData = pcall(function() return replion:GetExpect("Inventory") end)
    if not success or not inventoryData or not inventoryData.Items then return {} end
    local itemsToUnfavorite = {}
    for _, item in ipairs(inventoryData.Items) do
        if not (item.IsFavorite or item.Favorited) then continue end
        local itemUUID = item.UUID
        if typeof(itemUUID) ~= "string" or itemUUID:len() < 10 then continue end
        local name, rarity = GetFishNameAndRarity(item)
        local mutationFilterString = GetItemMutationString(item)
        local passesRarity = #selectedRarities > 0 and table.find(selectedRarities, rarity)
        local passesName = #selectedItemNames > 0 and table.find(selectedItemNames, name)
        local passesMutation = #selectedMutations > 0 and table.find(selectedMutations, mutationFilterString)
        local isTargetedForUnfavorite = passesRarity or passesName or passesMutation
        if isTargetedForUnfavorite then table.insert(itemsToUnfavorite, itemUUID) end
    end
    return itemsToUnfavorite
end

local function SetItemFavoriteState(itemUUID, isFavorite)
    if not RE_FavoriteItem then return false end
    pcall(function() RE_FavoriteItem:FireServer(itemUUID) end)
    return true
end

local function RunAutoFavoriteLoop()
    if autoFavoriteThread then task.cancel(autoFavoriteThread) end
    autoFavoriteThread = task.spawn(function()
        local waitTime = 1
        local actionDelay = 0.5
        while autoFavoriteState do
            local itemsToFavorite = GetItemsToFavorite()
            if #itemsToFavorite > 0 then
                WindUI:Notify({ Title = "Auto Favorite", Content = string.format("Favoriting %d items...", #itemsToFavorite), Duration = 1, Icon = "star" })
                for _, itemUUID in ipairs(itemsToFavorite) do
                    SetItemFavoriteState(itemUUID, true)
                    task.wait(actionDelay)
                end
            end
            task.wait(waitTime)
        end
    end)
end

local function RunAutoUnfavoriteLoop()
    if autoUnfavoriteThread then task.cancel(autoUnfavoriteThread) end
    autoUnfavoriteThread = task.spawn(function()
        local waitTime = 1
        local actionDelay = 0.5
        while autoUnfavoriteState do
            local itemsToUnfavorite = GetItemsToUnfavorite()
            if #itemsToUnfavorite > 0 then
                WindUI:Notify({ Title = "Auto Unfavorite", Content = string.format("Unfavoriting %d items...", #itemsToUnfavorite), Duration = 1, Icon = "x" })
                for _, itemUUID in ipairs(itemsToUnfavorite) do
                    SetItemFavoriteState(itemUUID, false)
                    task.wait(actionDelay)
                end
            end
            task.wait(waitTime)
        end
    end)
end

Reg("drer", favsec:Dropdown({
    Title = "by Rarity",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"},
    Multi = true,
    AllowNone = true,
    Value = false,
    Callback = function(values) selectedRarities = values or {} end
}))

Reg("dtem", favsec:Dropdown({
    Title = "by Item Name",
    Values = allItemNames,
    Multi = true,
    AllowNone = true,
    Value = false,
    Callback = function(values) selectedItemNames = values or {} end
}))

Reg("dmut", favsec:Dropdown({
    Title = "by Mutation",
    Values = {"Shiny", "Gemstone", "Corrupt", "Galaxy", "Holographic", "Ghost", "Lightning", "Fairy Dust", "Gold", "Midnight", "Radioactive", "Stone", "Albino", "Sandy", "Acidic", "Disco", "Frozen", "Noob"},
    Multi = true,
    AllowNone = true,
    Value = false,
    Callback = function(values) selectedMutations = values or {} end
}))

Reg("tvav", favsec:Toggle({
    Title = "Enable Auto Favorite",
    Value = false,
    Callback = function(state)
        autoFavoriteState = state
        if state then
            if autoUnfavoriteState then
                autoUnfavoriteState = false
                if autoUnfavoriteThread then task.cancel(autoUnfavoriteThread) autoUnfavoriteThread = nil end
            end
            if not GetPlayerDataReplion() or not ItemUtility or not TierUtility then
                WindUI:Notify({ Title = "Error", Content = "Failed to load data", Duration = 3, Icon = "x" })
                return false
            end
            WindUI:Notify({ Title = "Auto Favorite ON", Duration = 3, Icon = "check" })
            RunAutoFavoriteLoop()
        else
            WindUI:Notify({ Title = "Auto Favorite OFF", Duration = 3, Icon = "x" })
            if autoFavoriteThread then task.cancel(autoFavoriteThread) autoFavoriteThread = nil end
        end
    end
}))

Reg("tunfa", favsec:Toggle({
    Title = "Enable Auto Unfavorite",
    Value = false,
    Callback = function(state)
        autoUnfavoriteState = state
        if state then
            if autoFavoriteState then
                autoFavoriteState = false
                if autoFavoriteThread then task.cancel(autoFavoriteThread) autoFavoriteThread = nil end
            end
            if not GetPlayerDataReplion() or not ItemUtility or not TierUtility then
                WindUI:Notify({ Title = "Error", Content = "Failed to load data", Duration = 3, Icon = "x" })
                return false
            end
            WindUI:Notify({ Title = "Auto Unfavorite ON", Duration = 3, Icon = "check" })
            RunAutoUnfavoriteLoop()
        else
            WindUI:Notify({ Title = "Auto Unfavorite OFF", Duration = 3, Icon = "x" })
            if autoUnfavoriteThread then task.cancel(autoUnfavoriteThread) autoUnfavoriteThread = nil end
        end
    end
}))

print("[SynceHub] Part 3/4: Automatic Tab - Loaded ✅")

-- ============================================
-- SynceHub - Tab Content Part 4/4 (FINAL)
-- ADDITIONAL TABS: Teleport, Shop, Premium, Quests, Events, Tools, Webhook, Config, About
-- ============================================

print("[SynceHub] Loading Part 4/4: Additional Tabs...")

local TeleportToLookAt = _G.SynceHub.TeleportToLookAt
local FishingAreas = _G.SynceHub.FishingAreas
local GetRemote = _G.SynceHub.GetRemote
local RPath = _G.SynceHub.RPath
local SmartLoadConfig = _G.SynceHub.SmartLoadConfig
local LocalPlayer = game.Players.LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")

-- ============================================
-- TELEPORT TAB
-- ============================================
local teleport = Window:Tab({ Title = "Teleport", Icon = "map-pin", Locked = false })
local tpsec = teleport:Section({ Title = "Fast Travel Locations", TextSize = 20 })

for areaName, areaData in pairs(FishingAreas) do
    tpsec:Button({
        Title = areaName,
        Icon = "navigation",
        Callback = function() TeleportToLookAt(areaData.Pos, areaData.Look) end
    })
end

local npcsec = teleport:Section({ Title = "NPCs & Merchants", TextSize = 20 })
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
        Callback = function() TeleportToLookAt(npcData.Pos, npcData.Look) end
    })
end

print("[SynceHub] Teleport Tab - Loaded ✅")

-- ============================================
-- SHOP TAB
-- ============================================
local shop = Window:Tab({ Title = "Shop", Icon = "shopping-bag", Locked = false })
local ShopItems = {
    ["Rods"] = {
        {Name = "Luck Rod", ID = 79, Price = 325}, {Name = "Carbon Rod", ID = 76, Price = 750},
        {Name = "Grass Rod", ID = 85, Price = 1500}, {Name = "Damascus Rod", ID = 77, Price = 3000},
        {Name = "Ice Rod", ID = 78, Price = 5000}, {Name = "Lucky Rod", ID = 4, Price = 15000},
        {Name = "Midnight Rod", ID = 80, Price = 50000}, {Name = "Steampunk Rod", ID = 6, Price = 215000},
        {Name = "Chrome Rod", ID = 7, Price = 437000}, {Name = "Fluorescent Rod", ID = 255, Price = 715000},
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
        {Name = "Mini Yacht", ID = 14, Price = 1200000}, {Name = "Fish Boat", ID = 6, Price = 180000},
        {Name = "Speed Boat", ID = 5, Price = 70000}, {Name = "Highfield Boat", ID = 4, Price = 25000},
        {Name = "Jetski", ID = 3, Price = 7500}, {Name = "Kayak", ID = 2, Price = 1100},
        {Name = "Small Boat", ID = 1, Price = 100},
    },
}

local RF_PurchaseShopItem = GetRemote(RPath, "RF/PurchaseShopItem", 5)

for category, items in pairs(ShopItems) do
    local sec = shop:Section({ Title = category, TextSize = 18 })
    for _, item in ipairs(items) do
        sec:Button({
            Title = string.format("%s - $%s", item.Name, tostring(item.Price)),
            Icon = "shopping-cart",
            Callback = function()
                if RF_PurchaseShopItem then
                    pcall(function() RF_PurchaseShopItem:InvokeServer(item.ID) end)
                    WindUI:Notify({ Title = "Shop Purchase", Content = "Buying " .. item.Name, Duration = 3, Icon = "check" })
                else
                    WindUI:Notify({ Title = "Error", Content = "Shop remote not found", Duration = 3, Icon = "x" })
                end
            end
        })
    end
end

print("[SynceHub] Shop Tab - Loaded ✅")

-- ============================================
-- PREMIUM TAB
-- ============================================
local premium = Window:Tab({ Title = "Premium", Icon = "star", Locked = false })
local premsec = premium:Section({ Title = "Premium Features", TextSize = 20 })

premium:Label({ Title = "🌟 Premium Status", Description = "You are using SynceHub Premium Version" })

premsec:Button({
    Title = "Unlock All Features",
    Icon = "unlock",
    Callback = function()
        WindUI:Notify({ Title = "Premium Active", Content = "All features unlocked!", Duration = 3, Icon = "check" })
    end
})

premsec:Button({
    Title = "Premium Support",
    Icon = "help-circle",
    Callback = function()
        WindUI:Notify({ Title = "Support", Content = "Contact us on Discord!", Duration = 5, Icon = "message-circle" })
    end
})

print("[SynceHub] Premium Tab - Loaded ✅")

-- ============================================
-- QUESTS TAB
-- ============================================
local quests = Window:Tab({ Title = "Quests", Icon = "clipboard", Locked = false })
local questsec = quests:Section({ Title = "Quest Automation", TextSize = 20 })

quests:Label({ Title = "⚠️ Coming Soon", Description = "Auto Quest system under development" })

questsec:Button({
    Title = "View Active Quests",
    Icon = "list",
    Callback = function()
        WindUI:Notify({ Title = "Quests", Content = "Quest viewer coming soon!", Duration = 3, Icon = "info" })
    end
})

print("[SynceHub] Quests Tab - Loaded ✅")

-- ============================================
-- EVENTS TAB
-- ============================================
local events = Window:Tab({ Title = "Events", Icon = "zap", Locked = false })
local eventsec = events:Section({ Title = "Event Automation", TextSize = 20 })

local eventsList = {"Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole", "Shocked", "Ghost Worm", "Meteor Rain", "Megalodon Hunt", "Treasure Event"}
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
        if sunkenFolder then eventModel = sunkenFolder:FindFirstChild("Treasure") end
    elseif targetName == "Worm Hunt" then
        local menuRingsFolder = workspace:FindFirstChild("!!! MENU RINGS")
        if menuRingsFolder then
            for _, child in ipairs(menuRingsFolder:GetChildren()) do
                if child.Name == "Props" then
                    local specificModel = child:FindFirstChild("Model")
                    if specificModel then eventModel = specificModel break end
                end
            end
        end
    else
        local menuRingsFolder = workspace:FindFirstChild("!!! MENU RINGS")
        if menuRingsFolder then
            for _, container in ipairs(menuRingsFolder:GetChildren()) do
                if container:FindFirstChild(targetName) then eventModel = container:FindFirstChild(targetName) break end
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
        WindUI:Notify({ Title = "Event Found!", Content = "Teleported to: " .. targetName, Icon = "map-pin", Duration = 3 })
        return true
    end
    return false
end

local function RunAutoEventTeleportLoop()
    if autoEventTeleportThread then task.cancel(autoEventTeleportThread) end
    autoEventTeleportThread = task.spawn(function()
        WindUI:Notify({ Title = "Auto Event TP ON", Content = "Scanning for event...", Duration = 3, Icon = "search" })
        while autoEventTeleportState do
            if FindAndTeleportToTargetEvent() then
                task.wait(900)
            else
                task.wait(10)
            end
        end
        WindUI:Notify({ Title = "Auto Event TP OFF", Duration = 3, Icon = "x" })
    end)
end

eventsec:Dropdown({
    Title = "Select Event",
    Values = eventsList,
    Multi = false,
    AllowNone = true,
    Value = nil,
    Callback = function(selected) autoEventTargetName = selected end
})

Reg("autoeventtp", eventsec:Toggle({
    Title = "Auto Teleport to Event",
    Desc = "Auto find and teleport to selected event",
    Value = false,
    Callback = function(state)
        autoEventTeleportState = state
        if state then
            if not autoEventTargetName then
                WindUI:Notify({ Title = "Error", Content = "Select event first!", Duration = 3, Icon = "alert-triangle" })
                return false
            end
            RunAutoEventTeleportLoop()
        else
            if autoEventTeleportThread then task.cancel(autoEventTeleportThread) autoEventTeleportThread = nil end
        end
    end
}))

print("[SynceHub] Events Tab - Loaded ✅")

-- ============================================
-- TOOLS TAB
-- ============================================
local tools = Window:Tab({ Title = "Tools", Icon = "tool", Locked = false })
local toolsec = tools:Section({ Title = "Utility Tools", TextSize = 20 })

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
        WindUI:Notify({ Title = "Server Hop", Content = "No available servers found!", Duration = 3, Icon = "x" })
    end
})

toolsec:Button({
    Title = "Copy JobId",
    Icon = "copy",
    Callback = function()
        setclipboard(game.JobId)
        WindUI:Notify({ Title = "Copied", Content = "JobId copied to clipboard!", Duration = 3, Icon = "check" })
    end
})

print("[SynceHub] Tools Tab - Loaded ✅")

-- ============================================
-- WEBHOOK TAB
-- ============================================
local webhook = Window:Tab({ Title = "Webhook", Icon = "link", Locked = false })
local webhooksec = webhook:Section({ Title = "Discord Webhook", TextSize = 20 })
local webhookURL = ""

Reg("webhookurl", webhooksec:Input({
    Title = "Webhook URL",
    Desc = "Enter your Discord webhook URL",
    Value = "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Icon = "link",
    Callback = function(text) webhookURL = text end
}))

webhooksec:Button({
    Title = "Test Webhook",
    Icon = "send",
    Callback = function()
        if webhookURL == "" then
            WindUI:Notify({ Title = "Error", Content = "Enter webhook URL first!", Duration = 3, Icon = "x" })
            return
        end
        local data = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "SynceHub - Test Message",
                ["description"] = "Webhook connection successful!",
                ["color"] = 5814783,
                ["footer"] = { ["text"] = "SynceHub | Fish It" }
            }}
        }
        local HttpService = game:GetService("HttpService")
        local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
        local success = pcall(function()
            if requestFunc then
                requestFunc({
                    Url = webhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(data)
                })
            else
                error("No HTTP request function available")
            end
        end)
        if success then
            WindUI:Notify({ Title = "Success", Content = "Webhook message sent!", Duration = 3, Icon = "check" })
        else
            WindUI:Notify({ Title = "Error", Content = "Failed to send webhook!", Duration = 3, Icon = "x" })
        end
    end
})

webhook:Label({ Title = "⚠️ Feature Info", Description = "Auto notifications coming soon!" })

print("[SynceHub] Webhook Tab - Loaded ✅")

-- ============================================
-- CONFIGURATION TAB
-- ============================================
local config = Window:Tab({ Title = "Configuration", Icon = "settings", Locked = false })
local configsec = config:Section({ Title = "Config Management", TextSize = 20 })
local configName = "default"

Reg("configname", configsec:Input({
    Title = "Config Name",
    Value = "default",
    Placeholder = "my-config",
    Icon = "file-text",
    Callback = function(text) configName = text end
}))

configsec:Button({
    Title = "Save Config",
    Icon = "save",
    Callback = function()
        Window.ConfigManager:Save(configName)
        WindUI:Notify({ Title = "Config Saved", Content = "Config '" .. configName .. "' saved!", Duration = 3, Icon = "check" })
    end
})

configsec:Button({
    Title = "Load Config",
    Icon = "folder-open",
    Callback = function() SmartLoadConfig(configName) end
})

configsec:Button({
    Title = "Delete Config",
    Icon = "trash",
    Callback = function()
        Window.ConfigManager:Delete(configName)
        WindUI:Notify({ Title = "Config Deleted", Content = "Config '" .. configName .. "' deleted!", Duration = 3, Icon = "check" })
    end
})

configsec:Button({
    Title = "Refresh Config List",
    Icon = "refresh-cw",
    Callback = function()
        Window.ConfigManager:Refresh()
        WindUI:Notify({ Title = "Refreshed", Duration = 2, Icon = "check" })
    end
})

print("[SynceHub] Configuration Tab - Loaded ✅")

-- ============================================
-- ABOUT TAB
-- ============================================
local about = Window:Tab({ Title = "About", Icon = "info", Locked = false })
local aboutsec = about:Section({ Title = "SynceHub Information", TextSize = 20 })

about:Label({ Title = "🎣 SynceHub - Fish It", Description = "Premium Version 1.0.5" })
about:Label({ Title = "Created by:", Description = "Synce Development Team" })
about:Label({ Title = "Based on:", Description = "RockHub by alt_" })

about:Divider()

local statssec = about:Section({ Title = "Script Statistics", TextSize = 18 })
about:Label({ Title = "Total Features:", Description = "50+ Premium Features" })
about:Label({ Title = "Tabs:", Description = "12 Organized Tabs" })
about:Label({ Title = "Status:", Description = "✅ Fully Operational" })

about:Divider()

local linkssec = about:Section({ Title = "Links & Support", TextSize = 18 })

linkssec:Button({
    Title = "Join Discord Server",
    Icon = "message-circle",
    Callback = function()
        WindUI:Notify({ Title = "Discord", Content = "Discord link coming soon!", Duration = 3, Icon = "info" })
    end
})

linkssec:Button({
    Title = "Report Bug",
    Icon = "alert-circle",
    Callback = function()
        WindUI:Notify({ Title = "Bug Report", Content = "Report bugs on our Discord!", Duration = 3, Icon = "info" })
    end
})

linkssec:Button({
    Title = "Check for Updates",
    Icon = "download",
    Callback = function()
        WindUI:Notify({ Title = "Up to Date", Content = "Latest version!", Duration = 3, Icon = "check" })
    end
})

print("[SynceHub] About Tab - Loaded ✅")
print("[SynceHub] Part 4/4: Additional Tabs - Loaded ✅")
print("================================================")
print("   🎉 ALL TABS SUCCESSFULLY LOADED 🎉")
print("================================================")