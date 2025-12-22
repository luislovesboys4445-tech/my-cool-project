v0 = getgenv and getgenv() or _G
if v0.__XD_SPAM_PANEL__ then return else v0.__XD_SPAM_PANEL__ = true end

repeat task.wait() until game and game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ================= REMOTES =================
-- Admin command remote
local function findAdminRemote()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    if Packages and Packages:FindFirstChild("Net") then
        local remote = Packages.Net:FindFirstChild("RE/AdminPanelService/ExecuteCommand")
        if remote and remote:IsA("RemoteEvent") then
            return remote
        end
    end
end

local AdminRemote = findAdminRemote()
if not AdminRemote then
    warn("Admin command remote not found!")
    return
end

-- Brainrot steal remote
local StealRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StealBrainrot")

-- ================= COMMANDS =================
local Commands = {
    balloon = function(target) AdminRemote:FireServer(target,"balloon") end,
    rocket = function(target) AdminRemote:FireServer(target,"rocket") end,
    inverse = function(target) AdminRemote:FireServer(target,"inverse") end,
    tiny = function(target) AdminRemote:FireServer(target,"tiny") end,
    morph = function(target) AdminRemote:FireServer(target,"morph") end,
    jumpscare = function(target) AdminRemote:FireServer(target,"jumpscare") end,
    nightvision = function(target) AdminRemote:FireServer(target,"nightvision") end,
}

local CommandOrder = {"balloon","rocket","inverse","tiny","morph","jumpscare","nightvision"}

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoDefenseGUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui") -- GUI now visible

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220, 320)
frame.Position = UDim2.fromOffset(20, 80)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.35
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

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

-- Toggle Auto Defense
local AutoDefense = false
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

-- Spam function
local cooldown = {}
local COOLDOWN_TIME = 1
local function runSpam(target)
    if not target or target == LocalPlayer then return end
    for _, cmd in ipairs(CommandOrder) do
        local f = Commands[cmd]
        if f then pcall(f, target) end
        if cmd == "rocket" then task.wait(0.15) end
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

-- ================= AUTO DEFENSE =================
-- 1) RemoteEvent
StealRemote.OnClientEvent:Connect(function(thief)
    if not AutoDefense or not thief or thief == LocalPlayer then return end
    if typeof(thief) == "number" then
        thief = Players:GetPlayerByUserId(thief)
    end
    if not thief then return end
    if cooldown[thief] and os.clock() - cooldown[thief] < COOLDOWN_TIME then return end
    cooldown[thief] = os.clock()
    runSpam(thief)
end)

-- 2) ProximityPrompt
local function hookBrainrot(brainrot)
    local prompt = brainrot:FindFirstChildWhichIsA("ProximityPrompt")
    if not prompt then return end
    prompt.Triggered:Connect(function(thief)
        if not AutoDefense or not thief or thief == LocalPlayer then return end
        if cooldown[thief] and os.clock() - cooldown[thief] < COOLDOWN_TIME then return end
        cooldown[thief] = os.clock()
        runSpam(thief)
    end)
end

for _, obj in ipairs(workspace:GetDescendants()) do
    if obj.Name == "Brainrot" then hookBrainrot(obj) end
end
workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == "Brainrot" then hookBrainrot(obj) end
end)

Players.PlayerRemoving:Connect(function(p)
    cooldown[p] = nil
end)
