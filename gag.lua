-- All Variables
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
local Backpack = LocalPlayer:FindFirstChild("Backpack")
local PlayerGui = Players.LocalPlayer.PlayerGui
local GameEvents = ReplicatedStorage.GameEvents
local placeId = game.PlaceId
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
end)

local mainFolder = Workspace:FindFirstChild("Farm")
if not mainFolder then
    warn("Main 'Farm' folder not found in Workspace")
    return
end

local PlayerFarm = nil

for _, child in ipairs(mainFolder:GetChildren()) do
    if child.Name ~= "Farm" or not child:IsA("Folder") then
        continue
    end
        
    local Owner = child:FindFirstChild("Important") 
                    and child.Important:FindFirstChild("Data") 
                    and child.Important.Data:FindFirstChild("Owner")
        
    if Owner and Owner:IsA("StringValue") and Owner.Value == LocalPlayer.Name then
        PlayerFarm = child
        break
    end
end

local CONFIG_FOLDER = "Meowhan/Config/"
local CONFIG_FILENAME = "GrowAGarden.json"
local DEFAULT_CONFIG = {
    -- Collect Fruits
    FruitsToCollect = {},
    FruitMutationsToCollect = {},
    FruitWeightToCollect = 0,
    FruitWeightModeToCollect = "None",
    AutoCollectSelectedFruits = false,
    
    -- Mutation Machine
    PetToMutate = "",
    PetMutations = {},
    AutoStartPetMutation = false,
    AutoClaimMutatedPet = false,

    -- Event
    CollectGlimmering = false,
    SubmitGlimmering = false,
    SubmitAllGlimmering = false,
    ShowGlimmerCounter = false,

    -- ESP
    ShowMutationTimer = true,

    -- Player
    WalkSpeed = 20,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,

    -- Rejoin
    InitialDelay = 30,
    JobId = ""
}
local Running = {
    autoStartMachine = true,
    autoClaimPet = true,
    collectGlimmering = true,
    submitGlimmering = true,
    submitAllGlimmering = true,
    showMutationTimer = true,
    autoBuyAll = true,
    autoBuySelected = true,
    stockUpdate = true,
    infiniteJump = true
}
local MachineMutations = {
    "Ascended", "Frozen", "Golden", "Inverted", "IronSkin", "Mega", "Radiant", "Rainbow", "Shiny", "Shocked", "Tiny", "Windy"
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
local Window = UILib:CreateWindow("  Grow A Garden")
local config = loadConfig()
local currentJobId = game.JobId

local MainTab = Window:Tab("Main")
local EventTab = Window:Tab("Event")
local ShopTab = Window:Tab("Shop")
local SettingsTab = Window:Tab("Settings")
local InfoTab = Window:Tab("Info")

-- Tab Vars
    -- Collect Fruit Vars
    local selectedFruitsToCollect = config.FruitsToCollect or {}
    local selectedFruitMutations = config.FruitMutationsToCollect or {}
    local selectedFruitWeight = config.FruitWeightToCollect or 0
    local selectedWeightMode = config.FruitWeightModeToCollect or "None"
    local autoCollectSelectedFruitsEnabled = config.AutoCollectSelectedFruits

    -- Mutation Machine Vars
    local autoStartMachineEnabled = config.AutoStartPetMutation
    local autoClaimPetEnabled = config.AutoClaimMutatedPet
    local selectedPetToMutate = config.PetToMutate or ""
    local selectedPetMutations = config.PetMutations or {}
    local MutationMachine = GameEvents.PetMutationMachineService_RE

    -- Event vars
    local autoCollectGlimmeringEnabed = config.CollectGlimmering
    local submitGlimmeringEnabled = config.SubmitGlimmering
    local submitAllGlimmeringEnabled = config.SubmitAllGlimmering

    -- Settings Vars
    local mutationTimerEnabled = config.ShowMutationTimer
    local originalBillboardPosition = nil
    local billboardGui = nil
    local scalingLoop = nil
    local Humanoid = Character:WaitForChild("Humanoid")
    local walkSpeedValue = config.WalkSpeed
    local jumpPowerValue = config.JumpPower
    local infiniteJumpEnabled = config.InfiniteJump
    local noclipEnabled = config.NoClip
    local NoClipping = nil
    local jobIdInput = config.JobId or ""

-- Initialize
local teleport = PlayerGui:FindFirstChild("Teleport_UI")
local frame = teleport:FindFirstChild("Frame")
local buttonNames = {"Gears", "Event", "Rebirth", "Pet"}

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

local function holdItem(itemName)  
    if not Backpack then
        warn("Backpack not found for player: " .. LocalPlayer.Name)
        return false
    end
    
    if not Character then
        Character = LocalPlayer.CharacterAdded:Wait()
    end
    
    local item = Backpack:FindFirstChild(itemName)
    if not item then
        warn("Item not found in backpack: " .. itemName)
        return false
    end
    
    item.Parent = Character
    return true
end

local function extractItem(itemName, pattern)
    local match = itemName:match(pattern)
    return match and tonumber(match) or nil
end

-- Main filtering function (Inventory)
local function findItem(filters)
    local nameFilter = filters.name or "None"
    local typeFilter = filters.type
    local mutationFilter = filters.mutation or "None"
    local weightFilter = filters.weight or 0
    local weightMode = filters.weightMode or "None"
    local ageFilter = filters.age or 0
    local ageMode = filters.ageMode or "None"
    local action = filters.action
    
    if not typeFilter or not action then
        warn("Type and action are required parameters")
        return false
    end

    if not Backpack then
        warn("Backpack not found")
        return false
    end

    for _, child in ipairs(Backpack:GetChildren()) do
        if child:GetAttribute("d") ~= true then
            local matchesAllFilters = true
            
            if child:GetAttribute("b") ~= typeFilter then
                matchesAllFilters = false
            end
            
            if matchesAllFilters and nameFilter ~= "None" then
                local nameMatch = false

                if type(nameFilter) == "table" then
                    for _, name in ipairs(nameFilter) do
                        if child.Name:find(name, 1, true) then
                            nameMatch = true
                            break
                        end
                    end
                else
                    nameMatch = child.Name:find(nameFilter, 1 , true)
                end

                if not nameMatch then
                    matchesAllFilters = false
                end
            end
            
            if matchesAllFilters and mutationFilter ~= "None" then
                local mutationMatch = false

                if type(mutationFilter) == "table" then
                    for _, mutation in ipairs(mutationFilter) do
                        local attributeValue = child:GetAttribute(mutation)
                        if attributeValue then
                            mutationMatch = true
                            break
                        end

                        local variant = child:FindFirstChild("Variant")
                        if variant and variant.Value == mutation then
                            mutationMatch = true
                            break
                        end
                    end
                else
                    local attributeValue = child:GetAttribute(mutationFilter)
                    if attributeValue then
                        mutationMatch = true
                    else
                        local variant = child:FindFirstChild("Variant")
                        mutationMatch = variant and variant.Value == mutationFilter
                    end
                end

                if not mutationMatch then
                    matchesAllFilters = false
                end
            end
            
            if matchesAllFilters and weightMode ~= "None" then
                local weight = extractItem(child.Name, "%[(%d*%.?%d+) KG%]") or extractItem(child.Name, "%[(%d*%.?%d+)kg%]")
                
                if not weight then
                    matchesAllFilters = false
                elseif weightMode == "Less" and weight > weightFilter then
                    matchesAllFilters = false
                elseif weightMode == "Greater" and weight < weightFilter then
                    matchesAllFilters = false
                end
            end
            
            if matchesAllFilters and ageMode ~= "None" then
                local age = extractItem(child.Name, "%[Age (%d+)%]")
                
                if not age then
                    matchesAllFilters = false
                elseif ageMode == "Less" and age > ageFilter then
                    matchesAllFilters = false
                elseif ageMode == "Greater" and age < ageFilter then
                    matchesAllFilters = false
                end
            end
            
            if matchesAllFilters then
                if holdItem(child.Name) then
                    action()
                    return true
                end
            end
        end
    end
    
    return false
end

-- Main filtering function (Farm)
local function findFruit(filters)
    local nameFilter = filters.name or "None"
    local typeFilter = filters.type
    local mutationFilter = filters.mutation or "None"
    local weightFilter = filters.weight or 0
    local weightMode = filters.weightMode or "None"
    local action = filters.action
    local plants = PlayerFarm.Important:FindFirstChild("Plants_Physical")
    
    if not typeFilter or not action then
        warn("Type and action are required parameters")
        return false
    end

    if not plants then
        warn("PlayerFarm not found")
        return false
    end

    local function checkFruit(fruit)
        if fruit:GetAttribute("Favorited") == true then
            return false
        end

        local matchesAllFilters = true
        
        if matchesAllFilters and nameFilter ~= "None" then
            local nameMatch = false
            if type(nameFilter) == "table" then
                for _, name in ipairs(nameFilter) do
                    if fruit.Name:find(name, 1, true) then
                        nameMatch = true
                        break
                    end
                end
            else
                nameMatch = fruit.Name:find(nameFilter, 1, true)
            end
            matchesAllFilters = nameMatch
        end

        if matchesAllFilters and mutationFilter ~= "None" then
            local mutationMatch = false
            if type(mutationFilter) == "table" then
                for _, mutation in ipairs(mutationFilter) do
                    local attributeValue = fruit:GetAttribute(mutation)
                    if attributeValue then
                        mutationMatch = true
                        break
                    end
                    local variant = fruit:FindFirstChild("Variant")
                    if variant and variant.Value == mutation then
                        mutationMatch = true
                        break
                    end
                end
            else
                local attributeValue = fruit:GetAttribute(mutationFilter)
                if attributeValue then
                    mutationMatch = true
                else
                    local variant = fruit:FindFirstChild("Variant")
                    mutationMatch = variant and variant.Value == mutationFilter
                end
            end
            matchesAllFilters = mutationMatch
        end

        if matchesAllFilters and weightMode ~= "None" then
            local weight = fruit:FindFirstChild("Weight")
            if not weight then
                matchesAllFilters = false
            else
                weight = tonumber(weight.Value)
                if weightMode == "Less" and weight > weightFilter then
                    matchesAllFilters = false
                elseif weightMode == "Greater" and weight < weightFilter then
                    matchesAllFilters = false
                end
            end
        end

        return matchesAllFilters
    end

    for _, child in ipairs(plants:GetChildren()) do
        if child:IsA("Model") then
            local fruitsFolder = child:FindFirstChild("Fruits")
            if fruitsFolder then
                for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                    if fruit:IsA("Model") and checkFruit(fruit) then
                        if action(fruit) then
                            return true
                        end
                    end
                end
            else
                if checkFruit(child) then
                    if action(child) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

--[[
    for _, child in ipairs(plants:GetChildren()) do    
        if child:GetAttribute("Favorited") ~= true then
            local matchesAllFilters = true
            
            if matchesAllFilters and nameFilter ~= "None" then
                local nameMatch = false
            
                if type(nameFilter) == "table" then
                    for _, name in ipairs(nameFilter) do
                        if child.Name:find(name, 1, true) then
                            nameMatch = true
                            break
                        end
                    end
                else
                    nameMatch = child.Name:find(nameFilter, 1 , true)
                end
    
                if not nameMatch then
                    matchesAllFilters = false
                end
            end
            
            if matchesAllFilters and mutationFilter ~= "None" then
                local mutationMatch = false

                if type(mutationFilter) == "table" then
                    for _, mutation in ipairs(mutationFilter) do
                        local attributeValue = child:GetAttribute(mutation)
                        if attributeValue then
                            mutationMatch = true
                            break
                        end

                        local variant = child:FindFirstChild("Variant")
                        if variant and variant.Value == mutation then
                            mutationMatch = true
                            break
                        end
                    end
                else
                    local attributeValue = child:GetAttribute(mutationFilter)
                    if attributeValue then
                        mutationMatch = true
                    else
                        local variant = child:FindFirstChild("Variant")
                        mutationMatch = variant and variant.Value == mutationFilter
                    end
                end

                if not mutationMatch then
                    matchesAllFilters = false
                end
            end
            
            if matchesAllFilters and weightMode ~= "None" then
                local weight = extractItem(child.Name, "%[(%d*%.?%d+) KG%]") or extractItem(child.Name, "%[(%d*%.?%d+)kg%]")
                
                if not weight then
                    matchesAllFilters = false
                elseif weightMode == "Less" and weight > weightFilter then
                    matchesAllFilters = false
                elseif weightMode == "Greater" and weight < weightFilter then
                    matchesAllFilters = false
                end
            end
            
            if matchesAllFilters then
                if holdItem(child.Name) then
                    action()
                    return true
                end
            end
        end
    
    return false
end ]] --

-- Seeds teleport button UI
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

-- Main Tab
local CollectFruitSection = MainTab:Section("Collect Fruit")
local MutationMachineSection = MainTab:Section("Mutation Machine")
local MutationMachineVulnSection = MainTab:Section("Mutation Machine (Vuln)")

CollectFruitSection:Dropdown("Select Fruits: ", MachineMutations, selectedFruitsToCollect, function(selected)
    if selected then
        selectedFruitsToCollect = selected
        config.FruitsToCollect = selected
        saveConfig(config)
    end
end, true)

CollectFruitSection:Dropdown("Select Mutations: ", MachineMutations, selectedFruitMutations, function(selected)
    if selected then
        selectedFruitMutations = selected
        config.FruitMutationsToCollect = selected
        saveConfig(config)
    end
end, true)

CollectFruitSection:Dropdown("Weight Mode: ", {"None", "Below", "Above"}, selectedWeightMode, function(selected)
    if selected then
        selectedWeightMode = selected
        config.FruitWeightModeToCollect = selected
        saveConfig(config)
    end
end)

CollectFruitSection:TextBox("Weight: ", "Fruit Weight", tostring(selectedFruitWeight), function(weight)
    selectedFruitWeight = tonumber(weight)
    config.FruitWeightToCollect = tonumber(weight)
end)

CollectFruitSection:Toggle("Auto Collect Fruit", function(state)
    autoCollectSelectedFruitsEnabled = state
    config.AutoCollectSelectedFruits = state
        
    if state then
        Window:Notify("Auto Collect Enabled", 2)
        if autoCollectGlimmeringEnabed then
            autoCollectGlimmeringEnabed = false
            config.CollectGlimmering = false
        end
    else
        Window:Notify("Auto Collect Disabled", 2)
    end

    saveConfig(config)
end, {
    default = autoCollectSelectedFruitsEnabled,
    group = "Auto_Collect"
})

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

  -- Select pet dropdown
MutationMachineSection:Dropdown("Select Pet: ", {"Test1", "Test2", "Test3"}, selectedPetToMutate, function(selected)
    if selected then
        selectedPetToMutate = selected
        config.PetToMutate = selected
        saveConfig(config)
    end
end)

  -- Select mutation
MutationMachineSection:Dropdown("Select Mutation: ", MachineMutations, selectedPetMutations, function(selected)
    if selected then
        selectedPetMutations = selected
        config.PetMutations = selected
        saveConfig(config)
    end
end, true)

  -- Auto claim toggle
local autoClaimPet = MutationMachineSection:Toggle("Auto Claim Pet", function(state)
    toggleAutoClaimPet(state)
end, {
    default = autoClaimPetEnabled
})

-- Event Tab
local FairyEventSection = EventTab:Section("Fairy Event")

--[[ Ex use of findItem(table)

findItem({
    name = "Apple",          -- Optional: looks for names containing "Apple"
    type = "l",              -- Required: checks if type equals "l" (Pet) or "j" (Fruit)
    mutation = "Glimmering", -- Optional: checks if attribute "Glimmering"
    weight = 5,              -- Optional: weight threshold
    weightMode = "Less",     -- Optional: "Less", "Greater", or "None"
    age = 10,                -- Optional: age threshold
    ageMode = "Greater",     -- Optional: "Less", "Greater", or "None"
    action = function()      -- Required: function to execute if item is found
        -- action to perform
        game:GetService("ReplicatedStorage").PetMutationMachineService_RE:FireServer()
    end
})

]]
-- Auto collect glimmering
spawn(function()
    while Running.collectGlimmering do
        if autoCollectGlimmeringEnabed then
            findFruit({
                        type = "Fruit",
                        mutation = "Glimmering",
                        action = function(fruit)
                            for _, child in ipairs(fruit:GetDescendants()) do
                                if child.Name == "ProximityPrompt" then
                                    base = child.Parent
                                    base.Transparency = 0
                                    base.CanCollide = false
                                    base.CFrame = HumanoidRootPart.CFrame
                                    child:InputHoldBegin()
                                    child:InputHoldEnd()
                                    break
                                end
                            end
                        end
            })
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

-- Auto submit glimmering
spawn(function()
    while Running.submitGlimmering do
        if submitGlimmeringEnabled then
            findItem({
                type = "j",
                mutation = "Glimmering",
                action = function()
                            GameEvents.FairyService.SubmitFairyFountainHeldPlant:FireServer()
                        end
            })
            task.wait(0.5)
        else
            task.wait(1)    
        end
    end
end)

-- Auto submit all glimmering
spawn(function()
    while Running.submitAllGlimmering do
        if submitAllGlimmeringEnabled then
            GameEvents.FairyService.SubmitFairyFountainAllPlants:FireServer()
            task.wait(5)
        else
            task.wait(10)
        end
    end
end)

FairyEventSection:Toggle("Auto Collect Glimmering", function(state)
    autoCollectGlimmeringEnabed = state
    config.CollectGlimmering = state
    
    if state then
        Window:Notify("Auto Collect Enabled", 2)
        if autoCollectSelectedFruitsEnabled then
            autoCollectSelectedFruitsEnabled = false
            config.AutoCollectSelectedFruits = false
        end
    else
        Window:Notify("Auto Collect Disabled", 2)
    end
    
    saveConfig(config)
end, {
    default = autoCollectGlimmeringEnabed,
    group = "Auto_Collect"
})

FairyEventSection:Toggle("Auto Submit Glimmering", function(state)
    submitGlimmeringEnabled = state
    config.SubmitGlimmering = state
        
    if state then
        Window:Notify("Auto Submit Enabled", 2)
        if submitAllGlimmeringEnabled then
            submitAllGlimmeringEnabled = false
            config.SubmitAllGlimmering = false
        end            
    else
        Window:Notify("Auto Submit Disabled", 2)
    end

    saveConfig(config)
end, {
    default = submitGlimmeringEnabled,
    group = "Fairy_Fountain_Submit"
})

FairyEventSection:Toggle("Auto Submit All Glimmering", function(state)
    submitAllGlimmeringEnabled = state
    config.SubmitAllGlimmering = state
        
    if state then
        Window:Notify("Auto Submit All Enabled", 2)
        if submitGlimmeringEnabled then
            submitGlimmeringEnabled = false
            config.SubmitGlimmering = false
        end   
    else
        Window:Notify("Auto Submit All Disabled", 2)
    end

    saveConfig(config)
end, {
    default = submitAllGlimmeringEnabled,
    group = "Fairy_Fountain_Submit"
})

-- Shop Tab
local SeedShopSection = ShopTab:Section("Seed Shop")

-- Settings Tab
local ESPSection = SettingsTab:Section("ESP")
local LocalPlayerSection = SettingsTab:Section("Player")
local RejoinSection = SettingsTab:Section("Rejoin Config")

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
        if not Running.showMutationTimer or not mutationTimerEnabled or not billboardGui or not billboardGui.Parent then
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

local function connectDestroyEvent()
    local uiScreenGui = CoreGui:FindFirstChild("MeowhanUI") or PlayerGui:WaitForChild("MeowhanUI")
    
    if uiScreenGui then
        uiScreenGui.Destroying:Connect(function()
            for key, _ in pairs(Running) do
                Running[key] = false
            end
            if restoreOriginalProperties then
                restoreOriginalProperties()
            end
        end)
    else
        warn("ScreenGui not found in CoreGui or PlayerGui")
    end
end

connectDestroyEvent()

ESPSection:Toggle("Show Mutation Timer", function(state)
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
end, {
    default = mutationTimerEnabled
})

if mutationTimerEnabled then
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
infiniteJumpLoop = UserInputService.JumpRequest:connect(function()
    if infiniteJumpEnabled and Running.infiniteJump then	
    LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
    end
end)

UILib:TrackProcess("connections", infiniteJumpLoop, "infiniteJumpLoop")

LocalPlayerSection:Toggle("Infinite Jump", function(state)
    infiniteJumpEnabled = state
    config.InfiniteJump = state
    saveConfig(config)
    
    if state then
        Window:Notify("Infinite Jump Enabled", 2)
    else
        Window:Notify("Infinite Jump Disabled", 2)
    end
end, {
    default = infiniteJumpEnabled
})

-- Noclip toggle
local function noClipLoop()
    if noclipEnabled and Character then
        for _, child in ipairs(Character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CanCollide = false
            end
        end
    end
end

LocalPlayerSection:Toggle("Noclip", function(state)
    noclipEnabled = state
    config.NoClip = state
    saveConfig(config)

    if state then
        if not NoClipping then
            NoClipping = RunService.Stepped:Connect(noClipLoop)
            UILib:TrackProcess("connections", NoClipping, "NoClipping")
        end
    else
        if NoClipping then
            NoClipping:Disconnect()
            NoClipping = nil
            UILib:UntrackProcess("connections", "NoClipping")
        end
    end
end, {
    default = noclipEnabled
})

if noclipEnabled and NoClipping ~= nil then
    NoClipping = RunService.Stepped:Connect(noClipLoop)
    UILib:TrackProcess("connections", NoClipping, "NoClipping")
end

  -- Delay slider
local delayValue = config.InitialDelay or 5
local delaySlider = RejoinSection:Slider("Rejoin Delay", 0, 60, delayValue, function(value)
    delayValue = value
    config.InitialDelay = value
    saveConfig(config)
end)

  -- Job ID input with current job as placeholder
RejoinSection:TextBox("Input JobId", "Leave empty to use current", currentJobId, function(text)
    jobIdInput = text
    config.JobId = text
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
        JobId = jobIdInput
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
AboutSection:Label("Version: 1.2.6")

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
