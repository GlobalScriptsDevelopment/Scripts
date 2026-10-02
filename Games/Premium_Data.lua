-- ==============================================================================
-- [[ GLOBAL SCRIPTS DEVELOPMENT ]]
-- Project: Universal Hub (Payload)
-- Engine: Rayfield Gen 2
-- Version: 1.3.0 (Aimbot & Unload Update)
-- ==============================================================================

return function(Env, PassedKey)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local MarketplaceService = game:GetService("MarketplaceService")
    local UserInputService = game:GetService("UserInputService")
    local TeleportService = game:GetService("TeleportService")

    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local ExpectedKey = "Global-Scripts-2026-Gen2-2fhjg42cmb053nffas"

    if PassedKey ~= ExpectedKey then
        LocalPlayer:Kick("\n[Global Scripts]\nInvalid Authentication Key.\nNice try, but you are not authorized.")
        return
    end

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
        Aim = {
            Enabled = false,
            ShowFOV = true,
            FOV = 120,
            Smooth = 25,
            MaxDist = 500,
            Mode = "Single (Closest to Cursor)",
            Part = "Head",
            Activation = "Hold RMB",
            VisibleOnly = true,
            TeamCheck = true,
            ToggleKey = false,
            Holding = false
        },
        Connections = {},
        Objects = {}
    }

    local executorName = type(identifyexecutor) == "function" and identifyexecutor() or "Unknown Executor"
    local gameName = "Loading..."
    pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

    local function TheScript()
        local Window = Env.Window
        local GetIcon = Env.GetIcon

        local HomeTab = Env.TabHome
        local UpdatesTab = Env.TabUpdates
        local VisualTab = Env.TabVisual
        local AimTab = Env.TabAim
        local SettingsTab = Env.TabSettings

        -- ==========================================
        -- 🏠 ВКЛАДКА: HOME
        -- ==========================================
        HomeTab:CreateDivider({ line = true, spacing = 10 })
        HomeTab:CreateSection({ name = "User Information", icon = GetIcon("SectionInfo.png") })
        HomeTab:CreateDivider({ line = false, spacing = 2 })

        HomeTab:CreateText({
            name = "Profile: " .. LocalPlayer.Name,
            text = "Subscription Plan: Premium\nStatus: Authenticated & Secure.",
            icon = GetIcon("TextInfo.png")
        })

        HomeTab:CreateDivider({ line = true, spacing = 4 })

        HomeTab:CreateText({
            name = "System Info",
            text = "Executor: " .. executorName .. "\nCurrent Game: " .. gameName .. "\nPlace ID: " .. tostring(game.PlaceId),
            icon = GetIcon("TextSafe.png")
        })

        HomeTab:CreateDivider({ line = true, spacing = 6 })

        HomeTab:CreateSection({ name = "Quick Actions", icon = GetIcon("Teleport.png") })
        HomeTab:CreateDivider({ line = false, spacing = 2 })

        HomeTab:CreateButton({
            name = "Rejoin Current Server",
            callback = function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        })

        HomeTab:CreateDivider({ line = false, spacing = 2 })

        HomeTab:CreateButton({
            name = "Copy Discord Invite",
            callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/your_invite_code")
                    Window:Notify({
                        title = "Copied!",
                        content = "Discord invite copied to clipboard.",
                        duration = 3,
                        icon = GetIcon("NotifyCheck.png")
                    })
                end
            end
        })

        -- ==========================================
        -- 🔔 ВКЛАДКА: UPDATES
        -- ==========================================
        UpdatesTab:CreateDivider({ line = true, spacing = 10 })
        UpdatesTab:CreateSection({ name = "Latest Version: v1.3.0", icon = GetIcon("VersionToast.png") })
        UpdatesTab:CreateDivider({ line = false, spacing = 2 })

        UpdatesTab:CreateText({
            name = "Patch Notes - October 2026",
            text = "Added Smooth Aimbot with FOV Circle\nAdded Multiple Target Selection\nAdded Config Tab Icon\nFixed Safe UI Unload Sequence\nRemoved text emojis in favor of custom PNGs",
            icon = GetIcon("TextSafe.png")
        })

        UpdatesTab:CreateDivider({ line = true, spacing = 6 })

        UpdatesTab:CreateText({
            name = "Upcoming Features",
            text = "Server Hop (Low Ping Matchmaking)\nAutoFarm Categories\nConfig Saving System",
            icon = GetIcon("TextWarning.png")
        })

        -- ==========================================
        -- 👁️ ВКЛАДКА: VISUAL (ESP)
        -- ==========================================
        VisualTab:CreateDivider({ line = true, spacing = 10 })
        VisualTab:CreateSection({ name = "Main Settings", icon = GetIcon("Settings.png") })
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
        VisualTab:CreateSection({ name = "Colors & Rainbow", icon = GetIcon("Visual.png") })
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
        -- 🎯 ВКЛАДКА: AIMBOT
        -- ==========================================
        AimTab:CreateDivider({ line = true, spacing = 10 })
        AimTab:CreateSection({ name = "Aimbot Settings", icon = GetIcon("Aim.png") })
        AimTab:CreateDivider({ line = false, spacing = 2 })

        AimTab:CreateToggle({
            name = "Enable Aimbot",
            currentValue = false,
            flag = "AimEnabled",
            callback = function(v) GlobalState.Aim.Enabled = v end
        })

        AimTab:CreateDivider({ line = false, spacing = 2 })

        AimTab:CreateToggle({
            name = "Show FOV Circle",
            currentValue = true,
            flag = "AimShowFov",
            callback = function(v) GlobalState.Aim.ShowFOV = v end
        })

        AimTab:CreateDivider({ line = false, spacing = 4 })

        AimTab:CreateSlider({
            name = "FOV Radius",
            range = {30, 600},
            increment = 5,
            suffix = "px",
            currentValue = 120,
            flag = "AimFov",
            callback = function(v) GlobalState.Aim.FOV = v end
        })

        AimTab:CreateDivider({ line = false, spacing = 2 })

        AimTab:CreateSlider({
            name = "Smoothness",
            range = {1, 100},
            increment = 1,
            suffix = "%",
            currentValue = 25,
            flag = "AimSmooth",
            callback = function(v) GlobalState.Aim.Smooth = v end
        })

        AimTab:CreateDivider({ line = false, spacing = 2 })

        AimTab:CreateSlider({
            name = "Max Distance",
            range = {50, 2000},
            increment = 10,
            suffix = "m",
            currentValue = 500,
            flag = "AimDist",
            callback = function(v) GlobalState.Aim.MaxDist = v end
        })

        AimTab:CreateDivider({ line = true, spacing = 6 })
        AimTab:CreateSection({ name = "Target Selection", icon = GetIcon("SectionInfo.png") })
        AimTab:CreateDivider({ line = false, spacing = 2 })

        AimTab:CreateDropdown({
            name = "Target Mode",
            options = {"Single (Closest to Cursor)", "Multiple (All in FOV)"},
            currentOption = {"Single (Closest to Cursor)"},
            multipleOptions = false,
            flag = "AimMode",
            callback = function(opt)
                GlobalState.Aim.Mode = type(opt) == "table" and opt[1] or opt
            end
        })

        AimTab:CreateDivider({ line = false, spacing = 2 })

        AimTab:CreateDropdown({
            name = "Hit Part",
            options = {"Head", "HumanoidRootPart", "UpperTorso"},
            currentOption = {"Head"},
            multipleOptions = false,
            flag = "AimPart",
            callback = function(opt)
                GlobalState.Aim.Part = type(opt) == "table" and opt[1] or opt
            end
        })

        AimTab:CreateDivider({ line = false, spacing = 2 })

        AimTab:CreateDropdown({
            name = "Activation",
            options = {"Hold RMB", "Always On", "Toggle Key (T)"},
            currentOption = {"Hold RMB"},
            multipleOptions = false,
            flag = "AimActivate",
            callback = function(opt)
                GlobalState.Aim.Activation = type(opt) == "table" and opt[1] or opt
            end
        })

        AimTab:CreateDivider({ line = true, spacing = 6 })
        AimTab:CreateSection({ name = "Extras", icon = GetIcon("SectionSafe.png") })
        AimTab:CreateDivider({ line = false, spacing = 2 })

        AimTab:CreateToggle({
            name = "Visible Check (no walls)",
            currentValue = true,
            flag = "AimVisible",
            callback = function(v) GlobalState.Aim.VisibleOnly = v end
        })

        AimTab:CreateDivider({ line = false, spacing = 2 })

        AimTab:CreateToggle({
            name = "Team Check",
            currentValue = true,
            flag = "AimTeam",
            callback = function(v) GlobalState.Aim.TeamCheck = v end
        })

        -- ==========================================
        -- ⚙️ ВКЛАДКА: SETTINGS
        -- ==========================================
        SettingsTab:CreateDivider({ line = true, spacing = 5 })
        SettingsTab:CreateSection({ name = "Ui Changer", icon = GetIcon("Settings.png") })

        SettingsTab:CreateButton({
            name = "Close Hub",
            callback = function()
                Window:Popup({
                    title = "Are you sure to close hub?",
                    content = "This will close hub and stop all functions.",
                    options = {
                        { text = "Cancel" },
                        { text = "Close", style = "danger", callback = function()
                            Window:Notify({
                                title = "Warning",
                                content = "Hub will be closed after 5 seconds...",
                                duration = 5,
                                icon = GetIcon("NotifyError.png")
                            })
                            task.wait(5)

                            -- Очистка Drawing-объектов
                            for _, obj in pairs(GlobalState.Objects) do
                                if obj.Tracer then obj.Tracer:Remove() end
                                if obj.Text then obj.Text:Remove() end
                            end
                            if fovCircle then fovCircle:Remove() end

                            -- Очистка Highlight
                            for _, v in pairs(CoreGui:GetChildren()) do
                                if v.Name:match("^GlobalGlow_") then v:Destroy() end
                            end

                            -- Отключение коннектов
                            for _, c in pairs(GlobalState.Connections) do
                                pcall(function() c:Disconnect() end)
                            end

                            -- Уничтожение UI
                            if Rayfield and Rayfield.Destroy then
                                Rayfield:Destroy()
                            elseif Window and Window.Unload then
                                Window:Unload()
                            end
                        end },
                    },
                })
            end,
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

        -- ==========================================
        -- 🎯 AIMBOT ENGINE
        -- ==========================================
        local fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.NumSides = 64
        fovCircle.Radius = GlobalState.Aim.FOV
        fovCircle.Color = Color3.fromRGB(0, 183, 255)
        fovCircle.Filled = false
        fovCircle.Transparency = 1
        fovCircle.Visible = false

        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                GlobalState.Aim.Holding = true
            elseif input.KeyCode == Enum.KeyCode.T then
                GlobalState.Aim.ToggleKey = not GlobalState.Aim.ToggleKey
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                GlobalState.Aim.Holding = false
            end
        end)

        local function isVisible(part)
            if not GlobalState.Aim.VisibleOnly then return true end
            local origin = Camera.CFrame.Position
            local dir = (part.Position - origin)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
            local result = workspace:Raycast(origin, dir, params)
            return result == nil
        end

        local function getTargetPart(plr)
            local char = plr.Character
            if not char then return nil end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return nil end
            local part = char:FindFirstChild(GlobalState.Aim.Part)
            return part, hum
        end

        local aimConnection = RunService.RenderStepped:Connect(function()
            if GlobalState.Aim.ShowFOV then
                fovCircle.Visible = true
                fovCircle.Radius = GlobalState.Aim.FOV
                fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            else
                fovCircle.Visible = false
            end

            local active = false
            if GlobalState.Aim.Enabled then
                if GlobalState.Aim.Activation == "Hold RMB" then
                    active = GlobalState.Aim.Holding
                elseif GlobalState.Aim.Activation == "Always On" then
                    active = true
                elseif GlobalState.Aim.Activation == "Toggle Key (T)" then
                    active = GlobalState.Aim.ToggleKey
                end
            end
            if not active then return end

            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local candidates = {}

            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    if not (GlobalState.Aim.TeamCheck and plr.Team == LocalPlayer.Team) then
                        local part, hum = getTargetPart(plr)
                        if part then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                                local dist3D = (Camera.CFrame.Position - part.Position).Magnitude
                                if dist2D <= GlobalState.Aim.FOV and dist3D <= GlobalState.Aim.MaxDist then
                                    if isVisible(part) then
                                        table.insert(candidates, {
                                            part = part,
                                            dist2D = dist2D,
                                            screenPos = Vector2.new(screenPos.X, screenPos.Y)
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if #candidates == 0 then return end

            table.sort(candidates, function(a, b) return a.dist2D < b.dist2D end)

            if GlobalState.Aim.Mode == "Single (Closest to Cursor)" then
                local chosen = candidates[1].part
                local smooth = GlobalState.Aim.Smooth / 100
                local targetCF = CFrame.new(Camera.CFrame.Position, chosen.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - smooth)
            elseif GlobalState.Aim.Mode == "Multiple (All in FOV)" then
                local sum = Vector3.new()
                for _, c in ipairs(candidates) do
                    sum = sum + c.part.Position
                end
                local avg = sum / #candidates
                local smooth = GlobalState.Aim.Smooth / 100
                local targetCF = CFrame.new(Camera.CFrame.Position, avg)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - smooth)
            end
        end)

        table.insert(GlobalState.Connections, aimConnection)

        -- ==========================================
        -- 📊 ESP RENDER
        -- ==========================================
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

                    local targetAlpha = isVisible and 1 or 0
                    objs.Alpha = objs.Alpha + (targetAlpha - objs.Alpha) * GlobalState.ESP.FadeSpeed

                    local activeGlowColor = GlobalState.ESP.RainbowMode and currentRainbowColor or GlobalState.ESP.GlowColor
                    local glowTargetAlpha = (GlobalState.ESP.Glow and GlobalState.ESP.Master and character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0) and 1 or 0
                    ManageGlow(player, character, glowTargetAlpha, activeGlowColor)

                    if objs.Alpha > 0.01 and Vector and HeadVector then
                        if GlobalState.ESP.Tracers then
                            objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            objs.Tracer.To = Vector2.new(Vector.X, Vector.Y)
                            objs.Tracer.Color = GlobalState.ESP.RainbowMode and currentRainbowColor or GlobalState.ESP.TracerColor
                            objs.Tracer.Transparency = objs.Alpha * 0.8
                            objs.Tracer.Visible = true
                        else
                            objs.Tracer.Visible = false
                        end

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

    TheScript()
end
