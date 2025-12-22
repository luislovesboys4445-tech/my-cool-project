v0 = getgenv and getgenv() or _G
if v0.__XD_SPAM_PANEL__ then return else v0.__XD_SPAM_PANEL__ = true end

repeat task.wait() until game and game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ================= REMOTE =================
local function findRemote()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
    local remote = remotesFolder:FindFirstChild("StealBrainrot")
    if remote and remote:IsA("RemoteEvent") then
        return remote
    end
end

local BrainrotStealRemote = findRemote()
if not BrainrotStealRemote then
    warn("StealBrainrot remote not found!")
    return
end

-- ================= COMMANDS =================
local Commands = {
    balloon = function(target) Remote:FireServer(target,"balloon") end,
    rocket = function(target) Remote:FireServer(target,"rocket") end,
    inverse = function(target) Remote:FireServer(target,"inverse") end,
    tiny = function(target) Remote:FireServer(target,"tiny") end,
    morph = function(target) Remote:FireServer(target,"morph") end,
    jumpscare = function(target) Remote:FireServer(target,"jumpscare") end,
    nightvision = function(target) Remote:FireServer(target,"nightvision") end,
}

-- Command order for Auto Defense: Balloon first, Rocket second
local CommandOrder = {"balloon","rocket","inverse","tiny","morph","jumpscare","nightvision"}

-- ================= GUI =================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "AutoDefenseGUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

-- Main frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220, 320)
frame.Position = UDim2.fromOffset(20, 80)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.35
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- Top bar
local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1,0,0,28)
top.BackgroundColor3 = Color3.fromRGB(20,20,20)
top.BackgroundTransparency = 0.2
Instance.new("UICorner", top).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,0,1,0)
title.Text = "Hoopz Auto Defense"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1

-- Auto Defense toggle
local AutoDefense = false
local cooldown = {}
local COOLDOWN_TIME = 1

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1,-10,0,28)
toggle.Position = UDim2.fromOffset(5,32)
toggle.Text = "AUTO DEFENSE: OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.BackgroundColor3 = Color3.fromRGB(150,0,0)
toggle.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)

toggle.MouseButton1Click:Connect(function()
    AutoDefense = not AutoDefense
    toggle.Text = AutoDefense and "AUTO DEFENSE: ON" or "AUTO DEFENSE: OFF"
    toggle.BackgroundColor3 = AutoDefense and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

-- Player list scroll
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.fromOffset(0,70)
scroll.Size = UDim2.new(1,0,1,-70)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

-- Spam function (all commands)
local function runSpam(target)
    if not target or target == LocalPlayer then return end
    for _, cmd in ipairs(CommandOrder) do
        local f = Commands[cmd]
        if f then pcall(f, target) end
        if cmd == "rocket" then task.wait(0.25) end -- small delay for rocket
    end
end

-- Player buttons
local function createPlayerButton(p)
    if p == LocalPlayer then return end
    if scroll:FindFirstChild(p.Name) then return end

    local b = Instance.new("TextButton", scroll)
    b.Name = p.Name
    b.Size = UDim2.new(1,-12,0,34)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.BackgroundTransparency = 0.3
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.Text = ""
    b.AutoButtonColor = true

    local label = Instance.new("TextLabel", b)
    label.Size = UDim2.new(1,-40,1,0)
    label.Position = UDim2.fromOffset(40,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = p.DisplayName

    local avatar = Instance.new("ImageLabel", b)
    avatar.Size = UDim2.fromOffset(32,32)
    avatar.Position = UDim2.fromOffset(4,1)
    avatar.BackgroundTransparency = 1
    task.spawn(function()
        local ok,img = pcall(function()
            return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48)
        end)
        if ok then avatar.Image = img end
    end)

    b.MouseButton1Click:Connect(function()
        runSpam(p)
    end)

    task.defer(function()
        scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 4)
    end)
end

local function removePlayerButton(p)
    local btn = scroll:FindFirstChild(p.Name)
    if btn then btn:Destroy() end
    cooldown[p] = nil
end

for _,p in ipairs(Players:GetPlayers()) do createPlayerButton(p) end
Players.PlayerAdded:Connect(createPlayerButton)
Players.PlayerRemoving:Connect(removePlayerButton)

-- Drag system
do
    local dragging = false
    local dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ========= AUTO DEFENSE =========
BrainrotStealRemote.OnClientEvent:Connect(function(thief)
    if not AutoDefense then return end
    if not thief or thief == LocalPlayer then return end

    -- Convert to Player object if needed
    if typeof(thief) == "number" then
        thief = Players:GetPlayerByUserId(thief)
    end
    if not thief or thief == LocalPlayer then return end

    -- Check cooldown
    if cooldown[thief] and os.clock() - cooldown[thief] < COOLDOWN_TIME then return end
    cooldown[thief] = os.clock()

    print("[AutoDefense] Spamming all commands on:", thief.Name)
    runSpam(thief)
end)
