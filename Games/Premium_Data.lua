-- [[ Payload Script | Global Scripts Development ]] --
-- Возвращаем функцию, которую вызовет Лоадер

return function(Env, PassedKey)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Наш настоящий ключ
    local ExpectedKey = "Global-Scripts-2026-Gen2-2fhjg42cmb053nffas"

    -- [[ 1. ПРОВЕРКА КЛЮЧА ]] --
    if PassedKey ~= ExpectedKey then
        local reasontext = [[
You have been kicked for incorrect script key.
An attempt was made to compromise the script, or the script key was empty.
-
!! Upon a second hacking attempt, you will be permanently banned and unable to use the script. !!
]]
        LocalPlayer:Kick(reasontext)
        return
    end

    -- [[ 2. ГЛОБАЛЬНЫЕ НАСТРОЙКИ ESP ]] --
    local ESPSettings = {
        MasterEnabled = false,
        TracersAndStyle = false,
        CurrentStyle = "Skeleton", -- "Skeleton", "3D Box", "Health & Meters"
        GlowAndNames = false
    }

    -- [[ 3. ОСНОВНАЯ ФУНКЦИЯ СКРИПТА ]] --
    local function TheScript()
        local HomeTab = Env.TabHome
        local VisualTab = Env.TabVisual
        
        -- === ЗАПОЛНЯЕМ TAB VISUAL === --

        -- 1. Мастер-переключатель (Главный рубильник ESP)
        VisualTab:CreateToggle({
            name = "Toggle ESP Players (Master Switch)",
            value = false,
            callback = function(Value)
                ESPSettings.MasterEnabled = Value
            end
        })

        VisualTab:CreateDivider({ line = true, spacing = 10 })

        -- 2. Переключатель Трейсеров и Стиля
        VisualTab:CreateToggle({
            name = "Enable Tracers & Style",
            value = false,
            callback = function(Value)
                ESPSettings.TracersAndStyle = Value
            end
        })

        -- 3. Выбор стиля отрисовки (Dropdown)
        VisualTab:CreateDropdown({
            name = "ESP Style",
            options = {"Skeleton", "3D Box", "Health & Meters"},
            value = "Skeleton", -- Значение по умолчанию
            multipleOptions = false,
            callback = function(Option)
                -- Option передается как таблица (в Gen 2), извлекаем первое значение
                local selected = type(Option) == "table" and Option[1] or Option
                ESPSettings.CurrentStyle = selected
            end
        })

        VisualTab:CreateDivider({ line = true, spacing = 10 })

        -- 4. Переключатель Свечения (Glow) и Никнеймов
        VisualTab:CreateToggle({
            name = "Glowing Players & Nicknames",
            value = false,
            callback = function(Value)
                ESPSettings.GlowAndNames = Value
                -- Очистка хайлайтов при выключении
                if not Value then
                    for _, v in pairs(CoreGui:GetChildren()) do
                        if v.Name == "GlobalGlow" then v:Destroy() end
                    end
                end
            end
        })
        
        -- === ДВИЖОК ОТРИСОВКИ ESP === --
        
        -- Функция для создания свечения (Highlight)
        local function ManageGlow(player, character)
            if not ESPSettings.MasterEnabled or not ESPSettings.GlowAndNames then return end
            if player == LocalPlayer then return end

            local glow = CoreGui:FindFirstChild("GlobalGlow_" .. player.Name)
            if not glow then
                glow = Instance.new("Highlight")
                glow.Name = "GlobalGlow_" .. player.Name
                glow.FillColor = Color3.fromRGB(0, 255, 255) -- Цвет заливки (Голубой неон)
                glow.OutlineColor = Color3.fromRGB(255, 255, 255)
                glow.FillTransparency = 0.5
                glow.OutlineTransparency = 0.1
                glow.Parent = CoreGui
            end
            glow.Adornee = character
        end

        -- Основной цикл рендера (Работает со скоростью твоего FPS)
        RunService.RenderStepped:Connect(function()
            -- Если Мастер-переключатель выключен, ничего не рисуем
            if not ESPSettings.MasterEnabled then return end

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local hrp = player.Character.HumanoidRootPart
                    local hum = player.Character.Humanoid

                    -- Проверка жив ли игрок
                    if hum.Health > 0 then
                        local Vector, OnScreen = Camera:WorldToViewportPoint(hrp.Position)

                        -- 1. Свечение (Glow)
                        if ESPSettings.GlowAndNames then
                            ManageGlow(player, player.Character)
                        end

                        if OnScreen then
                            -- Здесь в будущем будет Drawing API логика:
                            
                            -- [ПРИМЕР ТРЕЙСЕРОВ]
                            if ESPSettings.TracersAndStyle then
                                -- Логика плавных трейсеров:
                                -- Рисуется линия от Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                -- до Vector2.new(Vector.X, Vector.Y)
                                
                                if ESPSettings.CurrentStyle == "Skeleton" then
                                    -- Отрисовка линий между костями (Голова -> Шея -> Торс -> Руки -> Ноги)
                                elseif ESPSettings.CurrentStyle == "3D Box" then
                                    -- Математика отрисовки 8 точек вокруг модели игрока
                                elseif ESPSettings.CurrentStyle == "Health & Meters" then
                                    -- Расчет дистанции: local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                                    -- Отрисовка полоски здоровья и текста
                                end
                            end
                        end
                    end
                end
            end
        end)
        
    end

    -- [[ 4. ЗАПУСК ]] --
    TheScript()

end
