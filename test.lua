local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Function to create the GUI window
local function createScriptViewerWindow(scriptContent)
    -- Create the main GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScriptViewer"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Create the main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
    mainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    -- Add corner rounding
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    -- Create the title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    -- Add title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(0.8, 0, 1, 0)
    titleText.Position = UDim2.new(0.1, 0, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Script Content Viewer"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.Parent = titleBar

    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar

    -- Add corner rounding to close button
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    -- Create script content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -50)
    contentFrame.Position = UDim2.new(0, 10, 0, 40)
    contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 8
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.Parent = mainFrame

    -- Add corner rounding to content frame
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentFrame

    -- Create script content text label
    local contentText = Instance.new("TextLabel")
    contentText.Name = "ContentText"
    contentText.Size = UDim2.new(1, -10, 0, 0)
    contentText.AutomaticSize = Enum.AutomaticSize.Y
    contentText.Position = UDim2.new(0, 10, 0, 10)
    contentText.BackgroundTransparency = 1
    contentText.Text = scriptContent or "No script content found"
    contentText.TextColor3 = Color3.fromRGB(220, 220, 220)
    contentText.TextXAlignment = Enum.TextXAlignment.Left
    contentText.TextYAlignment = Enum.TextYAlignment.Top
    contentText.Font = Enum.Font.Code
    contentText.TextSize = 12
    contentText.TextWrapped = false
    contentText.TextXAlignment = Enum.TextXAlignment.Left
    contentText.TextYAlignment = Enum.TextYAlignment.Top
    contentText.Parent = contentFrame

    -- Make window draggable
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragStart then
            update(input)
        end
    end)

    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    return screenGui
end

-- Function to find the correct Farm folder based on the Owner StringValue
local function findFarmFolder()
    local firstFarmFolder = workspace:FindFirstChild("Farm")
    if not firstFarmFolder then
        warn("First 'Farm' folder not found in Workspace")
        return nil
    end

    -- Iterate through all children of the first Farm folder
    for _, child in ipairs(firstFarmFolder:GetChildren()) do
        if child.Name == "Farm" and child:IsA("Folder") then
            local importantFolder = child:FindFirstChild("Important")
            if importantFolder then
                local ownerValue = importantFolder:FindFirstChild("Owner")
                if ownerValue and ownerValue:IsA("StringValue") and ownerValue.Value == localPlayer.Name then
                    return child  -- Found the correct Farm folder
                end
            end
        end
    end
    warn("No matching Farm folder found for player: ", localPlayer.Name)
    return nil
end

-- Function to retrieve the script content
local function getScriptContent()
    local farmFolder = findFarmFolder()
    if not farmFolder then
        return "Error: Could not find farm folder for player " .. localPlayer.Name
    end

    local objectsPhysical = farmFolder:FindFirstChild("Objects_Physical")
    if not objectsPhysical then
        return "Error: Objects_Physical folder not found"
    end

    -- Find the first PetEgg model
    local petEgg = objectsPhysical:FindFirstChild("PetEgg")
    if not petEgg then
        return "Error: PetEgg model not found"
    end

    -- Navigate to the Script inside Zen Egg/ProximityPrompt
    local zenEgg = petEgg:FindFirstChild("Zen Egg")
    if not zenEgg then
        return "Error: Zen Egg not found in PetEgg"
    end

    local proximityPrompt = zenEgg:FindFirstChild("ProximityPrompt")
    if not proximityPrompt then
        return "Error: ProximityPrompt not found in Zen Egg"
    end

    local targetScript = proximityPrompt:FindFirstChild("Script")
    if not targetScript or not targetScript:IsA("Script") then
        return "Error: Script not found in ProximityPrompt"
    end

    return targetScript.Source
end

-- Create and display the window with the script content
local scriptContent = getScriptContent()
createScriptViewerWindow(scriptContent)
