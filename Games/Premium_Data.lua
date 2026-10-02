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
        Glow = false
    }

    -- Таблица для хранения объектов отрисовки, чтобы они не засоряли память
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
        
        HomeTab:CreateParagraph({
            Title = "👤 Profile: " .. LocalPlayer.Name,
            Content = "Subscription Plan: Free\nStatus: Authenticated & Secure."
        })
        
        HomeTab:CreateParagraph({
            Title = "💻 System Info",
            Content = "Executor: " .. executorName .. "\nCurrent Game: " .. gameName .. "\nPlace ID: " .. tostring(game.PlaceId)
        })

        HomeTab:CreateSection("Quick Actions")
        
        HomeTab:CreateButton({
            Name = "Rejoin Current Server",
            Callback = function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        })

        HomeTab:CreateButton({
            Name = "Copy Discord Invite",
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/your_invite_code")
                    Window:Notify({Title = "Copied!", Content = "Discord invite copied to clipboard.", Duration = 3})
                end
            end
        })

        -- ==========================================
        -- 🔔 ВКЛАДКА: UPDATES
        -- ==========================================
        UpdatesTab:CreateSection("Latest Version: v1.0.0")

        UpdatesTab:CreateParagraph({
            Title = "Patch Notes - October 2026",
            Content = "✔️ Added Liquid Node Visuals (Drawing API)\n✔️ Added Handshake Key Authentication\n✔️ Improved Server Rejoin logic\n✔️ Patched memory leaks in ESP RenderStepped"
        })

        UpdatesTab:CreateParagraph({
            Title = "Upcoming Features",
            Content = "🔜 Server Hop (Low Ping Matchmaking)\n🔜 Aimbot & FOV Circle\n🔜 Custom Hitboxes"
        })

        -- ==========================================
        -- 👁️ ВКЛАДКА: VISUAL (ESP)
        -- ==========================================
        VisualTab:CreateSection("Main Settings")

        VisualTab:CreateToggle({
            Name = "Master ESP Switch",
            CurrentValue = false,
            Flag = "EspMaster",
            Callback = function(Value)
                ESPSettings.Master = Value
                -- Если выключили, очищаем всё с экрана
                if not Value then
                    for _, obj in pairs(ESP_Objects) do
                        if obj.Tracer then obj.Tracer.Visible = false end
                        if obj.Text then obj.Text.Visible = false end
                    end
                    for _, v in pairs(CoreGui:GetChildren()) do
                        if v.Name:match("^GlobalGlow_") then v:Destroy() end
                    end
                end
            end
        })

        VisualTab:CreateToggle({
            Name = "Enable Tracers (Lines)",
            CurrentValue = false,
            Flag = "EspTracers",
            Callback = function(Value)
                ESPSettings.Tracers = Value
            end
        })

        VisualTab:CreateDropdown({
            Name = "ESP Information Style",
            Options = {"Health & Meters", "Names Only", "Disabled"},
            CurrentOption = {"Health & Meters"},
            MultipleOptions = false,
            Flag = "EspStyle",
            Callback = function(Option)
                ESPSettings.Style = type(Option) == "table" and Option[1] or Option
            end
        })

        VisualTab:CreateSection("Effects")

        VisualTab:CreateToggle({
            Name = "Glowing Players (Chams)",
            CurrentValue = false,
            Flag = "EspGlow",
            Callback = function(Value)
                ESPSettings.Glow = Value
                if not Value then
                    for _, v in pairs(CoreGui:GetChildren()) do
                        if v.Name:match("^GlobalGlow_") then v:Destroy() end
                    end
                end
            end
        })

        -- ==========================================
        -- ⚙️ ДВИЖОК ОТРИСОВКИ (DRAWING API)
        -- ==========================================
        
        -- Функция для создания линий и текста для каждого игрока
        local function GetESPObjects(player)
            if not ESP_Objects[player] then
                ESP_Objects[player] = {
                    Tracer = Drawing.new("Line"),
                    Text = Drawing.new("Text")
                }
                -- Настройки линии
                ESP_Objects[player].Tracer.Thickness = 1.5
                ESP_Objects[player].Tracer.Color = Color3.fromRGB(255, 255, 255)
                ESP_Objects[player].Tracer.Transparency = 0.8
                -- Настройки текста
                ESP_Objects[player].Text.Size = 16
                ESP_Objects[player].Text.Center = true
                ESP_Objects[player].Text.Outline = true
                ESP_Objects[player].Text.Color = Color3.fromRGB(0, 255, 255)
            end
            return ESP_Objects[player]
        end

        local function ManageGlow(player, character)
            local glowName = "GlobalGlow_" .. player.Name
            local glow = CoreGui:FindFirstChild(glowName)

            if ESPSettings.Glow and ESPSettings.Master then
                if not glow then
                    glow = Instance.new("Highlight")
                    glow.Name = glowName
                    glow.FillColor = Color3.fromRGB(0, 242, 254)
                    glow.OutlineColor = Color3.fromRGB(255, 255, 255)
                    glow.FillTransparency = 0.5
                    glow.OutlineTransparency = 0.1
                    glow.Parent = CoreGui
                end
                glow.Adornee = character
            else
                if glow then glow:Destroy() end
            end
        end

        -- Основной цикл рендера (Выполняется каждый кадр)
        RunService.RenderStepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local objs = GetESPObjects(player)
                    local character = player.Character

                    if ESPSettings.Master and character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                        local hrp = character.HumanoidRootPart
                        local hum = character.Humanoid
                        local head = character:FindFirstChild("Head")

                        -- Проверка, находится ли игрок на экране
                        local Vector, OnScreen = Camera:WorldToViewportPoint(hrp.Position)
                        local HeadVector, HeadOnScreen = Camera:WorldToViewportPoint(head and head.Position or hrp.Position)

                        ManageGlow(player, character)

                        if OnScreen then
                            -- Отрисовка Трейсеров (Линий от низа экрана до игрока)
                            if ESPSettings.Tracers then
                                objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                objs.Tracer.To = Vector2.new(Vector.X, Vector.Y)
                                objs.Tracer.Visible = true
                            else
                                objs.Tracer.Visible = false
                            end

                            -- Отрисовка Текста (Имя, ХП, Дистанция)
                            if ESPSettings.Style ~= "Disabled" then
                                local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                                
                                if ESPSettings.Style == "Health & Meters" then
                                    local hp = math.floor(hum.Health)
                                    objs.Text.Text = string.format("%s [%d HP] [%dm]", player.Name, hp, dist)
                                    -- Меняем цвет в зависимости от ХП
                                    objs.Text.Color = Color3.fromRGB(255 - (hp * 2.55), hp * 2.55, 0)
                                elseif ESPSettings.Style == "Names Only" then
                                    objs.Text.Text = player.Name
                                    objs.Text.Color = Color3.fromRGB(255, 255, 255)
                                end

                                objs.Text.Position = Vector2.new(HeadVector.X, HeadVector.Y - 25)
                                objs.Text.Visible = true
                            else
                                objs.Text.Visible = false
                            end
                        else
                            -- Если игрок за спиной камеры — прячем
                            objs.Tracer.Visible = false
                            objs.Text.Visible = false
                        end
                    else
                        -- Если Мастер-Свитч выключен или игрок мертв
                        objs.Tracer.Visible = false
                        objs.Text.Visible = false
                        ManageGlow(player, nil)
                    end
                end
            end
        end)

        -- Защита от утечки памяти (Удаляем объекты, когда игрок выходит)
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
