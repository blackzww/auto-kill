--==================================================
-- AutoKill CORE v8.3
-- King Legacy | Delta Safe
-- by blackzw
--==================================================

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

--------------------------------------------------
-- GLOBAL STATE (PARA TOGGLE)
--------------------------------------------------
getgenv().AUTOKILL_ENABLED = getgenv().AUTOKILL_ENABLED or false

--------------------------------------------------
-- REMOTES
--------------------------------------------------
local SkillRemote = ReplicatedStorage
    :WaitForChild("Chest")
    :WaitForChild("Remotes")
    :WaitForChild("Functions")
    :WaitForChild("SkillAction")

local KenRemote = ReplicatedStorage
    :WaitForChild("Chest")
    :WaitForChild("Remotes")
    :WaitForChild("Functions")
    :WaitForChild("KenEvent")

local ArmamentRemote = ReplicatedStorage
    :WaitForChild("Chest")
    :WaitForChild("Remotes")
    :WaitForChild("Events")
    :WaitForChild("Armament")

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
-- ESPADA CLICK (MUITO RÁPIDO)
--------------------------------------------------
local function swordSpam()
    -- spam real de M1
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

--------------------------------------------------
-- HAKI
--------------------------------------------------
local function enableHaki()
    pcall(function()
        KenRemote:InvokeServer()
    end)
    pcall(function()
        ArmamentRemote:FireServer()
    end)
end

--------------------------------------------------
-- RENDER LOOP (TP + LOOK)
--------------------------------------------------
local function startRender()
    if renderConnection then return end

    renderConnection = RunService.RenderStepped:Connect(function()
        if not getgenv().AUTOKILL_ENABLED then return end

        local char = getChar()
        if not isAlive(char) then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if tick() - lastTargetCheck > 0.25 then
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
-- MAIN LOOP (SKILLS + ESPADA)
--------------------------------------------------
if not loopStarted then
    loopStarted = true

    task.spawn(function()
        local args = {
            "DF_GasGas_Z",
            {
                MouseHit = CFrame.new(0, 0, 0),
                Type = "Down"
            }
        }

        while true do
            if getgenv().AUTOKILL_ENABLED then
                enableHaki()

                -- SKILLS
                args[1] = "DF_GasGas_Z"
                SkillRemote:InvokeServer(unpack(args))
                task.wait(0.07)

                args[1] = "DF_GasGas_X"
                SkillRemote:InvokeServer(unpack(args))
                task.wait(0.07)

                args[1] = "DF_GasGas_C"
                SkillRemote:InvokeServer(unpack(args))
                task.wait(0.07)

                args[1] = "DF_GasGas_V"
                SkillRemote:InvokeServer(unpack(args))
                task.wait(0.07)

                args[1] = "DF_GasGas_B"
                SkillRemote:InvokeServer(unpack(args))
                task.wait(0.07)

                -- ESPADA SPAM (FORTE)
                for i = 1, 6 do
                    swordSpam()
                    task.wait(0.03)
                end
            end
            task.wait(0.1)
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
        startRender()
    end
end)

--------------------------------------------------
-- API GLOBAL (PARA HUB)
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
