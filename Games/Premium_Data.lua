-- [[ Payload Script | Global Scripts Development ]] --
-- Возвращаем функцию, которую вызовет Лоадер

return function(Env, PassedKey)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local MarketplaceService = game:GetService("MarketplaceService")

    -- Наш настоящий ключ
    local ExpectedKey = "Global-Scripts-2026-Gen2-2fhjg42ষ্ঠান42cmb053nffas"

    -- [[ 1. ПРОВЕРКА КЛЮЧА ]] --
    if PassedKey ~= ExpectedKey then
        local reasontext = [[
You have been kicked for incorrect script key.
An attempt was made to compromise the script, or the script key was empty.
-
!! Upon a second hacking attempt, you will be permanently banned and unable to use the script. !!
]]
        LocalPlayer:Kick(reasontext)
        return -- Останавливаем выполнение скрипта
    end

    -- [[ 2. СБОР ИНФОРМАЦИИ (ДЛЯ HOME TAB) ]] --
    -- Получаем имя экзекутора (если функция поддерживается)
    local executorName = type(identifyexecutor) == "function" and identifyexecutor() or "Unknown Executor"
    
    -- Словарь статусов экзекуторов (синтаксис Lua: ["Ключ"] = "Значение")
    local supportedExecutors = {
        ["Real"] = "Supported (Stable) ✔️",
        ["Delta"] = "Supported (Stable) ✔️",
        ["Ronix"] = "Unstable (May crash) ⚠️",
        ["Velocity"] = "Not Checked ❓"
    }
    local execStatus = supportedExecutors[executorName] or "Unknown Compatibility"

    -- Получаем реальное название текущей игры
    local gameName = "Unknown Game"
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    -- [[ 3. ОСНОВНАЯ ФУНКЦИЯ СКРИПТА ]] --
    local function TheScript()
        -- Создаем локальные переменные из таблицы Env (исправлена опечатка TabVisual)
        local HomeTab = Env.TabHome
        local UpdatesTab = Env.TabUpdates
        local TabGames = Env.TabGames
        local TabVisual = Env.TabVisual 
        local TabMisc = Env.TabMiscellaneous
        local TabConfig = Env.TabConfigurator
        local TabSettings = Env.TabSettings
        
        -- [[ Home Tab ]] --
        HomeTab:CreateDivider({ line = true, spacing = 5 })
        HomeTab:CreateSection({ name = "Profile Info", icon = "" })
        
        HomeTab:CreateText({
            name = "👤 User: " .. LocalPlayer.Name .. " | Plan: Free",
            text = "All common functions available."
        })
        
        HomeTab:CreateDivider({ line = true, spacing = 5 })
        
        -- Вывод статуса экзекутора с объединением строк (..)
        HomeTab:CreateText({
            name = "💻 Executor: " .. executorName,
            text = "Status: " .. execStatus
        })
        
        HomeTab:CreateDivider({ line = true, spacing = 5 })
        
        -- Вывод названия текущей игры и ее PlaceId
        HomeTab:CreateText({
            name = "🎮 Current Game:",
            text = gameName .. " (" .. tostring(game.PlaceId) .. ")"
        })

        HomeTab:CreateDivider({ line = true, spacing = 5 })
        
        -- === ИДЕИ ДЛЯ ДОБАВЛЕНИЯ В HOME TAB ===
        HomeTab:CreateSection({ name = "Quick Actions", icon = "" })
        
        -- 1. Кнопка Rejoin (Перезаход на тот же сервер)
        HomeTab:CreateButton({
            name = "Rejoin Server",
            callback = function()
                local ts = game:GetService("TeleportService")
                ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        })

        -- 2. Кнопка Server Hop (Поиск сервера с меньшим пингом/другими игроками)
        HomeTab:CreateButton({
            name = "Server Hop",
            callback = function()
                -- Сюда позже встроим логику Server Hop, о которой ты упоминал
                Env.Window:Notify({
                    title = "Server Hop",
                    content = "Searching for a new server...",
                    duration = 3,
                    icon = ""
                })
            end
        })

        -- 3. Быстрое копирование Discord
        HomeTab:CreateButton({
            name = "Copy Discord Invite",
            callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/your_invite_code")
                    Env.Window:Notify({
                        title = "Copied!",
                        content = "Discord invite linked copied to clipboard.",
                        duration = 3,
                        icon = ""
                    })
                end
            end
        })
    end

    -- [[ 4. ЗАПУСК ]] --
    TheScript()

end
