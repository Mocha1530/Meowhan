local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Create UI elements (same as before)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventMonitor"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- ... (UI creation code remains the same) ...

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
            
            -- Only capture touch input to prevent camera movement
            if input.UserInputType == Enum.UserInputType.Touch then
                input:Capture()  -- This is now safe as we're only calling it on touch input
            end
            
            -- Connect to input changed event
            dragInput = input
            UserInputService.InputChanged:Connect(onInputChanged)
            
            -- Disconnect when input ends
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if connection then
                        connection:Disconnect()
                    end
                    UserInputService.InputChanged:Disconnect(onInputChanged)
                end
            end)
        end
    end
end

-- Connect input events
UserInputService.InputBegan:Connect(onInputBegan)

-- ... (rest of your UI and monitoring code remains the same) ...
