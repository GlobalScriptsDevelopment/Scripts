-- [[ Payload Script | Global Scripts Development ]] --
-- Возвращаем функцию, которую вызовет Лоадер

return function(Env, PassedKey)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local MarketplaceService = game:GetService("MarketplaceService")
    
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Наш настоящий ключ
    local ExpectedKey = "Global-Scripts-2026-Gen2-2fhjg42cmb053nffas"

    -- [[ 1. ПРОВЕРКА КЛЮЧА ]] --
    if PassedKey ~= ExpectedKey then
        LocalPlayer:Kick("\n[Global Scripts]\nInvalid Authentication Key.\nNice try, but you are not authorized.")
        return
    end

    -- [[ 2. ГЛОБАЛЬНЫЕ НАСТРОЙКИ И ДАННЫЕ ]] --
    local ESPSettings = {
        Master = false,
        Tracers = false,
        Style = "Health & Meters", 
        Glow = false,
        -- Цвета
        TracerColor = Color3.fromRGB(255, 255, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        GlowColor = Color3.fromRGB(0, 242, 254),
        FadeSpeed = 0.1,
        -- Радуга
        RainbowMode = false,
        RainbowSpeed = 1
    }

    local ESP_Objects = {}

    local executorName = type(identifyexecutor) == "function" and identifyexecutor() or "Unknown Executor"
    local gameName = "Loading..."
    pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

    -- [[ 3. ОСНОВНАЯ ФУНКЦИЯ СКРИПТА ]] --
    local function TheScript()
        local HomeTab = Env.TabHome
        local UpdatesTab = Env.TabUpdates
        local VisualTab = Env.TabVisual
        local Window = Env.Window

        -- ==========================================
        -- 🏠 ВКЛАДКА: HOME
        -- ==========================================
        HomeTab:CreateSection("User Information")
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

        HomeTab:CreateSection("Quick Actions")
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
        UpdatesTab:CreateSection("Latest Version: v1.2.0")
        UpdatesTab:CreateDivider({ line = false, spacing = 2 })

        UpdatesTab:CreateText({
            name = "Patch Notes - October 2026",
            text = "✔️ Added Rainbow ESP with Speed Slider\n✔️ Reduced UI Spacing for a cleaner look\n✔️ Added Liquid Node Visuals (Drawing API)\n✔️ Added Smooth Fade In/Out for ESP"
        })

        -- ==========================================
        -- 👁️ ВКЛАДКА: VISUAL (ESP)
        -- ==========================================
        VisualTab:CreateSection("Main Settings")
        VisualTab:CreateDivider({ line = false, spacing = 2 })

        VisualTab:CreateToggle({
            name = "Master ESP Switch",
            currentValue = false,
            flag = "EspMaster",
            callback = function(Value)
                ESPSettings.Master = Value
            end
        })

        VisualTab:CreateDivider({ line = false, spacing = 4 })

        VisualTab:CreateToggle({
            name = "Enable Tracers (Lines)",
            currentValue = false,
            flag = "EspTracers",
            callback = function(Value)
                ESPSettings.Tracers = Value
            end
        })

        VisualTab:CreateDropdown({
            name = "ESP Information Style",
            options = {"Health & Meters", "Names Only", "Disabled"},
            currentOption = {"Health & Meters"},
            multipleOptions = false,
            flag = "EspStyle",
            callback = function(Option)
                ESPSettings.Style = type(Option) == "table" and Option[1] or Option
            end
        })

        VisualTab:CreateToggle({
            name = "Glowing Players (Chams)",
            currentValue = false,
            flag = "EspGlow",
            callback = function(Value)
                ESPSettings.Glow = Value
            end
        })

        VisualTab:CreateDivider({ line = true, spacing = 6 })
        VisualTab:CreateSection("Colors & Rainbow")
        VisualTab:CreateDivider({ line = false, spacing = 2 })

        -- Радужный режим
        VisualTab:CreateToggle({
            name = "Enable Rainbow ESP",
            currentValue = false,
            flag = "EspRainbow",
            callback = function(Value)
                ESPSettings.RainbowMode = Value
            end
        })

        -- Слайдер скорости радуги
        VisualTab:CreateSlider({
            name = "Rainbow Speed",
            range = {0.1, 5},
            increment = 0.1,
            suffix = "x",
            currentValue = 1,
            flag = "EspRainbowSpeed",
            callback = function(Value)
                ESPSettings.RainbowSpeed = Value
            end
        })

        VisualTab:CreateDivider({ line = false, spacing = 4 })

        VisualTab:CreateColorPicker({
            name = "Tracer Color",
            color = ESPSettings.TracerColor,
            flag = "TracerColorPicker",
            callback = function(color, alpha)
                ESPSettings.TracerColor = color
            end
        })

        VisualTab:CreateColorPicker({
            name = "Text Color",
            color = ESPSettings.TextColor,
            flag = "TextColorPicker",
            callback = function(color, alpha)
                ESPSettings.TextColor = color
            end
        })

        VisualTab:CreateColorPicker({
            name = "Glow Color",
            color = ESPSettings.GlowColor,
            flag = "GlowColorPicker",
            callback = function(color, alpha)
                ESPSettings.GlowColor = color
            end
        })

        -- ==========================================
        -- ⚙️ ДВИЖОК ОТРИСОВКИ (SMOOTH DRAWING API)
        -- ==========================================
        
        local function GetESPObjects(player)
            if not ESP_Objects[player] then
                ESP_Objects[player] = {
                    Tracer = Drawing.new("Line"),
                    Text = Drawing.new("Text"),
                    Alpha = 0
                }
                ESP_Objects[player].Tracer.Thickness = 1.5
                ESP_Objects[player].Text.Size = 16
                ESP_Objects[player].Text.Center = true
                ESP_Objects[player].Text.Outline = true
            end
            return ESP_Objects[player]
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
        RunService.RenderStepped:Connect(function()
            -- Генерация текущего цвета радуги на основе времени
            local currentRainbowColor = Color3.fromHSV((tick() * ESPSettings.RainbowSpeed * 0.2) % 1, 1, 1)

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local objs = GetESPObjects(player)
                    local character = player.Character
                    
                    local isVisible = false
                    local Vector, HeadVector

                    if ESPSettings.Master and character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
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
                    objs.Alpha = objs.Alpha + (targetAlpha - objs.Alpha) * ESPSettings.FadeSpeed

                    -- Цвет свечения (Выбираем между радугой и кастомным цветом)
                    local activeGlowColor = ESPSettings.RainbowMode and currentRainbowColor or ESPSettings.GlowColor
                    local glowTargetAlpha = (ESPSettings.Glow and ESPSettings.Master and character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0) and 1 or 0
                    ManageGlow(player, character, glowTargetAlpha, activeGlowColor)

                    if objs.Alpha > 0.01 and Vector and HeadVector then
                        
                        -- ТРЕЙСЕРЫ
                        if ESPSettings.Tracers then
                            objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            objs.Tracer.To = Vector2.new(Vector.X, Vector.Y)
                            objs.Tracer.Color = ESPSettings.RainbowMode and currentRainbowColor or ESPSettings.TracerColor
                            objs.Tracer.Transparency = objs.Alpha * 0.8
                            objs.Tracer.Visible = true
                        else
                            objs.Tracer.Visible = false
                        end

                        -- ТЕКСТ
                        if ESPSettings.Style ~= "Disabled" then
                            local hum = character:FindFirstChild("Humanoid")
                            local hrp = character:FindFirstChild("HumanoidRootPart")
                            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                            
                            if ESPSettings.Style == "Health & Meters" and hum then
                                local hp = math.floor(hum.Health)
                                objs.Text.Text = string.format("%s [%d HP] [%dm]", player.Name, hp, dist)
                                -- Если включена радуга — перекрашиваем в радугу, иначе показываем цвет по здоровью
                                objs.Text.Color = ESPSettings.RainbowMode and currentRainbowColor or Color3.fromRGB(255 - (hp * 2.55), hp * 2.55, 0)
                            elseif ESPSettings.Style == "Names Only" then
                                objs.Text.Text = player.Name
                                objs.Text.Color = ESPSettings.RainbowMode and currentRainbowColor or ESPSettings.TextColor
                            end

                            objs.Text.Position = Vector2.new(HeadVector.X, HeadVector.Y - 25)
                            objs.Text.Transparency = objs.Alpha
                            objs.Text.Visible = true
                        else
                            objs.Text.Visible = false
                        end
                        
                    else
                        -- Оптимизация: прячем объекты, если прозрачность нулевая
                        objs.Tracer.Visible = false
                        objs.Text.Visible = false
                    end
                end
            end
        end)

        -- Очистка кэша (Предотвращает падения FPS при выходе игроков)
        Players.PlayerRemoving:Connect(function(player)
            if ESP_Objects[player] then
                ESP_Objects[player].Tracer:Remove()
                ESP_Objects[player].Text:Remove()
                ESP_Objects[player] = nil
            end
            local glow = CoreGui:FindFirstChild("GlobalGlow_" .. player.Name)
            if glow then glow:Destroy() end
        end)

    end

    -- [[ 4. ЗАПУСК ]] --
    TheScript()

end
