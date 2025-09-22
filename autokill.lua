-- Script para King Legacy - Auto Kill Final IMPROVADO
-- LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Criar a GUI com proteção contra morte
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KingLegacyAutoKillFinal"
screenGui.ResetOnSpawn = false -- Impede que a GUI resete quando o personagem morrer
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Adicionar efeito de sombra para melhor visualização
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.8
shadow.BorderSizePixel = 0
shadow.ZIndex = -1
shadow.Parent = mainFrame
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 12)

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
title.Text = "KING LEGACY AUTO KILL FINAL"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.85, 0, 0, 50)
toggleButton.Position = UDim2.new(0.075, 0, 0.22, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
toggleButton.Text = "ATIVAR AUTO KILL"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 15
toggleButton.Parent = mainFrame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 6)

local autoClickToggle = Instance.new("TextButton")
autoClickToggle.Size = UDim2.new(0.4, 0, 0, 35)
autoClickToggle.Position = UDim2.new(0.075, 0, 0.48, 0)
autoClickToggle.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
autoClickToggle.Text = "AUTO CLICK: ON"
autoClickToggle.TextColor3 = Color3.new(1, 1, 1)
autoClickToggle.Font = Enum.Font.GothamBold
autoClickToggle.TextSize = 13
autoClickToggle.Parent = mainFrame
Instance.new("UICorner", autoClickToggle).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.85, 0, 0, 30)
statusLabel.Position = UDim2.new(0.075, 0, 0.65, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Desativado"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = mainFrame

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(0.85, 0, 0, 25)
targetLabel.Position = UDim2.new(0.075, 0, 0.8, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Alvo: Nenhum | Slot: 1"
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetLabel.TextSize = 12
targetLabel.Parent = mainFrame

-- Botão de minimizar
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -30, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
minimizeButton.Text = "_"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.Parent = mainFrame
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 4)

-- Variáveis de controle
local autoKillEnabled = false
local targetPlayer = nil
local connection = nil
local autoClickEnabled = true
local lastSlotChange = 0
local slotCooldown = 1.5
local currentSlot = 1
local isMinimized = false
local originalSize = mainFrame.Size
local minimizedSize = UDim2.new(0, 300, 0, 45)

-- Função para minimizar/restaurar a GUI
local function toggleMinimize()
    if isMinimized then
        -- Restaurar
        mainFrame.Size = originalSize
        minimizeButton.Text = "_"
        isMinimized = false
    else
        -- Minimizar
        mainFrame.Size = minimizedSize
        minimizeButton.Text = "□"
        isMinimized = true
    end
end

minimizeButton.MouseButton1Click:Connect(toggleMinimize)

-- Aguardar o player carregar
local function waitForCharacter()
    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

-- Reconectar quando o personagem morrer
player.CharacterAdded:Connect(function(character)
    waitForCharacter()
    if autoKillEnabled then
        statusLabel.Text = "Status: ATIVADO (Reconectado)"
        task.wait(3) -- Pequeno delay após respawn
        statusLabel.Text = "Status: ATIVADO"
    end
end)

-- Inicializar
waitForCharacter()

local mouse = player:GetMouse()

-- Encontrar player mais próximo com alcance maior
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
                if dist < shortest and dist < 150 then
                    shortest = dist
                    nearest = other
                end
            end
        end
    end
    return nearest, shortest
end

-- Clique rápido melhorado
local function rapidAutoClick()
    if not autoClickEnabled then return end
    for i = 1, 3 do
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
        task.wait(0.02)
    end
end

-- Usar tecla J uma vez para empurrar jogadores
local function useJPush()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.J, false, game)
    task.wait(0.15)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.J, false, game)
    task.wait(0.1)
end

-- Sequência de ataques otimizada
local function executeAttackSequence()
    local attackKeys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.E, Enum.KeyCode.B}
    
    useJPush()
    
    for _, key in ipairs(attackKeys) do
        if not autoKillEnabled then break end
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        rapidAutoClick()
        task.wait(0.06)
    end
end

-- Teleporte melhorado para manter distância ideal
local function smoothTeleportToTarget()
    if not targetPlayer or not targetPlayer.Character then return end
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local pRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot or not pRoot then return end
    
    local dir = (tRoot.Position - pRoot.Position).Unit
    local distance = (tRoot.Position - pRoot.Position).Magnitude
    
    if distance < 8 then
        local pos = tRoot.Position - dir * 12
        pRoot.CFrame = CFrame.new(pos, tRoot.Position)
    else
        local pos = tRoot.Position - dir * 10
        pRoot.CFrame = CFrame.new(pos, tRoot.Position)
    end
end

-- Teclas numéricas (1-4)
local numberKeys = {
    [1] = Enum.KeyCode.One,
    [2] = Enum.KeyCode.Two,
    [3] = Enum.KeyCode.Three,
    [4] = Enum.KeyCode.Four,
}

-- Mudança de slot mais lenta
local function changeSlotSlowly()
    local currentTime = tick()
    if currentTime - lastSlotChange < slotCooldown then
        return currentSlot
    end
    
    lastSlotChange = currentTime
    currentSlot = (currentSlot % 4) + 1
    
    targetLabel.Text = "Alvo: " .. (targetPlayer and targetPlayer.Name or "Nenhum") .. " | Slot: " .. currentSlot
    
    return currentSlot
end

-- Loop do auto kill otimizado
local lastExecution = 0
local cooldown = 1.2

local function autoKillLoop()
    if not autoKillEnabled then return end

    if tick() - lastExecution < cooldown then return end
    lastExecution = tick()

    -- Verificar se o personagem do jogador existe
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    -- Verificar se o alvo atual ainda é válido
    if targetPlayer and targetPlayer.Character then
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            targetPlayer = nil
            targetLabel.Text = "Alvo: Procurando... | Slot: " .. currentSlot
        end
    end

    -- Procurar novo alvo se necessário
    if not targetPlayer then
        local nearest, dist = findNearestPlayer()
        if nearest and dist < 140 then
            targetPlayer = nearest
            targetLabel.Text = "Alvo: " .. nearest.Name .. " | Slot: " .. currentSlot
        else
            targetLabel.Text = "Alvo: Procurando... | Slot: " .. currentSlot
            return
        end
    end

    -- Atacar o alvo
    if targetPlayer and targetPlayer.Character then
        smoothTeleportToTarget()

        local slot = changeSlotSlowly()
        local key = numberKeys[slot]
        
        if key then
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.4)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            task.wait(0.3)
        end

        executeAttackSequence()
        task.wait(0.2)
        rapidAutoClick()
    end
end

-- Botão principal
toggleButton.MouseButton1Click:Connect(function()
    autoKillEnabled = not autoKillEnabled
    
    if autoKillEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        toggleButton.Text = "DESATIVAR AUTO KILL"
        statusLabel.Text = "Status: ATIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        connection = RunService.Heartbeat:Connect(autoKillLoop)
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        toggleButton.Text = "ATIVAR AUTO KILL"
        statusLabel.Text = "Status: Desativado"
        statusLabel.TextColor3 = Color3.new(1, 1, 1)
        
        if connection then 
            connection:Disconnect() 
            connection = nil 
        end
        targetPlayer = nil
        targetLabel.Text = "Alvo: Nenhum | Slot: 1"
        currentSlot = 1
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

-- Atalhos melhorados
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == Enum.KeyCode.T and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        smoothTeleportToTarget()
    end
    
    if input.KeyCode == Enum.KeyCode.R and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        targetPlayer = nil
        targetLabel.Text = "Alvo: Resetado | Slot: " .. currentSlot
    end
end)

-- Proteção contra destruição
screenGui.Destroying:Connect(function()
    if connection then 
        connection:Disconnect() 
    end
end)

-- Notificação de sucesso
task.wait(2)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "King Legacy Auto Kill FINAL",
    Text = "Script carregado com sucesso! GUI não desaparece ao morrer.",
    Duration = 5
})

print("✅ King Legacy Auto Kill FINAL carregado!")
print("🎯 Use Shift + T para teleporte rápido")
print("🔄 Use Shift + R para resetar alvo")
print("📌 GUI permanece visível mesmo após morte")
print("⚡ Versão FINAL - Impossível de escapar!")
