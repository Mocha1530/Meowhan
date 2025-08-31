local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Create a simple UI to display the monitored events
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventMonitor"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 300)
Frame.Position = UDim2.new(0.5, -200, 0, 10)
Frame.AnchorPoint = Vector2.new(0.5, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
Title.BorderSizePixel = 0
Title.Text = "RemoteEvent Monitor"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollingFrame

-- Collapse/Expand button
local CollapseButton = Instance.new("TextButton")
CollapseButton.Size = UDim2.new(0, 30, 0, 30)
CollapseButton.Position = UDim2.new(1, -35, 0, 5)
CollapseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
CollapseButton.BorderSizePixel = 0
CollapseButton.Text = "-"
CollapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CollapseButton.Font = Enum.Font.GothamBold
CollapseButton.TextSize = 18
CollapseButton.Parent = Frame

local CollapseCorner = Instance.new("UICorner")
CollapseCorner.CornerRadius = UDim.new(0, 6)
CollapseCorner.Parent = CollapseButton

-- Clear button
local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0, 80, 0, 30)
ClearButton.Position = UDim2.new(1, -120, 0, 5)
ClearButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
ClearButton.BorderSizePixel = 0
ClearButton.Text = "Clear Logs"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.Font = Enum.Font.Gotham
ClearButton.TextSize = 14
ClearButton.Parent = Frame

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearButton

-- Draggable UI variables 
local dragging = false
local dragInput
local dragStart
local startPos

-- Function to make UI draggable with proper input handling
local function onInputChanged(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end

-- Handle input based on device type
local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Check if the input is on the title bar
        local titleBarAbsolutePosition = Title.AbsolutePosition
        local titleBarAbsoluteSize = Title.AbsoluteSize
        
        if input.Position.X >= titleBarAbsolutePosition.X and 
           input.Position.X <= titleBarAbsolutePosition.X + titleBarAbsoluteSize.X and
           input.Position.Y >= titleBarAbsolutePosition.Y and 
           input.Position.Y <= titleBarAbsolutePosition.Y + titleBarAbsoluteSize.Y then
            
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            
            -- Capture the input for mobile to prevent camera movement
            if input.UserInputType == Enum.UserInputType.Touch then
                input:Capture()
            end
            
            -- Connect to input changed event
            dragInput = input
            UserInputService.InputChanged:Connect(onInputChanged)
            
            -- Disconnect when input ends
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                    UserInputService.InputChanged:Disconnect(onInputChanged)
                end
            end)
        end
    end
end

-- Connect input events
UserInputService.InputBegan:Connect(onInputBegan)

-- Collapse/Expand functionality 
local isCollapsed = false
local originalSize = Frame.Size
local collapsedSize = UDim2.new(0, 400, 0, 40) -- Only show title bar when collapsed

CollapseButton.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    
    if isCollapsed then
        -- Collapse the frame
        local tween = TweenService:Create(
            Frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = collapsedSize}
        )
        tween:Play()
        CollapseButton.Text = "+"
        ScrollingFrame.Visible = false
    else
        -- Expand the frame
        local tween = TweenService:Create(
            Frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = originalSize}
        )
        tween:Play()
        CollapseButton.Text = "-"
        ScrollingFrame.Visible = true
    end
end)

-- Function to add a log entry to the UI
local function addLogEntry(text, color)
    local LogEntry = Instance.new("TextLabel")
    LogEntry.Size = UDim2.new(1, 0, 0, 40)
    LogEntry.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    LogEntry.BorderSizePixel = 0
    LogEntry.Text = "[" .. os.date("%H:%M:%S") .. "] " .. text
    LogEntry.TextColor3 = color
    LogEntry.Font = Enum.Font.Gotham
    LogEntry.TextSize = 14
    LogEntry.TextWrapped = true
    LogEntry.TextXAlignment = Enum.TextXAlignment.Left
    LogEntry.Parent = ScrollingFrame
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 10)
    Padding.Parent = LogEntry
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = LogEntry
    
    -- Update canvas size
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    
    -- Auto-scroll to bottom
    ScrollingFrame.CanvasPosition = Vector2.new(0, ScrollingFrame.AbsoluteCanvasSize.Y)
end

ClearButton.MouseButton1Click:Connect(function()
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    addLogEntry("Logs cleared", Color3.fromRGB(200, 200, 200))
end)

-- Wait for the GameEvents folder
local GameEventsFolder = ReplicatedStorage:WaitForChild("GameEvents", 10)

if not GameEventsFolder then
    addLogEntry("GameEvents folder not found or inaccessible", Color3.fromRGB(255, 100, 100))
    return
end

addLogEntry("Monitoring started for GameEvents folder", Color3.fromRGB(100, 200, 100))

-- Function to safely hook a RemoteEvent
local function hookRemoteEvent(event)
    if not event:IsA("RemoteEvent") then
        return
    end
    
    -- Hook FireServer
    local oldFire = event.FireServer
    event.FireServer = function(...)
        local args = {...}
        pcall(function()
            addLogEntry("[Fire] " .. event.Name .. " fired", Color3.fromRGB(100, 180, 255))
        end)
        
        -- Always call the original function
        return oldFire(event, unpack(args))
    end
    
    -- Listen for server messages
    event.OnClientEvent:Connect(function(...)
        pcall(function()
            addLogEntry("[Receive] " .. event.Name .. " received", Color3.fromRGB(100, 255, 180))
        end)
    end)
    
    addLogEntry("Now monitoring: " .. event.Name, Color3.fromRGB(200, 200, 200))
end

-- Monitor all existing events in the folder
for _, event in ipairs(GameEventsFolder:GetChildren()) do
    pcall(hookRemoteEvent, event)
end

-- Monitor for new events added dynamically
GameEventsFolder.ChildAdded:Connect(function(child)
    pcall(function()
        if child:IsA("RemoteEvent") then
            hookRemoteEvent(child)
        end
    end)
end)
