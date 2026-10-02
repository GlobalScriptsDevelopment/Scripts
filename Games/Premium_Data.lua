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
        local WelcomeSection = Env.TabHome:CreateSection("Welcome Category")
        
        Env.TabHome:CreateParagraph({
            Title = "Authentication Successful",
            Content = "Script securely loaded from GitHub. Welcome to Global Scripts Hub, " .. LocalPlayer.Name .. "!"
        })

        Env.TabHome:CreateButton({
            Name = "Test Function",
            Callback = function()
                print("[Global Scripts]: Key matched. Functions are fully operational.")
            end,
        })

        -- Здесь ты можешь продолжать строить UI в других вкладках:
        -- local VisualSection = Env.TabVisual:CreateSection("ESP Settings")
        -- ...
    end

    -- [[ 3. ЗАПУСК ]] --
    -- Так как проверка ключа пройдена, запускаем построение UI
    TheScript()

end
