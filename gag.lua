local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = Players.LocalPlayer.PlayerGui
local GameEvents = ReplicatedStorage.GameEvents
local placeId = game.PlaceId

local CONFIG_FOLDER = "Meowhan/Config/"
local CONFIG_FILENAME = "GrowAGarden.json"
local DEFAULT_CONFIG = {
    InitialDelay = 30,
    JobId = "",
    AutoStartPetMutation = false,
    AutoClaimMutatedPet = false,
    ShowGlimmerCounter = false,
    ShowMutationTimer = true,
    WalkSpeed = 20,
    JumpPower = 50,
    InfiniteJump = false
}

local Running = {
    autoStartMachine = true,
    autoClaimPet = true,
    showMutationTimer = true,
    autoBuyAll = true,
    autoBuySelected = true,
    stockUpdate = true,
    infiniteJump = true
}

-- Create folder structure
local function ensureFolderStructure()
    if not pcall(function() 
        if not isfolder("Meowhan") then
            makefolder("Meowhan")
        end
        if not isfolder("Meowhan/Config") then
            makefolder("Meowhan/Config")
        end
    end) then
        warn("Could not create folder structure - using root directory")
        CONFIG_FOLDER = ""
    end
end

-- Load configuration
local function loadConfig()
    ensureFolderStructure()
    local fullPath = CONFIG_FOLDER .. CONFIG_FILENAME
    
    if not pcall(function() return readfile(fullPath) end) then
        return DEFAULT_CONFIG
    end
    
    local success, config = pcall(function()
        return HttpService:JSONDecode(readfile(fullPath))
    end)
    
    return success and config or DEFAULT_CONFIG
end

-- Save configuration
local function saveConfig(config)
    ensureFolderStructure()
    local fullPath = CONFIG_FOLDER .. CONFIG_FILENAME
    local success, err = pcall(function()
        writefile(fullPath, HttpService:JSONEncode(config))
    end)
    if not success then
        warn("Failed to save config:", err)
    end
end

-- Create UI
local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Mocha1530/Meowhan/main/UI%20Library.lua'))()
local Window = UILib:CreateWindow("   Grow A Garden - Meowhan")
local config = loadConfig()
local currentJobId = game.JobId

local MainTab = Window:Tab("Main")
local EventTab = Window:Tab("Event")
local ShopTab = Window:Tab("Shop")
local SettingsTab = Window:Tab("Settings")
local InfoTab = Window:Tab("Info")

-- Initialize
local function connectDestroyEvent()
    local uiScreenGui = CoreGui:FindFirstChild("MeowhanUI") or PlayerGui:WaitForChild("MeowhanUI")
    
    if uiScreenGui then
        uiScreenGui.Destroying:Connect(function()
            for key, _ in pairs(Running) do
                Running[key] = false
            end
            
            if scalingLoop then
                scalingLoop:Disconnect()
            end
            
            if restoreOriginalProperties then
                restoreOriginalProperties()
            end
        end)
    else
        warn("ScreenGui not found in CoreGui or PlayerGui")
    end
end

task.delay(1, connectDestroyEvent)

local teleport = PlayerGui:FindFirstChild("Teleport_UI")
local frame = teleport:FindFirstChild("Frame")
local buttonNames = {"Gear", "Event", "Rebirth", "Pets"}

local function removeExistingButtons(parent, names)
    if not parent then
        warn("Parent is nil. Cannot remove buttons.")
        return
    end

    for _, child in ipairs(parent:GetChildren()) do
        if table.find(names, child.Name) and (child:IsA("ImageButton") or child:IsA("TextButton")) then
            child:Destroy()
        end
    end
end

removeExistingButtons(frame, buttonNames)

-- Seeds teleport button UI
local seedButton = frame:FindFirstChild("Seeds")
if seedButton then
    seedButton.LayoutOrder = -3
end

-- Gear teleport button UI
local gearButton = Instance.new("ImageButton")
gearButton.Name = "Gear"
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
petButton.Name = "Pets"
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
        5.99999976, 
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

-- Main Tab
local MutationMachineSection = MainTab:Section("Mutation Machine")
local MutationMachineVulnSection = MainTab:Section("Mutation Machine (Vuln)")

-- Mutation Machine Vars
local autoStartMachineEnabled = config.AutoStartPetMutation or false
local autoClaimPetEnabled = config.AutoClaimMutatedPet or false
local MutationMachine = GameEvents.PetMutationMachineService_RE

-- Mutation Machine Timer
local function getMutationMachineTimer()
    local model = Workspace:FindFirstChild("NPCS")
    
    if model then
        model = model:FindFirstChild("PetMutationMachine")
        if model then
            model = model:FindFirstChild("Model")
            if model then
                for _, child in ipairs(model:GetChildren()) do
                    if child:IsA("Part") and child:FindFirstChild("BillboardPart") then
                        local billboardPart = child.BillboardPart
                        if billboardPart then
                            local billboardGui = billboardPart:FindFirstChild("BillboardGui")
                            if billboardGui then
                                local timerTextLabel = billboardGui:FindFirstChild("TimerTextLabel")
                                if timerTextLabel then
                                    return timerTextLabel.Text
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

-- Mutation Machine (Vuln)
MutationMachineVulnSection:Button("Submit Held Pet", function()
    MutationMachine:FireServer("SubmitHeldPet")
end)

MutationMachineVulnSection:Button("Start Machine", function()
    local timerStatus = getMutationMachineTimer()
    if timerStatus == nil or timerStatus == "" then
        MutationMachine:FireServer("StartMachine")
        Window:Notify("Machine Started", 2)
    else
        Window:Notify("Machine Already Started", 2)
    end
end)

MutationMachineVulnSection:Toggle("Auto Start Machine", function(state)
    autoStartMachineEnabled = state
    config.AutoStartPetMutation = state
    saveConfig(config)
    
    if state then
        Window:Notify("Auto Start Machine Enabled", 2)
    else
        Window:Notify("Auto Start Machine Disabled", 2)
    end
end, {
    default = autoStartMachineEnabled
})

spawn(function()
    while Running.autoStartMachine do
        if autoStartMachineEnabled then
            local timerStatus = getMutationMachineTimer()
            if timerStatus == nil or timerStatus == "" then
                MutationMachine:FireServer("StartMachine")
            end
            task.wait(10)
        else
            task.wait(1)
        end
    end
end)

-- Mutation machine functions
spawn(function()
    while Running.autoClaimPet do
        if autoClaimPetEnabled then
            local timerStatus = getMutationMachineTimer()
            if timerStatus == "READY" then
                MutationMachine:FireServer("ClaimMutatedPet")
                task.wait(2)
            else
                task.wait(1)
            end
        else
            task.wait(1)
        end
    end
end)

local function toggleAutoClaimPet(state)
    autoClaimPetEnabled = state
    config.AutoClaimMutatedPet = state
    saveConfig(config)
    
    if state then
        Window:Notify("Auto Claim Pet Enabled", 2)
    else
        Window:Notify("Auto Claim Pet Disabled", 2)
    end
end

  -- Select det dropdown
MutationMachineSection:Dropdown("Select Pet: ", {"Test1", "Test2", "Test3"}, "None", function(selected)
    if selected then
        Window:Notify("Selected: " .. selected, 2)
    end
end)

  -- Auto claim toggle
local autoClaimPet = MutationMachineSection:Toggle("Auto Claim Pet", function(state)
    toggleAutoClaimPet(state)
end, {
    default = autoClaimPetEnabled
})

-- Event Tab
local EventSection = EventTab:Section("Fairy Event")

-- Shop Tab
local SeedShopSection = ShopTab:Section("Seed Shop")

-- Settings Tab
local UISection = SettingsTab:Section("UI")
local LocalPlayerSection = SettingsTab:Section("Player")
local RejoinSection = SettingsTab:Section("Rejoin Config")

-- Settings Vars
local mutationTimerEnabled = config.ShowMutationTimer or true
local originalBillboardPosition = nil
local billboardGui = nil
local scalingLoop = nil
local Humanoid = Character:WaitForChild("Humanoid")
local walkSpeedValue = config.WalkSpeed or 20
local jumpPowerValue = config.JumpPower or 50
local infiniteJumpEnabled = config.InfiniteJump or false

-- Function to find and store the BillboardGui reference
local function findBillboardGui()
    local model2 = Workspace:FindFirstChild("NPCS")
    
    if model2 then
        model2 = model2:FindFirstChild("PetMutationMachine")
        if model2 then
            model2 = model2:FindFirstChild("Model")
            if model2 then
                for _, child in ipairs(model2:GetChildren()) do
                    if child:IsA("Part") and child:FindFirstChild("BillboardPart") then
                        local billboardPart = child.BillboardPart
                        
                        if not originalBillboardPosition then
                            originalBillboardPosition = billboardPart.Position
                        end
                        
                        local currentPosition = billboardPart.Position
                        billboardPart.Position = Vector3.new(
                            currentPosition.X,
                            15,               
                            currentPosition.Z
                        )
                        
                        billboardPart.CanCollide = false
                        
                        billboardGui = billboardPart:FindFirstChild("BillboardGui")
                        if billboardGui then
                            billboardGui.MaxDistance = 10000
                            return true
                        end
                    end
                end
            end
        end
    end
    
    return false
end

local function startScalingLoop()
    if scalingLoop then
        scalingLoop:Disconnect()
        scalingLoop = nil
    end

    scalingLoop = RunService.RenderStepped:Connect(function()
        local mutationTimerEnabled = config.ShowMutationTimer or true
        if not mutationTimerEnabled or not billboardGui or not billboardGui.Parent then
            if scalingLoop then
                scalingLoop:Disconnect()
                scalingLoop = nil
            end
            return
        end
        
        local localPlayer = Players.LocalPlayer
        
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = localPlayer.Character.HumanoidRootPart.Position
            local billboardPos = billboardGui.Parent.Parent.Position
            local distance = (playerPos - billboardPos).Magnitude
            
            -- Size parameters
            local minSize = UDim2.new(14, 0, 8, 0)   -- Minimum size (close)
            local maxSize = UDim2.new(50, 0, 34, 0)  -- Maximum size (far)
            
            -- Distance parameters
            local minDistance = 60  -- Distance where size is minimum
            local maxDistance = 200 -- Distance where size is maximum
            
            -- Calculate scale factor (0 to 1)
            local factor = math.clamp((distance - minDistance) / (maxDistance - minDistance), 0, 1)
            
            -- Interpolate between min and max size
            local newX = minSize.X.Scale + (maxSize.X.Scale - minSize.X.Scale) * factor
            local newY = minSize.Y.Scale + (maxSize.Y.Scale - minSize.Y.Scale) * factor
            
            billboardGui.Size = UDim2.new(newX, 0, newY, 0)
        end
    end)
    
    UILib:TrackProcess("connections", scalingLoop, "scalingLoop")
end

-- Function to restore the original position and properties
local function restoreOriginalProperties()
    if originalBillboardPosition then
        local model3 = Workspace:FindFirstChild("NPCS")
        
        if model3 then
            model3 = model3:FindFirstChild("PetMutationMachine")
            if model3 then
                model3 = model3:FindFirstChild("Model")
                if model3 then
                    for _, child in ipairs(model3:GetChildren()) do
                        if child:IsA("Part") and child:FindFirstChild("BillboardPart") then
                            local billboardPart = child.BillboardPart
                            billboardPart.Position = originalBillboardPosition
                            billboardPart.CanCollide = true  -- Restore collision
                            
                            -- Restore the BillboardGui properties
                            local gui = billboardPart:FindFirstChild("BillboardGui")
                            if gui then
                                gui.MaxDistance = 60
                                gui.Size = UDim2.new(7, 0, 4, 0)
                            end
                        end
                    end
                end 
            end
        end
    end
    
    if scalingLoop then
        scalingLoop:Disconnect()
        scalingLoop = nil
    end
    
    billboardGui = nil
end

local function showMutationTimerDisplay()
    if not mutationTimerEnabled then
        restoreOriginalProperties()
        return false
    end

    local success = findBillboardGui()
    
    if success and billboardGui then
        startScalingLoop()
        return true
    else
        task.spawn(function()
            task.wait(2)
            if mutationTimerEnabled then
                local success = findBillboardGui()
                if success and billboardGui then
                    startScalingLoop()
                end
            end
        end)
        return false
    end
end


local function toggleMutationTimer(state)
    mutationTimerEnabled = state
    config.ShowMutationTimer = state
    saveConfig(config)
    
    if state then
        if showMutationTimerDisplay() then
            Window:Notify("Mutation Timer Display Enabled", 2)
        else
            Window:Notify("Could not find mutation timer", 2)
        end
    else
        restoreOriginalProperties()
        Window:Notify("Mutation Timer Display Disabled", 2)
    end
end

UISection:Toggle("Show Mutation Timer", function(state)
    toggleMutationTimer(state)
end, {
    default = mutationTimerEnabled
})

if mutationTimerEnabled then
    task.wait(3)
    showMutationTimerDisplay()
end

-- Set walkspeed slider
local function setWalkSpeed(speed)
    Humanoid.WalkSpeed = speed
end

LocalPlayerSection:Slider("Walkspeed", 20, 1000, walkSpeedValue, function(value)
    walkSpeedValue = value
    config.WalkSpeed = value
    saveConfig(config)

    if value then
        setWalkSpeed(value)
    end
end)

setWalkSpeed(walkSpeedValue)

-- Set jumppower slider
local function setJumpPower(power)
    Humanoid.JumpPower = power
end

LocalPlayerSection:Slider("Jump Power", 50, 1000, jumpPowerValue, function(value)
    jumpPowerValue = value
    config.JumpPower = value
    saveConfig(config)
    
    if value then
        setJumpPower(value)
    end
end)

setJumpPower(jumpPowerValue)

-- Inf jump toggle
UserInputService.JumpRequest:connect(function()
    if infiniteJumpEnabled and Running.infiniteJump then	
    LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
    end
end)

LocalPlayerSection:Toggle("Infinite Jump", function(state)
    infiniteJumpEnabled = state
    config.InfiniteJump = state
    saveConfig(config)
    
    if state then
        Window:Notify("Infinite Jump Enabled", 2)
    else
        Window:Notify("Infinite Jump Disabled", 2)
    end
end)

-- Job ID input with current job as placeholder
local jobIdInput = RejoinSection:Label("Current Job ID: " .. currentJobId)

  -- Delay slider
local delayValue = config.InitialDelay or 5
local delaySlider = RejoinSection:Slider("Rejoin Delay", 0, 60, delayValue, function(value)
    delayValue = value
    config.InitialDelay = value
    saveConfig(config)
end)

  -- Countdown function
local function countdown(seconds)
    for i = seconds, 1, -1 do
        print("Rejoining in " .. i .. " seconds...")
        task.wait(1)
    end
end

  -- Main teleport function
local function persistentTeleport(jobId, initialDelay)
    local ATTEMPT_COUNTER = 0
    local FIXED_RETRY_DELAY = 2
    
    if ATTEMPT_COUNTER == 0 then
        countdown(initialDelay)
    end
    
    while true do
        ATTEMPT_COUNTER += 1
        print("\nAttempt #" .. ATTEMPT_COUNTER .. " to rejoin server")

        local teleportSucceeded = false
        local teleportError = ""

        local failureConnection
        failureConnection = TeleportService.TeleportInitFailed:Connect(function(player, result, errorMsg)
            if player == Players.LocalPlayer then
                teleportSucceeded = false
                teleportError = errorMsg
                failureConnection:Disconnect()
            end
        end)
        
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
        end)

        local startTime = os.clock()
        while os.clock() - startTime < 5 and not teleportSucceeded do
            task.wait(0.1)
        end

        if failureConnection.Connected then
            failureConnection:Disconnect()
        end
        
        if teleportSucceeded then
            print("Rejoined")
            return
        end

        if not success then
            warn("Rejoin call failed:", err)
        elseif teleportError ~= "" then
            warn("Rejoin failed:", teleportError)
        else
            warn("Rejoin failed for unknown reason")
        end
        
        local jitter = math.random(0, 20) * 0.1
        local total_delay = FIXED_RETRY_DELAY + jitter
        
        print("Next attempt in " .. string.format("%.1f", total_delay) .. " seconds")
        
        local wait_interval = 1 
        local waited = 0
        while waited < total_delay do
            local remaining = total_delay - waited
            print("Retrying in " .. string.format("%.1f", remaining) .. "s")
            task.wait(wait_interval)
            waited += wait_interval
        end
    end
end

  -- Start button
RejoinSection:Button("Auto Rejoin", function()
    -- Update and save config
    local newConfig = {
        InitialDelay = delayValue,
        JobId = currentJobId
    }
    saveConfig(newConfig)
    
    -- Determine job ID to use
    local targetJobId = #newConfig.JobId > 0 and newConfig.JobId or currentJobId
    
    -- Start teleport process
    local success, err = pcall(function()
        persistentTeleport(targetJobId, newConfig.InitialDelay)
    end)
    
    if not success then
        warn("CRITICAL ERROR:", err)
        print("Restarting rejoin process...")
        task.wait(5)
        pcall(function()
            persistentTeleport(targetJobId, newConfig.InitialDelay)
        end)
    end
end)

-- Info Tab
local AboutSection = InfoTab:Section("About Meowhan")
local StatsSection = InfoTab:Section("Session Statistics")

-- About
AboutSection:Label("Meowhan Grow A Garden Exploit")
AboutSection:Label("Version: 1.2.5")

-- Stats
local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
local GameName = GameInfo.Name

StatsSection:Label("Current Game: " .. GameName)
StatsSection:Label("Player: " .. LocalPlayer.Name)
StatsSection:Label("Current Job ID: " .. game.JobId)
StatsSection:Label("Current Place ID: " .. game.PlaceId)

StatsSection:Button("Copy Job ID", function()
    setclipboard(game.JobId)
    Window:Notify("Job ID copied to clipboard!", 2)
end)
