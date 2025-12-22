--// Hoopz Defender - Auto Defense Script (Clear GUI)
local v0 = getgenv and getgenv() or _G
if v0.__HOOPZ_DEFENDER__ then return end
v0.__HOOPZ_DEFENDER__ = true

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local STEAL_REMOTE_NAME = "StealBrainrot"

-- ADMIN COMMAND LIST
local function send(cmd)
    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(cmd, "All")
end

local AdminCommands = {
    function(p) send(":balloon "..p.Name) end,
    function(p) task.wait(0.15) send(":rocket "..p.Name) end,
    function(p) task.wait(0.1) send(":jail "..p.Name) end,
    function(p) task.wait(0.1) send(":morph "..p.Name) end,
    function(p) task.wait(0.1) send(":jumpscare "..p.Name) end,
    function(p) task.wait(0.1) send(":tiny "..p.Name) end,
    function(p) task.wait(0.1) send(":inverse "..p.Name) end,
}

local AutoDefense = false
local TargetPlayer = nil

-- GUI
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "HoopzDefender"

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 240, 0, 280)  -- smaller
Main.Position = UDim2.new(0.5, -120, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BackgroundTransparency = 0.5       -- semi-transparent
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundTransparency = 1
Title.Text = "🛡️ Hoopz Defender"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1,1,1)

local Toggle = Instance.new("TextButton", Main)
Toggle.Position = UDim2.new(0, 16, 0, 46)
Toggle.Size = UDim2.new(1, -32, 0, 36)
Toggle.Text = "Auto Defense: OFF"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.BackgroundColor3 = Color3.fromRGB(170,60,60)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,8)

local List = Instance.new("ScrollingFrame", Main)
List.Position = UDim2.new(0, 16, 0, 88)
List.Size = UDim2.new(1, -32, 1, -108)
List.CanvasSize = UDim2.new(0,0,0,0)
List.ScrollBarImageTransparency = 0.4
List.BackgroundTransparency = 0.6  -- clearer
List.BackgroundColor3 = Color3.fromRGB(32,32,32)
List.BorderSizePixel = 0
Instance.new("UICorner", List).CornerRadius = UDim.new(0,8)

local Layout = Instance.new("UIListLayout", List)
Layout.Padding = UDim.new(0,4)

-- FUNCTIONS
local function refreshPlayers()
    for _, v in ipairs(List:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -4, 0, 32)
            b.Text = p.Name
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 = Color3.fromRGB(60,60,60)
            b.Parent = List
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

            b.MouseButton1Click:Connect(function()
                TargetPlayer = p
                for _, x in ipairs(List:GetChildren()) do
                    if x:IsA("TextButton") then
                        x.BackgroundColor3 = Color3.fromRGB(60,60,60)
                    end
                end
                b.BackgroundColor3 = Color3.fromRGB(70,120,255)
            end)
        end
    end

    task.wait()
    List.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 4)
end

Toggle.MouseButton1Click:Connect(function()
    AutoDefense = not AutoDefense
    Toggle.Text = "Auto Defense: "..(AutoDefense and "ON" or "OFF")
    Toggle.BackgroundColor3 = AutoDefense and Color3.fromRGB(60,170,90) or Color3.fromRGB(170,60,60)
end)

refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

-- AUTO DEFENSE CORE
local StealRemote = ReplicatedStorage:FindFirstChild(STEAL_REMOTE_NAME, true)
if StealRemote and StealRemote:IsA("RemoteEvent") then
    StealRemote.OnClientEvent:Connect(function(thief)
        if AutoDefense and TargetPlayer and thief == TargetPlayer then
            for _, cmd in ipairs(AdminCommands) do
                task.spawn(function()
                    pcall(function()
                        cmd(thief)
                    end)
                end)
            end
        end
    end)
end
