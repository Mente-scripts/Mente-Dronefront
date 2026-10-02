-- [[ Mente | Dronefront ]] --
-- [[ Разработчик: @Mente_Rox ]] --
-- [[ Используется библиотека WindUI ]] --

-- Защита от двойного запуска
if _G.MenteLoaded then return end
_G.MenteLoaded = true

-- Настройки функций
local Settings = {
    DroneAimbot = false,
    AntiDrone = false,
    ESP = false,
}

local LogoID = "rbxassetid://138712853718259"

-- [ ЗАГРУЗКА БИБЛИОТЕКИ WINDUI ]
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- [ СОЗДАНИЕ ОКНА ]
local Window = WindUI:CreateWindow({
    Title = "Mente | Dronefront",
    Icon = LogoID,
    Author = "@Mente_Rox",
    Folder = "MenteConfig",
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.RightControl,
    Transparent = true,
})

-- [ ВКЛАДКА: АИМБОТ ]
local TabAimbot = Window:Tab({
    Title = "Aimbot",
    Icon = "target",
})

TabAimbot:Toggle({
    Title = "Drone Aimbot (Оператор)",
    Desc = "Автонаведение дрона на вражеских игроков",
    Value = Settings.DroneAimbot,
    Callback = function(Value)
        Settings.DroneAimbot = Value
        WindUI:Notify({
            Title = "Mente",
            Content = "Drone Aimbot: " .. (Value and "Включен" or "Выключен"),
            Duration = 2
        })
    end
})

TabAimbot:Toggle({
    Title = "Anti-Drone Aimbot (ПВО)",
    Desc = "Автонаведение зенитки/оружия на вражеские дроны",
    Value = Settings.AntiDrone,
    Callback = function(Value)
        Settings.AntiDrone = Value
        WindUI:Notify({
            Title = "Mente",
            Content = "Anti-Drone Aimbot: " .. (Value and "Включен" or "Выключен"),
            Duration = 2
        })
    end
})

-- [ ВКЛАДКА: ВИЗУАЛЫ ]
local TabVisuals = Window:Tab({
    Title = "Visuals",
    Icon = "eye",
})

TabVisuals:Toggle({
    Title = "ESP (Подсветка игроков)",
    Desc = "Показывает врагов сквозь стены",
    Value = Settings.ESP,
    Callback = function(Value)
        Settings.ESP = Value
        WindUI:Notify({
            Title = "Mente",
            Content = "ESP: " .. (Value and "Включен" or "Выключен"),
            Duration = 2
        })
    end
})

-- [ ВКЛАДКА: ИНФО ]
local TabInfo = Window:Tab({
    Title = "Credits",
    Icon = "user",
})

TabInfo:Paragraph({
    Title = "Связь с разработчиком",
    Desc = "Tg: @Mente_Rox\n\nПрисоединяйтесь к каналу для обновлений!"
})

TabInfo:Button({
    Title = "Скопировать Telegram",
    Callback = function()
        setclipboard("@Mente_Rox")
        WindUI:Notify({
            Title = "Mente",
            Content = "Ссылка скопирована в буфер обмена!",
            Duration = 3
        })
    end
})

-- =====================================
-- [ ЛОГИКА ФУНКЦИОНАЛА ]
-- =====================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function GetClosestTarget(targetType)
    local closestDist = math.huge
    local closestTarget = nil

    if targetType == "Player" then
        for _, player in ipairs(Players:GetPlayers()) do
            if player \~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
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
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
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

RunService.RenderStepped:Connect(function()
    if Settings.DroneAimbot then
        local target = GetClosestTarget("Player")
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    if Settings.AntiDrone then
        local target = GetClosestTarget("Drone")
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Settings.ESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player \~= LocalPlayer and player.Character then
                    if not player.Character:FindFirstChild("MenteESP") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "MenteESP"
                        highlight.FillColor = Color3.fromRGB(255, 255, 255)
                        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
                        highlight.FillTransparency = 0.5
                        highlight.Parent = player.Character
                    end
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("MenteESP") then
                    player.Character.MenteESP:Destroy()
                end
            end
        end
    end
end)