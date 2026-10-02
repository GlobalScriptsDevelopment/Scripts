-- ==============================================================================
-- [[ GLOBAL SCRIPTS DEVELOPMENT ]]
-- Project: Universal Hub (Payload)
-- Engine: Rayfield Gen 2
-- Version: 1.2.0 (Stable)
-- ==============================================================================

return function(Env, PassedKey)
    -- [[ 1. СИСТЕМНЫЕ СЕРВИСЫ ]]
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local MarketplaceService = game:GetService("MarketplaceService")
    local Stats = game:GetService("Stats")
    
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- [[ 2. АУТЕНТИФИКАЦИЯ (HANDSHAKE) ]]
    local ExpectedKey = "Global-Scripts-2026-Gen2-2fhjg42cmb053nffas"

    if PassedKey ~= ExpectedKey then
        LocalPlayer:Kick("\n[Global Scripts]\nInvalid Authentication Key.\nNice try, but you are not authorized.")
        return
    end

    -- [[ 3. ГЛОБАЛЬНАЯ БАЗА ДАННЫХ (STATE) ]]
    local GlobalState = {
        ESP = {
            Master = false,
            Tracers = false,
            Style = "Health & Meters", 
            Glow = false,
            TracerColor = Color3.fromRGB(255, 255, 255),
            TextColor = Color3.fromRGB(255, 255, 255),
            GlowColor = Color3.fromRGB(0, 242, 254),
            FadeSpeed = 0.1,
            RainbowMode = false,
            RainbowSpeed = 1
        },
        Connections = {}, -- Для хранения эвентов, чтобы их можно было выгрузить (Unload)
        Objects = {}      -- Для хранения элементов Drawing
    }

    -- [[ 4. СБОР ИНФОРМАЦИИ ОБ ОКРУЖЕНИИ ]]
    local executorName = type(identifyexecutor) == "function" and identifyexecutor() or "Unknown Executor"
    local gameName = "Loading..."
    pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

    -- [[ 5. ЯДРО ИНТЕРФЕЙСА ]]
    local function TheScript()
        local Window = Env.Window
        local HomeTab = Env.TabHome
        local UpdatesTab = Env.TabUpdates
        local VisualTab = Env.TabVisual
        local SettingsTab = Env.TabSettings

        -- ==========================================
        -- 🏠 ВКЛАДКА: HOME
        -- ==========================================
        HomeTab:CreateDivider({ line = true, spacing = 10 })
        HomeTab:CreateSection({ name = "User Information" })
        HomeTab:CreateDivider({ line = false, spacing = 2 })
        
        HomeTab:CreateText({
            name = "👤 Profile: " .. LocalPlayer.Name,
            text = "Subscription Plan: Premium\nStatus: Authenticated & Secure."
        })
        
        HomeTab:CreateDivider({ line = true, spacing = 4 })
        
        HomeTab:CreateText({
            name = "💻 System Info",
            text = "Executor: " .. executorName .. "\nCurrent Game: " .. gameName .. "\nPlace ID: " .. tostring(game.PlaceId)
        })

        HomeTab:CreateDivider({ line = true, spacing = 6 })

        HomeTab:CreateSection({ name = "Quick Actions" })
        HomeTab:CreateDivider({ line = false, spacing = 2 })
        
        HomeTab:CreateButton({
            name = "Rejoin Current Server",
            callback = function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        })

        HomeTab:CreateDivider({ line = false, spacing = 2 })

        HomeTab:CreateButton({
            name = "Copy Discord Invite",
            callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/your_invite_code")
                    Window:Notify({title = "Copied!", content = "Discord invite copied to clipboard.", duration = 3, icon = ""})
                end
            end
        })

        -- ==========================================
        -- 🔔 ВКЛАДКА: UPDATES
        -- ==========================================
        UpdatesTab:CreateDivider({ line = true, spacing = 10 })
        UpdatesTab:CreateSection({ name = "Latest Version: v1.2.0" })
        UpdatesTab:CreateDivider({ line = false, spacing = 2 })

        UpdatesTab:CreateText({
            name = "Patch Notes - October 2026",
            text = "✔️ Fixed CreateSection strict syntax\n✔️ Added Script Unload & UI Keybinds\n✔️ Added Rainbow ESP with Speed Slider\n✔️ Reduced UI Spacing for a cleaner look\n✔️ Smooth Fade In/Out for ESP Engine"
        })

        -- ==========================================
        -- 👁️ ВКЛАДКА: VISUAL (ESP)
        -- ==========================================
        VisualTab:CreateDivider({ line = true, spacing = 10 })
        VisualTab:CreateSection({ name = "Main Settings" })
        VisualTab:CreateDivider({ line = false, spacing = 2 })

        VisualTab:CreateToggle({
            name = "Master ESP Switch",
            currentValue = false,
            flag = "EspMaster",
            callback = function(Value)
                GlobalState.ESP.Master = Value
            end
        })

        VisualTab:CreateDivider({ line = false, spacing = 4 })

        VisualTab:CreateToggle({
            name = "Enable Tracers (Lines)",
            currentValue = false,
            flag = "EspTracers",
            callback = function(Value)
                GlobalState.ESP.Tracers = Value
            end
        })

        VisualTab:CreateDropdown({
            name = "ESP Information Style",
            options = {"Health & Meters", "Names Only", "Disabled"},
            currentOption = {"Health & Meters"},
            multipleOptions = false,
            flag = "EspStyle",
            callback = function(Option)
                GlobalState.ESP.Style = type(Option) == "table" and Option[1] or Option
            end
        })

        VisualTab:CreateToggle({
            name = "Glowing Players (Chams)",
            currentValue = false,
            flag = "EspGlow",
            callback = function(Value)
                GlobalState.ESP.Glow = Value
            end
        })

        VisualTab:CreateDivider({ line = true, spacing = 6 })
        VisualTab:CreateSection({ name = "Colors & Rainbow" })
        VisualTab:CreateDivider({ line = false, spacing = 2 })

        VisualTab:CreateToggle({
            name = "Enable Rainbow ESP",
            currentValue = false,
            flag = "EspRainbow",
            callback = function(Value)
                GlobalState.ESP.RainbowMode = Value
            end
        })

        VisualTab:CreateSlider({
            name = "Rainbow Speed",
            range = {0.1, 5},
            increment = 0.1,
            suffix = "x",
            currentValue = 1,
            flag = "EspRainbowSpeed",
            callback = function(Value)
                GlobalState.ESP.RainbowSpeed = Value
            end
        })

        VisualTab:CreateDivider({ line = false, spacing = 4 })

        VisualTab:CreateColorPicker({
            name = "Tracer Color",
            color = GlobalState.ESP.TracerColor,
            flag = "TracerColorPicker",
            callback = function(color, alpha)
                GlobalState.ESP.TracerColor = color
            end
        })

        VisualTab:CreateColorPicker({
            name = "Text Color",
            color = GlobalState.ESP.TextColor,
            flag = "TextColorPicker",
            callback = function(color, alpha)
                GlobalState.ESP.TextColor = color
            end
        })

        VisualTab:CreateColorPicker({
            name = "Glow Color",
            color = GlobalState.ESP.GlowColor,
            flag = "GlowColorPicker",
            callback = function(color, alpha)
                GlobalState.ESP.GlowColor = color
            end
        })

        -- ==========================================
        -- ⚙️ ВКЛАДКА: SETTINGS (НАСТРОЙКИ СКРИПТА)
        -- ==========================================
        SettingsTab:CreateDivider({ line = true, spacing = 10 })
        SettingsTab:CreateSection({ name = "Menu Configuration" })
        SettingsTab:CreateDivider({ line = false, spacing = 2 })

        SettingsTab:CreateKeybind({
            name = "Toggle Menu UI",
            currentKeybind = "RightShift",
            holdToInteract = false,
            flag = "UIToggleBind",
            callback = function(Keybind)
                -- Встроенная функция Rayfield для скрытия/показа меню (если поддерживается)
                -- Либо можно оставить пустой коллбэк, Rayfield часто биндит это сам внутри ядра
            end
        })

        SettingsTab:CreateDivider({ line = true, spacing = 10 })
        SettingsTab:CreateSection({ name = "Script Management" })
        SettingsTab:CreateDivider({ line = false, spacing = 2 })

        SettingsTab:CreateButton({
            name = "⚠️ Unload Script",
            callback = function()
                -- Удаляем все линии и текст
                for _, obj in pairs(GlobalState.Objects) do
                    if obj.Tracer then obj.Tracer:Remove() end
                    if obj.Text then obj.Text:Remove() end
                end
                -- Очищаем хайлайты
                for _, v in pairs(CoreGui:GetChildren()) do
                    if v.Name:match("^GlobalGlow_") then v:Destroy() end
                end
                -- Отключаем все циклы
                for _, connection in pairs(GlobalState.Connections) do
                    connection:Disconnect()
                end
                -- Уничтожаем интерфейс Rayfield
                Rayfield:Destroy()
            end
        })

        -- ==========================================
        -- 🧠 ДВИЖОК ОТРИСОВКИ (SMOOTH DRAWING API)
        -- ==========================================
        
        local function GetESPObjects(player)
            if not GlobalState.Objects[player] then
                GlobalState.Objects[player] = {
                    Tracer = Drawing.new("Line"),
                    Text = Drawing.new("Text"),
                    Alpha = 0
                }
                GlobalState.Objects[player].Tracer.Thickness = 1.5
                GlobalState.Objects[player].Text.Size = 16
                GlobalState.Objects[player].Text.Center = true
                GlobalState.Objects[player].Text.Outline = true
            end
            return GlobalState.Objects[player]
        end

        local function ManageGlow(player, character, targetAlpha, currentColor)
            local glowName = "GlobalGlow_" .. player.Name
            local glow = CoreGui:FindFirstChild(glowName)

            if targetAlpha > 0.01 then
                if not glow then
                    glow = Instance.new("Highlight")
                    glow.Name = glowName
                    glow.Parent = CoreGui
                end
                glow.Adornee = character
                glow.FillColor = currentColor
                glow.OutlineColor = Color3.fromRGB(255, 255, 255)
                
                glow.FillTransparency = 1 - (0.5 * targetAlpha)
                glow.OutlineTransparency = 1 - (0.9 * targetAlpha)
            else
                if glow then glow:Destroy() end
            end
        end

        -- Основной цикл рендера
        local renderConnection = RunService.RenderStepped:Connect(function()
            local currentRainbowColor = Color3.fromHSV((tick() * GlobalState.ESP.RainbowSpeed * 0.2) % 1, 1, 1)

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local objs = GetESPObjects(player)
                    local character = player.Character
                    
                    local isVisible = false
                    local Vector, HeadVector

                    if GlobalState.ESP.Master and character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                        local hrp = character.HumanoidRootPart
                        local head = character:FindFirstChild("Head")
                        
                        local OnScreen
                        Vector, OnScreen = Camera:WorldToViewportPoint(hrp.Position)
                        HeadVector, _ = Camera:WorldToViewportPoint(head and head.Position or hrp.Position)
                        
                        if OnScreen then
                            isVisible = true
                        end
                    end

                    -- Плавность (Lerp)
                    local targetAlpha = isVisible and 1 or 0
                    objs.Alpha = objs.Alpha + (targetAlpha - objs.Alpha) * GlobalState.ESP.FadeSpeed

                    -- Отрисовка Glow
                    local activeGlowColor = GlobalState.ESP.RainbowMode and currentRainbowColor or GlobalState.ESP.GlowColor
                    local glowTargetAlpha = (GlobalState.ESP.Glow and GlobalState.ESP.Master and character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0) and 1 or 0
                    ManageGlow(player, character, glowTargetAlpha, activeGlowColor)

                    -- Отрисовка Drawing API
                    if objs.Alpha > 0.01 and Vector and HeadVector then
                        
                        -- Трейсеры
                        if GlobalState.ESP.Tracers then
                            objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            objs.Tracer.To = Vector2.new(Vector.X, Vector.Y)
                            objs.Tracer.Color = GlobalState.ESP.RainbowMode and currentRainbowColor or GlobalState.ESP.TracerColor
                            objs.Tracer.Transparency = objs.Alpha * 0.8
                            objs.Tracer.Visible = true
                        else
                            objs.Tracer.Visible = false
                        end

                        -- Текст
                        if GlobalState.ESP.Style ~= "Disabled" then
                            local hum = character:FindFirstChild("Humanoid")
                            local hrp = character:FindFirstChild("HumanoidRootPart")
                            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                            
                            if GlobalState.ESP.Style == "Health & Meters" and hum then
                                local hp = math.floor(hum.Health)
                                objs.Text.Text = string.format("%s [%d HP] [%dm]", player.Name, hp, dist)
                                objs.Text.Color = GlobalState.ESP.RainbowMode and currentRainbowColor or Color3.fromRGB(255 - (hp * 2.55), hp * 2.55, 0)
                            elseif GlobalState.ESP.Style == "Names Only" then
                                objs.Text.Text = player.Name
                                objs.Text.Color = GlobalState.ESP.RainbowMode and currentRainbowColor or GlobalState.ESP.TextColor
                            end

                            objs.Text.Position = Vector2.new(HeadVector.X, HeadVector.Y - 25)
                            objs.Text.Transparency = objs.Alpha
                            objs.Text.Visible = true
                        else
                            objs.Text.Visible = false
                        end
                        
                    else
                        objs.Tracer.Visible = false
                        objs.Text.Visible = false
                    end
                end
            end
        end)

        -- Добавляем коннекшн в память, чтобы скрипт мог остановить его при нажатии Unload
        table.insert(GlobalState.Connections, renderConnection)

        local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
            if GlobalState.Objects[player] then
                GlobalState.Objects[player].Tracer:Remove()
                GlobalState.Objects[player].Text:Remove()
                GlobalState.Objects[player] = nil
            end
            local glow = CoreGui:FindFirstChild("GlobalGlow_" .. player.Name)
            if glow then glow:Destroy() end
        end)
        
        table.insert(GlobalState.Connections, playerRemovingConnection)

    end

    -- [[ 6. ЗАПУСК ]] --
    TheScript()

end
