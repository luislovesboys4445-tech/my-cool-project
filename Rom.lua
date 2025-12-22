v0 = getgenv and getgenv() or _G
if v0.__XD_SPAM_PANEL__ then return else v0.__XD_SPAM_PANEL__ = true end

repeat task.wait() until game and game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Find AdminPanel remote
local function findRemote(timeout)
    timeout = timeout or 6
    local start = os.clock()
    while os.clock() - start < timeout do
        local p = ReplicatedStorage:FindFirstChild("Packages")
        if p and p:FindFirstChild("Net") and p.Net:FindFirstChild("RE/AdminPanelService/ExecuteCommand") then
            return p.Net["RE/AdminPanelService/ExecuteCommand"]
        end
        task.wait(0.1)
    end
end

local Remote = findRemote()
if not Remote or not Remote:IsA("RemoteEvent") then return end

local function formatName(p)
    return p.DisplayName ~= "" and p.DisplayName or p.Name
end

-- Commands
local Commands = {
    balloon = function(target) Remote:FireServer(target,"balloon") end,
    rocket = function(target) Remote:FireServer(target,"rocket") end,
    inverse = function(target) Remote:FireServer(target,"inverse") end,
    tiny = function(target) Remote:FireServer(target,"tiny") end,
    morph = function(target) Remote:FireServer(target,"morph") end,
    jumpscare = function(target) Remote:FireServer(target,"jumpscare") end,
    nightvision = function(target) Remote:FireServer(target,"nightvision") end,
}

-- Command order (balloon first, rocket second)
local CommandOrder = {"balloon","rocket","inverse","tiny","morph","jumpscare","nightvision"}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "xd_spam_gui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer:WaitForChild("PlayerGui") -- FIXED: use PlayerGui

-- Main frame
local frame = Instance.new("Frame")
frame.Name = "Root"
frame.Size = UDim2.fromOffset(200, 300) -- increased height for toggle
frame.Position = UDim2.fromOffset(20, 80)
frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 1
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- Top bar
local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1,0,0,24)
top.BackgroundColor3 = Color3.fromRGB(40,40,40)
top.BackgroundTransparency = 0.2
top.BorderSizePixel = 0
top.Parent = frame
Instance.new("UICorner", top).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,1,0)
title.Position = UDim2.fromOffset(8,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "hoopz spammer"
title.Parent = top

-- Auto-Defense Toggle Button
local autoDefenseEnabled = true -- starts enabled
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -8, 0, 24)
toggleBtn.Position = UDim2.fromOffset(4, 28)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 14
toggleBtn.Text = "Auto-Defense: ON"
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

toggleBtn.Activated:Connect(function()
    autoDefenseEnabled = not autoDefenseEnabled
    toggleBtn.Text = "Auto-Defense: " .. (autoDefenseEnabled and "ON" or "OFF")
end)

-- Player holder
local holder = Instance.new("Frame")
holder.BackgroundTransparency = 1
holder.Size = UDim2.fromOffset(200, 224)
holder.Position = UDim2.fromOffset(0, 56) -- moved down for toggle button
holder.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Active = true
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ScrollBarThickness = 6
scroll.Size = UDim2.new(1,0,1,0)
scroll.CanvasSize = UDim2.fromOffset(0,0)
scroll.Parent = holder

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll
Instance.new("UIPadding",scroll).PaddingTop = UDim.new(0,4)

-- Drag system
do
    local dragging = false
    local dragStart, startPos

    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position

            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    top.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            frame.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Spam function
local function runSpam(target)
    if target and target.Parent == Players then
        for _,cmd in ipairs(CommandOrder) do
            local exec = Commands[cmd]
            if exec then
                pcall(function()
                    exec(target)
                end)
            end
            if cmd == "rocket" then
                task.wait(0.25)
            end
        end
    end
end

-- Player buttons
local function makeBtn(p)
    if not p or p == LocalPlayer or p.Parent ~= Players then return end
    for _,c in ipairs(scroll:GetChildren()) do
        if c:IsA("TextButton") and c.Name == p.Name then return end
    end

    local b = Instance.new("TextButton")
    b.Name = p.Name
    b.Size = UDim2.new(1,-4,0,28)
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.BackgroundTransparency = 0.2
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Text = "  " .. formatName(p)
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0,24,0,24)
    avatar.Position = UDim2.new(1,-30,0,2)
    avatar.BackgroundTransparency = 1
    avatar.Parent = b

    task.spawn(function()
        local success, thumbUrl = pcall(function()
            return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if success then avatar.Image = thumbUrl end
    end)

    b.Activated:Connect(function()
        runSpam(p)
    end)

    b.Parent = scroll
    task.defer(function()
        scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 4)
    end)
end

-- Add/remove players
for _,p in ipairs(Players:GetPlayers()) do
    makeBtn(p)
end

Players.PlayerAdded:Connect(function(p)
    task.wait(0.05)
    makeBtn(p)
end)

Players.PlayerRemoving:Connect(function(p)
    for _,c in ipairs(scroll:GetChildren()) do
        if c:IsA("TextButton") and c.Name == p.Name then
            c:Destroy()
        end
    end
end)

-- =========================
-- Auto-Defense Based on StealBrainrot Remote
-- =========================
local StealRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StealBrainrot")

StealRemote.OnClientEvent:Connect(function(thiefPlayer)
    if autoDefenseEnabled and thiefPlayer and thiefPlayer.Parent == Players then
        runSpam(thiefPlayer)
    end
end)
