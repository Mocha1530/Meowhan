local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = Players.LocalPlayer.PlayerGui
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
end)

local teleport = PlayerGui:FindFirstChild("Teleport_UI")
local frame = teleport:FindFirstChild("Frame")
local buttonNames = {"Gears", "Event", "Rebirth", "Pet"}

if not frame then
    warn("Parent is nil. Cannot remove buttons.")
    end
else
    for _, child in ipairs(frame:GetChildren()) do
        if table.find(buttonNames, child.Name) and (child:IsA("ImageButton") or child:IsA("TextButton")) then
            child:Destroy()
        end
    end
end

local seedButton = frame:FindFirstChild("Seeds")
if seedButton then
    seedButton.LayoutOrder = -3
end

-- Gear teleport button UI
local gearButton = Instance.new("ImageButton")
gearButton.Name = "Gears"
gearButton.BackgroundColor3 = Color3.fromRGB(97, 226, 51)
gearButton.BackgroundTransparency = 0
gearButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
gearButton.BorderSizePixel = 0
gearButton.LayoutOrder = -2
gearButton.Position = UDim2.new(0.688038409, 0, 0.114772804, 0)
gearButton.Size = UDim2.new(0.259808183, 0, 0.790713012, 0)
gearButton.ZIndex = 1
gearButton.ScaleType = Enum.ScaleType.Fit
gearButton.Image = "rbxassetid://0"
gearButton.HoverImage = "rbxassetid://0"
gearButton.Parent = frame

local gearAspectRatio = Instance.new("UIAspectRatioConstraint")
gearAspectRatio.AspectRatio = 2.8125
gearAspectRatio.AspectType = Enum.AspectType.FitWithinMaxSize
gearAspectRatio.DominantAxis = Enum.DominantAxis.Width
gearAspectRatio.Parent = gearButton

local gearUIStroke = Instance.new("UIStroke")
gearUIStroke.Color = Color3.fromRGB(80, 184, 42)
gearUIStroke.Thickness = 1.5
gearUIStroke.Parent = gearButton

local geartxt = Instance.new("TextLabel")
geartxt.Name = "Txt"
geartxt.AnchorPoint = Vector2.new(0.5, 0.5)
geartxt.BackgroundColor3 = Color3.fromRGB(76, 52, 35)
geartxt.BackgroundTransparency = 1
geartxt.BorderColor3 = Color3.fromRGB(0, 0, 0)
geartxt.BorderSizePixel = 0
geartxt.Position = UDim2.new(0.5, 0, 0.5, 0)
geartxt.Size = UDim2.new(0.86500001, 0, 0.86500001, 0)
geartxt.ZIndex = 1
geartxt.FontFace = Font.new(
    "rbxasset://fonts/families/ComicNeueAngular.json",  
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)
geartxt.Text = "GEAR"
geartxt.TextColor3 = Color3.fromRGB(255, 255, 255)
geartxt.TextScaled = true
geartxt.TextSize = 14
geartxt.TextWrapped = true
geartxt.Parent = gearButton

local gearSizeConstraint = Instance.new("UISizeConstraint")
gearSizeConstraint.MaxSize = Vector2.new(math.huge, math.huge)
gearSizeConstraint.MinSize = Vector2.new(50, 20)
gearSizeConstraint.Parent = geartxt

local gearUIStroke1 = Instance.new("UIStroke")
gearUIStroke1.Color = Color3.fromRGB(80, 184, 42)
gearUIStroke1.Thickness = 2
gearUIStroke1.Parent = geartxt

-- Event teleport button UI
local eventButton = Instance.new("ImageButton")
eventButton.Name = "Event"
eventButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
eventButton.BackgroundTransparency = 1
eventButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
eventButton.BorderSizePixel = 0
eventButton.LayoutOrder = -1
eventButton.Position = UDim2.new(0.311, 0, 0, 0)
eventButton.Size = UDim2.new(0.41, 0, 0.985, 0)
eventButton.ZIndex = 1
eventButton.ScaleType = Enum.ScaleType.Fit
eventButton.Image = "rbxassetid://110208924430993"
eventButton.HoverImage = "rbxassetid://135080523802244"
eventButton.Parent = frame

local aspectRatio = Instance.new("UIAspectRatioConstraint")
aspectRatio.AspectRatio = 3.558823585510254
aspectRatio.AspectType = Enum.AspectType.FitWithinMaxSize
aspectRatio.DominantAxis = Enum.DominantAxis.Width
aspectRatio.Parent = eventButton

local txt = Instance.new("TextLabel")
txt.Name = "Txt"
txt.AnchorPoint = Vector2.new(0.5, 0.5)
txt.BackgroundColor3 = Color3.fromRGB(76, 52, 35)
txt.BackgroundTransparency = 1
txt.BorderColor3 = Color3.fromRGB(0, 0, 0)
txt.BorderSizePixel = 0
txt.Position = UDim2.new(0.5, 0, 0.557, 0)
txt.Size = UDim2.new(0.9, 0, 0.684, 0)
txt.ZIndex = 1
txt.FontFace = Font.new(
    "rbxasset://fonts/families/ComicNeueAngular.json",  
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)
txt.Text = "EVENT"
txt.TextColor3 = Color3.fromRGB(255, 255, 255)
txt.TextScaled = true
txt.TextSize = 14
txt.TextWrapped = true
txt.Parent = eventButton

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(math.huge, math.huge)
sizeConstraint.MinSize = Vector2.new(100, 20)
sizeConstraint.Parent = txt

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(40, 20, 11)
uiStroke.Thickness = 2
uiStroke.Parent = txt

-- Rebirth teleport button UI
local rebirthButton = Instance.new("ImageButton")
rebirthButton.Name = "Rebirth"
rebirthButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rebirthButton.BackgroundTransparency = 1
rebirthButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
rebirthButton.BorderSizePixel = 0
rebirthButton.LayoutOrder = 0
rebirthButton.Position = UDim2.new(0.311, 0, 0, 0)
rebirthButton.Size = UDim2.new(0.41, 0, 0.985, 0)
rebirthButton.ZIndex = 1
rebirthButton.ScaleType = Enum.ScaleType.Fit
rebirthButton.Image = "rbxassetid://110208924430993"
rebirthButton.HoverImage = "rbxassetid://135080523802244"
rebirthButton.Parent = frame

local rebirthAspectRatio = Instance.new("UIAspectRatioConstraint")
rebirthAspectRatio.AspectRatio = 3.558823585510254
rebirthAspectRatio.AspectType = Enum.AspectType.FitWithinMaxSize
rebirthAspectRatio.DominantAxis = Enum.DominantAxis.Width
rebirthAspectRatio.Parent = rebirthButton

local rebirthTxt = Instance.new("TextLabel")
rebirthTxt.Name = "Txt"
rebirthTxt.AnchorPoint = Vector2.new(0.5, 0.5)
rebirthTxt.BackgroundColor3 = Color3.fromRGB(76, 52, 35)
rebirthTxt.BackgroundTransparency = 1
rebirthTxt.BorderColor3 = Color3.fromRGB(0, 0, 0)
rebirthTxt.BorderSizePixel = 0
rebirthTxt.Position = UDim2.new(0.5, 0, 0.557, 0)
rebirthTxt.Size = UDim2.new(0.9, 0, 0.684, 0)
rebirthTxt.ZIndex = 1
rebirthTxt.FontFace = Font.new(
    "rbxasset://fonts/families/ComicNeueAngular.json",  
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)
rebirthTxt.Text = "REBIRTH"
rebirthTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthTxt.TextScaled = true
rebirthTxt.TextSize = 14
rebirthTxt.TextWrapped = true
rebirthTxt.Parent = rebirthButton

local rebirthSizeConstraint = Instance.new("UISizeConstraint")
rebirthSizeConstraint.MaxSize = Vector2.new(math.huge, math.huge)
rebirthSizeConstraint.MinSize = Vector2.new(100, 20)
rebirthSizeConstraint.Parent = rebirthTxt

local rebirthUIStroke = Instance.new("UIStroke")
rebirthUIStroke.Color = Color3.fromRGB(40, 20, 11)
rebirthUIStroke.Thickness = 2
rebirthUIStroke.Parent = rebirthTxt

-- Garden teleport button UI
local gardenButton = frame:FindFirstChild("Garden")
if gardenButton then
    gardenButton.LayoutOrder = 1
end

-- Pet teleport button UI
local petButton = Instance.new("ImageButton")
petButton.Name = "Pet"
petButton.BackgroundColor3 = Color3.fromRGB(226, 163, 37)
petButton.BackgroundTransparency = 0
petButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
petButton.BorderSizePixel = 0
petButton.LayoutOrder = 2
petButton.Position = UDim2.new(0.688038409, 0, 0.114772804, 0)
petButton.Size = UDim2.new(0.259808183, 0, 0.790713012, 0)
petButton.ZIndex = 1
petButton.ScaleType = Enum.ScaleType.Fit
petButton.Image = "rbxassetid://0"
petButton.HoverImage = "rbxassetid://0"
petButton.Parent = frame

local petAspectRatio = Instance.new("UIAspectRatioConstraint")
petAspectRatio.AspectRatio = 2.8125
petAspectRatio.AspectType = Enum.AspectType.FitWithinMaxSize
petAspectRatio.DominantAxis = Enum.DominantAxis.Width
petAspectRatio.Parent = petButton

local petUIStroke = Instance.new("UIStroke")
petUIStroke.Color = Color3.fromRGB(166, 120, 27)
petUIStroke.Thickness = 1.5
petUIStroke.Parent = petButton

local pettxt = Instance.new("TextLabel")
pettxt.Name = "Txt"
pettxt.AnchorPoint = Vector2.new(0.5, 0.5)
pettxt.BackgroundColor3 = Color3.fromRGB(76, 52, 35)
pettxt.BackgroundTransparency = 1
pettxt.BorderColor3 = Color3.fromRGB(0, 0, 0)
pettxt.BorderSizePixel = 0
pettxt.Position = UDim2.new(0.5, 0, 0.5, 0)
pettxt.Size = UDim2.new(0.86500001, 0, 0.86500001, 0)
pettxt.ZIndex = 1
pettxt.FontFace = Font.new(
    "rbxasset://fonts/families/ComicNeueAngular.json",  
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)
pettxt.Text = "PETS"
pettxt.TextColor3 = Color3.fromRGB(255, 255, 255)
pettxt.TextScaled = true
pettxt.TextSize = 14
pettxt.TextWrapped = true
pettxt.Parent = petButton

local petSizeConstraint = Instance.new("UISizeConstraint")
petSizeConstraint.MaxSize = Vector2.new(math.huge, math.huge)
petSizeConstraint.MinSize = Vector2.new(50, 20)
petSizeConstraint.Parent = pettxt

local petUIStroke1 = Instance.new("UIStroke")
petUIStroke1.Color = Color3.fromRGB(166, 120, 27)
petUIStroke1.Thickness = 2
petUIStroke1.Parent = pettxt

-- Sell teleport button UI
local sellButton = frame:FindFirstChild("Sell")
if sellButton then
    sellButton.LayoutOrder = 3
end

local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Tp_Points = Workspace:FindFirstChild("Tutorial_Points")

gearButton.MouseButton1Click:Connect(function()
    local teleportPoint = Tp_Points.Tutorial_Point_3

    if teleportPoint then
        HumanoidRootPart.CFrame = teleportPoint.CFrame
    end
end)

eventButton.MouseButton1Click:Connect(function()
    local teleportPoint = Tp_Points.Event_Point

    if teleportPoint then
        HumanoidRootPart.CFrame = teleportPoint.CFrame
    end
end)

rebirthButton.MouseButton1Click:Connect(function()
    local targetCFrame = CFrame.new(
        126.44146, 
        3.99999976, 
        167.216751, 
        -0.720815241, -9.22248873e-08, -0.693127275, 
        -4.49386484e-08, 1, -8.6322423e-08, 
        0.693127275, -3.10743182e-08, -0.720815241
    )

    HumanoidRootPart.CFrame = targetCFrame
end)

petButton.MouseButton1Click:Connect(function()
    local teleportPoint = Tp_Points.Tutorial_Point_4

    if teleportPoint then
        HumanoidRootPart.CFrame = teleportPoint.CFrame
    end
end)
