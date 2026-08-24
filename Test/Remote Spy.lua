-- // GLOBAL SCRIPTS: SPY PROTOCOL V5.0 \\ --
-- // ARCHITECTURE: NOTHING OS STYLE \\ --
-- // FEATURES: STRESS TESTER, DB EXPORT DROPDOWN, SAFE THREADING \\ --

if getgenv().GlobalScriptsRemoteSpy and getgenv().GlobalScriptsRemoteSpy.Active then
    warn("[GLOBAL SCRIPTS] Spy Protocol is already running.")
    return
end

-- ============================================
-- SERVICES & ASSET MANAGER
-- ============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if not isfolder("my-icons") then makefolder("my-icons") end
local iconUrl = "https://raw.githubusercontent.com/GlobalScriptsDevelopment/Scripts/main/Icons/ShowIcon.png"
local iconPath = "my-icons/ShowIcon.png"
if not isfile(iconPath) then
    pcall(function() writefile(iconPath, game:HttpGet(iconUrl)) end)
end

local Settings = {
    MaxLogsPerRemote = 50,
    MaxSerializationDepth = 4,
    Active = true,
    IgnoreSpam = true
}

local SpamRemotes = {
    ["CharacterSoundEvent"] = true, ["MoveDirection"] = true, 
    ["UpdateAnimationRemote"] = true, ["MousePos"] = true, 
    ["Heartbeat"] = true, ["Ping"] = true, ["OnRelayPing"] = true
}

local RemoteLogs = {}
local RemoteButtons = {}
local SelectedRemote = nil
local LastSelectedArgs = nil
local RemoteStats = {Total = 0, Count = 0}
local originalnamecall = nil
local ScannedRemotesData = {}

-- Animation Helper
local function Tween(obj, props, time)
    if not obj then return end
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

-- ============================================
-- NOTHING OS V5 UI CONSTRUCTION
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GlobalScriptsSpyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = PlayerGui

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 780, 0, 520)
MainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true 
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner") 
MainCorner.CornerRadius = UDim.new(0, 12) 
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke") 
MainStroke.Color = Color3.fromRGB(255, 255, 255) 
MainStroke.Thickness = 1 
MainStroke.Transparency = 0.85 
MainStroke.Parent = MainFrame

-- Draggable Logic
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GLOBAL SCRIPTS V5"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Tab Buttons
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 300, 1, 0)
TabContainer.Position = UDim2.new(0.5, -150, 0, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = TopBar

local function CreateTabButton(name, xPos, isSelected)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 1, -12)
    btn.Position = UDim2.new(0, xPos, 0, 6)
    btn.BackgroundColor3 = isSelected and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(25, 25, 25)
    btn.Text = name
    btn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabContainer
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = btn
    
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}) end)
    btn.MouseLeave:Connect(function() 
        if btn.TextColor3 == Color3.fromRGB(255, 255, 255) then Tween(btn, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}) 
        else Tween(btn, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}) end 
    end)
    return btn
end

local SpyTabBtn = CreateTabButton("SPY MODE", 5, true)
local DatabaseTabBtn = CreateTabButton("DATABASE", 155, false)

local CloseBtn = Instance.new("TextButton") CloseBtn.Size = UDim2.new(0, 45, 0, 45) CloseBtn.Position = UDim2.new(1, -45, 0, 0) CloseBtn.BackgroundTransparency = 1 CloseBtn.Text = "X" CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50) CloseBtn.TextSize = 16 CloseBtn.Font = Enum.Font.GothamBold CloseBtn.Parent = TopBar
local MinimizeBtn = Instance.new("TextButton") MinimizeBtn.Size = UDim2.new(0, 45, 0, 45) MinimizeBtn.Position = UDim2.new(1, -90, 0, 0) MinimizeBtn.BackgroundTransparency = 1 MinimizeBtn.Text = "-" MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255) MinimizeBtn.TextSize = 20 MinimizeBtn.Font = Enum.Font.GothamBold MinimizeBtn.Parent = TopBar

-- Minimized State
local MinimizedButton = Instance.new("TextButton")
MinimizedButton.Size = UDim2.new(0, 160, 0, 40)
MinimizedButton.Position = UDim2.new(0, 20, 0, 20)
MinimizedButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MinimizedButton.Text = "  SPY ACTIVE"
MinimizedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizedButton.TextSize = 12
MinimizedButton.Font = Enum.Font.GothamBold
MinimizedButton.Visible = false
MinimizedButton.Active = true
MinimizedButton.Parent = ScreenGui
local MinIcon = Instance.new("ImageLabel") MinIcon.Size = UDim2.new(0, 20, 0, 20) MinIcon.Position = UDim2.new(0, 10, 0.5, -10) MinIcon.BackgroundTransparency = 1 MinIcon.Image = getcustomasset("my-icons/ShowIcon.png") MinIcon.Parent = MinimizedButton
local MinCorner = Instance.new("UICorner") MinCorner.CornerRadius = UDim.new(0, 8) MinCorner.Parent = MinimizedButton
local MinStroke = Instance.new("UIStroke") MinStroke.Color = Color3.fromRGB(255, 255, 255) MinStroke.Thickness = 1 MinStroke.Transparency = 0.5 MinStroke.Parent = MinimizedButton
local minDragging, minDragStart, minStartPos
MinimizedButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then minDragging = true minDragStart = input.Position minStartPos = MinimizedButton.Position end end)
MinimizedButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then minDragging = false end end)
UserInputService.InputChanged:Connect(function(input) if minDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - minDragStart MinimizedButton.Position = UDim2.new(minStartPos.X.Scale, minStartPos.X.Offset + delta.X, minStartPos.Y.Scale, minStartPos.Y.Offset + delta.Y) end end)

-- Screens Container
local ScreensContainer = Instance.new("Frame")
ScreensContainer.Size = UDim2.new(2, 0, 1, -45)
ScreensContainer.Position = UDim2.new(0, 0, 0, 45)
ScreensContainer.BackgroundTransparency = 1
ScreensContainer.Parent = MainFrame

local function CreateButton(name, xPos, width, parent, color)
    local btn = Instance.new("TextButton") btn.Name = name btn.Size = UDim2.new(0, width, 1, 0) btn.Position = UDim2.new(1, -xPos, 0, 0) btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30) btn.Text = name btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.TextSize = 11 btn.Font = Enum.Font.GothamBold btn.Parent = parent
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = btn
    local targetColor = color and Color3.new(color.R*1.2, color.G*1.2, color.B*1.2) or Color3.fromRGB(50, 50, 50)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = targetColor}) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)}) end)
    return btn
end

-- ============================================
-- SPY SCREEN (INDEX 1)
-- ============================================
local SpyScreen = Instance.new("Frame")
SpyScreen.Size = UDim2.new(0.5, 0, 1, 0)
SpyScreen.Position = UDim2.new(0, 0, 0, 0)
SpyScreen.BackgroundTransparency = 1
SpyScreen.Parent = ScreensContainer

local LeftPanel = Instance.new("Frame") LeftPanel.Size = UDim2.new(0, 240, 1, -60) LeftPanel.Position = UDim2.new(0, 10, 0, 10) LeftPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20) LeftPanel.Parent = SpyScreen
local LeftCorner = Instance.new("UICorner") LeftCorner.CornerRadius = UDim.new(0, 8) LeftCorner.Parent = LeftPanel
local RemoteList = Instance.new("ScrollingFrame") RemoteList.Size = UDim2.new(1, -10, 1, -10) RemoteList.Position = UDim2.new(0, 5, 0, 5) RemoteList.BackgroundTransparency = 1 RemoteList.BorderSizePixel = 0 RemoteList.ScrollBarThickness = 2 RemoteList.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255) RemoteList.Parent = LeftPanel
local ListLayout = Instance.new("UIListLayout") ListLayout.Padding = UDim.new(0, 4) ListLayout.Parent = RemoteList

local RightPanel = Instance.new("Frame") RightPanel.Size = UDim2.new(1, -270, 1, -60) RightPanel.Position = UDim2.new(0, 260, 0, 10) RightPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20) RightPanel.Parent = SpyScreen
local RightCorner = Instance.new("UICorner") RightCorner.CornerRadius = UDim.new(0, 8) RightCorner.Parent = RightPanel
local CodeScroll = Instance.new("ScrollingFrame") CodeScroll.Size = UDim2.new(1, -10, 1, -10) CodeScroll.Position = UDim2.new(0, 5, 0, 5) CodeScroll.BackgroundTransparency = 1 CodeScroll.BorderSizePixel = 0 CodeScroll.ScrollBarThickness = 2 CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255) CodeScroll.Parent = RightPanel
local CodeView = Instance.new("TextBox") CodeView.Size = UDim2.new(1, -10, 1, -10) CodeView.Position = UDim2.new(0, 5, 0, 5) CodeView.BackgroundTransparency = 1 CodeView.TextColor3 = Color3.fromRGB(220, 220, 220) CodeView.TextSize = 13 CodeView.Font = Enum.Font.RobotoMono CodeView.Text = "-- Waiting for remote signals..." CodeView.TextXAlignment = Enum.TextXAlignment.Left CodeView.TextYAlignment = Enum.TextYAlignment.Top CodeView.ClearTextOnFocus = false CodeView.MultiLine = true CodeView.TextWrapped = false CodeView.Parent = CodeScroll

local BottomBar = Instance.new("Frame") BottomBar.Size = UDim2.new(1, -20, 0, 35) BottomBar.Position = UDim2.new(0, 10, 1, -45) BottomBar.BackgroundTransparency = 1 BottomBar.Parent = SpyScreen
local StatusLabel = Instance.new("TextLabel") StatusLabel.Size = UDim2.new(0, 200, 1, 0) StatusLabel.BackgroundTransparency = 1 StatusLabel.Text = "CAPTURED: 0 | CALLS: 0" StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150) StatusLabel.TextSize = 11 StatusLabel.Font = Enum.Font.GothamBold StatusLabel.TextXAlignment = Enum.TextXAlignment.Left StatusLabel.Parent = BottomBar

local ToggleBtn = CreateButton("PAUSE", 80, 80, BottomBar)
local CopyBtn = CreateButton("COPY", 170, 80, BottomBar)
local ClearBtn = CreateButton("CLEAR", 260, 80, BottomBar)
local ReplayBtn = CreateButton("REPLAY CALL", 370, 100, BottomBar, Color3.fromRGB(0, 120, 215)) 
local StressBtn = CreateButton("STRESS TEST", 480, 100, BottomBar, Color3.fromRGB(220, 40, 40)) 
local FilterBtn = CreateButton("SPAM FILTER: ON", 610, 120, BottomBar)

-- ============================================
-- DATABASE SCREEN (INDEX 2)
-- ============================================
local DatabaseScreen = Instance.new("Frame")
DatabaseScreen.Size = UDim2.new(0.5, 0, 1, 0)
DatabaseScreen.Position = UDim2.new(0.5, 0, 0, 0)
DatabaseScreen.BackgroundTransparency = 1
DatabaseScreen.Parent = ScreensContainer

local DBLeftPanel = Instance.new("Frame") DBLeftPanel.Size = UDim2.new(0, 240, 1, -60) DBLeftPanel.Position = UDim2.new(0, 10, 0, 10) DBLeftPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20) DBLeftPanel.Parent = DatabaseScreen
local DBLeftCorner = Instance.new("UICorner") DBLeftCorner.CornerRadius = UDim.new(0, 8) DBLeftCorner.Parent = DBLeftPanel
local DBList = Instance.new("ScrollingFrame") DBList.Size = UDim2.new(1, -10, 1, -10) DBList.Position = UDim2.new(0, 5, 0, 5) DBList.BackgroundTransparency = 1 DBList.BorderSizePixel = 0 DBList.ScrollBarThickness = 2 DBList.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255) DBList.Parent = DBLeftPanel
local DBListLayout = Instance.new("UIListLayout") DBListLayout.Padding = UDim.new(0, 4) DBListLayout.Parent = DBList

local DBRightPanel = Instance.new("Frame") DBRightPanel.Size = UDim2.new(1, -270, 1, -60) DBRightPanel.Position = UDim2.new(0, 260, 0, 10) DBRightPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20) DBRightPanel.Parent = DatabaseScreen
local DBRightCorner = Instance.new("UICorner") DBRightCorner.CornerRadius = UDim.new(0, 8) DBRightCorner.Parent = DBRightPanel
local DBCodeScroll = Instance.new("ScrollingFrame") DBCodeScroll.Size = UDim2.new(1, -10, 1, -10) DBCodeScroll.Position = UDim2.new(0, 5, 0, 5) DBCodeScroll.BackgroundTransparency = 1 DBCodeScroll.BorderSizePixel = 0 DBCodeScroll.ScrollBarThickness = 2 DBCodeScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255) DBCodeScroll.Parent = DBRightPanel
local DBCodeView = Instance.new("TextBox") DBCodeView.Size = UDim2.new(1, -10, 1, -10) DBCodeView.Position = UDim2.new(0, 5, 0, 5) DBCodeView.BackgroundTransparency = 1 DBCodeView.TextColor3 = Color3.fromRGB(220, 220, 220) DBCodeView.TextSize = 13 DBCodeView.Font = Enum.Font.RobotoMono DBCodeView.Text = "-- Click 'SCAN GAME' to build database." DBCodeView.TextXAlignment = Enum.TextXAlignment.Left DBCodeView.TextYAlignment = Enum.TextYAlignment.Top DBCodeView.ClearTextOnFocus = false DBCodeView.MultiLine = true DBCodeView.TextWrapped = false DBCodeView.Parent = DBCodeScroll

local DBBottomBar = Instance.new("Frame") DBBottomBar.Size = UDim2.new(1, -20, 0, 35) DBBottomBar.Position = UDim2.new(0, 10, 1, -45) DBBottomBar.BackgroundTransparency = 1 DBBottomBar.Parent = DatabaseScreen
local DBStatusLabel = Instance.new("TextLabel") DBStatusLabel.Size = UDim2.new(0, 200, 1, 0) DBStatusLabel.BackgroundTransparency = 1 DBStatusLabel.Text = "FOUND: 0 REMOTES" DBStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150) DBStatusLabel.TextSize = 11 DBStatusLabel.Font = Enum.Font.GothamBold DBStatusLabel.TextXAlignment = Enum.TextXAlignment.Left DBStatusLabel.Parent = DBBottomBar

local ScanBtn = CreateButton("SCAN GAME", 140, 140, DBBottomBar)
local DBDropdownBtn = CreateButton("COPY OPTIONS ▼", 300, 150, DBBottomBar, Color3.fromRGB(0, 160, 100))

-- DB Copy Dropdown Menu
local DropdownMenu = Instance.new("Frame")
DropdownMenu.Size = UDim2.new(0, 220, 0, 0)
DropdownMenu.Position = UDim2.new(1, -300, 1, -150)
DropdownMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DropdownMenu.ClipsDescendants = true
DropdownMenu.Visible = false
DropdownMenu.ZIndex = 100
DropdownMenu.Parent = DBBottomBar

local DDCorner = Instance.new("UICorner") DDCorner.CornerRadius = UDim.new(0, 8) DDCorner.Parent = DropdownMenu
local DDLayout = Instance.new("UIListLayout") DDLayout.Padding = UDim.new(0, 5) DDLayout.SortOrder = Enum.SortOrder.LayoutOrder DDLayout.Parent = DropdownMenu
local DDPadding = Instance.new("UIPadding") DDPadding.PaddingTop = UDim.new(0, 5) DDPadding.PaddingBottom = UDim.new(0, 5) DDPadding.PaddingLeft = UDim.new(0, 5) DDPadding.PaddingRight = UDim.new(0, 5) DDPadding.Parent = DropdownMenu

local function CreateDropdownItem(text, layoutOrder)
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(1, 0, 0, 30) btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35) btn.Text = text btn.TextColor3 = Color3.fromRGB(255, 255, 255) btn.TextSize = 10 btn.Font = Enum.Font.GothamBold btn.LayoutOrder = layoutOrder btn.ZIndex = 101 btn.Parent = DropdownMenu
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 4) corner.Parent = btn
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.1) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.1) end)
    return btn
end

local CopyAllBtn = CreateDropdownItem("1. COPY ALL (PATHS & CALLS)", 1)
local CopyCallsBtn = CreateDropdownItem("2. COPY ONLY CALLS", 2)
local CopyPathsBtn = CreateDropdownItem("3. COPY ONLY PATHS", 3)

DBDropdownBtn.MouseButton1Click:Connect(function()
    DropdownMenu.Visible = not DropdownMenu.Visible
    if DropdownMenu.Visible then
        DropdownMenu.Size = UDim2.new(0, 220, 0, 0)
        Tween(DropdownMenu, {Size = UDim2.new(0, 220, 0, 115)}, 0.25)
    end
end)

-- TAB ANIMATIONS
SpyTabBtn.MouseButton1Click:Connect(function()
    SpyTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) SpyTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    DatabaseTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150) DatabaseTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    DropdownMenu.Visible = false
    Tween(ScreensContainer, {Position = UDim2.new(0, 0, 0, 45)})
end)
DatabaseTabBtn.MouseButton1Click:Connect(function()
    DatabaseTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255) DatabaseTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SpyTabBtn.TextColor3 = Color3.fromRGB(150, 150, 150) SpyTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Tween(ScreensContainer, {Position = UDim2.new(-1, 0, 0, 45)})
end)

-- ============================================
-- PATH & SERIALIZATION LOGIC
-- ============================================
local function GetInstancePath(instance)
    if not instance then return "nil" end
    if instance.Parent == nil then return string.format('nil -- [Destroyed: "%s"]', instance.Name) end
    local current = instance local pathAfterCharacter = {} local characterFound = nil
    while current and current ~= game do
        if current.Parent == Workspace then
            local player = Players:FindFirstChild(current.Name)
            if player and (current:FindFirstChildOfClass("Humanoid") or current:FindFirstChild("Humanoid")) then
                characterFound = true break
            end
        end
        table.insert(pathAfterCharacter, 1, current.Name)
        current = current.Parent
    end
    if characterFound then
        local path = 'game:GetService("Players").LocalPlayer.Character'
        for _, name in ipairs(pathAfterCharacter) do path = path .. string.format(':WaitForChild("%s")', name:gsub('"', '\\"')) end
        return path
    end
    local segments = {} current = instance
    while current and current ~= game do table.insert(segments, 1, current) current = current.Parent end
    local path = "game"
    for _, obj in ipairs(segments) do
        local name = obj.Name:gsub('"', '\\"')
        if obj.Parent == game then path = string.format('game:GetService("%s")', obj.Name)
        elseif obj == LocalPlayer then path = path .. ".LocalPlayer"
        elseif obj.Parent == LocalPlayer and obj.Name == "Character" then path = path .. ".Character"
        else path = path .. string.format(':WaitForChild("%s")', name) end
    end
    return path
end

local function SerializeValue(value, depth, seen)
    depth = depth or 0 seen = seen or {}
    if depth > Settings.MaxSerializationDepth then return "\"[Max Depth]\"" end
    if seen[value] then return "\"[Circular]\"" end
    local valueType = typeof(value)
    
    if valueType == "string" then return "\"" .. value:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n"):gsub("\t", "\\t") .. "\""
    elseif valueType == "number" or valueType == "boolean" then return tostring(value)
    elseif valueType == "nil" then return "nil"
    elseif valueType == "Instance" then return GetInstancePath(value)
    elseif valueType == "table" then
        seen[value] = true
        local items = {}
        for k, v in pairs(value) do
            local key = type(k) == "string" and k:match("^[A-Za-z_][A-Za-z0-9_]*$") and k or "[" .. SerializeValue(k, depth + 1, seen) .. "]"
            table.insert(items, key .. " = " .. SerializeValue(v, depth + 1, seen))
        end
        return "{" .. table.concat(items, ", ") .. "}"
    elseif valueType == "Vector3" then return string.format("Vector3.new(%.4f, %.4f, %.4f)", value.X, value.Y, value.Z)
    elseif valueType == "CFrame" then return string.format("CFrame.new(%.4f, %.4f, %.4f)", value.X, value.Y, value.Z)
    elseif valueType == "EnumItem" then return tostring(value)
    else return "\"[" .. valueType .. "]\"" end
end

local function FormatArgs(args)
    if type(args) ~= "table" then return "" end
    local formatted = {}
    for _, v in ipairs(args) do table.insert(formatted, SerializeValue(v)) end
    return table.concat(formatted, ",\n    ")
end

-- ============================================
-- SPY CORE LOGIC (SAFE THREADING)
-- ============================================
local function UpdateStatus()
    StatusLabel.Text = string.format("CAPTURED: %d | CALLS: %d", RemoteStats.Count, RemoteStats.Total)
end

local function RenderCodeView(remote)
    local logs = RemoteLogs[remote] or {}
    if #logs > 0 then
        local log = logs[#logs]
        local isEvent = remote:IsA("RemoteEvent")
        local remotePath = GetInstancePath(remote)
        local method = isEvent and "FireServer" or "InvokeServer"
        
        local argsFormatted = {}
        for _, v in ipairs(log.args) do table.insert(argsFormatted, SerializeValue(v)) end
        
        local code = string.format("-- Target: %s\n-- Type: %s\n\nlocal args = {\n    %s\n}\n\n", remote.Name, isEvent and "RemoteEvent" or "RemoteFunction", table.concat(argsFormatted, ",\n    "))
        code = code .. string.format("%s:%s(unpack(args))", remotePath, method)
        CodeView.Text = code
    end
end

local function CreateRemoteButton(remote)
    if RemoteButtons[remote] then return end
    RemoteStats.Count = RemoteStats.Count + 1
    
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(1, 0, 0, 32) btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) btn.Text = "" btn.AutoButtonColor = false btn.LayoutOrder = RemoteStats.Count btn.Parent = RemoteList
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = btn
    
    local typeIndicator = Instance.new("TextLabel") typeIndicator.Size = UDim2.new(0, 20, 1, 0) typeIndicator.Position = UDim2.new(0, 5, 0, 0) typeIndicator.BackgroundTransparency = 1 typeIndicator.Text = remote:IsA("RemoteEvent") and "E" or "F" typeIndicator.TextColor3 = remote:IsA("RemoteEvent") and Color3.fromRGB(150, 150, 255) or Color3.fromRGB(255, 150, 150) typeIndicator.TextSize = 14 typeIndicator.Font = Enum.Font.GothamBold typeIndicator.Parent = btn
    local nameLabel = Instance.new("TextLabel") nameLabel.Size = UDim2.new(1, -30, 1, 0) nameLabel.Position = UDim2.new(0, 30, 0, 0) nameLabel.BackgroundTransparency = 1 nameLabel.Text = remote.Name nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220) nameLabel.TextSize = 12 nameLabel.Font = Enum.Font.GothamBold nameLabel.TextXAlignment = Enum.TextXAlignment.Left nameLabel.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        SelectedRemote = remote
        for _, b in pairs(RemoteButtons) do Tween(b, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.1) end
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.1)
        local logs = RemoteLogs[remote] or {}
        if #logs > 0 then LastSelectedArgs = logs[#logs].args end
        RenderCodeView(remote)
    end)
    
    RemoteButtons[remote] = btn
    RemoteList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 5)
    UpdateStatus()
end

local function safeClone(obj, seen, depth)
    depth = depth or 0
    if depth > Settings.MaxSerializationDepth then return tostring(obj) end
    if type(obj) == "table" then
        seen = seen or {} if seen[obj] then return "\"[Circular]\"" end seen[obj] = true
        local clone = {}
        for k, v in pairs(obj) do clone[type(k) == "table" and tostring(k) or k] = safeClone(v, seen, depth + 1) end
        return clone
    end return obj
end

local function LogRemoteSafe(remote, args)
    if not Settings.Active then return end
    if Settings.IgnoreSpam and SpamRemotes[remote.Name] then return end
    
    pcall(function()
        if not RemoteButtons[remote] then CreateRemoteButton(remote) end
        RemoteStats.Total = RemoteStats.Total + 1
        if not RemoteLogs[remote] then RemoteLogs[remote] = {} end
        
        table.insert(RemoteLogs[remote], {args = safeClone(args), time = tick()})
        if #RemoteLogs[remote] > Settings.MaxLogsPerRemote then table.remove(RemoteLogs[remote], 1) end
        
        if SelectedRemote == remote then 
            LastSelectedArgs = RemoteLogs[remote][#RemoteLogs[remote]].args
            RenderCodeView(remote) 
        end
        UpdateStatus()
    end)
end

local function SetupHooks()
    if hookmetamethod then
        originalnamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and typeof(self) == "Instance" then
                if method == "FireServer" or method == "fireServer" or method == "InvokeServer" or method == "invokeServer" then
                    local args = {...}
                    task.spawn(LogRemoteSafe, self, args)
                end
            end
            return originalnamecall(self, ...)
        end)
    end
end

-- ============================================
-- DATABASE SCANNER LOGIC
-- ============================================
local DBButtons = {}

local function CreateDBButton(remote)
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(1, 0, 0, 32) btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) btn.Text = "" btn.AutoButtonColor = false btn.Parent = DBList
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 6) corner.Parent = btn
    
    local typeIndicator = Instance.new("TextLabel") typeIndicator.Size = UDim2.new(0, 20, 1, 0) typeIndicator.Position = UDim2.new(0, 5, 0, 0) typeIndicator.BackgroundTransparency = 1 typeIndicator.Text = remote:IsA("RemoteEvent") and "E" or "F" typeIndicator.TextColor3 = remote:IsA("RemoteEvent") and Color3.fromRGB(150, 150, 255) or Color3.fromRGB(255, 150, 150) typeIndicator.TextSize = 14 typeIndicator.Font = Enum.Font.GothamBold typeIndicator.Parent = btn
    local nameLabel = Instance.new("TextLabel") nameLabel.Size = UDim2.new(1, -30, 1, 0) nameLabel.Position = UDim2.new(0, 30, 0, 0) nameLabel.BackgroundTransparency = 1 nameLabel.Text = remote.Name nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220) nameLabel.TextSize = 12 nameLabel.Font = Enum.Font.GothamBold nameLabel.TextXAlignment = Enum.TextXAlignment.Left nameLabel.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(DBButtons) do Tween(b, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.1) end
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.1)
        
        local path = GetInstancePath(remote)
        local method = remote:IsA("RemoteEvent") and "FireServer" or "InvokeServer"
        DBCodeView.Text = string.format("-- Database Entry\n-- Name: %s\n-- Class: %s\n\nlocal Target = %s\n\n-- Example Call:\nTarget:%s()", remote.Name, remote.ClassName, path, method)
    end)
    table.insert(DBButtons, btn)
end

ScanBtn.MouseButton1Click:Connect(function()
    ScanBtn.Text = "SCANNING..."
    for _, btn in pairs(DBButtons) do btn:Destroy() end DBButtons = {}
    ScannedRemotesData = {}
    DBCodeView.Text = "-- Scanning game structure. Please wait..."
    task.wait(0.1)
    
    local foundCount = 0
    local services = {Workspace, ReplicatedStorage, Players, game:GetService("Lighting"), game:GetService("StarterGui"), game:GetService("StarterPlayer")}
    
    for _, service in ipairs(services) do
        pcall(function()
            for _, desc in ipairs(service:GetDescendants()) do
                if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                    table.insert(ScannedRemotesData, desc)
                    CreateDBButton(desc)
                    foundCount = foundCount + 1
                end
            end
        end)
    end
    
    DBList.CanvasSize = UDim2.new(0, 0, 0, DBListLayout.AbsoluteContentSize.Y + 5)
    DBStatusLabel.Text = string.format("FOUND: %d REMOTES", foundCount)
    DBCodeView.Text = "-- Scan Complete.\n-- Select a remote from the list."
    ScanBtn.Text = "SCAN GAME"
end)

local function ExportDatabase(mode)
    if not setclipboard then return end
    if #ScannedRemotesData == 0 then DBCodeView.Text = "-- [SYSTEM] Database is empty. Scan the game first." return end
    
    local out = "-- GLOBAL SCRIPTS: DATABASE EXPORT\n\n"
    for _, remote in ipairs(ScannedRemotesData) do
        local path = GetInstancePath(remote)
        local method = remote:IsA("RemoteEvent") and "FireServer" or "InvokeServer"
        
        if mode == 1 then
            out = out .. string.format("local %s = %s\n%s:%s()\n\n", remote.Name, path, remote.Name, method)
        elseif mode == 2 then
            out = out .. string.format("%s:%s()\n", path, method)
        elseif mode == 3 then
            out = out .. string.format("local %s = %s\n", remote.Name, path)
        end
    end
    
    setclipboard(out)
    DBCodeView.Text = "-- [SYSTEM] Successfully copied database to clipboard."
    DropdownMenu.Visible = false
end

CopyAllBtn.MouseButton1Click:Connect(function() ExportDatabase(1) end)
CopyCallsBtn.MouseButton1Click:Connect(function() ExportDatabase(2) end)
CopyPathsBtn.MouseButton1Click:Connect(function() ExportDatabase(3) end)

-- ============================================
-- BUTTON EVENTS
-- ============================================
ToggleBtn.MouseButton1Click:Connect(function()
    Settings.Active = not Settings.Active
    ToggleBtn.Text = Settings.Active and "PAUSE" or "RESUME"
    ToggleBtn.TextColor3 = Settings.Active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 50, 50)
end)
FilterBtn.MouseButton1Click:Connect(function()
    Settings.IgnoreSpam = not Settings.IgnoreSpam
    FilterBtn.Text = Settings.IgnoreSpam and "SPAM FILTER: ON" or "SPAM FILTER: OFF"
    FilterBtn.TextColor3 = Settings.IgnoreSpam and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 50, 50)
end)
CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard and CodeView.Text ~= "" then
        setclipboard(CodeView.Text)
        CodeView.Text = CodeView.Text .. "\n\n-- [SYSTEM] Copied to clipboard."
    end
end)
ClearBtn.MouseButton1Click:Connect(function()
    RemoteLogs = {} for _, btn in pairs(RemoteButtons) do btn:Destroy() end
    RemoteButtons = {} RemoteStats = {Total = 0, Count = 0} SelectedRemote = nil LastSelectedArgs = nil
    UpdateStatus() CodeView.Text = "-- [SYSTEM] Cache cleared."
end)

-- Power Feature: Replay Once
ReplayBtn.MouseButton1Click:Connect(function()
    if SelectedRemote and LastSelectedArgs then
        CodeView.Text = CodeView.Text .. "\n\n-- [SYSTEM] REPLAYING CALL NOW..."
        if SelectedRemote:IsA("RemoteEvent") then
            SelectedRemote:FireServer(unpack(LastSelectedArgs))
        elseif SelectedRemote:IsA("RemoteFunction") then
            task.spawn(function()
                local response = SelectedRemote:InvokeServer(unpack(LastSelectedArgs))
                print("[GLOBAL SCRIPTS] Replay Response:", response)
            end)
        end
    else
        CodeView.Text = CodeView.Text .. "\n\n-- [ERROR] Select a remote from the list first."
    end
end)

-- God Mode Feature: Spam Remote (Stress Test)
local isSpamming = false
StressBtn.MouseButton1Click:Connect(function()
    if not SelectedRemote or not LastSelectedArgs then 
        CodeView.Text = CodeView.Text .. "\n\n-- [ERROR] Select a remote first to stress test."
        return 
    end
    
    if isSpamming then return end
    isSpamming = true
    
    CodeView.Text = CodeView.Text .. "\n\n-- [WARNING] STRESS TEST INITIATED. SENDING 100 PACKETS..."
    
    task.spawn(function()
        if SelectedRemote:IsA("RemoteEvent") then
            for i = 1, 100 do
                SelectedRemote:FireServer(unpack(LastSelectedArgs))
                task.wait(0.01)
            end
        end
        isSpamming = false
        CodeView.Text = CodeView.Text .. "\n-- [SYSTEM] STRESS TEST COMPLETE."
    end)
end)

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false MinimizedButton.Visible = true end)
MinimizedButton.MouseButton1Click:Connect(function() MinimizedButton.Visible = false MainFrame.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if originalnamecall then hookmetamethod(game, "__namecall", originalnamecall) end
    getgenv().GlobalScriptsRemoteSpy = nil
end)

getgenv().GlobalScriptsRemoteSpy = {Active = true}
SetupHooks()
print("[GLOBAL SCRIPTS] Protocol V5 Injected Successfully.")
