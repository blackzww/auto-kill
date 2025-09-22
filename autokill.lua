-- Script para King Legacy - Auto Kill Final ULTRA RÁPIDO
-- LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Criar a GUI com proteção contra morte
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KingLegacyAutoKillFinal"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 280)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
title.Text = "KING LEGACY AUTO KILL ULTRA RÁPIDO"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.85, 0, 0, 50)
toggleButton.Position = UDim2.new(0.075, 0, 0.2, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
toggleButton.Text = "ATIVAR AUTO KILL"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 15
toggleButton.Parent = mainFrame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 6)

local autoClickToggle = Instance.new("TextButton")
autoClickToggle.Size = UDim2.new(0.4, 0, 0, 35)
autoClickToggle.Position = UDim2.new(0.075, 0, 0.42, 0)
autoClickToggle.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
autoClickToggle.Text = "AUTO CLICK: ON"
autoClickToggle.TextColor3 = Color3.new(1, 1, 1)
autoClickToggle.Font = Enum.Font.GothamBold
autoClickToggle.TextSize = 13
autoClickToggle.Parent = mainFrame
Instance.new("UICorner", autoClickToggle).CornerRadius = UDim.new(0, 6)

local aggressiveToggle = Instance.new("TextButton")
aggressiveToggle.Size = UDim2.new(0.4, 0, 0, 35)
aggressiveToggle.Position = UDim2.new(0.525, 0, 0.42, 0)
aggressiveToggle.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
aggressiveToggle.Text = "AGGRESSIVE: ON"
aggressiveToggle.TextColor3 = Color3.new(1, 1, 1)
aggressiveToggle.Font = Enum.Font.GothamBold
aggressiveToggle.TextSize = 13
aggressiveToggle.Parent = mainFrame
Instance.new("UICorner", aggressiveToggle).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.85, 0, 0, 30)
statusLabel.Position = UDim2.new(0.075, 0, 0.58, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Desativado"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = mainFrame

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(0.85, 0, 0, 25)
targetLabel.Position = UDim2.new(0.075, 0, 0.7, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Alvo: Nenhum | Slot: 1"
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetLabel.TextSize = 12
targetLabel.Parent = mainFrame

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(0.85, 0, 0, 20)
distanceLabel.Position = UDim2.new(0.075, 0, 0.8, 0)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Text = "Distância: 0"
distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distanceLabel.TextSize = 11
distanceLabel.Parent = mainFrame

-- Variáveis de controle
local autoKillEnabled = false
local targetPlayer = nil
local connection = nil
local autoClickEnabled = true
local aggressiveMode = true
local lastSlotChange = 0
local slotCooldown = 1.5 -- Reduzido para ser mais rápido
local currentSlot = 1
local lastTeleport = 0
local teleportCooldown = 0.1 -- Teleporte muito mais rápido

-- Aguardar o player carregar
local function waitForCharacter()
    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

-- Reconectar quando o personagem morrer
player.CharacterAdded:Connect(function(character)
    waitForCharacter()
    if autoKillEnabled then
        statusLabel.Text = "Status: ATIVADO (Reconectado)"
        task.wait(2)
        statusLabel.Text = "Status: ATIVADO"
    end
end)

waitForCharacter()

local mouse = player:GetMouse()

-- Encontrar player mais próximo com alcance maior e mais rápido
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
                if dist < shortest and dist < 200 then -- Alcance aumentado
                    shortest = dist
                    nearest = other
                end
            end
        end
    end
    return nearest, shortest
end

-- Clique ultra rápido
local function ultraRapidClick()
    if not autoClickEnabled then return end
    for i = 1, 5 do -- Aumentado para 5 cliques
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
        task.wait(0.01) -- Quase instantâneo
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
        task.wait(0.01)
    end
end

-- Teleporte ultra rápido que segue o jogador continuamente
local function ultraFastTeleportToTarget()
    if not targetPlayer or not targetPlayer.Character then return end
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local pRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot or not pRoot then return end
    
    local currentTime = tick()
    if currentTime - lastTeleport < teleportCooldown then return end
    lastTeleport = currentTime
    
    -- Calcular posição ideal para ficar colado no alvo
    local dir = (tRoot.Position - pRoot.Position).Unit
    local distance = (tRoot.Position - pRoot.Position).Magnitude
    
    -- Ficar sempre muito próximo do alvo (2-5 unidades de distância)
    local targetDistance = 3
    if distance > targetDistance + 1 or distance < targetDistance - 1 then
        local pos = tRoot.Position - dir * targetDistance
        pRoot.CFrame = CFrame.new(pos, tRoot.Position)
    end
    
    -- Atualizar distância na GUI
    distanceLabel.Text = "Distância: " .. math.floor(distance)
    
    return distance
end

-- Sequência de ataques ULTRA RÁPIDA
local function ultraFastAttackSequence()
    local attackKeys = {
        Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, 
        Enum.KeyCode.V, Enum.KeyCode.E, Enum.KeyCode.B,
        Enum.KeyCode.Q, Enum.KeyCode.R, Enum.KeyCode.T
    }
    
    -- Ataque mais agressivo com tecla J
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.J, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.J, false, game)
    
    -- Executar todos os ataques quase simultaneamente
    for _, key in ipairs(attackKeys) do
        if not autoKillEnabled then break end
        
        -- Pressionar e soltar rapidamente
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.03) -- Muito mais rápido
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        
        -- Clique rápido entre ataques
        ultraRapidClick()
        task.wait(0.02)
    end
end

-- Teclas numéricas (1-4) com mudança mais rápida
local numberKeys = {
    [1] = Enum.KeyCode.One,
    [2] = Enum.KeyCode.Two,
    [3] = Enum.KeyCode.Three,
    [4] = Enum.KeyCode.Four,
}

-- Mudança de slot RÁPIDA
local function changeSlotFast()
    local currentTime = tick()
    if currentTime - lastSlotChange < slotCooldown then
        return currentSlot
    end
    
    lastSlotChange = currentTime
    currentSlot = (currentSlot % 4) + 1
    
    -- Mudança instantânea de slot
    local key = numberKeys[currentSlot]
    if key then
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end
    
    targetLabel.Text = "Alvo: " .. (targetPlayer and targetPlayer.Name or "Nenhum") .. " | Slot: " .. currentSlot
    
    return currentSlot
end

-- Loop principal ULTRA RÁPIDO
local function ultraFastKillLoop()
    if not autoKillEnabled then return end

    -- Verificar se o personagem existe
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    -- Verificar alvo atual
    if targetPlayer and targetPlayer.Character then
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            targetPlayer = nil
            targetLabel.Text = "Alvo: Procurando... | Slot: " .. currentSlot
        end
    end

    -- Procurar novo alvo
    if not targetPlayer then
        local nearest, dist = findNearestPlayer()
        if nearest and dist < 180 then
            targetPlayer = nearest
            targetLabel.Text = "Alvo: " .. nearest.Name .. " | Slot: " .. currentSlot
        else
            targetLabel.Text = "Alvo: Procurando... | Slot: " .. currentSlot
            return
        end
    end

    -- SEQUÊNCIA ULTRA RÁPIDA DE ATAQUE
    if targetPlayer and targetPlayer.Character then
        -- 1. Teleportar para ficar COLADO no alvo
        ultraFastTeleportToTarget()
        
        -- 2. Mudar slot rapidamente (se necessário)
        changeSlotFast()
        
        -- 3. Executar sequência de ataques ultra rápida
        ultraFastAttackSequence()
        
        -- 4. Clique extra garantido
        ultraRapidClick()
        
        -- 5. Se modo agressivo, repetir teleporte para garantir proximidade
        if aggressiveMode then
            task.wait(0.05)
            ultraFastTeleportToTarget()
        end
    end
end

-- Botão principal
toggleButton.MouseButton1Click:Connect(function()
    autoKillEnabled = not autoKillEnabled
    
    if autoKillEnabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        toggleButton.Text = "DESATIVAR AUTO KILL"
        statusLabel.Text = "Status: ATIVADO - ULTRA RÁPIDO"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Usar RenderStepped para máxima velocidade
        connection = RunService.RenderStepped:Connect(ultraFastKillLoop)
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
        distanceLabel.Text = "Distância: 0"
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

-- Botão modo agressivo
aggressiveToggle.MouseButton1Click:Connect(function()
    aggressiveMode = not aggressiveMode
    if aggressiveMode then
        aggressiveToggle.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
        aggressiveToggle.Text = "AGGRESSIVE: ON"
        teleportCooldown = 0.05 -- Modo agressivo é ainda mais rápido
    else
        aggressiveToggle.BackgroundColor3 = Color3.fromRGB(200, 100, 60)
        aggressiveToggle.Text = "AGGRESSIVE: OFF"
        teleportCooldown = 0.1
    end
end)

-- Atalhos ULTRA RÁPIDOS
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Shift + T para teleporte instantâneo
    if input.KeyCode == Enum.KeyCode.T and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        ultraFastTeleportToTarget()
    end
    
    -- Shift + R para resetar alvo
    if input.KeyCode == Enum.KeyCode.R and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        targetPlayer = nil
        targetLabel.Text = "Alvo: Resetado | Slot: " .. currentSlot
    end
    
    -- Shift + F para modo ultra rápido
    if input.KeyCode == Enum.KeyCode.F and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        aggressiveMode = true
        teleportCooldown = 0.03
        aggressiveToggle.BackgroundColor3 = Color3.fromRGB(200, 60, 200)
        aggressiveToggle.Text = "AGGRESSIVE: ULTRA"
        statusLabel.Text = "Status: MODO ULTRA ATIVADO"
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
    Title = "King Legacy Auto Kill ULTRA RÁPIDO",
    Text = "Script ULTRA RÁPIDO carregado!",
    Duration = 5
})

print("⚡ King Legacy Auto Kill ULTRA RÁPIDO carregado!")
print("🎯 Use Shift + T para teleporte instantâneo")
print("🔄 Use Shift + R para resetar alvo")
print("💥 Use Shift + F para modo ULTRA RÁPIDO")
print("📌 O script agora segue o alvo continuamente")
print("⚡ TODOS os ataques vão acertar o alvo!")
