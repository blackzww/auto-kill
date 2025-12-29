-- AutoKill CORE v8.2
-- Toggle Safe / WindUI Ready
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
-- GLOBAL STATE (PARA HUB)
--------------------------------------------------
getgenv().AUTOKILL_ENABLED = getgenv().AUTOKILL_ENABLED or false

--------------------------------------------------
-- INTERNAL STATE
--------------------------------------------------
local lockedTarget = nil
local lastTargetCheck = 0
local renderConnection = nil
local loopStarted = false

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
-- ANTI HIT
--------------------------------------------------
local function applyAntiHit(char, state)
    if not char then return end

    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = not state
        end
    end
end

--------------------------------------------------
-- TARGET
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
-- CLICK / KEYS
--------------------------------------------------
local function autoClick()
    local p = cam.ViewportSize * 0.5
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 0)
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 0)
end

local function press(key)
    VIM:SendKeyEvent(true, key, false, game)
    VIM:SendKeyEvent(false, key, false, game)
end

--------------------------------------------------
-- RENDER LOOP
--------------------------------------------------
local function startRender()
    if renderConnection then return end

    renderConnection = RunService.RenderStepped:Connect(function()
        if not getgenv().AUTOKILL_ENABLED then return end

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
                hrp.CFrame = CFrame.lookAt(
                    thrp.Position + Vector3.new(0, 5, 0),
                    thrp.Position
                )
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
-- MAIN LOOP (SÓ 1 VEZ)
--------------------------------------------------
if not loopStarted then
    loopStarted = true

    task.spawn(function()
        while true do
            if getgenv().AUTOKILL_ENABLED then
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
end

--------------------------------------------------
-- RESPAWN FIX
--------------------------------------------------
lp.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    if getgenv().AUTOKILL_ENABLED then
        applyAntiHit(char, true)
    end
end)

--------------------------------------------------
-- API GLOBAL (OPCIONAL)
--------------------------------------------------
getgenv().AutoKill = {
    Start = function()
        getgenv().AUTOKILL_ENABLED = true
        lockedTarget = nil
        applyAntiHit(getChar(), true)
        startRender()
    end,

    Stop = function()
        getgenv().AUTOKILL_ENABLED = false
        lockedTarget = nil
        applyAntiHit(getChar(), false)
        stopRender()
    end
}
