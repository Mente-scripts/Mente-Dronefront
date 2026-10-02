-- [[ Mente | Dronefront ]] --
-- [[ Разработчик: @Mente_Rox ]] --
-- [[ Используется библиотека WindUI ]] --

-- Защита от двойного запуска
if _G.MenteLoaded then return end
_G.MenteLoaded = true

-- Настройки функций (хранят состояния включено/выключено)
local Settings = {
    DroneAimbot = false,
    AntiDrone = false,
    ESP = false,
}

local LogoID = "rbxassetid://138712853718259" -- Твой ID логотипа

-- [ ЗАГРУЗКА БИБЛИОТЕКИ WINDUI ]
-- Используем стабильную версию библиотеки
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/BearK4v/WindUI/main/source.lua"))()

-- [ СОЗДАНИЕ ОКНА ]
local Window = WindUI:CreateWindow({
    Title = "Mente | Dronefront", -- Заголовок
    Icon = LogoID,               -- Твой логотип
    Author = "@Mente_Rox",      -- Автор
    Folder = "MenteConfig",      -- Папка для сохранений (если понадобятся)
    Theme = "Dark",              -- Тема (Dark идеально подходит под черно-белый стиль)
    Accent = Color3.fromRGB(255, 255, 255), -- Белые акценты интерфейса
    Transparency = 0.1,          -- Небольшая прозрачность
    Blur = true,                 -- Размытие фона
    Keybind = Enum.KeyCode.RightControl -- Кнопка для скрытия меню на ПК
})

-- У WindUI есть встроенная красивая плавающая кнопка для телефона, она создается автоматически.

-- [ ВКЛАДКА: АИМБОТ ]
local TabAimbot = Window:CreateTab("Aimbot", "target") -- Иконка прицела

TabAimbot:CreateToggle({
    Name = "Drone Aimbot (Оператор)",
    Desc = "Автонаведение дрона на вражеских игроков",
    Value = Settings.DroneAimbot, -- Начальное значение
    Callback = function(Value)
        Settings.DroneAimbot = Value
        WindUI:Notify({
            Title = "Mente",
            Content = "Drone Aimbot: " .. (Value and "Включен" or "Выключен"),
            Time = 2
        })
    end
})

TabAimbot:CreateToggle({
    Name = "Anti-Drone Aimbot (ПВО)",
    Desc = "Автонаведение зенитки/оружия на вражеские дроны",
    Value = Settings.AntiDrone,
    Callback = function(Value)
        Settings.AntiDrone = Value
        WindUI:Notify({
            Title = "Mente",
            Content = "Anti-Drone Aimbot: " .. (Value and "Включен" or "Выключен"),
            Time = 2
        })
    end
})

-- [ ВКЛАДКА: ВИЗУАЛЫ ]
local TabVisuals = Window:CreateTab("Visuals", "eye") -- Иконка глаза

TabVisuals:CreateToggle({
    Name = "ESP (Подсветка игроков)",
    Desc = "Показывает врагов сквозь стены",
    Value = Settings.ESP,
    Callback = function(Value)
        Settings.ESP = Value
        WindUI:Notify({
            Title = "Mente",
            Content = "ESP: " .. (Value and "Включен" or "Выключен"),
            Time = 2
        })
    end
})

-- [ ВКЛАДКА: ИНФО ]
local TabInfo = Window:CreateTab("Credits", "user") -- Иконка пользователя

TabInfo:CreateParagraph({
    Title = "Связь с разработчиком",
    Content = "Tg: @Mente_Rox\n\nПрисоединяйтесь к каналу для обновлений!"
})

TabInfo:CreateButton({
    Name = "Скопировать Telegram",
    Callback = function()
        setclipboard("@Mente_Rox")
        WindUI:Notify({
            Title = "Mente",
            Content = "Ссылка скопирована в буфер обмена!",
            Time = 3
        })
    end
})


-- =====================================
-- [ ЛОГИКА ФУНКЦИОНАЛА ]
-- Оставляем твою рабочую и оптимизированную логику
-- =====================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Функция поиска ближайшей цели
local function GetClosestTarget(targetType)
    local closestDist = math.huge
    local closestTarget = nil

    if targetType == "Player" then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestTarget = player.Character.HumanoidRootPart
                    end
                end
            end
        end
    elseif targetType == "Drone" then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():match("drone") or obj.Name:lower():match("uav")) and obj:FindFirstChild("MainPart") then
                local pos, onScreen = Camera:WorldToViewportPoint(obj.MainPart.Position)
                if onScreen then
                    local dist = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestTarget = obj.MainPart
                    end
                end
            end
        end
    end
    return closestTarget
end

-- Цикл Аимбота (RenderStepped для плавности)
RunService.RenderStepped:Connect(function()
    -- Drone Aimbot
    if Settings.DroneAimbot then
        local target = GetClosestTarget("Player")
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- Anti-Drone Aimbot
    if Settings.AntiDrone then
        local target = GetClosestTarget("Drone")
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- Цикл ESP (Highlight)
task.spawn(function()
    while task.wait(1) do
        if Settings.ESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not player.Character:FindFirstChild("MenteESP") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "MenteESP"
                        highlight.FillColor = Color3.fromRGB(255, 255, 255) -- Белая заливка
                        highlight.OutlineColor = Color3.fromRGB(0, 0, 0) -- Черная обводка
                        highlight.FillTransparency = 0.5
                        highlight.Parent = player.Character
                    end
                end
            end
        else
            -- Очистка ESP
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("MenteESP") then
                    player.Character.MenteESP:Destroy()
                end
            end
        end
    end
end)