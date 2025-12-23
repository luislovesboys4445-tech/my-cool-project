-- [[ CONFIGURATION ]]
local WHITELIST_ID = 1918726906 -- <--- PUT YOUR ID HERE

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if LocalPlayer.UserId ~= WHITELIST_ID then return end

local autoDefenseActive = true 

-- [[ GUI DESIGN ]]
local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.Name = "HoopzTimed_UI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(210, 335) 
main.Position = UDim2.new(0.5, -105, 0.4, -165)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BackgroundTransparency = 0.4
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- [[ DRAGGABLE HEADER ]]
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1, 0, 0, 35)
header.Text = "  hoopz spammer"
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.BackgroundTransparency = 1
header.Font = Enum.Font.GothamBold
header.TextSize = 14
header.TextXAlignment = Enum.TextXAlignment.Left
header.Active = true

-- [[ AUTO-DEFENSE TOGGLE ]]
local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.fromOffset(50, 22)
toggleBtn.Position = UDim2.new(1, -55, 0, 7)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
toggleBtn.Text = "DEF: ON"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 10
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.ZIndex = 5
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

toggleBtn.Activated:Connect(function()
    autoDefenseActive = not autoDefenseActive
    toggleBtn.BackgroundColor3 = autoDefenseActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 50, 50)
    toggleBtn.Text = autoDefenseActive and "DEF: ON" or "DEF: OFF"
end)

-- [[ SCROLL LIST ]]
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -12, 1, -50)
scroll.Position = UDim2.fromOffset(6, 40)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.Name

-- [[ FAST EXECUTION LOGIC ]]
local Remote = ReplicatedStorage:FindFirstChild("RE/AdminPanelService/ExecuteCommand", true)

local function executeFullPayload(target)
    if not Remote or not target then return end
    
    -- List of commands to fire instantly (within 0.1s)
    local instantCmds = {"balloon", "inverse", "tiny", "morph", "jumpscare", "nightvision"}
    
    -- Fire all instant commands simultaneously
    for _, c in ipairs(instantCmds) do
        task.spawn(function()
            pcall(function()
                Remote:FireServer(target, c)
            end)
        end)
    end
    
    -- Specifically delayed Rocket (0.15s)
    task.delay(0.15, function()
        pcall(function()
            Remote:FireServer(target, "rocket")
        end)
    end)
end

local function createRow(p)
    if p == LocalPlayer then return end
    local row = Instance.new("TextButton", scroll)
    row.Name = p.Name:lower()
    row.Size = UDim2.new(1, -2, 0, 38)
    row.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    row.BackgroundTransparency = 0.5
    row.Text = "  " .. (p.DisplayName or p.Name)
    row.TextColor3 = Color3.fromRGB(255, 255, 255)
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.Font = Enum.Font.Gotham; row.TextSize = 12
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local img = Instance.new("ImageLabel", row)
    img.Size = UDim2.fromOffset(28, 28)
    img.Position = UDim2.new(1, -32, 0, 5)
    img.BackgroundTransparency = 1
    Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        pcall(function()
            img.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
    end)
    
    row.Activated:Connect(function() executeFullPayload(p) end)
end

local function refresh()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do createRow(p) end
end
Players.PlayerAdded:Connect(refresh); Players.PlayerRemoving:Connect(refresh); refresh()

-- [[ HEADER-ONLY DRAG ]]
local dragging, dragStart, startPos
header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = i.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- [[ DEFENSE ]]
local Steal = ReplicatedStorage:FindFirstChild("StealBrainrot", true)
if Steal then
    Steal.OnClientEvent:Connect(function(thief)
        if autoDefenseActive and thief and thief.Parent == Players then executeFullPayload(thief) end
    end)
end
