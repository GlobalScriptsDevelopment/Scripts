local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- === 1. НАСТРОЙКИ СИСТЕМЫ ТЕЛЕПОРТА ===
local WAYPOINTS = {
	Vector3.new(1886.0, 863.1, -6382.8),
	Vector3.new(2045.1, 1355.8, -6429.1),
	Vector3.new(2148.1, 2008.0, -6705.2),
	Vector3.new(2607.0, 2245.3, -7143.5),
	Vector3.new(3001.7, 2291.6, -7345.3)
}

local TWEEN_SPEED = 250
local CHUNK_DISTANCE = 150
local PAUSE_TIME = 0.15
local DROP_TIME = 0.35
local IS_TELEPORTING = false

local function FollowPath(targetPlayer, waypoints)
	if IS_TELEPORTING then return end
	IS_TELEPORTING = true

	local character = targetPlayer.Character
	if not character then IS_TELEPORTING = false return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		IS_TELEPORTING = false return
	end

	targetPlayer:SetAttribute("IsSystemMoving", true)
	local originalWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0

	local tpNoclip
	tpNoclip = RunService.Stepped:Connect(function()
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end)

	for index, targetPosition in ipairs(waypoints) do
		if humanoid.Health <= 0 then break end

		humanoidRootPart.Anchored = true
		local startPosition = humanoidRootPart.Position
		local totalDistance = (targetPosition - startPosition).Magnitude
		local steps = math.ceil(totalDistance / CHUNK_DISTANCE)

		if steps > 0 then
			for i = 1, steps do
				if humanoid.Health <= 0 then break end

				local alpha = i / steps
				local nextPosition = startPosition:Lerp(targetPosition, alpha)
				local currentLookVector = humanoidRootPart.CFrame.LookVector
				local targetCFrame = CFrame.new(nextPosition, nextPosition + currentLookVector)

				local currentStepDistance = (humanoidRootPart.Position - nextPosition).Magnitude
				local stepDuration = currentStepDistance / TWEEN_SPEED

				local tweenInfo = TweenInfo.new(stepDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
				local moveTween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
				
				moveTween:Play()
				moveTween.Completed:Wait()
				moveTween:Destroy()

				if i < steps then task.wait(PAUSE_TIME) end
			end
		end

		if index < #waypoints then
			humanoidRootPart.Anchored = false
			humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) 
			task.wait(DROP_TIME) 
		end
	end

	if tpNoclip then tpNoclip:Disconnect() end
	if humanoidRootPart and humanoidRootPart.Parent then
		humanoidRootPart.Anchored = false
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end
	if humanoid and humanoid.Parent then humanoid.WalkSpeed = originalWalkSpeed end
	if targetPlayer and targetPlayer.Parent then targetPlayer:SetAttribute("IsSystemMoving", false) end
	IS_TELEPORTING = false
end


-- === 2. СОЗДАНИЕ ИНТЕРФЕЙСА (GLASSMORPHISM) ===
local guiName = "SystemControlGui"
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild(guiName) then
	playerGui[guiName]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- Вспомогательная функция для применения стиля и анимаций
local function StyleButton(btn, origSizeX, origSizeY)
	btn.AnchorPoint = Vector2.new(0.5, 0.5)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	btn.BackgroundTransparency = 0.4
	btn.AutoButtonColor = false
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.7
	stroke.Thickness = 1.5
	stroke.Parent = btn

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, origSizeX - 10, 0, origSizeY - 5)
			}):Play()
		end
	end)

	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(btn, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, origSizeX, 0, origSizeY)
			}):Play()
		end
	end)
end

-- Вспомогательная функция для перетаскивания (Drag & Drop)
local function MakeDraggable(uiElement)
	local dragging, dragStart, startPos
	uiElement.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = uiElement.Position
		end
	end)
	uiElement.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			TweenService:Create(uiElement, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			}):Play()
		end
	end)
end

-- --- КНОПКА ТЕЛЕПОРТАЦИИ (УМЕНЬШЕННАЯ) ---
local TeleportButton = Instance.new("TextButton")
TeleportButton.Name = "TeleportButton"
TeleportButton.Size = UDim2.new(0, 120, 0, 40) -- Уменьшенный размер
TeleportButton.Position = UDim2.new(0.5, 0, 0.85, 0)
TeleportButton.Text = "TELEPORT"
TeleportButton.TextSize = 14
TeleportButton.Parent = ScreenGui
StyleButton(TeleportButton, 120, 40)
MakeDraggable(TeleportButton)

local tpIsDragThresholdMet = false
local tpDragStart = nil
TeleportButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		tpDragStart = input.Position
		tpIsDragThresholdMet = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if tpDragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		if (input.Position - tpDragStart).Magnitude > 5 then
			tpIsDragThresholdMet = true
		end
	end
end)
TeleportButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		tpDragStart = nil
		if not tpIsDragThresholdMet and not IS_TELEPORTING then
			TeleportButton.Text = "MOVING..."
			TeleportButton.TextColor3 = Color3.fromRGB(150, 255, 150)
			task.spawn(function()
				FollowPath(player, WAYPOINTS)
				TeleportButton.Text = "TELEPORT"
				TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			end)
		end
	end
end)


-- --- ПАНЕЛЬ FLY & NOCLIP ---
local FlyFrame = Instance.new("Frame")
FlyFrame.Name = "FlyFrame"
FlyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FlyFrame.Size = UDim2.new(0, 240, 0, 180)
FlyFrame.Position = UDim2.new(0.2, 0, 0.4, 0)
FlyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FlyFrame.BackgroundTransparency = 0.4
FlyFrame.Active = true
FlyFrame.Parent = ScreenGui
MakeDraggable(FlyFrame)

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = FlyFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FrameStroke.Color = Color3.fromRGB(255, 255, 255)
FrameStroke.Transparency = 0.7
FrameStroke.Thickness = 1.5
FrameStroke.Parent = FlyFrame

local Title = Instance.new("TextLabel")
Title.AnchorPoint = Vector2.new(0.5, 0.5)
Title.Size = UDim2.new(0, 140, 0, 30)
Title.Position = UDim2.new(0.35, 0, 0.15, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "CONTROL PANEL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Parent = FlyFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.88, 0, 0.15, 0)
CloseBtn.Text = "X"
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = FlyFrame
StyleButton(CloseBtn, 30, 30)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.72, 0, 0.15, 0)
MinBtn.Text = "-"
MinBtn.TextSize = 20
MinBtn.Parent = FlyFrame
StyleButton(MinBtn, 30, 30)

local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(0, 90, 0, 35)
FlyBtn.Position = UDim2.new(0.28, 0, 0.4, 0)
FlyBtn.Text = "FLY: OFF"
FlyBtn.TextSize = 12
FlyBtn.Parent = FlyFrame
StyleButton(FlyBtn, 90, 35)

local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0, 90, 0, 35)
NoclipBtn.Position = UDim2.new(0.72, 0, 0.4, 0)
NoclipBtn.Text = "NOCLIP: OFF"
NoclipBtn.TextSize = 12
NoclipBtn.Parent = FlyFrame
StyleButton(NoclipBtn, 90, 35)

local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0, 90, 0, 30)
UpBtn.Position = UDim2.new(0.28, 0, 0.62, 0)
UpBtn.Text = "UP"
UpBtn.TextSize = 12
UpBtn.Parent = FlyFrame
StyleButton(UpBtn, 90, 30)

local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0, 90, 0, 30)
DownBtn.Position = UDim2.new(0.72, 0, 0.62, 0)
DownBtn.Text = "DOWN"
DownBtn.TextSize = 12
DownBtn.Parent = FlyFrame
StyleButton(DownBtn, 90, 30)

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 40, 0, 30)
MinusBtn.Position = UDim2.new(0.2, 0, 0.85, 0)
MinusBtn.Text = "-"
MinusBtn.TextSize = 16
MinusBtn.Parent = FlyFrame
StyleButton(MinusBtn, 40, 30)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.AnchorPoint = Vector2.new(0.5, 0.5)
SpeedLabel.Size = UDim2.new(0, 60, 0, 30)
SpeedLabel.Position = UDim2.new(0.5, 0, 0.85, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Text = "SPD: 1"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.Parent = FlyFrame

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 40, 0, 30)
PlusBtn.Position = UDim2.new(0.8, 0, 0.85, 0)
PlusBtn.Text = "+"
PlusBtn.TextSize = 16
PlusBtn.Parent = FlyFrame
StyleButton(PlusBtn, 40, 30)


-- === 3. ЛОГИКА ИНТЕРФЕЙСА ===
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	for _, child in ipairs(FlyFrame:GetChildren()) do
		if child:IsA("GuiObject") and child ~= Title and child ~= CloseBtn and child ~= MinBtn and not child:IsA("UICorner") and not child:IsA("UIStroke") then
			child.Visible = not minimized
		end
	end
	if minimized then
		MinBtn.Text = "+"
		TweenService:Create(FlyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 240, 0, 50)}):Play()
	else
		MinBtn.Text = "-"
		TweenService:Create(FlyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 240, 0, 180)}):Play()
	end
end)


-- === 4. ЛОГИКА NOCLIP ===
local noclipActive = false
local manualNoclipConnection
NoclipBtn.MouseButton1Click:Connect(function()
	noclipActive = not noclipActive
	if noclipActive then
		NoclipBtn.Text = "NOCLIP: ON"
		NoclipBtn.TextColor3 = Color3.fromRGB(150, 255, 150)
		manualNoclipConnection = RunService.Stepped:Connect(function()
			local char = player.Character
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		NoclipBtn.Text = "NOCLIP: OFF"
		NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		if manualNoclipConnection then
			manualNoclipConnection:Disconnect()
			manualNoclipConnection = nil
		end
	end
end)


-- === 5. ИНТЕГРАЦИЯ ТВОЕЙ ЛОГИКИ FLY ===
local speeds = 1
local nowe = false
local tpwalking = false
local tis
local dis

game:GetService("StarterGui"):SetCore("SendNotification", { 
	Title = "SYSTEM LOADED";
	Text = "FLY & TELEPORT ACTIVE";
	Duration = 5;
})

FlyBtn.MouseButton1Down:connect(function()
	if nowe == true then
		nowe = false
		FlyBtn.Text = "FLY: OFF"
		FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
		player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	else 
		nowe = true
		FlyBtn.Text = "FLY: ON"
		FlyBtn.TextColor3 = Color3.fromRGB(150, 255, 150)

		for i = 1, speeds do
			task.spawn(function()
				local hb = RunService.Heartbeat	
				tpwalking = true
				local chr = player.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end
			end)
		end
		
		local Char = player.Character
		if Char:FindFirstChild("Animate") then Char.Animate.Disabled = true end
		local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

		for i,v in next, Hum:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end
		
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
		player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
		player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	end

	if player.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
		local torso = player.Character.Torso
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0

		local bg = Instance.new("BodyGyro", torso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = torso.CFrame
		local bv = Instance.new("BodyVelocity", torso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		
		if nowe == true then
			player.Character.Humanoid.PlatformStand = true
		end
		
		while nowe == true or player.Character.Humanoid.Health == 0 do
			RunService.RenderStepped:Wait()
			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then speed = maxspeed end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then speed = 0 end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		player.Character.Humanoid.PlatformStand = false
		if player.Character:FindFirstChild("Animate") then player.Character.Animate.Disabled = false end
		tpwalking = false
	else
		local UpperTorso = player.Character.UpperTorso
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0

		local bg = Instance.new("BodyGyro", UpperTorso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = UpperTorso.CFrame
		local bv = Instance.new("BodyVelocity", UpperTorso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		
		if nowe == true then
			player.Character.Humanoid.PlatformStand = true
		end
		
		while nowe == true or player.Character.Humanoid.Health == 0 do
			task.wait()
			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then speed = maxspeed end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then speed = 0 end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		player.Character.Humanoid.PlatformStand = false
		if player.Character:FindFirstChild("Animate") then player.Character.Animate.Disabled = false end
		tpwalking = false
	end
end)

UpBtn.MouseButton1Down:connect(function()
	tis = UpBtn.MouseEnter:connect(function()
		while tis do
			task.wait()
			player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
		end
	end)
end)

UpBtn.MouseLeave:connect(function()
	if tis then tis:Disconnect() tis = nil end
end)

DownBtn.MouseButton1Down:connect(function()
	dis = DownBtn.MouseEnter:connect(function()
		while dis do
			task.wait()
			player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
		end
	end)
end)

DownBtn.MouseLeave:connect(function()
	if dis then dis:Disconnect() dis = nil end
end)

player.CharacterAdded:Connect(function(char)
	task.wait(0.7)
	player.Character.Humanoid.PlatformStand = false
	if player.Character:FindFirstChild("Animate") then
		player.Character.Animate.Disabled = false
	end
end)

PlusBtn.MouseButton1Down:connect(function()
	speeds = speeds + 1
	SpeedLabel.Text = "SPD: " .. speeds
	if nowe == true then
		tpwalking = false
		for i = 1, speeds do
			task.spawn(function()
				local hb = RunService.Heartbeat	
				tpwalking = true
				local chr = player.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end
			end)
		end
	end
end)

MinusBtn.MouseButton1Down:connect(function()
	if speeds == 1 then
		SpeedLabel.Text = 'MIN: 1'
		task.wait(1)
		SpeedLabel.Text = "SPD: " .. speeds
	else
		speeds = speeds - 1
		SpeedLabel.Text = "SPD: " .. speeds
		if nowe == true then
			tpwalking = false
			for i = 1, speeds do
				task.spawn(function()
					local hb = RunService.Heartbeat	
					tpwalking = true
					local chr = player.Character
					local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
					while tpwalking and hb:Wait() and chr and hum and hum.Parent do
						if hum.MoveDirection.Magnitude > 0 then
							chr:TranslateBy(hum.MoveDirection)
						end
					end
				end)
			end
		end
	end
end)
