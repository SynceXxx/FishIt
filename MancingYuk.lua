local T=game:GetService("TweenService")
local U=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local R=game:GetService("ReplicatedStorage")
local E,L,V,C,W,SPAM_ENABLED,SPAM_CONNECTION,SPAM_COUNT=false,nil,true,0,998.0,false,nil,0

local P={{name="El Maja",rarity="Secret"},{name="El Maja Pink",rarity="Secret"},{name="Devilish Gran Maja",rarity="Secret"},{name="Kraken",rarity="Secret"},{name="Mega Hunt",rarity="Secret"},{name="Lochness Monster",rarity="Secret"},{name="Devilish Lochness",rarity="Secret"},{name="purple Kraken",rarity="Secret"},{name="Wraithfin Abyssal",rarity="Secret"},{name="Sotong",rarity="Secret"},{name="KingJally Strong",rarity="Secret"},{name="King Crab",rarity="Secret"},{name="Sapu Sapu Goib",rarity="Secret"},{name="Shark Bone",rarity="Secret"},{name="Naga",rarity="Secret"},{name="Worm Fish",rarity="Secret"},{name="Ancient Whale",rarity="Secret"},{name="Jungle Crocodile",rarity="Secret"}}

local S=1
local btns={}

local G=Instance.new("ScreenGui")
G.Name="FishingLeaderboard"
G.ResetOnSpawn=false
G.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

local success_gui=pcall(function()
    local X=game:GetService("CoreGui"):FindFirstChild("FishingLeaderboard")
    if X then X:Destroy() end
    G.Parent=game:GetService("CoreGui")
end)

if not success_gui then
    local X=game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FishingLeaderboard")
    if X then X:Destroy() end
    G.Parent=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local M=Instance.new("Frame")
M.Name="MainFrame"
M.Size=UDim2.new(0,520,0,260)
M.Position=UDim2.new(0.5,-260,0.5,-130)
M.BackgroundColor3=Color3.fromRGB(15,15,20)
M.BorderSizePixel=0
M.Parent=G

Instance.new("UICorner",M).CornerRadius=UDim.new(0,16)

local stroke_m=Instance.new("UIStroke",M)
stroke_m.Color=Color3.fromRGB(60,60,70)
stroke_m.Thickness=1
stroke_m.Transparency=0.5

local topbar=Instance.new("Frame",M)
topbar.Name="TopBar"
topbar.Size=UDim2.new(1,0,0,40)
topbar.BackgroundColor3=Color3.fromRGB(20,20,28)
topbar.BorderSizePixel=0

Instance.new("UICorner",topbar).CornerRadius=UDim.new(0,16)

local fill_t=Instance.new("Frame",topbar)
fill_t.Size=UDim2.new(1,0,0,16)
fill_t.Position=UDim2.new(0,0,1,-16)
fill_t.BackgroundColor3=Color3.fromRGB(20,20,28)
fill_t.BorderSizePixel=0

local title=Instance.new("TextLabel",topbar)
title.Size=UDim2.new(1,-50,1,0)
title.Position=UDim2.new(0,12,0,0)
title.BackgroundTransparency=1
title.Text="🎣 SynceHub | MANCING"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=13
title.TextXAlignment=Enum.TextXAlignment.Left

local hide_btn=Instance.new("TextButton",topbar)
hide_btn.Size=UDim2.new(0,30,0,30)
hide_btn.Position=UDim2.new(1,-38,0.5,-15)
hide_btn.BackgroundColor3=Color3.fromRGB(30,30,38)
hide_btn.BorderSizePixel=0
hide_btn.Text="—"
hide_btn.TextColor3=Color3.fromRGB(200,200,200)
hide_btn.Font=Enum.Font.GothamBold
hide_btn.TextSize=16
hide_btn.AutoButtonColor=false

Instance.new("UICorner",hide_btn).CornerRadius=UDim.new(0,8)

local content=Instance.new("Frame",M)
content.Name="Content"
content.Size=UDim2.new(1,-16,1,-48)
content.Position=UDim2.new(0,8,0,44)
content.BackgroundTransparency=1

local left_panel=Instance.new("Frame",content)
left_panel.Size=UDim2.new(0,245,1,0)
left_panel.BackgroundColor3=Color3.fromRGB(20,20,28)
left_panel.BorderSizePixel=0

Instance.new("UICorner",left_panel).CornerRadius=UDim.new(0,12)

local label_catch=Instance.new("TextLabel",left_panel)
label_catch.Size=UDim2.new(1,-16,0,16)
label_catch.Position=UDim2.new(0,8,0,6)
label_catch.BackgroundTransparency=1
label_catch.Text="⚡ Auto Catch"
label_catch.TextColor3=Color3.fromRGB(255,215,0)
label_catch.Font=Enum.Font.GothamBold
label_catch.TextSize=11
label_catch.TextXAlignment=Enum.TextXAlignment.Left

local catch_btn=Instance.new("TextButton",left_panel)
catch_btn.Size=UDim2.new(1,-16,0,32)
catch_btn.Position=UDim2.new(0,8,0,26)
catch_btn.BackgroundColor3=Color3.fromRGB(80,200,120)
catch_btn.BorderSizePixel=0
catch_btn.Text="START"
catch_btn.TextColor3=Color3.fromRGB(255,255,255)
catch_btn.Font=Enum.Font.GothamBold
catch_btn.TextSize=11
catch_btn.AutoButtonColor=false

Instance.new("UICorner",catch_btn).CornerRadius=UDim.new(0,10)

local counter=Instance.new("Frame",left_panel)
counter.Size=UDim2.new(1,-16,0,28)
counter.Position=UDim2.new(0,8,0,62)
counter.BackgroundColor3=Color3.fromRGB(30,30,40)
counter.BorderSizePixel=0

Instance.new("UICorner",counter).CornerRadius=UDim.new(0,8)

local counter_stroke=Instance.new("UIStroke",counter)
counter_stroke.Color=Color3.fromRGB(80,200,120)
counter_stroke.Thickness=1
counter_stroke.Transparency=0.5

local counter_label=Instance.new("TextLabel",counter)
counter_label.Size=UDim2.new(0.5,-5,1,0)
counter_label.Position=UDim2.new(0,8,0,0)
counter_label.BackgroundTransparency=1
counter_label.Text="Caught:"
counter_label.TextColor3=Color3.fromRGB(200,200,200)
counter_label.Font=Enum.Font.Gotham
counter_label.TextSize=10
counter_label.TextXAlignment=Enum.TextXAlignment.Left

local counter_value=Instance.new("TextLabel",counter)
counter_value.Size=UDim2.new(0.5,-5,1,0)
counter_value.Position=UDim2.new(0.5,0,0,0)
counter_value.BackgroundTransparency=1
counter_value.Text="0"
counter_value.TextColor3=Color3.fromRGB(80,200,120)
counter_value.Font=Enum.Font.GothamBold
counter_value.TextSize=13
counter_value.TextXAlignment=Enum.TextXAlignment.Right

local reset_btn=Instance.new("TextButton",left_panel)
reset_btn.Size=UDim2.new(1,-16,0,28)
reset_btn.Position=UDim2.new(0,8,0,94)
reset_btn.BackgroundColor3=Color3.fromRGB(70,70,85)
reset_btn.BorderSizePixel=0
reset_btn.Text="RESET COUNT"
reset_btn.TextColor3=Color3.fromRGB(255,255,255)
reset_btn.Font=Enum.Font.GothamBold
reset_btn.TextSize=10
reset_btn.AutoButtonColor=false

Instance.new("UICorner",reset_btn).CornerRadius=UDim.new(0,8)

local tip_label=Instance.new("TextLabel",left_panel)
tip_label.Size=UDim2.new(1,-16,0,82)
tip_label.Position=UDim2.new(0,8,0,128)
tip_label.BackgroundTransparency=1
tip_label.Text="💡 Tips:\n\n• Fill weight 10000.0\n• Sell quickly to exceed 998.0\n• Use spam for mass inject"
tip_label.TextColor3=Color3.fromRGB(120,120,130)
tip_label.Font=Enum.Font.Gotham
tip_label.TextSize=8
tip_label.TextWrapped=true
tip_label.TextXAlignment=Enum.TextXAlignment.Left
tip_label.TextYAlignment=Enum.TextYAlignment.Top

local right_panel=Instance.new("Frame",content)
right_panel.Size=UDim2.new(0,247,1,0)
right_panel.Position=UDim2.new(1,-247,0,0)
right_panel.BackgroundColor3=Color3.fromRGB(20,20,28)
right_panel.BorderSizePixel=0

Instance.new("UICorner",right_panel).CornerRadius=UDim.new(0,12)

local label_fish=Instance.new("TextLabel",right_panel)
label_fish.Size=UDim2.new(1,-16,0,16)
label_fish.Position=UDim2.new(0,8,0,6)
label_fish.BackgroundTransparency=1
label_fish.Text="🐟 Fish Secret"
label_fish.TextColor3=Color3.fromRGB(138,43,226)
label_fish.Font=Enum.Font.GothamBold
label_fish.TextSize=11
label_fish.TextXAlignment=Enum.TextXAlignment.Left

local fish_label=Instance.new("TextLabel",right_panel)
fish_label.Size=UDim2.new(1,-16,0,12)
fish_label.Position=UDim2.new(0,8,0,24)
fish_label.BackgroundTransparency=1
fish_label.Text="Selected: El Maja"
fish_label.TextColor3=Color3.fromRGB(180,180,180)
fish_label.Font=Enum.Font.Gotham
fish_label.TextSize=9
fish_label.TextXAlignment=Enum.TextXAlignment.Left

local scroll=Instance.new("ScrollingFrame",right_panel)
scroll.Size=UDim2.new(1,-16,0,90)
scroll.Position=UDim2.new(0,8,0,38)
scroll.BackgroundColor3=Color3.fromRGB(15,15,20)
scroll.BorderSizePixel=0
scroll.ScrollBarThickness=2
scroll.ScrollBarImageColor3=Color3.fromRGB(138,43,226)
scroll.CanvasSize=UDim2.new(0,0,0,0)

Instance.new("UICorner",scroll).CornerRadius=UDim.new(0,8)

local list=Instance.new("UIListLayout",scroll)
list.Padding=UDim.new(0,3)
list.SortOrder=Enum.SortOrder.LayoutOrder

local pad_sc=Instance.new("UIPadding",scroll)
pad_sc.PaddingTop=UDim.new(0,3)
pad_sc.PaddingLeft=UDim.new(0,3)
pad_sc.PaddingRight=UDim.new(0,3)
pad_sc.PaddingBottom=UDim.new(0,3)

for i,p in ipairs(P) do
    local btn=Instance.new("TextButton",scroll)
    btn.Size=UDim2.new(1,-6,0,22)
    btn.BackgroundColor3=i==1 and Color3.fromRGB(138,43,226) or Color3.fromRGB(30,30,38)
    btn.BorderSizePixel=0
    btn.Text=p.name:gsub("Devilish ","D."):gsub("Monster ","M."):gsub("Lochness ","L.")
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=9
    btn.AutoButtonColor=false
    btn.LayoutOrder=i
    btns[i]=btn
    
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5)
    
    if i==1 then
        local glow=Instance.new("UIStroke",btn)
        glow.Color=Color3.fromRGB(138,43,226)
        glow.Thickness=1.5
        glow.Transparency=0.3
    end
    
    btn.MouseButton1Click:Connect(function()
        S=i
        fish_label.Text="Selected: "..p.name
        for idx,b in pairs(btns) do
            for _,child in pairs(b:GetChildren()) do
                if child:IsA("UIStroke") then child:Destroy() end
            end
            b.BackgroundColor3=Color3.fromRGB(30,30,38)
        end
        btn.BackgroundColor3=Color3.fromRGB(138,43,226)
        local new_glow=Instance.new("UIStroke",btn)
        new_glow.Color=Color3.fromRGB(138,43,226)
        new_glow.Thickness=1.5
        new_glow.Transparency=0.3
    end)
end

list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize=UDim2.new(0,0,0,list.AbsoluteContentSize.Y+6)
end)

local weight_container=Instance.new("Frame",right_panel)
weight_container.Size=UDim2.new(1,-16,0,16)
weight_container.Position=UDim2.new(0,8,0,132)
weight_container.BackgroundTransparency=1

local weight_label=Instance.new("TextLabel",weight_container)
weight_label.Size=UDim2.new(0,65,1,0)
weight_label.BackgroundTransparency=1
weight_label.Text="Weight: "..W
weight_label.TextColor3=Color3.fromRGB(200,200,200)
weight_label.Font=Enum.Font.Gotham
weight_label.TextSize=9
weight_label.TextXAlignment=Enum.TextXAlignment.Left

local weight_box=Instance.new("TextBox",weight_container)
weight_box.Size=UDim2.new(0,80,1,0)
weight_box.Position=UDim2.new(1,-80,0,0)
weight_box.BackgroundColor3=Color3.fromRGB(30,30,38)
weight_box.BorderSizePixel=0
weight_box.Text="998.0"
weight_box.PlaceholderText="998.0"
weight_box.TextColor3=Color3.fromRGB(255,255,255)
weight_box.Font=Enum.Font.Gotham
weight_box.TextSize=9

Instance.new("UICorner",weight_box).CornerRadius=UDim.new(0,5)

weight_box.FocusLost:Connect(function()
    local val=tonumber(weight_box.Text)
    if val and val>0 then
        if val>998.0 then
            weight_box.Text="998.0"
            W=998.0
        else
            W=val
        end
    else
        weight_box.Text="998.0"
        W=998.0
    end
    weight_label.Text="Weight: "..W
end)

local button_container=Instance.new("Frame",right_panel)
button_container.Size=UDim2.new(1,-16,0,60)
button_container.Position=UDim2.new(0,8,0,151)
button_container.BackgroundTransparency=1

local inject_btn=Instance.new("TextButton",button_container)
inject_btn.Size=UDim2.new(1,0,0,26)
inject_btn.BackgroundColor3=Color3.fromRGB(138,43,226)
inject_btn.BorderSizePixel=0
inject_btn.Text="INJECT FISH"
inject_btn.TextColor3=Color3.fromRGB(255,255,255)
inject_btn.Font=Enum.Font.GothamBold
inject_btn.TextSize=10
inject_btn.AutoButtonColor=false

Instance.new("UICorner",inject_btn).CornerRadius=UDim.new(0,8)

local spam_btn=Instance.new("TextButton",button_container)
spam_btn.Size=UDim2.new(1,0,0,28)
spam_btn.Position=UDim2.new(0,0,0,32)
spam_btn.BackgroundColor3=Color3.fromRGB(80,200,120)
spam_btn.BorderSizePixel=0
spam_btn.Text="SPAM INJECT"
spam_btn.TextColor3=Color3.fromRGB(255,255,255)
spam_btn.Font=Enum.Font.GothamBold
spam_btn.TextSize=10
spam_btn.AutoButtonColor=false

Instance.new("UICorner",spam_btn).CornerRadius=UDim.new(0,8)

local float_btn=Instance.new("TextButton",G)
float_btn.Size=UDim2.new(0,35,0,35)
float_btn.Position=UDim2.new(1,-45,0,10)
float_btn.BackgroundColor3=Color3.fromRGB(0,0,0)
float_btn.BackgroundTransparency=0.3
float_btn.BorderSizePixel=0
float_btn.Text="🎣"
float_btn.TextSize=16
float_btn.Font=Enum.Font.GothamBold
float_btn.TextColor3=Color3.fromRGB(255,255,255)
float_btn.AutoButtonColor=false
float_btn.Visible=false

Instance.new("UICorner",float_btn).CornerRadius=UDim.new(1,0)

local stroke_fb=Instance.new("UIStroke",float_btn)
stroke_fb.Color=Color3.fromRGB(255,255,255)
stroke_fb.Thickness=1
stroke_fb.Transparency=0.7

local dragging,dragInput,dragStart,startPos

topbar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        startPos=M.Position
    end
end)

topbar.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        dragInput=input
    end
end)

U.InputChanged:Connect(function(input)
    if input==dragInput and dragging then
        local delta=input.Position-dragStart
        M.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)

U.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end)

local float_dragging,float_dragInput,float_dragStart,float_startPos

float_btn.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        float_dragging=true
        float_dragStart=input.Position
        float_startPos=float_btn.Position
    end
end)

float_btn.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        float_dragInput=input
    end
end)

U.InputChanged:Connect(function(input)
    if input==float_dragInput and float_dragging then
        local delta=input.Position-float_dragStart
        float_btn.Position=UDim2.new(float_startPos.X.Scale,float_startPos.X.Offset+delta.X,float_startPos.Y.Scale,float_startPos.Y.Offset+delta.Y)
    end
end)

local function toggleUI()
    V=not V
    if V then
        float_btn.Visible=false
        M.Visible=true
        M.Size=UDim2.new(0,0,0,0)
        M.Position=UDim2.new(0.5,0,0.5,0)
        T:Create(M,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,520,0,260),Position=UDim2.new(0.5,-260,0.5,-130)}):Play()
    else
        T:Create(M,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
        task.wait(0.25)
        M.Visible=false
        float_btn.Visible=true
    end
end

local function autoCatch()
    pcall(function()
        R:WaitForChild("FishingCatchSuccess"):FireServer()
        C=C+1
        counter_value.Text=tostring(C)
    end)
end

local function toggleAutoCatch()
    E=not E
    if E then
        catch_btn.Text="STOP"
        T:Create(catch_btn,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(220,50,50)}):Play()
        L=task.spawn(function()
            for i=1,1000 do
                if not E then break end
                autoCatch()
                task.wait(0.05)
            end
            E=false
            catch_btn.Text="START"
            T:Create(catch_btn,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(80,200,120)}):Play()
        end)
    else
        catch_btn.Text="START"
        T:Create(catch_btn,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(80,200,120)}):Play()
        if L then task.cancel(L) end
    end
end

local function resetCount()
    C=0
    counter_value.Text="0"
    T:Create(reset_btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(80,200,120)}):Play()
    T:Create(counter_stroke,TweenInfo.new(0.1),{Color=Color3.fromRGB(80,255,120)}):Play()
    T:Create(counter_value,TweenInfo.new(0.1),{TextColor3=Color3.fromRGB(80,255,120)}):Play()
    task.wait(0.15)
    T:Create(reset_btn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(70,70,85)}):Play()
    T:Create(counter_stroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(80,200,120)}):Play()
    T:Create(counter_value,TweenInfo.new(0.2),{TextColor3=Color3.fromRGB(80,200,120)}):Play()
end

local function injectFish()
    local p=P[S]
    pcall(function()
        local args={{hookPosition=Vector3.new(-33.0011100769043,-7.850030422210693,456.7280578613281),name=p.name,rarity=p.rarity,weight=W}}
        R:WaitForChild("FishingSystem"):WaitForChild("FishGiver"):FireServer(unpack(args))
    end)
    T:Create(inject_btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(80,255,80)}):Play()
    task.wait(0.15)
    T:Create(inject_btn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(138,43,226)}):Play()
end

local function toggleSpamInject()
    SPAM_ENABLED=not SPAM_ENABLED
    if SPAM_ENABLED then
        spam_btn.Text="STOP SPAM"
        T:Create(spam_btn,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(220,50,50)}):Play()
        SPAM_COUNT=0
        SPAM_CONNECTION=RunService.Heartbeat:Connect(function()
            pcall(function()
                local p=P[S]
                local args={{hookPosition=Vector3.new(-33.0011100769043,-7.850030422210693,456.7280578613281),name=p.name,rarity=p.rarity,weight=W}}
                R:WaitForChild("FishingSystem"):WaitForChild("FishGiver"):FireServer(unpack(args))
                SPAM_COUNT=SPAM_COUNT+1
                if SPAM_COUNT%10==0 then
                    fish_label.Text="Injected: "..SPAM_COUNT
                end
            end)
        end)
    else
        spam_btn.Text="START SPAM"
        T:Create(spam_btn,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(80,200,120)}):Play()
        if SPAM_CONNECTION then
            SPAM_CONNECTION:Disconnect()
            SPAM_CONNECTION=nil
        end
        fish_label.Text="Selected: "..P[S].name
    end
end

catch_btn.MouseButton1Click:Connect(toggleAutoCatch)
reset_btn.MouseButton1Click:Connect(resetCount)
inject_btn.MouseButton1Click:Connect(injectFish)
spam_btn.MouseButton1Click:Connect(toggleSpamInject)
float_btn.MouseButton1Click:Connect(toggleUI)
hide_btn.MouseButton1Click:Connect(toggleUI)

catch_btn.MouseEnter:Connect(function()
    if not E then T:Create(catch_btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(90,220,140)}):Play() end
end)
catch_btn.MouseLeave:Connect(function()
    if not E then T:Create(catch_btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(80,200,120)}):Play() end
end)

reset_btn.MouseEnter:Connect(function()
    T:Create(reset_btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(90,90,105)}):Play()
end)
reset_btn.MouseLeave:Connect(function()
    T:Create(reset_btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(70,70,85)}):Play()
end)

inject_btn.MouseEnter:Connect(function()
    T:Create(inject_btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(158,63,246)}):Play()
end)
inject_btn.MouseLeave:Connect(function()
    T:Create(inject_btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(138,43,226)}):Play()
end)

spam_btn.MouseEnter:Connect(function()
    if not SPAM_ENABLED then T:Create(spam_btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(90,220,140)}):Play() end
end)
spam_btn.MouseLeave:Connect(function()
    if not SPAM_ENABLED then T:Create(spam_btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(80,200,120)}):Play() end
end)

hide_btn.MouseEnter:Connect(function()
    T:Create(hide_btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(40,40,50)}):Play()
end)
hide_btn.MouseLeave:Connect(function()
    T:Create(hide_btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(30,30,38)}):Play()
end)

print("✅ SynceHub | MANCING loaded!")