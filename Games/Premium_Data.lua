-- [[ Payload Script | Global Scripts Development ]] --
-- Возвращаем функцию, которую вызовет Лоадер

return function(Env, PassedKey)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Наш настоящий ключ
    local ExpectedKey = "Global-Scripts-2026-Gen2-2fhjg42cmb053nffas"

    -- [[ 1. ПРОВЕРКА КЛЮЧА ]] --
    if PassedKey ~= ExpectedKey then
        local reasontext = [[
You have been kicked for incorrect key script.
An attempt was made to compromise the script, or the script key was empty.
-
!! Upon a second hacking attempt, you will be permanently banned and unable to use the script. !!
]]
        LocalPlayer:Kick(reasontext)
        return -- Останавливаем выполнение скрипта
    end

    -- [[ 2. ОСНОВНАЯ ФУНКЦИЯ СКРИПТА ]] --
    local function TheScript()
        -- Создаем категорию во вкладке Home, используя переданный Env
        local HomeTab = Env.TabHome
        local UpdatesTab = Env.TabUpdates
        local TabGames = Env.TabGames
        local TabVisual = Env.Visual
        local TabMisc = Env.TabMiscellaneous
        local TabConfig = Env.TabConfigurator
        local TabSettings = Env.TabSettings
        
        -- [[ Home Tab ]] --
        HomeTab:CreateDivider({ line = true, spacing = 12 })
        HomeTab:CreateSection({ name = "Profile", icon = "" })
        HomeTab:CreateText({
            name = "Your Plan: Free",
            text = "All common functions.",
        })
        
    end

    -- [[ 3. ЗАПУСК ]] --
    -- Так как проверка ключа пройдена, запускаем построение UI
    TheScript()

end
