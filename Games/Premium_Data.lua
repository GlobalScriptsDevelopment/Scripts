-- ==============================================================================
-- [[ GLOBAL SCRIPTS DEVELOPMENT ]]
-- Payload  |  Rayfield Gen 2  |  v1.6.0
-- ==============================================================================

return function(Env, PassedKey)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local MarketplaceService = game:GetService("MarketplaceService")
    local UserInputService = game:GetService("UserInputService")
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    if PassedKey ~= "Global-Scripts-2026-Gen2-2fhjg42cmb053nffas" then
        LocalPlayer:Kick("[Global Scripts] Invalid Auth Key.")
        return
    end

    local State = {
        ESP = {
            Master = false, Tracers = false, Style = "Health & Meters", Glow = false,
            TracerColor = Color3.fromRGB(255,255,255), TextColor = Color3.fromRGB(255,255,255),
            GlowColor = Color3.fromRGB(0,242,254), FadeSpeed = 0.1,
            RainbowMode = false, RainbowSpeed = 1
        },
        Aim = {
            Enabled = false, ShowFOV = false, FOV = 120, Smooth = 0.15, MaxDist = 1000,
            Part = "Head", Wall = false, TargetName = "", Holding = false, ToggleKey = false
        },
        Mods = { Speed = 16, Jump = 50, Gravity = 196.2, TargetFOV = 70,
                 LoopSpeed = false, LoopJump = false, LoopGravity = false, SmoothFOV = true },
        Spin = { Enabled = false, Speed = 180, AutoRotateStore = nil },
        AntiAnchor = { Enabled = false },
        Hitbox = {
            LocalColor = Color3.fromRGB(86,171,128), PlayersColor = Color3.fromRGB(86,171,128),
            LocalTrans = 0.7, PlayersTrans = 0.7,
            LocalEnabled = false, PlayersEnabled = false
        },
        NameTags = { Enabled = false },
        Connections = {},
        Objects = {},
        HitboxConns = {},
        NameTagConns = {},
        HitboxTags = {}
    }

    local execName = type(identifyexecutor) == "function" and identifyexecutor() or "Unknown"
    local gameName = "Loading..."
    pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

    -- ==========================================================================
    local function TheScript()
        local Window = Env.Window
        local GetIcon = Env.GetIcon

        local HomeTab = Env.TabHome
        local UpdatesTab = Env.TabUpdates
        local VisualTab = Env.TabVisual
        local MiscTab = Env.TabMiscellaneous
        local SettingsTab = Env.TabSettings

        -- ======================================================================
        -- HOME
        -- ======================================================================
        HomeTab:CreateDivider({ line = true, spacing = 4 })
        HomeTab:CreateSection({ name = "User Information", icon = GetIcon("SectionInfo.png") })
        HomeTab:CreateDivider({ line = false, spacing = 2 })
        HomeTab:CreateText({
            name = "Profile: " .. LocalPlayer.Name,
            text = "Plan: Premium\nStatus: Authenticated.",
            icon = GetIcon("TextInfo.png")
        })
        HomeTab:CreateDivider({ line = false, spacing = 2 })
        HomeTab:CreateText({
            name = "System Info",
            text = "Executor: " .. execName .. "\nGame: " .. gameName .. "\nPlace ID: " .. tostring(game.PlaceId),
            icon = GetIcon("TextSafe.png")
        })
        HomeTab:CreateDivider({ line = true, spacing = 4 })
        HomeTab:CreateSection({ name = "Quick Actions", icon = GetIcon("SectionSafe.png") })
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
                    Window:Notify({ title = "Copied!", content = "Discord invite copied.", duration = 3, icon = GetIcon("NotifyCheck.png") })
                end
            end
        })

        -- ======================================================================
        -- UPDATES
        -- ======================================================================
        UpdatesTab:CreateDivider({ line = true, spacing = 4 })
        UpdatesTab:CreateSection({ name = "Latest Version: v1.6.0", icon = GetIcon("VersionToast.png") })
        UpdatesTab:CreateDivider({ line = false, spacing = 2 })
        UpdatesTab:CreateText({
            name = "Patch Notes",
            text = "Aimbot fixed with BindToRenderStep\nImported ESP Hitboxes + Name Tags\nAdded Server Hop tools\nAdded Admin Tools\nAdded Spin Player + Anti-Anchor\nSmooth Camera FOV",
            icon = GetIcon("TextSafe.png")
        })
        UpdatesTab:CreateDivider({ line = false, spacing = 2 })

        -- ======================================================================
        -- VISUAL (Rayfield ESP)
        -- ======================================================================
        VisualTab:CreateDivider({ line = true, spacing = 4 })
        VisualTab:CreateSection({ name = "Main Settings", icon = GetIcon("Settings.png") })
        VisualTab:CreateDivider({ line = false, spacing = 2 })
        VisualTab:CreateText({
            name = "Info",
            text = "Master — вкл/выкл ESP.\nTracers — линии к игрокам.\nStyle — что писать над головой.\nGlow — подсветка силуэта.",
            icon = GetIcon("TextInfo.png")
        })
        VisualTab:CreateDivider({ line = false, spacing = 2 })
        VisualTab:CreateToggle({ name = "Master ESP Switch", currentValue = false, flag = "EspMaster",
            callback = function(v) State.ESP.Master = v end })
        VisualTab:CreateDivider({ line = false, spacing = 2 })
        VisualTab:CreateToggle({ name = "Enable Tracers (Lines)", currentValue = false, flag = "EspTracers",
            callback = function(v) State.ESP.Tracers = v end })
        VisualTab:CreateDivider({ line = false, spacing = 2 })
        VisualTab:CreateDropdown({
            name = "ESP Information Style",
            options = {"Health & Meters", "Names Only", "Disabled"},
            currentOption = {"Health & Meters"}, multipleOptions = false, flag = "EspStyle",
            callback = function(o) State.ESP.Style = type(o) == "table" and o[1] or o end
        })
        VisualTab:CreateDivider({ line = false, spacing = 2 })
        VisualTab:CreateToggle({ name = "Glowing Players (Chams)", currentValue = false, flag = "EspGlow",
            callback = function(v) State.ESP.Glow = v end })
        VisualTab:CreateDivider({ line = true, spacing = 4 })
        VisualTab:CreateSection({ name = "Colors & Rainbow", icon = GetIcon("Visual.png") })
        VisualTab:CreateDivider({ line = false, spacing = 2 })
        VisualTab:CreateToggle({ name = "Enable Rainbow ESP", currentValue = false, flag = "EspRainbow",
            callback = function(v) State.ESP.RainbowMode = v end })
        VisualTab:CreateDivider({ line = false, spacing = 2 })
        VisualTab:CreateSlider({ name = "Rainbow Speed", range = {0.1, 5}, increment = 0.1, suffix = "x",
            currentValue = 1, flag = "EspRainbowSpeed",
            callback = function(v) State.ESP.RainbowSpeed = v end })
        VisualTab:CreateDivider({ line = false, spacing = 2 })
        VisualTab:CreateColorPicker({ name = "Tracer Color", color = State.ESP.TracerColor, flag = "TracerColorPicker",
            callback = function(c) State.ESP.TracerColor = c end })
        VisualTab:CreateDivider({ line = false, spacing = 2 })
        VisualTab:CreateColorPicker({ name = "Text Color", color = State.ESP.TextColor, flag = "TextColorPicker",
            callback = function(c) State.ESP.TextColor = c end })
        VisualTab:CreateDivider({ line = false, spacing = 2 })
        VisualTab:CreateColorPicker({ name = "Glow Color", color = State.ESP.GlowColor, flag = "GlowColorPicker",
            callback = function(c) State.ESP.GlowColor = c end })

        -- ======================================================================
        -- MISC — AIMBOT
        -- ======================================================================
        MiscTab:CreateDivider({ line = true, spacing = 4 })
        MiscTab:CreateSection({ name = "Aimbot", icon = GetIcon("Aim.png") })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateText({
            name = "Как работает",
            text = "Плавно наводит камеру на ближайшего игрока в радиусе FOV.\nSmooth — меньше = плавнее.\nAim Wall — игнор стен.\nPlayer Aimbot — фильтр по нику.",
            icon = GetIcon("TextInfo.png")
        })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Enable Aimbot", currentValue = false, flag = "AimEnabled",
            callback = function(v) State.Aim.Enabled = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Aim Wall (ignore walls)", currentValue = false, flag = "AimWall",
            callback = function(v) State.Aim.Wall = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Show FOV Circle", currentValue = false, flag = "AimShowFov",
            callback = function(v) State.Aim.ShowFOV = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateDropdown({
            name = "Hit Part",
            options = {"Head", "Torso", "HumanoidRootPart"},
            currentOption = {"Head"}, multipleOptions = false, flag = "AimPart",
            callback = function(o) State.Aim.Part = type(o) == "table" and o[1] or o end
        })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateSlider({ name = "Zone of Aimbot (FOV)", range = {0, 1000}, increment = 1, suffix = "px",
            currentValue = 120, flag = "AimFov",
            callback = function(v) State.Aim.FOV = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateSlider({ name = "Smooth Aim", range = {0.01, 1}, increment = 0.01,
            currentValue = 0.15, flag = "AimSmooth",
            callback = function(v) State.Aim.Smooth = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateSlider({ name = "Max Distance", range = {50, 2000}, increment = 10, suffix = "m",
            currentValue = 1000, flag = "AimDist",
            callback = function(v) State.Aim.MaxDist = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateInput({
            name = "Player Aimbot (nickname)",
            placeholderText = "Nickname or empty",
            currentValue = "",
            removeAfter = false,
            flag = "AimTarget",
            callback = function(txt)
                if txt == "" then
                    State.Aim.TargetName = ""
                    Window:Notify({ title = "Cleared", content = "Target reset.", duration = 2, icon = GetIcon("NotifyCheck.png") })
                else
                    if Players:FindFirstChild(txt) then
                        State.Aim.TargetName = txt
                        Window:Notify({ title = "Target", content = txt, duration = 2, icon = GetIcon("NotifyCheck.png") })
                    else
                        State.Aim.TargetName = ""
                        Window:Notify({ title = "Not found", content = "Reset.", duration = 2, icon = GetIcon("NotifyError.png") })
                    end
                end
            end
        })

        -- ======================================================================
        -- MISC — ESP HITBOXES (imported)
        -- ======================================================================
        MiscTab:CreateDivider({ line = true, spacing = 4 })
        MiscTab:CreateSection({ name = "ESP Hitboxes", icon = GetIcon("Visual.png") })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateText({
            name = "Что это",
            text = "Local Hitbox — рамка вокруг тебя.\nPlayers Hitbox — вокруг других.\nМожно менять цвет и прозрачность.",
            icon = GetIcon("TextInfo.png")
        })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Local Hitbox", currentValue = false, flag = "HitboxLocal",
            callback = function(v)
                State.Hitbox.LocalEnabled = v
                if v then
                    if LocalPlayer.Character then addHitbox(LocalPlayer.Character, false) end
                else
                    if LocalPlayer.Character then removeHitbox(LocalPlayer.Character) end
                end
            end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Players Hitbox", currentValue = false, flag = "HitboxPlayers",
            callback = function(v)
                State.Hitbox.PlayersEnabled = v
                if v then
                    for _, p in ipairs(Players:GetPlayers()) do connectHitboxPlayer(p) end
                    local c = Players.PlayerAdded:Connect(connectHitboxPlayer)
                    table.insert(State.HitboxConns, c)
                else
                    for _, c in ipairs(State.HitboxConns) do c:Disconnect() end
                    State.HitboxConns = {}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character then removeHitbox(p.Character) end
                    end
                end
            end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateColorPicker({ name = "Local Hitbox Color", color = State.Hitbox.LocalColor, flag = "HitboxLocalColor",
            callback = function(v)
                State.Hitbox.LocalColor = v
                if LocalPlayer.Character then
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:FindFirstChild("Hitbox") then
                        local h = hrp.Hitbox:FindFirstChildOfClass("Highlight")
                        if h then h.FillColor = v; h.OutlineColor = v end
                    end
                end
            end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateSlider({ name = "Local Hitbox Transparency", range = {0, 1}, increment = 0.05,
            currentValue = 0.7, flag = "HitboxLocalTrans",
            callback = function(v)
                State.Hitbox.LocalTrans = v
                if LocalPlayer.Character then
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:FindFirstChild("Hitbox") then
                        hrp.Hitbox.Transparency = v
                        local h = hrp.Hitbox:FindFirstChildOfClass("Highlight")
                        if h then h.FillTransparency = v end
                    end
                end
            end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateColorPicker({ name = "Players Hitbox Color", color = State.Hitbox.PlayersColor, flag = "HitboxPlayersColor",
            callback = function(v)
                State.Hitbox.PlayersColor = v
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and hrp:FindFirstChild("Hitbox") then
                            local h = hrp.Hitbox:FindFirstChildOfClass("Highlight")
                            if h then h.FillColor = v; h.OutlineColor = v end
                        end
                    end
                end
            end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateSlider({ name = "Players Hitbox Transparency", range = {0, 1}, increment = 0.05,
            currentValue = 0.7, flag = "HitboxPlayersTrans",
            callback = function(v)
                State.Hitbox.PlayersTrans = v
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and hrp:FindFirstChild("Hitbox") then
                            hrp.Hitbox.Transparency = v
                            local h = hrp.Hitbox:FindFirstChildOfClass("Highlight")
                            if h then h.FillTransparency = v end
                        end
                    end
                end
            end })

        -- ======================================================================
        -- MISC — NAME TAGS (imported)
        -- ======================================================================
        MiscTab:CreateDivider({ line = true, spacing = 4 })
        MiscTab:CreateSection({ name = "Name Tags", icon = GetIcon("SectionSafe.png") })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateText({
            name = "Что это",
            text = "Показывает над головой игрока DisplayName + ник.",
            icon = GetIcon("TextInfo.png")
        })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Name of Players", currentValue = false, flag = "NameTagsEnabled",
            callback = function(v)
                State.NameTags.Enabled = v
                if v then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer then connectNameTag(p) end
                    end
                    local c1 = Players.PlayerAdded:Connect(connectNameTag)
                    local c2 = Players.PlayerRemoving:Connect(removeNameTag)
                    table.insert(State.NameTagConns, c1)
                    table.insert(State.NameTagConns, c2)
                else
                    for _, c in ipairs(State.NameTagConns) do c:Disconnect() end
                    State.NameTagConns = {}
                    for p, tag in pairs(State.HitboxTags) do tag:Destroy() end
                    State.HitboxTags = {}
                end
            end })

        -- ======================================================================
        -- MISC — MOVEMENT TRICKS
        -- ======================================================================
        MiscTab:CreateDivider({ line = true, spacing = 4 })
        MiscTab:CreateSection({ name = "Movement Tricks", icon = GetIcon("SectionSafe.png") })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateText({
            name = "Spin & Anti-Anchor",
            text = "Spin Player — крутит персонажа.\nAnti-Anchor — снимает Anchored с HRP и торса.",
            icon = GetIcon("TextInfo.png")
        })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Spin Player", currentValue = false, flag = "SpinEnabled",
            callback = function(v) State.Spin.Enabled = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateSlider({ name = "Spin Speed", range = {30, 2000}, increment = 10, suffix = " deg/s",
            currentValue = 180, flag = "SpinSpeed",
            callback = function(v) State.Spin.Speed = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Permanent Anti-Anchor", currentValue = false, flag = "AntiAnchorEnabled",
            callback = function(v) State.AntiAnchor.Enabled = v end })

        -- ======================================================================
        -- MISC — PLAYER MODIFICATIONS
        -- ======================================================================
        MiscTab:CreateDivider({ line = true, spacing = 4 })
        MiscTab:CreateSection({ name = "Player Modifications", icon = GetIcon("SectionSafe.png") })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateText({
            name = "Что это",
            text = "Speed — скорость ходьбы.\nJump — прыжок.\nGravity — гравитация мира.\nCamera FOV — угол обзора.",
            icon = GetIcon("TextInfo.png")
        })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateSlider({ name = "Walk Speed", range = {16, 500}, increment = 1, suffix = " spd",
            currentValue = 16, flag = "WalkSpeedVal",
            callback = function(v) State.Mods.Speed = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Apply Walk Speed", callback = function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = State.Mods.Speed end
        end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Loop Walk Speed", currentValue = false, flag = "LoopSpeed",
            callback = function(v) State.Mods.LoopSpeed = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateSlider({ name = "Jump Power", range = {50, 500}, increment = 1, suffix = " jmp",
            currentValue = 50, flag = "JumpPowerVal",
            callback = function(v) State.Mods.Jump = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Apply Jump Power", callback = function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.UseJumpPower = true; hum.JumpPower = State.Mods.Jump end
        end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Loop Jump Power", currentValue = false, flag = "LoopJump",
            callback = function(v) State.Mods.LoopJump = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateSlider({ name = "Gravity", range = {10, 500}, increment = 1, suffix = " grav",
            currentValue = 196, flag = "GravityVal",
            callback = function(v) State.Mods.Gravity = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Apply Gravity", callback = function()
            workspace.Gravity = State.Mods.Gravity
        end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Loop Gravity", currentValue = false, flag = "LoopGravity",
            callback = function(v) State.Mods.LoopGravity = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateSlider({ name = "Camera FOV", range = {30, 120}, increment = 1, suffix = " fov",
            currentValue = 70, flag = "CamFOVVal",
            callback = function(v)
                State.Mods.TargetFOV = v
                if not State.Mods.SmoothFOV then Camera.FieldOfView = v end
            end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateToggle({ name = "Smooth Camera FOV", currentValue = true, flag = "SmoothFOV",
            callback = function(v) State.Mods.SmoothFOV = v end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Reset Camera FOV", callback = function()
            State.Mods.TargetFOV = 70
            Camera.FieldOfView = 70
        end })

        -- ======================================================================
        -- MISC — SERVER TOOLS (imported)
        -- ======================================================================
        MiscTab:CreateDivider({ line = true, spacing = 4 })
        MiscTab:CreateSection({ name = "Server Tools", icon = GetIcon("SectionSafe.png") })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateText({
            name = "Что это",
            text = "Server Hop — случайный сервер.\nServer Small — минимум игроков.\nServer Private — приват (beta).",
            icon = GetIcon("TextInfo.png")
        })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Server Hop", callback = function()
            Window:Notify({ title = "Server Hop", content = "Teleporting...", duration = 3, icon = GetIcon("NotifyCheck.png") })
            local ok, servers = pcall(function()
                return HttpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            end)
            if ok and servers and servers.data then
                for _, srv in ipairs(servers.data) do
                    if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
                        break
                    end
                end
            end
        end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Server Small (fewest players)", callback = function()
            Window:Notify({ title = "Server Small", content = "Searching...", duration = 3, icon = GetIcon("NotifyCheck.png") })
            local ok, servers = pcall(function()
                return HttpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            end)
            if ok and servers and servers.data then
                local best
                for _, srv in ipairs(servers.data) do
                    if srv.id ~= game.JobId then
                        if not best or srv.playing < best.playing then best = srv end
                    end
                end
                if best then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
                end
            end
        end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Server Private [BETA]", callback = function()
            Window:Notify({ title = "Private", content = "Loading...", duration = 3, icon = GetIcon("NotifyCheck.png") })
            loadstring(game:HttpGet("https://raw.githubusercontent.com/veil0x14/LocalScripts/refs/heads/main/pg.lua"))()
        end })

        -- ======================================================================
        -- MISC — ADMIN TOOLS (imported)
        -- ======================================================================
        MiscTab:CreateDivider({ line = true, spacing = 4 })
        MiscTab:CreateSection({ name = "Admin & Explorer", icon = GetIcon("SectionSafe.png") })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateText({
            name = "Что это",
            text = "Btools / F3X — строительные тулзы.\nInfinite Yield — админ-панель.\nDex V2/V4 — проводник по игре.",
            icon = GetIcon("TextInfo.png")
        })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Btools", callback = function()
            Window:Notify({ title = "Btools", content = "Executing...", duration = 3, icon = GetIcon("NotifyCheck.png") })
            pcall(function() loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/BTools.txt"))() end)
        end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "F3X Tools", callback = function()
            Window:Notify({ title = "F3X", content = "Executing...", duration = 3, icon = GetIcon("NotifyCheck.png") })
            pcall(function() loadstring(game:GetObjects("rbxassetid://6695644299")[1].Source)() end)
        end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Infinite Yield", callback = function()
            Window:Notify({ title = "IY", content = "Executing...", duration = 3, icon = GetIcon("NotifyCheck.png") })
            pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
        end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Dex V2", callback = function()
            Window:Notify({ title = "Dex V2", content = "Executing...", duration = 3, icon = GetIcon("NotifyCheck.png") })
            pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/MariyaFurmanova/Library/main/dex2.0", true))() end)
        end })
        MiscTab:CreateDivider({ line = false, spacing = 2 })
        MiscTab:CreateButton({ name = "Dex V4", callback = function()
            Window:Notify({ title = "Dex V4", content = "Executing...", duration = 3, icon = GetIcon("NotifyCheck.png") })
            pcall(function() loadstring(game:HttpGet("https://gist.githubusercontent.com/dannythehacker/1781582ab545302f2b34afc4ec53e811/raw/ee5324771f017073fc30e640323ac2a9b3bfc550/dark%2520dex%2520v4"))() end)
        end })

        -- ======================================================================
        -- SETTINGS
        -- ======================================================================
        SettingsTab:CreateDivider({ line = true, spacing = 4 })
        SettingsTab:CreateSection({ name = "Ui Changer", icon = GetIcon("Settings.png") })
        SettingsTab:CreateDivider({ line = false, spacing = 2 })
        SettingsTab:CreateText({
            name = "Что делает",
            text = "Close Hub — безопасно закрывает UI, отвязывает аимбот и удаляет Drawing.",
            icon = GetIcon("TextInfo.png")
        })
        SettingsTab:CreateDivider({ line = false, spacing = 2 })
        SettingsTab:CreateButton({
            name = "Close Hub",
            callback = function()
                Window:Popup({
                    title = "Close hub?",
                    content = "All functions will stop.",
                    options = {
                        { text = "Cancel" },
                        { text = "Close", style = "danger", callback = function()
                            Window:Notify({ title = "Warning", content = "Closing in 5 sec...", duration = 5, icon = GetIcon("NotifyError.png") })
                            task.wait(5)
                            for _, obj in pairs(State.Objects) do
                                if obj.Tracer then obj.Tracer:Remove() end
                                if obj.Text then obj.Text:Remove() end
                            end
                            pcall(function() fovCircle:Remove() end)
                            pcall(function() RunService:UnbindFromRenderStep("GS_Aimbot") end)
                            for _, v in pairs(CoreGui:GetChildren()) do
                                if v.Name:match("^GS_Glow_") then v:Destroy() end
                            end
                            for _, c in pairs(State.Connections) do pcall(function() c:Disconnect() end) end
                            if Rayfield and Rayfield.Destroy then Rayfield:Destroy()
                            elseif Window and Window.Unload then Window:Unload() end
                        end },
                    },
                })
            end,
        })

        -- ======================================================================
        -- ESP OBJECTS
        -- ======================================================================
        local function GetESPObjects(p)
            if not State.Objects[p] then
                State.Objects[p] = { Tracer = Drawing.new("Line"), Text = Drawing.new("Text"), Alpha = 0 }
                State.Objects[p].Tracer.Thickness = 1.5
                State.Objects[p].Text.Size = 16
                State.Objects[p].Text.Center = true
                State.Objects[p].Text.Outline = true
            end
            return State.Objects[p]
        end

        local function ManageGlow(p, char, targetAlpha, color)
            local name = "GS_Glow_" .. p.Name
            local glow = CoreGui:FindFirstChild(name)
            if targetAlpha > 0.01 then
                if not glow then
                    glow = Instance.new("Highlight")
                    glow.Name = name
                    glow.Parent = CoreGui
                end
                glow.Adornee = char
                glow.FillColor = color
                glow.OutlineColor = Color3.fromRGB(255,255,255)
                glow.FillTransparency = 1 - (0.5 * targetAlpha)
                glow.OutlineTransparency = 1 - (0.9 * targetAlpha)
            else
                if glow then glow:Destroy() end
            end
        end

        -- ======================================================================
        -- HITBOX HELPERS
        -- ======================================================================
        function addHitbox(character, isPlayer)
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp or hrp:FindFirstChild("Hitbox") then return end

            local part = Instance.new("Part")
            part.Name = "Hitbox"
            part.Size = Vector3.new(2.55, 3.45, 2.05)
            part.CanCollide = false
            part.Anchored = false
            part.Transparency = isPlayer and State.Hitbox.PlayersTrans or State.Hitbox.LocalTrans
            part.Position = hrp.Position
            part.Parent = hrp

            local hl = Instance.new("Highlight")
            hl.Parent = part
            hl.FillColor = isPlayer and State.Hitbox.PlayersColor or State.Hitbox.LocalColor
            hl.OutlineColor = isPlayer and State.Hitbox.PlayersColor or State.Hitbox.LocalColor
            hl.FillTransparency = isPlayer and State.Hitbox.PlayersTrans or State.Hitbox.LocalTrans

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = part
            weld.Part1 = hrp
            weld.Parent = part
        end

        function removeHitbox(character)
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hb = hrp:FindFirstChild("Hitbox")
                if hb then hb:Destroy() end
            end
        end

        function connectHitboxPlayer(p)
            if p.Character then addHitbox(p.Character, true) end
            local c = p.CharacterAdded:Connect(function(ch) addHitbox(ch, true) end)
            table.insert(State.HitboxConns, c)
        end

        -- ======================================================================
        -- NAME TAG HELPERS
        -- ======================================================================
        function createNameTag(p)
            if not p.Character or not p.Character:FindFirstChild("Head") then return end
            if State.HitboxTags[p] then return end
            local bb = Instance.new("BillboardGui")
            bb.Name = "NameTag"
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0, 200, 0, 50)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.MaxDistance = 50000
            bb.Parent = p.Character.Head

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.TextColor3 = Color3.fromRGB(255,255,255)
            lbl.TextStrokeTransparency = 0.3
            lbl.TextScaled = true
            lbl.Font = Enum.Font.SourceSansBold
            lbl.Text = p.DisplayName .. " (" .. p.Name .. ")"
            lbl.Parent = bb
            State.HitboxTags[p] = bb
        end

        function removeNameTag(p)
            if State.HitboxTags[p] then
                State.HitboxTags[p]:Destroy()
                State.HitboxTags[p] = nil
            end
        end

        function connectNameTag(p)
            if p == LocalPlayer then return end
            createNameTag(p)
            local c = p.CharacterAdded:Connect(function()
                task.wait(0.5)
                createNameTag(p)
            end)
            table.insert(State.NameTagConns, c)
        end

        -- ======================================================================
        -- AIMBOT ENGINE
        -- ======================================================================
        local fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.NumSides = 64
        fovCircle.Color = Color3.fromRGB(0,183,255)
        fovCircle.Filled = false
        fovCircle.Transparency = 1
        fovCircle.Visible = false

        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                State.Aim.Holding = true
            elseif input.KeyCode == Enum.KeyCode.T then
                State.Aim.ToggleKey = not State.Aim.ToggleKey
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                State.Aim.Holding = false
            end
        end)

        local function IsVisible(origin, part)
            if State.Aim.Wall then return true end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
            return workspace:Raycast(origin, part.Position - origin, params) == nil
        end

        local function GetClosestPlayer()
            local closest, shortest = nil, State.Aim.FOV
            local origin = Camera.CFrame.Position
            local mouseLoc = UserInputService:GetMouseLocation()

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if State.Aim.TargetName == "" or p.Name == State.Aim.TargetName then
                        local part = p.Character:FindFirstChild(State.Aim.Part)
                            or p.Character:FindFirstChild("UpperTorso")
                            or p.Character:FindFirstChild("Torso")
                        if part then
                            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local d2 = (Vector2.new(mouseLoc.X, mouseLoc.Y) - Vector2.new(sp.X, sp.Y)).Magnitude
                                local d3 = (origin - part.Position).Magnitude
                                if d2 <= shortest and d3 <= State.Aim.MaxDist then
                                    if IsVisible(origin, part) then
                                        shortest = d2
                                        closest = p
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return closest
        end

        RunService:BindToRenderStep("GS_Aimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
            if State.Aim.ShowFOV then
                fovCircle.Visible = true
                fovCircle.Radius = State.Aim.FOV
                fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            else
                fovCircle.Visible = false
            end

            if not State.Aim.Enabled then return end

            local target = GetClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(State.Aim.Part)
                    or target.Character:FindFirstChild("UpperTorso")
                    or target.Character:FindFirstChild("Torso")
                if part then
                    local camPos = Camera.CFrame.Position
                    local targetCF = CFrame.new(camPos, part.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, math.clamp(State.Aim.Smooth, 0.01, 1))
                end
            end
        end)

        -- ======================================================================
        -- MAIN LOOP
        -- ======================================================================
        local loopConn = RunService.Heartbeat:Connect(function(dt)
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            -- Spin
            if State.Spin.Enabled and hum and hrp then
                if State.Spin.AutoRotateStore == nil then
                    State.Spin.AutoRotateStore = hum.AutoRotate
                end
                hum.AutoRotate = false
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(State.Spin.Speed) * dt, 0)
            elseif not State.Spin.Enabled and State.Spin.AutoRotateStore ~= nil then
                if hum then hum.AutoRotate = State.Spin.AutoRotateStore end
                State.Spin.AutoRotateStore = nil
            end

            -- Anti-Anchor
            if State.AntiAnchor.Enabled and char then
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                if hrp and hrp.Anchored then hrp.Anchored = false end
                if torso and torso.Anchored then torso.Anchored = false end
            end

            -- Player Mods
            if State.Mods.LoopSpeed and hum then hum.WalkSpeed = State.Mods.Speed end
            if State.Mods.LoopJump and hum then hum.UseJumpPower = true; hum.JumpPower = State.Mods.Jump end
            if State.Mods.LoopGravity then workspace.Gravity = State.Mods.Gravity end

            -- Smooth FOV
            if State.Mods.SmoothFOV then
                local target = State.Mods.TargetFOV
                Camera.FieldOfView = Camera.FieldOfView + (target - Camera.FieldOfView) * math.min(dt * 5, 1)
            end
        end)
        table.insert(State.Connections, loopConn)

        -- ======================================================================
        -- ESP RENDER
        -- ======================================================================
        local espConn = RunService.RenderStepped:Connect(function()
            local rainbow = Color3.fromHSV((tick() * State.ESP.RainbowSpeed * 0.2) % 1, 1, 1)

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local objs = GetESPObjects(p)
                    local char = p.Character
                    local visible = false
                    local Vector, HeadVector

                    if State.ESP.Master and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                        local hrp = char.HumanoidRootPart
                        local head = char:FindFirstChild("Head")
                        local OnScreen
                        Vector, OnScreen = Camera:WorldToViewportPoint(hrp.Position)
                        HeadVector = Camera:WorldToViewportPoint(head and head.Position or hrp.Position)
                        if OnScreen then visible = true end
                    end

                    local targetAlpha = visible and 1 or 0
                    objs.Alpha = objs.Alpha + (targetAlpha - objs.Alpha) * State.ESP.FadeSpeed

                    local activeColor = State.ESP.RainbowMode and rainbow or State.ESP.GlowColor
                    local glowA = (State.ESP.Glow and State.ESP.Master and char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0) and 1 or 0
                    ManageGlow(p, char, glowA, activeColor)

                    if objs.Alpha > 0.01 and Vector and HeadVector then
                        if State.ESP.Tracers then
                            objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            objs.Tracer.To = Vector2.new(Vector.X, Vector.Y)
                            objs.Tracer.Color = State.ESP.RainbowMode and rainbow or State.ESP.TracerColor
                            objs.Tracer.Transparency = objs.Alpha * 0.8
                            objs.Tracer.Visible = true
                        else
                            objs.Tracer.Visible = false
                        end

                        if State.ESP.Style ~= "Disabled" then
                            local hum = char:FindFirstChild("Humanoid")
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)

                            if State.ESP.Style == "Health & Meters" and hum then
                                local hp = math.floor(hum.Health)
                                objs.Text.Text = string.format("%s [%d HP] [%dm]", p.Name, hp, dist)
                                objs.Text.Color = State.ESP.RainbowMode and rainbow or Color3.fromRGB(255 - hp*2.55, hp*2.55, 0)
                            elseif State.ESP.Style == "Names Only" then
                                objs.Text.Text = p.Name
                                objs.Text.Color = State.ESP.RainbowMode and rainbow or State.ESP.TextColor
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
        table.insert(State.Connections, espConn)

        local removeConn = Players.PlayerRemoving:Connect(function(p)
            if State.Objects[p] then
                State.Objects[p].Tracer:Remove()
                State.Objects[p].Text:Remove()
                State.Objects[p] = nil
            end
            local glow = CoreGui:FindFirstChild("GS_Glow_" .. p.Name)
            if glow then glow:Destroy() end
        end)
        table.insert(State.Connections, removeConn)

        -- Auto-apply hitboxes / mods при респавне
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if State.Hitbox.LocalEnabled then addHitbox(LocalPlayer.Character, false) end
            if State.Mods.LoopSpeed then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = State.Mods.Speed end
            end
            if State.Mods.LoopJump then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.UseJumpPower = true; hum.JumpPower = State.Mods.Jump end
            end
        end)
    end

    TheScript()
end
