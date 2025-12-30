--==================================================
-- AutoKill CORE v5 (API MODE)
-- Controlado por WindUI
-- by blackzw
--==================================================

--------------------------------------------------
-- PROTEÇÃO DUPLA
--------------------------------------------------
if getgenv().AutoKillLoaded then
    warn("AutoKill já carregado")
    return
end
getgenv().AutoKillLoaded = true

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer

--------------------------------------------------
-- REMOTE M1
--------------------------------------------------
local SkillRemote =
    ReplicatedStorage:WaitForChild("Chest")
        :WaitForChild("Remotes")
        :WaitForChild("Functions")
        :WaitForChild("SkillAction")

--------------------------------------------------
-- SETTINGS
--------------------------------------------------
local ABOVE_STUDS = 5
local M1_DELAY = 0.08
local SKILL_DELAY = 0.12
local SWITCH_COOLDOWN = 1

--------------------------------------------------
-- VARS
--------------------------------------------------
local enabled = false
local lastM1 = 0
local lastSkill = 0
local lastSwitch = 0
local currentSlot = 1

--------------------------------------------------
-- UTILS
--------------------------------------------------
local function getChar()
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    return char, hrp
end

--------------------------------------------------
-- GET CLOSEST PLAYER
--------------------------------------------------
local function getClosestPlayer(hrp)
    local closest, dist = nil, math.huge

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local phrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and phrp and hum.Health > 0 then
                local d = (phrp.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = phrp
                end
            end
        end
    end

    return closest
end

--------------------------------------------------
-- INPUT
--------------------------------------------------
local function press(key)
    VIM:SendKeyEvent(true, key, false, game)
    VIM:SendKeyEvent(false, key, false, game)
end

--------------------------------------------------
-- AUTO M1
--------------------------------------------------
local function autoM1()
    SkillRemote:InvokeServer("SW_Bloodmoon Twins_M1")
end

--------------------------------------------------
-- MAIN LOOP (ÚNICO)
--------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not enabled then return end

    local char, hrp = getChar()
    if not char then return end

    -- TP EM CIMA + DEITADO
    local targetHRP = getClosestPlayer(hrp)
    if targetHRP then
        hrp.CFrame =
            CFrame.new(targetHRP.Position + Vector3.new(0, ABOVE_STUDS, 0))
            * CFrame.Angles(math.rad(90), 0, 0)
    end

    -- M1
    if tick() - lastM1 >= M1_DELAY then
        lastM1 = tick()
        autoM1()
    end

    -- SKILLS
    if tick() - lastSkill >= SKILL_DELAY then
        lastSkill = tick()
        press(Enum.KeyCode.Z)
        press(Enum.KeyCode.X)
        press(Enum.KeyCode.C)
        press(Enum.KeyCode.V)
        press(Enum.KeyCode.B)
    end

    -- SWITCH 1–4
    if tick() - lastSwitch >= SWITCH_COOLDOWN then
        lastSwitch = tick()

        local keys = {
            Enum.KeyCode.One,
            Enum.KeyCode.Two,
            Enum.KeyCode.Three,
            Enum.KeyCode.Four
        }

        press(keys[currentSlot])
        currentSlot += 1
        if currentSlot > 4 then
            currentSlot = 1
        end
    end
end)

--------------------------------------------------
-- API GLOBAL (WIND UI)
--------------------------------------------------
getgenv().AutoKill = {

    Start = function()
        enabled = true
        warn("[AutoKill] ATIVADO")
    end,

    Stop = function()
        enabled = false
        warn("[AutoKill] DESATIVADO")
    end
}
