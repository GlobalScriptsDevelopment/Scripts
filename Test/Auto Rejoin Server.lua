
loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/EvadeEvent"))()
print(" Активирован фарм вещей")
local WAIT_TIME = 300       -- Время ожидания в секундах (10 минут)
local PLACE_ID = game.PlaceId -- Идентификатор текущей игры
local CURSOR_COLOR = Color3.fromRGB(255, 0, 0) -- Цвет курсора (сейчас красный)
local CURSOR_SIZE = 15       -- Размер курсора в пикселях

print("[Система] Скрипт активирован. Курсор включен. Ожидание 1 минут...")

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. СОЗДАНИЕ НАРИСОВАННОГО КУРСОРА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomCursorGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999 -- Поверх всех остальных элементов интерфейса
ScreenGui.Parent = PlayerGui

-- Сам нарисованный указатель (точка/квадрат)
local CursorFrame = Instance.new("Frame")
CursorFrame.Size = UDim2.new(0, CURSOR_SIZE, 0, CURSOR_SIZE)
CursorFrame.BackgroundColor3 = CURSOR_COLOR
CursorFrame.BorderSizePixel = 0
CursorFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- Центрирование по мышке
CursorFrame.Parent = ScreenGui

-- Скругление, чтобы сделать его круглым (если нужен квадрат — удалите этот блок)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CursorFrame

-- Обводка для видимости на любом фоне
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Parent = CursorFrame

-- Функция обновления позиции курсора
local function updateCursor()
    local mouseLocation = UserInputService:GetMouseLocation()
    -- Корректировка GUI-координат (игнорируем верхний бар Roblox)
    CursorFrame.Position = UDim2.new(0, mouseLocation.X, 0, mouseLocation.Y - 36)
end

-- Привязка движения курсора к каждому кадру
local RenderConnection = RunService.RenderStepped:Connect(updateCursor)

-- Скрываем стандартный системный курсор Roblox
UserInputService.MouseIconEnabled = false

-- 2. ТАЙМЕР И ПЕРЕЗАХОД НА ДРУГОЙ СЕРВЕР
task.wait(WAIT_TIME)

print("[Система] Время вышло. Ищу новый сервер...")

-- Восстанавливаем стандартную мышь перед выходом
if RenderConnection then RenderConnection:Disconnect() end
UserInputService.MouseIconEnabled = true
ScreenGui:Destroy()

-- Функция телепортации
local function teleportToNewServer()
    local success, result = pcall(function()
        local url = "https://roblox.com" .. PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                print("[Система] Сервер найден! Телепортация...")
                TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, LocalPlayer)
                return
            end
        end
    end
    
    print("[Система] Используем стандартный телепорт...")
    TeleportService:Teleport(PLACE_ID, LocalPlayer)
end

teleportToNewServer()
