-- AutoKill CORE v8.3
-- NO CLICK / REMOTE BASED
-- Toggle Safe / WindUI Ready
-- Stable Delta Version
-- by blackzw

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer

--------------------------------------------------
-- AUTO ATIVAR AO EXECUTAR O SCRIPT (EXATO)
--------------------------------------------------
game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("Armament"):FireServer()

game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("KenEvent"):InvokeServer()

--------------------------------------------------
-- REMOTE (KING LEGACY)
--------------------------------------------------
local SkillRemote = ReplicatedStorage
    :WaitForChild("Chest")
    :WaitForChild("Remotes")
    :WaitForChild("Functions")
    :WaitForChild("SkillAction")

--------------------------------------------------
-- GLOBAL STATE (HUB SAFE)
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
-- MAIN LOOP (REMOTE ATTACK + SKILLS)
--------------------------------------------------
if not loopStarted then
    loopStarted = true

    task.spawn(function()
        while true do
            if getgenv().AUTOKILL_ENABLED then
                pcall(function()
                    -- M1 REAL (SEM CLIQUE)
                    SkillRemote:InvokeServer("SW_Bloodmoon Twins_M1")
                end)

                pcall(function()
                    local args = {
                        "DF_GasGas_Z",
                        {
                            MouseHit = CFrame.new(2311.26953125, 51.18202590942383, 584.1146240234375, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Type = "Down"
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("SkillAction"):InvokeServer(unpack(args))
                end)

                pcall(function()
                    local args = {
                        "DF_GasGas_X",
                        {
                            MouseHit = CFrame.new(2311.26953125, 51.18202590942383, 584.1146240234375, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Type = "Down"
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("SkillAction"):InvokeServer(unpack(args))
                end)

                pcall(function()
                    local args = {
                        "DF_GasGas_C",
                        {
                            MouseHit = CFrame.new(2311.26953125, 51.18202590942383, 584.1146240234375, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Type = "Down"
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("SkillAction"):InvokeServer(unpack(args))
                end)

                pcall(function()
                    local args = {
                        "DF_GasGas_V",
                        {
                            MouseHit = CFrame.new(2311.26953125, 51.18202590942383, 584.1146240234375, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Type = "Down"
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Chest"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("SkillAction"):InvokeServer(unpack(args))
                end)
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
    end
end)

--------------------------------------------------
-- API GLOBAL (PARA HUB / TOGGLE)
--------------------------------------------------
getgenv().AutoKill = {
    Start = function()
        if getgenv().AUTOKILL_ENABLED then return end
        getgenv().AUTOKILL_ENABLED = true
        lockedTarget = nil
        applyAntiHit(getChar(), true)
        startRender()
    end,

    Stop = function()
        if not getgenv().AUTOKILL_ENABLED then return end
        getgenv().AUTOKILL_ENABLED = false
        lockedTarget = nil
        applyAntiHit(getChar(), false)
        stopRender()
    end
}
