-- Script para King Legacy - Auto Kill com Teclas 1-4
-- LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Aguardar o player carregar
repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

-- Variáveis de controle
local autoKillEnabled = false
local targetPlayer = nil
local connection = nil
local autoClickEnabled = true

-- Criar a GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KingLegacyAutoKill"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 220)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
title.Text = "KING LEGACY AUTO KILL"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 45)
toggleButton.Position = UDim2.new(0.1, 0, 0.25, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
toggleButton.Text = "ATIVAR AUTO KILL"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = mainFrame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 6)

local autoClickToggle = Instance.new("TextButton")
autoClickToggle.Size = UDim2.new(0.35, 0, 0, 30)
autoClickToggle.Position = UDim2.new(0.1, 0, 0.55, 0)
autoClickToggle.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
autoClickToggle.Text = "AUTO CLICK: ON"
autoClickToggle.TextColor3 = Color3.new(1, 1, 1)
autoClickToggle.Font = Enum.Font.Gotham
autoClickToggle.TextSize = 12
autoClickToggle.Parent = mainFrame
Instance.new("UICorner", autoClickToggle).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0, 25)
statusLabel.Position = UDim2.new(0.1, 0, 0.7, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Desativado"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextSize = 14
statusLabel.Parent = mainFrame

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(0.8, 0, 0, 25)
targetLabel.Position = UDim2.new(0.1, 0, 0.85, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Alvo: Nenhum"
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetLabel.TextSize = 12
targetLabel.Parent = mainFrame

-- Encontrar player mais próximo
local function findNearestPlayer()
    local nearest, shortest = nil, math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, math.huge end

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            local oRoot = other.Character:FindFirstChild("HumanoidRootPart")
            local hum = other.Character:FindFirstChildOfClass("Humanoid")
            if oRoot and hum and hum.Health > 0 then
                local dist = (root.Position - oRoot.Position).Magnitude
                if dist < shortest and dist < 100 then
                    shortest = dist
                    nearest = other
                end
            end
        end
    end
    return nearest, shortest
end

-- Clique rápido
local function rapidAutoClick()
    if not autoClickEnabled then return end
    for i = 1, 2 do
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
        task.wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
        task.wait(0.03)
    end
end

-- Sequência de ataques
local function executeAttackSequence()
    local attackKeys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.E, Enum.KeyCode.B}
    for _, key in ipairs(attackKeys) do
        if not autoKillEnabled then break end
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.12)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        rapidAutoClick()
        task.wait(0.08)
    end
end

-- Teleporte suave até alvo
local function smoothTeleportToTarget()
    if not targetPlayer or not targetPlayer.Character then return end
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local pRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot or not pRoot then return end
    local dir = (tRoot.Position - pRoot.Position).Unit
    local pos = tRoot.Position - dir * 5
    pRoot.CFrame = CFrame.new(pos, tRoot.Position)
end

-- Teclas numéricas (1-4)
local numberKeys = {
    [1] = Enum.KeyCode.One,
    [2] = Enum.KeyCode.Two,
    [3] = Enum.KeyCode.Three,
    [4] = Enum.KeyCode.Four,
}

-- Loop do auto kill
local lastExecution = 0
local cooldown = 1.5 -- segundos entre cada ciclo

local function autoKillLoop()
    if not autoKillEnabled then return end

    -- Cooldown para evitar rodar muitas vezes por segundo
    if tick() - lastExecution < cooldown then return end
    lastExecution = tick()

    -- Verificar se o alvo atual ainda é válido
    if targetPlayer and targetPlayer.Character then
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            targetPlayer = nil
            targetLabel.Text = "Alvo: Nenhum"
        end
    end

    -- Procurar novo alvo se necessário
    if not targetPlayer then
        local nearest, dist = findNearestPlayer()
        if nearest and dist < 80 then
            targetPlayer = nearest
            targetLabel.Text = "Alvo: " .. nearest.Name
        else
            targetLabel.Text = "Alvo: Procurando..."
            return
        end
    end

    -- Atacar o alvo
    if targetPlayer and targetPlayer.Character then
        smoothTeleportToTarget()

        -- Percorrer as teclas 1-4
        for i = 1, 4 do
            if not autoKillEnabled then break end
            
            local key = numberKeys[i]
            if key then
                -- Pressionar tecla numérica
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(0.3)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                task.wait(0.2)
            end

            -- Executar sequência de ataques
            executeAttackSequence()
            task.wait(0.3)
        end
    end
end

-- Botão principal
toggleButton.MouseButton1Click:Connect(function()
    autoKillEnabled = not autoKillEnabled
    
    if autoKillEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        toggleButton.Text = "DESATIVAR AUTO KILL"
        statusLabel.Text = "Status: Ativado"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Iniciar o loop
        connection = RunService.Heartbeat:Connect(autoKillLoop)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        toggleButton.Text = "ATIVAR AUTO KILL"
        statusLabel.Text = "Status: Desativado"
        statusLabel.TextColor3 = Color3.new(1, 1, 1)
        
        -- Parar o loop
        if connection then 
            connection:Disconnect() 
            connection = nil 
        end
        targetPlayer = nil
        targetLabel.Text = "Alvo: Nenhum"
    end
end)

-- Botão auto click
autoClickToggle.MouseButton1Click:Connect(function()
    autoClickEnabled = not autoClickEnabled
    if autoClickEnabled then
        autoClickToggle.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        autoClickToggle.Text = "AUTO CLICK: ON"
    else
        autoClickToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        autoClickToggle.Text = "AUTO CLICK: OFF"
    end
end)

-- Atalho Shift+T para teleporte
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        smoothTeleportToTarget()
    end
end)

-- Limpeza
screenGui.Destroying:Connect(function()
    if connection then 
        connection:Disconnect() 
    end
end)

-- Notificação de sucesso
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "King Legacy Auto Kill",
    Text = "Script carregado com sucesso!",
    Duration = 3
})

print("✅ King Legacy Auto Kill carregado!")
print("🎯 Use Shift + T para teleporte rápido")
