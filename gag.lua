local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local PlayerGui = Players.LocalPlayer.PlayerGui
local GameEvents = ReplicatedStorage.GameEvents
local placeId = game.PlaceId
local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
local GameName = GameInfo.Name

local CONFIG_FOLDER = "Meowhan/Config/"
local CONFIG_FILENAME = "GrowAGarden.json"
local DEFAULT_CONFIG = {
    InitialDelay = 30,
    JobId = "",
    AutoStartPetMutation = false,
    AutoClaimMutatedPet = false,
    ShowGlimmerCounter = false,
    ShowMutationTimer = true
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
local teleport = PlayerGui:FindFirstChild("Teleport_UI")
local frame = teleport:FindFirstChild("Frame")

local eventButton = Instance.new("ImageButton")
eventButton.Name = "Event"
eventButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
eventButton.BackgroundTransparency = 1
eventButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
eventButton.BorderSizePixel = 0
eventButton.LayoutOrder = 0
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

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local function findTeleportPoint()
    local Interaction = Workspace:WaitForChild("Interaction")
    local UpdateItems = Interaction:WaitForChild("UpdateItems")
    
    for _, item in ipairs(UpdateItems:GetDescendants()) do
        if item.Name == "Event_Point_Teleport" then
            return item
        end
    end
    
    return nil
end

eventButton.MouseButton1Click:Connect(function()
    local teleportPoint = findTeleportPoint()
    
    if teleportPoint then
        HumanoidRootPart.CFrame = teleportPoint.CFrame
    end
end)

-- Main Tab
local MutationMachineSection = MainTab:Section("Mutation Machine")
local MutationMachineVulnSection = MainTab:Section("Mutation Machine (Vuln)")
local RejoinSection = MainTab:Section("Rejoin Config")

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
    while true do
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
    while true do
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

  -- Auto claim toggle
local autoClaimPet = MutationMachineSection:Toggle("Auto Claim Pet", function(state)
    toggleAutoClaimPet(state)
end, {
    default = autoClaimPetEnabled
})
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

-- Event Tab
local EventSection = EventTab:Section("Fairy Event")

-- Glimmering Counter UI
local glimmerCounterEnabled = config.ShowGlimmerCounter or false
local glimmerGui = nil
local glimmerCount = 0

local function createGlimmerCounter()
    -- Destroy existing GUI if it exists
    if glimmerGui and typeof(glimmerGui) == "Instance" then
        glimmerGui:Destroy()
    end

    local player = game.Players.LocalPlayer
    local rs = game:GetService('ReplicatedStorage')

    -- Create the GUI
    glimmerGui = Instance.new('ScreenGui')
    glimmerGui.Name = 'GlimmerCounter'
    glimmerGui.ResetOnSpawn = false
    glimmerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    glimmerGui.Parent = player:WaitForChild('PlayerGui')

    local frame = Instance.new('Frame')
    frame.Size = UDim2.new(0, 380, 0, 70)
    frame.Position = UDim2.new(1, -400, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(150, 50, 200)
    frame.Parent = glimmerGui

    local header = Instance.new('TextLabel')
    header.Size = UDim2.new(1, -20, 0, 28)
    header.Position = UDim2.new(0, 10, 0, 5)
    header.BackgroundTransparency = 1
    header.Text = 'Glimmering Fruits'
    header.TextColor3 = Color3.fromRGB(180, 100, 255)
    header.TextSize = 20
    header.Font = Enum.Font.Code
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = frame

    local counter = Instance.new('TextLabel')
    counter.Size = UDim2.new(1, -20, 0, 35)
    counter.Position = UDim2.new(0, 10, 0, 28)
    counter.BackgroundTransparency = 1
    counter.Text = 'Count: 0'
    counter.TextColor3 = Color3.fromRGB(230, 230, 230)
    counter.TextSize = 16
    counter.Font = Enum.Font.Code
    counter.TextXAlignment = Enum.TextXAlignment.Left
    counter.Parent = frame

    glimmerCount = 0

    local notificationEvent = rs:WaitForChild('GameEvents'):WaitForChild('Notification')
    notificationEvent.OnClientEvent:Connect(function(msg)
        if typeof(msg) == 'string' and msg == 'A Fruit in your garden, mutated to Glimmering!' then
            glimmerCount = glimmerCount + 1
            counter.Text = 'Count: ' .. glimmerCount
        end
    end)

    return glimmerGui
end

local function toggleGlimmerCounter(state)
    glimmerCounterEnabled = state
    config.ShowGlimmerCounter = state
    saveConfig(config)

    if state then
        createGlimmerCounter()
        Window:Notify("Glimmer Counter Enabled", 2)
    else
        if glimmerGui and typeof(glimmerGui) == "Instance" then
            glimmerGui:Destroy()
            glimmerGui = nil
        end
        Window:Notify("Glimmer Counter Disabled", 2)
    end
end

-- FIXED: Use the correct toggle method from the UI library
-- Create a toggle using the Section:Toggle method instead of EventSection:Toggle
local glimmerToggle = EventSection:Toggle("Enable Glimmering Counter", function(state)
    toggleGlimmerCounter(state)
end, {
    default = glimmerCounterEnabled
})

-- Initialize glimmer counter if enabled
if glimmerCounterEnabled then
    createGlimmerCounter()
end

-- Shop Tab
local SeedShopSection = ShopTab:Section("Seed Shop")

-- Settings
local UISection = SettingsTab:Section("UI")

  -- Settings Vars
local mutationTimerEnabled = config.ShowMutationTimer or true
local originalBillboardPosition = nil
local billboardGui = nil
local scalingLoop = nil

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
                                gui.MaxDistance = 60  -- Default value
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
            task.wait(2) -- Wait a bit for the game to load
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


  -- Function to toggle the timer enhancement
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

-- Info Tab
local AboutSection = InfoTab:Section("About Meowhan")

AboutSection:Label("Meowhan Grow A Garden Exploit")
AboutSection:Label("Version: 1.2.5")

local StatsSection = InfoTab:Section("Session Statistics")

StatsSection:Label("Current Game: " .. GameName)
StatsSection:Label("Player: " .. game.Players.LocalPlayer.Name)
StatsSection:Label("Current Job ID: " .. game.JobId)
StatsSection:Label("Current Place ID: " .. game.PlaceId)

StatsSection:Button("Copy Job ID", function()
    setclipboard(game.JobId)
    Window:Notify("Job ID copied to clipboard!", 2)
end)
