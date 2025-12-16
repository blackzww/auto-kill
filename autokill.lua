-- AutoKill FINAL v3 - TP MAIS PRÓXIMO (Delta)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

--------------------------------------------------
-- GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AutoKillGUI"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,180,0,45)
btn.Position = UDim2.new(0.05,0,0.4,0)
btn.Text = "AutoKill: OFF"
btn.TextScaled = true
btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
btn.TextColor3 = Color3.new(1,1,1)
btn.BorderSizePixel = 0
btn.Active = true
btn.Draggable = true
btn.Parent = gui

--------------------------------------------------
local enabled = false
local switchCooldown = 1 -- 1 segundo para trocar 1–4
local lastSwitch = 0
local currentSlot = 1

--------------------------------------------------
-- Util: personagem
--------------------------------------------------
local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
end

--------------------------------------------------
-- Jogador mais próximo (FIX ESTÁVEL)
--------------------------------------------------
local function getClosestPlayer()
    local char = getChar()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closest, dist = nil, math.huge

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local phrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and phrp then
                local d = (phrp.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = plr.Character
                end
            end
        end
    end

    return closest
end

--------------------------------------------------
-- AutoClick contínuo
--------------------------------------------------
local function autoClick()
    local p = cam.ViewportSize / 2
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 0)
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 0)
end

--------------------------------------------------
-- Pressionar tecla
--------------------------------------------------
local function press(key)
    VIM:SendKeyEvent(true, key, false, game)
    VIM:SendKeyEvent(false, key, false, game)
end

--------------------------------------------------
-- TP contínuo para o MAIS PRÓXIMO
--------------------------------------------------
task.spawn(function()
    while true do
        if enabled then
            local char = lp.Character
            local targetChar = getClosestPlayer()
            if char and targetChar then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local thrp = targetChar:FindFirstChild("HumanoidRootPart")
                if hrp and thrp then
                    hrp.CFrame = thrp.CFrame
                end
            end
        end
        RunService.RenderStepped:Wait()
    end
end)

--------------------------------------------------
-- AutoClick infinito
--------------------------------------------------
task.spawn(function()
    while true do
        if enabled then
            autoClick()
        end
        RunService.RenderStepped:Wait()
    end
end)

--------------------------------------------------
-- ZXCVB SEM DELAY
--------------------------------------------------
task.spawn(function()
    while true do
        if enabled then
            press(Enum.KeyCode.Z)
            press(Enum.KeyCode.X)
            press(Enum.KeyCode.C)
            press(Enum.KeyCode.V)
            press(Enum.KeyCode.B)
        end
        RunService.RenderStepped:Wait()
    end
end)

--------------------------------------------------
-- Troca 1–4 com cooldown de 1s
--------------------------------------------------
task.spawn(function()
    while true do
        if enabled and tick() - lastSwitch >= switchCooldown then
            lastSwitch = tick()

            if currentSlot == 1 then
                press(Enum.KeyCode.One)
            elseif currentSlot == 2 then
                press(Enum.KeyCode.Two)
            elseif currentSlot == 3 then
                press(Enum.KeyCode.Three)
            elseif currentSlot == 4 then
                press(Enum.KeyCode.Four)
            end

            currentSlot += 1
            if currentSlot > 4 then
                currentSlot = 1
            end
        end
        RunService.Heartbeat:Wait()
    end
end)

--------------------------------------------------
-- Toggle
--------------------------------------------------
btn.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        btn.Text = "AutoKill: ON"
        btn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    else
        btn.Text = "AutoKill: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
    end
end)