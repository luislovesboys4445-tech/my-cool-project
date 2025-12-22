-- Auto Defense Script for Steal a Brainrot
-- Place in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ======================
-- SETTINGS
-- ======================
local AUTO_DEFENSE_ENABLED = true

local COMMAND_DELAY = 0.15
local ROCKET_DELAY = 0.25

local COMMAND_ORDER = {
    "balloon",
    "rocket",
    "inverse",
    "tiny",
    "morph",
    "jumpscare",
    "nightvision",
}

-- ======================
-- ADMIN REMOTE
-- ======================
local AdminRemote =
    ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("Net")
    :WaitForChild("RE/AdminPanelService/ExecuteCommand")

-- ======================
-- STEAL REMOTE
-- ======================
local StealRemote =
    ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("StealBrainrot")

-- ======================
-- COOLDOWN (ANTI-SPAM)
-- ======================
local cooldown = {} -- [userId] = time
local COOLDOWN_TIME = 3

local function onCooldown(player)
    local last = cooldown[player.UserId]
    if last and os.clock() - last < COOLDOWN_TIME then
        return true
    end
    cooldown[player.UserId] = os.clock()
    return false
end

-- ======================
-- ADMIN SPAM FUNCTION
-- ======================
local function runAdminSpam(target)
    if not target or not target:IsA("Player") then return end
    if not target.Character then return end

    for _, command in ipairs(COMMAND_ORDER) do
        pcall(function()
            AdminRemote:FireServer(target, command)
        end)

        if command == "rocket" then
            task.wait(ROCKET_DELAY)
        else
            task.wait(COMMAND_DELAY)
        end
    end
end

-- ======================
-- AUTO DEFENSE LOGIC
-- ======================
StealRemote.OnServerEvent:Connect(function(thief, brainrot)
    if not AUTO_DEFENSE_ENABLED then return end
    if not thief or not thief:IsA("Player") then return end
    if onCooldown(thief) then return end

    -- Optional ownership check
    if brainrot and brainrot:FindFirstChild("OwnerUserId") then
        if brainrot.OwnerUserId.Value == thief.UserId then
            return -- owner picked up their own brainrot
        end
    end

    warn("[AUTO DEFENSE] Brainrot stolen by:", thief.Name)

    runAdminSpam(thief)
end)

-- ======================
-- CLEANUP
-- ======================
Players.PlayerRemoving:Connect(function(player)
    cooldown[player.UserId] = nil
end)
