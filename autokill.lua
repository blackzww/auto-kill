-- AutoKill CORE v8.1 (Separated / UI Ready)
-- Stable Delta Version
-- by blackzw

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

--------------------------------------------------
-- MODULE TABLE
--------------------------------------------------
local AutoKill = {}

--------------------------------------------------
-- STATE
--------------------------------------------------
local enabled = false
local lockedTarget = nil
local lastTargetCheck = 0
local renderConnection = nil
local loopRunning = false

--------------------------------------------------
-- UTIL
--------------------------------------------------
local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function isAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

--------------------------------------------------
-- ANTI HIT (DELTA SAFE)
--------------------------------------------------
local function applyAntiHit(char, state)
    if not char then return end

    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = not state
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end

--------------------------------------------------
-- TARGET MAIS PRÓXIMO
--------------------------------------------------
local function getClosestPlayer()
    local char = getChar()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closest, dist = nil, math.huge

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character and isAlive(plr.Character) then
            local phrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if phrp then
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
-- CLICK
--------------------------------------------------
local function autoClick()
    local p = cam.ViewportSize * 0.5
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 0)
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 0)
end

--------------------------------------------------
-- KEY PRESS
--------------------------------------------------
local function press(key)
    VIM:SendKeyEvent(true, key, false, game)
    VIM:SendKeyEvent(false, key, false, game)
end

--------------------------------------------------
-- RENDER LOOP (TP + LOOK DOWN)
--------------------------------------------------
local function startRender()
    if renderConnection then return end

    renderConnection = RunService.RenderStepped:Connect(function()
        if not enabled then return end

        local char = getChar()
        if not isAlive(char) then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if tick() - lastTargetCheck > 0.3 then
            lastTargetCheck = tick()
            if not lockedTarget or not isAlive(lockedTarget) then
                lockedTarget = getClosestPlayer()
            end
        end

        if lockedTarget then
            local thrp = lockedTarget:FindFirstChild("HumanoidRootPart")
            if thrp then
                local pos = thrp.Position + Vector3.new(0, 5, 0)
                hrp.CFrame = CFrame.lookAt(pos, thrp.Position)
            end
        end
    end)
end

local function stopRender()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
end

--------------------------------------------------
-- MAIN LOOP (CLICK + SKILLS)
--------------------------------------------------
task.spawn(function()
    if loopRunning then return end
    loopRunning = true

    while true do
        if enabled then
            autoClick()
            press(Enum.KeyCode.Z)
            press(Enum.KeyCode.X)
            press(Enum.KeyCode.C)
            press(Enum.KeyCode.V)
            press(Enum.KeyCode.B)
        end
        task.wait(0.05)
    end
end)

--------------------------------------------------
-- PUBLIC API (PARA UI)
--------------------------------------------------
function AutoKill.Start()
    if enabled then return end
    enabled = true
    lockedTarget = nil

    applyAntiHit(getChar(), true)
    startRender()
end

function AutoKill.Stop()
    if not enabled then return end
    enabled = false
    lockedTarget = nil

    applyAntiHit(getChar(), false)
    stopRender()
end

function AutoKill.Toggle(state)
    if state then
        AutoKill.Start()
    else
        AutoKill.Stop()
    end
end

function AutoKill.IsEnabled()
    return enabled
end

--------------------------------------------------
-- RESPAWN FIX
--------------------------------------------------
lp.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    if enabled then
        applyAntiHit(char, true)
    end
end)

--------------------------------------------------
return AutoKill---------------------------------
return Aut
