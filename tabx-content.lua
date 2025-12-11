--[[
    SynceHub - Fish It
    Tab Content (Frontend UI)
    
    PART 1/3 - Config System & Player Tab
]]

local TabContent = {}

-- References
local Window, WindUI, Features
local ElementRegistry = {}
local SynceHubConfig

-- Helper untuk register config
local function Reg(id, element)
    SynceHubConfig:Register(id, element)
    ElementRegistry[id] = element 
    return element
end

-- Smart Load Config Function
local function SmartLoadConfig(configName)
    local HttpService = game:GetService("HttpService")
    local BaseFolder = "WindUI/" .. (Window.Folder or "SynceHub") .. "/config/"
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

    WindUI:Notify({ 
        Title = "Config Loaded", 
        Content = string.format("Updated: %d settings", changeCount), 
        Duration = 3, 
        Icon = "check" 
    })
end

-- Initialize
function TabContent.Init(win, wui, feat)
    Window = win
    WindUI = wui
    Features = feat
    
    -- Setup Config Manager
    SynceHubConfig = Window.ConfigManager:CreateConfig("Syncehub")
    
    -- Build Tabs
    TabContent.BuildPlayerTab()
    TabContent.BuildFishingTab()
    TabContent.BuildAutomaticTab()
end

-- ========================================
-- PLAYER TAB
-- ========================================
function TabContent.BuildPlayerTab()
    local player = Window:Tab({
        Title = "Player",
        Icon = "user",
        Locked = false,
    })

    -- MOVEMENT SECTION
    local movement = player:Section({
        Title = "Movement",
        TextSize = 20,
    })

    local SliderSpeed = Reg("Walkspeed", movement:Slider({
        Title = "WalkSpeed",
        Step = 1,
        Value = {
            Min = 16,
            Max = 200,
            Default = Features.State.CurrentSpeed,
        },
        Callback = function(value)
            Features.SetWalkSpeed(value)
        end,
    }))

    local SliderJump = Reg("slidjump", movement:Slider({
        Title = "JumpPower",
        Step = 1,
        Value = {
            Min = 50,
            Max = 200,
            Default = Features.State.CurrentJump,
        },
        Callback = function(value)
            Features.SetJumpPower(value)
        end,
    }))
    
    local reset = movement:Button({
        Title = "Reset Movement",
        Icon = "rotate-ccw",
        Locked = false,
        Callback = function()
            Features.ResetMovement()
            SliderSpeed:Set(Features.Constants.DEFAULT_SPEED)
            SliderJump:Set(Features.Constants.DEFAULT_JUMP)
            WindUI:Notify({
                Title = "Movement Direset",
                Content = "WalkSpeed & JumpPower Reset to default",
                Duration = 3,
                Icon = "check",
            })
        end
    })

    local freezeplr = Reg("frezee", movement:Toggle({
        Title = "Freeze Player",
        Desc = "Membekukan karakter di posisi saat ini (Anti-Push).",
        Value = false,
        Callback = function(state)
            Features.FreezePlayer(state)
            
            if state then
                WindUI:Notify({ 
                    Title = "Player Frozen", 
                    Content = "Posisi dikunci (Anchored).", 
                    Duration = 2, 
                    Icon = "lock" 
                })
            else
                WindUI:Notify({ 
                    Title = "Player Unfrozen", 
                    Content = "Gerakan kembali normal.", 
                    Duration = 2, 
                    Icon = "unlock" 
                })
            end
        end
    }))

    -- ABILITIES SECTION
    local ability = player:Section({
        Title = "Abilities",
        TextSize = 20,
    })

    local infjump = Reg("infj", ability:Toggle({
        Title = "Infinite Jump",
        Value = false,
        Callback = function(state)
            Features.InfiniteJump(state)
            if state then
                WindUI:Notify({ Title = "Infinite Jump ON!", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "Infinite Jump OFF!", Duration = 3, Icon = "check" })
            end
        end
    }))

    local noclip = Reg("nclip", ability:Toggle({
        Title = "No Clip",
        Value = false,
        Callback = function(state)
            Features.NoClip(state)
            if state then
                WindUI:Notify({ Title = "No Clip ON!", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "No Clip OFF!", Duration = 3, Icon = "x" })
            end
        end
    }))

    local flytog = Reg("flym", ability:Toggle({
        Title = "Fly Mode",
        Value = false,
        Callback = function(state)
            Features.FlyMode(state)
            if state then
                WindUI:Notify({ Title = "Fly Mode ON!", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "Fly Mode OFF!", Duration = 3, Icon = "x" })
            end
        end
    }))

    local walkon = Reg("walkwat", ability:Toggle({
        Title = "Walk on Water",
        Value = false,
        Callback = function(state)
            Features.WalkOnWater(state)
            if state then
                WindUI:Notify({ Title = "Walk on Water ON!", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "Walk on Water OFF!", Duration = 3, Icon = "x" })
            end
        end
    }))

    -- OTHER SECTION
    local other = player:Section({
        Title = "Other",
        TextSize = 20,
    })

    local customName = "SynceHub"
    local customLevel = "Lvl. 969"

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

    local hideusn = Reg("hideallusr", other:Toggle({
        Title = "Hide All Usernames (Streamer Mode)",
        Value = false,
        Callback = function(state)
            Features.HideAllUsernames(state, customName, customLevel)
            
            if state then
                WindUI:Notify({ Title = "Hide Name ON", Content = "Nama & Level disamarkan.", Duration = 3, Icon = "eye-off" })
            else
                WindUI:Notify({ Title = "Hide Name OFF", Content = "Tampilan dikembalikan.", Duration = 3, Icon = "eye" })
            end
        end
    }))

    local espplay = Reg("esp", other:Toggle({
        Title = "Player ESP",
        Value = false,
        Callback = function(state)
            Features.PlayerESP(state)
            if state then
                WindUI:Notify({ Title = "ESP Aktif", Duration = 3, Icon = "eye" })
            else
                WindUI:Notify({ Title = "ESP Nonaktif", Content = "Semua marker ESP dihapus.", Duration = 3, Icon = "eye-off" })
            end
        end
    }))

    local respawnin = other:Button({
        Title = "Reset Character (In Place)",
        Icon = "refresh-cw",
        Callback = function()
            local success = Features.ResetCharacterInPlace()
            if success then
                WindUI:Notify({ Title = "Character Reset Sukses!", Content = "Kamu direspawn di posisi yang sama ✅", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "Gagal Reset", Content = "Karakter tidak ditemukan!", Duration = 3, Icon = "x" })
            end
        end
    })
end

return TabContent

--[[
    SynceHub - Fish It
    Tab Content (Frontend UI)
    
    PART 2/3 - Fishing Tab
]]

-- ========================================
-- FISHING TAB
-- ========================================
function TabContent.BuildFishingTab()
    local farm = Window:Tab({
        Title = "Fishing",
        Icon = "fish",
        Locked = false,
    })

    -- AUTO FISHING SECTION
    local autofish = farm:Section({
        Title = "Auto Fishing",
        TextSize = 20,
        FontWeight = Enum.FontWeight.SemiBold,
    })

    -- Variables untuk Auto Fishing
    local SPEED_LEGIT = 0.05
    local normalCompleteDelay = 1.50
    local blatantLoopInterval = 1.715
    local blatantCompleteDelay = 3.055
    local blatantCancelDelay = 0.3

    -- Legit Mode
    local slidlegit = Reg("klikd", autofish:Slider({
        Title = "Legit Click Speed (Delay)",
        Step = 0.01,
        Value = { Min = 0.01, Max = 0.5, Default = SPEED_LEGIT },
        Callback = function(value)
            SPEED_LEGIT = value
        end
    }))

    local toglegit = Reg("legit", autofish:Toggle({
        Title = "Auto Fish (Legit)",
        Value = false,
        Callback = function(state)
            local success = Features.AutoFishLegit(state, SPEED_LEGIT)
            if not success then return false end
            
            if state then
                WindUI:Notify({ Title = "Auto Fish Legit ON!", Content = "Auto-Equip Protection Active.", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "Auto Fish Legit OFF!", Duration = 3, Icon = "x" })
            end
        end
    }))

    farm:Divider()
    
    -- Normal Mode
    local NormalInstantSlider = Reg("normalslid", autofish:Slider({
        Title = "Normal Complete Delay",
        Step = 0.05,
        Value = { Min = 0.5, Max = 5.0, Default = normalCompleteDelay },
        Callback = function(value) 
            normalCompleteDelay = value 
        end
    }))

    local normalins = Reg("tognorm", autofish:Toggle({
        Title = "Normal Instant Fish",
        Value = false,
        Callback = function(state)
            local success = Features.AutoFishNormal(state, normalCompleteDelay)
            if not success then return end
            
            if state then
                WindUI:Notify({ Title = "Auto Fish ON", Content = "Auto-Equip Protection Active.", Duration = 3, Icon = "fish" })
            else
                WindUI:Notify({ Title = "Auto Fish OFF", Duration = 3, Icon = "x" })
            end
        end
    }))

    -- Blatant Mode
    local blatant = farm:Section({ 
        Title = "Blatant Mode", 
        TextSize = 20 
    })

    local LoopIntervalInput = Reg("blatantint", blatant:Input({
        Title = "Blatant Interval", 
        Value = tostring(blatantLoopInterval), 
        Icon = "fast-forward", 
        Type = "Input", 
        Placeholder = "1.58",
        Callback = function(input)
            local newInterval = tonumber(input)
            if newInterval and newInterval >= 0.5 then 
                blatantLoopInterval = newInterval 
            end
        end
    }))

    local CompleteDelayInput = Reg("blatantcom", blatant:Input({
        Title = "Complete Delay", 
        Value = tostring(blatantCompleteDelay), 
        Icon = "loader", 
        Type = "Input", 
        Placeholder = "2.75",
        Callback = function(input)
            local newDelay = tonumber(input)
            if newDelay and newDelay >= 0.5 then 
                blatantCompleteDelay = newDelay 
            end
        end
    }))

    local CancelDelayInput = Reg("blatantcanc", blatant:Input({
        Title = "Cancel Delay", 
        Value = tostring(blatantCancelDelay), 
        Icon = "clock", 
        Type = "Input", 
        Placeholder = "0.3",
        Callback = function(input)
            local newDelay = tonumber(input)
            if newDelay and newDelay >= 0.1 then 
                blatantCancelDelay = newDelay 
            end
        end
    }))

    local togblat = Reg("blatantt", blatant:Toggle({
        Title = "Instant Fishing (Blatant)",
        Value = false,
        Callback = function(state)
            local success = Features.AutoFishBlatant(state, blatantLoopInterval, blatantCompleteDelay, blatantCancelDelay)
            if not success then return end
            
            if state then
                WindUI:Notify({ Title = "Blatant Mode ON", Duration = 3, Icon = "zap" })
            else
                WindUI:Notify({ Title = "Stopped", Duration = 2 })
            end
        end
    }))

    farm:Divider()

    -- FISHING AREA SECTION
    local areafish = farm:Section({
        Title = "Fishing Area",
        TextSize = 20,
    })

    local AreaNames = {}
    for name, _ in pairs(Features.Constants.FishingAreas) do
        table.insert(AreaNames, name)
    end

    local selectedArea = nil

    local choosearea = areafish:Dropdown({
        Title = "Choose Area",
        Values = AreaNames,
        AllowNone = true,
        Value = nil,
        Callback = function(option)
            selectedArea = option
        end
    })

    local freezeToggle = areafish:Toggle({
        Title = "Teleport & Freeze at Area (Fix Server Lag)",
        Desc = "Teleport -> Tunggu Sync Server -> Freeze.",
        Value = false,
        Callback = function(state)
            if state then
                if not selectedArea then
                    WindUI:Notify({ 
                        Title = "Aksi Gagal", 
                        Content = "Pilih Area dulu di Dropdown!", 
                        Duration = 3, 
                        Icon = "alert-triangle" 
                    })
                    if freezeToggle and freezeToggle.Set then 
                        freezeToggle:Set(false) 
                    end
                    return
                end
                
                local success = Features.TeleportAndFreeze(true, selectedArea)
                if not success then
                    WindUI:Notify({ 
                        Title = "Aksi Gagal", 
                        Duration = 3, 
                        Icon = "alert-triangle" 
                    })
                    if freezeToggle and freezeToggle.Set then 
                        freezeToggle:Set(false) 
                    end
                    return
                end
                
                WindUI:Notify({ 
                    Title = "Ready to Fish", 
                    Content = "Posisi dikunci & Zona terupdate.", 
                    Duration = 2, 
                    Icon = "check" 
                })
            else
                Features.TeleportAndFreeze(false)
                WindUI:Notify({ 
                    Title = "Unfrozen", 
                    Content = "Gerakan kembali normal.", 
                    Duration = 2, 
                    Icon = "unlock" 
                })
            end
        end
    })

    local teleto = areafish:Button({
        Title = "Teleport to Choosen Area",
        Icon = "corner-down-right",
        Callback = function()
            if not selectedArea then
                WindUI:Notify({ 
                    Title = "Teleport Gagal", 
                    Content = "Pilih Area dulu di Dropdown.", 
                    Duration = 3, 
                    Icon = "alert-triangle" 
                })
                return
            end

            if Features.State.IsTeleportFreezeActive and freezeToggle then
                freezeToggle:Set(false)
                task.wait(0.1)
            end
            
            Features.TeleportToArea(selectedArea)
        end
    })

    farm:Divider()

    local savepos = areafish:Button({
        Title = "Save Current Position",
        Icon = "map-pin",
        Callback = function()
            local success = Features.SaveCurrentPosition()
            if success then
                WindUI:Notify({
                    Title = "Posisi Disimpan!",
                    Duration = 3,
                    Icon = "save",
                })
            else
                WindUI:Notify({ 
                    Title = "Gagal Simpan", 
                    Duration = 3, 
                    Icon = "x" 
                })
            end
        end
    })

    local teletosave = areafish:Button({
        Title = "Teleport to SAVED Pos",
        Icon = "navigation",
        Callback = function()
            if not Features.State.SavedPosition then
                WindUI:Notify({ 
                    Title = "Teleport Gagal", 
                    Content = "Belum ada posisi yang disimpan.", 
                    Duration = 3, 
                    Icon = "alert-triangle" 
                })
                return
            end
            
            if Features.State.IsTeleportFreezeActive and freezeToggle then
                freezeToggle:Set(false)
                task.wait(0.1)
            end
            
            Features.TeleportToLookAt(Features.State.SavedPosition.Pos, Features.State.SavedPosition.Look)
        end
    })
end

--[[
    SynceHub - Fish It
    Tab Content (Frontend UI)
    
    PART 3/3 - Automatic Tab (Auto Sell & Auto Favorite)
]]

-- ========================================
-- AUTOMATIC TAB
-- ========================================
function TabContent.BuildAutomaticTab()
    local automatic = Window:Tab({
        Title = "Automatic",
        Icon = "loader",
        Locked = false,
    })

    -- AUTO SELL SECTION
    local sellall = automatic:Section({ 
        Title = "Autosell Fish", 
        TextSize = 20 
    })

    local autoSellMethod = "Delay"
    local autoSellValue = 50

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
            
            if Features.State.AutoSellState then
                Features.AutoSell(true, autoSellMethod, autoSellValue)
            end
        end
    })

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

    local CurrentCountDisplay = sellall:Paragraph({ 
        Title = "Current Fish Count: 0", 
        Icon = "package" 
    })
    
    task.spawn(function() 
        while true do 
            if CurrentCountDisplay and Features.GetPlayerDataReplion() then 
                local count = Features.GetFishCount() 
                CurrentCountDisplay:SetTitle("Current Fish Count: " .. tostring(count)) 
            end 
            task.wait(1) 
        end 
    end)

    local togSell = Reg("tsell", sellall:Toggle({
        Title = "Enable Auto Sell",
        Desc = "Menjalankan auto sell sesuai metode di atas.",
        Value = false,
        Callback = function(state)
            if state then
                if not Features.Remotes.RF_SellAllItems then
                    WindUI:Notify({ 
                        Title = "Error", 
                        Content = "Remote Sell tidak ditemukan.", 
                        Duration = 3, 
                        Icon = "x" 
                    })
                    return false
                end
                
                local msg = (autoSellMethod == "Delay") and ("Setiap " .. autoSellValue .. " detik.") or ("Saat jumlah >= " .. autoSellValue)
                WindUI:Notify({ 
                    Title = "Auto Sell ON (" .. autoSellMethod .. ")", 
                    Content = msg, 
                    Duration = 3, 
                    Icon = "check" 
                })
                
                Features.AutoSell(true, autoSellMethod, autoSellValue)
            else
                WindUI:Notify({ 
                    Title = "Auto Sell OFF", 
                    Duration = 3, 
                    Icon = "x" 
                })
                Features.AutoSell(false)
            end
        end
    }))

    -- AUTO FAVORITE/UNFAVORITE SECTION
    local favsec = automatic:Section({ 
        Title = "Auto Favorite / Unfavorite", 
        TextSize = 20 
    })

    local selectedRarities = {}
    local selectedItemNames = {}
    local selectedMutations = {}

    -- Get all item names from ReplicatedStorage
    local function getAutoFavoriteItemOptions()
        local itemNames = {}
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local itemsContainer = ReplicatedStorage:FindFirstChild("Items")

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

    local RarityDropdown = Reg("drer", favsec:Dropdown({
        Title = "by Rarity",
        Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"},
        Multi = true, 
        AllowNone = true, 
        Value = false,
        Callback = function(values) 
            selectedRarities = values or {} 
        end
    }))

    local ItemNameDropdown = Reg("dtem", favsec:Dropdown({
        Title = "by Item Name",
        Values = allItemNames,
        Multi = true, 
        AllowNone = true, 
        Value = false,
        Callback = function(values) 
            selectedItemNames = values or {} 
        end
    }))

    local MutationDropdown = Reg("dmut", favsec:Dropdown({
        Title = "by Mutation",
        Values = {
            "Shiny", "Gemstone", "Corrupt", "Galaxy", "Holographic", 
            "Ghost", "Lightning", "Fairy Dust", "Gold", "Midnight", 
            "Radioactive", "Stone", "Albino", "Sandy", "Acidic", 
            "Disco", "Frozen", "Noob"
        },
        Multi = true, 
        AllowNone = true, 
        Value = false,
        Callback = function(values) 
            selectedMutations = values or {} 
        end
    }))

    local togglefav = Reg("tvav", favsec:Toggle({
        Title = "Enable Auto Favorite",
        Value = false,
        Callback = function(state)
            if state then
                -- Disable unfavorite if favorite is ON
                if Features.State.AutoUnfavoriteState then
                    Features.AutoUnfavorite(false)
                    local unfavToggle = automatic:GetElementByTitle("Enable Auto Unfavorite")
                    if unfavToggle and unfavToggle.Set then 
                        unfavToggle:Set(false) 
                    end
                end

                if not Features.GetPlayerDataReplion() then 
                    WindUI:Notify({ 
                        Title = "Error", 
                        Content = "Gagal memuat data Replion.", 
                        Duration = 3, 
                        Icon = "x" 
                    }) 
                    return false 
                end
                
                WindUI:Notify({ 
                    Title = "Auto Favorite ON!", 
                    Duration = 3, 
                    Icon = "check" 
                })
                
                Features.AutoFavorite(true, selectedRarities, selectedItemNames, selectedMutations)
            else
                WindUI:Notify({ 
                    Title = "Auto Favorite OFF!", 
                    Duration = 3, 
                    Icon = "x" 
                })
                Features.AutoFavorite(false)
            end
        end
    }))

    local toggleunfav = Reg("tunfa", favsec:Toggle({
        Title = "Enable Auto Unfavorite",
        Value = false,
        Callback = function(state)
            if state then
                -- Disable favorite if unfavorite is ON
                if Features.State.AutoFavoriteState then
                    Features.AutoFavorite(false)
                    local favToggle = automatic:GetElementByTitle("Enable Auto Favorite")
                    if favToggle and favToggle.Set then 
                        favToggle:Set(false) 
                    end
                end

                if not Features.GetPlayerDataReplion() then 
                    WindUI:Notify({ 
                        Title = "Error", 
                        Content = "Gagal memuat data Replion.", 
                        Duration = 3, 
                        Icon = "x" 
                    }) 
                    return false 
                end
                
                WindUI:Notify({ 
                    Title = "Auto Unfavorite ON!", 
                    Duration = 3, 
                    Icon = "check" 
                })
                
                Features.AutoUnfavorite(true, selectedRarities, selectedItemNames, selectedMutations)
            else
                WindUI:Notify({ 
                    Title = "Auto Unfavorite OFF!", 
                    Duration = 3, 
                    Icon = "x" 
                })
                Features.AutoUnfavorite(false)
            end
        end
    }))
end

return TabContent