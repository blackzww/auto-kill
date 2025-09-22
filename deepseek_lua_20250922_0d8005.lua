-- Script para King Legacy - Auto Kill Final IMPROVADO
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
local lastSlotChange = 0
local slotCooldown = 2.5 -- Cooldown maior entre mudanças de slot
local currentSlot = 1

-- Criar a GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KingLegacyAutoKillFinal"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 250)
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
                -- Alcance aumentado para 150
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
    for i = 1, 3 do -- Aumentado para 3 cliques
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
    
    -- Usar J no início para empurrar
    useJPush()
    
    for _, key in ipairs(attackKeys) do
        if not autoKillEnabled then break end
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.1) -- Tempo reduzido
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        rapidAutoClick()
        task.wait(0.06) -- Tempo reduzido
    end
end

-- Teleporte melhorado para manter distância ideal
local function smoothTeleportToTarget()
    if not targetPlayer or not targetPlayer.Character then return end
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local pRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot or not pRoot then return end
    
    -- Calcular posição ideal (mais longe do alvo)
    local dir = (tRoot.Position - pRoot.Position).Unit
    local distance = (tRoot.Position - pRoot.Position).Magnitude
    
    -- Se estiver muito perto, teleportar para mais longe
    if distance < 8 then
        local pos = tRoot.Position - dir * 12 -- Distância aumentada
        pRoot.CFrame = CFrame.new(pos, tRoot.Position)
    else
        -- Manover para manter distância ideal
        local pos = tRoot.Position - dir * 10
        pRoot.CFrame = CFrame.new(pos, tRoot.Position)
    end
end

-- Teclas numéricas (1-4) com mudança mais lenta
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
    
    -- Atualizar display
    targetLabel.Text = "Alvo: " .. (targetPlayer and targetPlayer.Name or "Nenhum") .. " | Slot: " .. currentSlot
    
    return currentSlot
end

-- Loop do auto kill otimizado
local lastExecution = 0
local cooldown = 1.2 -- Cooldown reduzido para maior eficiência

local function autoKillLoop()
    if not autoKillEnabled then return end

    -- Cooldown para evitar sobrecarga
    if tick() - lastExecution < cooldown then return end
    lastExecution = tick()

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
        if nearest and dist < 140 then -- Alcance aumentado
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

        -- Mudar slot lentamente
        local slot = changeSlotSlowly()
        local key = numberKeys[slot]
        
        if key then
            -- Pressionar tecla numérica do slot atual
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.4) -- Tempo aumentado
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            task.wait(0.3)
        end

        -- Executar sequência de ataques completa
        executeAttackSequence()
        task.wait(0.2)
        
        -- Clique extra para garantir dano
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
    
    -- Shift + T para teleporte
    if input.KeyCode == Enum.KeyCode.T and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        smoothTeleportToTarget()
    end
    
    -- Shift + R para resetar alvo
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
    Text = "Script carregado com sucesso!",
    Duration = 5
})

print("✅ King Legacy Auto Kill FINAL carregado!")
print("🎯 Use Shift + T para teleporte rápido")
print("🔄 Use Shift + R para resetar alvo")
print("⚡ Versão FINAL - Impossível de escapar!")