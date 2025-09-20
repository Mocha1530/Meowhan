--[[
	Grow A Garden automation and more by Mocha1530
]]

-- All Variables
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local CraftingTables = Workspace:FindFirstChild("CraftingTables")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:FindFirstChild("Backpack")
local PlayerGui = Players.LocalPlayer.PlayerGui
local GameEvents = ReplicatedStorage.GameEvents
local UpdateItems = Workspace.Interaction.UpdateItems
local EventFolder = Workspace:FindFirstChild("Fall Festival")
local placeId = game.PlaceId
local CraftingData = require(ReplicatedStorage:FindFirstChild("Data"):FindFirstChild("CraftingData"))
local EventShopData = require(ReplicatedStorage:FindFirstChild("Data"):FindFirstChild("EventShopData"))
local DataService = require(ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("DataService"))
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

local a_s_data = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mocha1530/Meowhan/refs/heads/main/gag/data/Seeds.lua", true))()
local a_s_list = {}
for k_a_s, _ in pairs(a_s_data) do
    table.insert(a_s_list, k_a_s)
end

local a_s_m_data = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mocha1530/Meowhan/refs/heads/main/gag/data/FruitMutations.lua", true))()
local a_s_m_list = {}
for _, v_a_s_m in ipairs(a_s_m_data.mutations) do
    table.insert(a_s_m_list, v_a_s_m.display_name)
end

local a_c_data = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mocha1530/Meowhan/refs/heads/main/gag/data/ShopCosmetics.lua", true))()
local a_c_list = {
    cosmetics = {},
    crates = {}
}
for k_a_c, _ in pairs(a_c_data["Cosmetic Items"]) do
    table.insert(a_c_list.cosmetics, k_a_c)
end
for k_a_c, _ in pairs(a_c_data["Cosmetic Crates"]) do
    table.insert(a_c_list.crates, k_a_c)
end

local a_e_s_data = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mocha1530/Meowhan/refs/heads/main/gag/data/EventShopData.lua", true))() --[[EventShopData]]
local a_e_s_list = {
    seed = {},
    gear = {},
    pet = {},
    cosmetic = {}
    
}
for k_a_e_s, v_a_e_s in pairs(a_e_s_data) do
    local ShopIndex = v_a_e_s.ShopIndex
    if ShopIndex == 1 then
        table.insert(a_e_s_list.seed, k_a_e_s)
    elseif ShopIndex == 2 then
        table.insert(a_e_s_list.gear, k_a_e_s)
    elseif ShopIndex == 3 then
        table.insert(a_e_s_list.pet, k_a_e_s)
    elseif ShopIndex == 4 then
        table.insert(a_e_s_list.cosmetic, k_a_e_s)
    end
end

local ownedPets = {}
local function getOwnedPets()
    table.clear(ownedPets)
    for _, pets in ipairs(Backpack:GetChildren()) do
        if pets:GetAttribute("b") == "l" then
            ownedPets[pets.Name] = pets:GetAttribute("PET_UUID")
        end
    end
    local PetDisplay = PlayerGui.ActivePetUI:FindFirstChild("PetDisplay", true)
    for _, pets in ipairs(PetDisplay.ScrollingFrame:GetChildren()) do
        if pets:IsA("Frame") and pets.Name ~= "PetTemplate" then
            local nameLabel = pets:FindFirstChild("PET_TYPE", true)
            local ageLabel = pets:FindFirstChild("PET_AGE", true)
            local age = ageLabel.Text:match("%d+")
            local name = nameLabel.Text .. " [Age " .. age .. "]"
            ownedPets[name] = pets.Name
        end
    end
    return ownedPets
end

getOwnedPets()

local itemRecipes = {}
local craftingItems = {}
local RecipeByMachine = CraftingData.CraftingRecipeRegistry.RecipiesSortedByMachineType
for a, v in pairs(RecipeByMachine) do
    for b, val in pairs(v) do
        if not craftingItems[a] then
            craftingItems[a] = {}
        end
        table.insert(craftingItems[a], b)
        for c, vals in ipairs(val.Inputs) do
            local var1 = itemRecipes[b]
            if not var1 then
                var1 = {}
                itemRecipes[b] = var1
            end
            var1[c] = { ItemType = vals.ItemType, ItemName = vals.ItemData.ItemName }
        end
    end
end
        
local IMAGE_FOLDER = "Meowhan/Image/GrowAGarden/"
local CONFIG_FOLDER = "Meowhan/Config/"
local CONFIG_FILENAME = "GrowAGarden.json"
local DEFAULT_CONFIG = {
    -- Collect Fruits
    FruitsToCollect = {},
    FruitMutationsToCollect = {},
    FruitWeightToCollect = 0,
    FruitWeightModeToCollect = "None",
    AutoCollectSelectedFruits = false,

    -- Event
        --[[ Fairy Event
        CollectGlimmering = false,
        SubmitGlimmering = false,
        SubmitAllGlimmering = false,
        ShowGlimmerCounter = false,
        SelectedRewards = {},
        MakeAWish = false,
        RestartWish = false, ]]

        -- Fall Market Event
        CollectRequested = false,
        FeedRequested = false,
        FeedAllRequested = false,
    -- Machine
        -- Mutation Machine
        PetToMutate = "",
        PetMutations = {},
        AutoStartPetMutation = false,
        AutoMutatePet = false,
        AutoClaimMutatedPet = false,

        -- Crafting Tables
        GearRecipe = "",
        SeedRecipe = "",
        AutoCraft = false,
    
    -- Shop
        -- Seed Shop
        SelectedSeeds = {},
        BuySelectedSeeds = false,
        BuyAllSeeds = false,
    
        -- Gear Shop
        SelectedGears = {},
        BuySelectedGears = false,
        BuyAllGears = false,

        -- Pet Egg Shop
        SelectedEggs = {},
        BuySelectedEggs = false,
        BuyAllEggs = false,

        -- Cosmetic Shop
        SelectedCosmetics = {},
        BuySelectedCosmetics = false,
        BuyAllCosmetics = false,
        SelectedCrates = {},
        BuySelectedCrates = false,
        BuyAllCrates = false,

        -- Event Shop
        SelectedEvents = {
            seed = {},
            gear = {},
            pet = {},
            cosmetic = {}
        },
        BuySelectedEvents = false,
        BuyAllEventss = false,
    
    -- ESP
    ShowMutationTimer = true,
	ShowEggESP = false,

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
    collectCrops = true,
    autoSubmitGlimmering = true,
    autoMakeAWish = true,
    autoRestartWish = true,
    autoFeedRequested = true,
    autoStartMachine = true,
    autoClaimPet = true,
    autoCraft = true,
    showMutationTimer = true,
    autoBuyStocks = true,
    autoBuySeeds = true,
    autoBuyGears = true,
    infiniteJump = true
}
local MachineMutations = {
    "Ascended", "Frozen", "Golden", "Inverted", "IronSkin", "Mega", "Radiant", "Rainbow", "Shiny", "Shocked", "Tiny", "Windy"
}
local FairyWishRewards = {
    "Aurora Vine", "Enchanted Crate", "Enchanted Egg", "Enchanted Seed Pack", "FairyPoints", "Fairy Targeter", "Glimmering Radar", "Mutation Spray Glimmering", "Pet Shard Glimmering"
}
local PlantTraits = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mocha1530/Meowhan/refs/heads/main/gag/data/PlantTraits.lua", true))()

-- Create folder structure
local function ensureFolderStructure()
    if not pcall(function() 
        if not isfolder("Meowhan") then
            makefolder("Meowhan")
        end
        if not isfolder("Meowhan/Config") then
            makefolder("Meowhan/Config")
        end
        if not isfolder("Meowhan/Image/GrowAGarden") then
            makefolder("Meowhan/Image/GrowAGarden")
        end
    end) then
        warn("Could not create folder structure - using root directory")
        CONFIG_FOLDER = ""
        IMAGE_FOLDER = ""
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

-- Save file
local function saveFile(folder, filename, data)
    ensureFolderStructure()
    local fullpath = folder .. filename
    local success, err = pcall(function()
        writefile(fullpath, data)
    end)
    if not success then
        warn("Failed to save file:", err)
    end
end

-- Create UI
local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Mocha1530/Meowhan/refs/heads/main/UI/UI%20LibraryV2.lua'))()
local Window = UILib:CreateWindow("  Grow A Garden")
local config = loadConfig()
local currentJobId = game.JobId

local MainTab = Window:Tab("Main")
local EventTab = Window:Tab("Event")
local MachineTab = Window:Tab("Machine")
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

    -- Event vars
        --[[ Fairy Event
        local autoCollectGlimmeringEnabed = config.CollectGlimmering
        local submitGlimmeringEnabled = config.SubmitGlimmering
        local submitAllGlimmeringEnabled = config.SubmitAllGlimmering
        local selectedFairyWishRewards = config.SelectedRewards or {}
        local autoMakeAWishEnabled = config.MakeAWish
        local autoRestartWishEnabled = config.RestartWish]]

        -- Fall Market Event
        local autoCollectRequestedEnabed = config.CollectRequested
        local feedRequestedEnabled = config.FeedRequested
        local feedAllRequestedEnabled = config.FeedAllRequested
        local requestedPlant = nil
        local OaklayProgress = nil
        local OaklayTrait = nil

    -- Machine Vars
        -- Mutation Machine
        local autoStartMachineEnabled = config.AutoStartPetMutation
        local autoMutatePetEnabled = config.AutoMutatePet
        local autoClaimPetEnabled = config.AutoClaimMutatedPet
        local selectedPetToMutate = config.PetToMutate or ""
        local selectedPetMutations = config.PetMutations or {}
        local MutationMachine = GameEvents.PetMutationMachineService_RE

        -- Crafting Table
        local selectedGearRecipe = config.GearRecipe or ""
        local selectedSeedRecipe = config.SeedRecipe or ""
        local autoCraftEnabled = config.AutoCraft

    -- Shop Vars
        -- Seed Shop Vars
        local selectedShopSeeds = config.SelectedSeeds or {}
        local autoBuySelectedSeedsEnabled = config.BuySelectedSeeds
        local autoBuyAllSeedsEnabled = config.BuyAllSeeds
    
        -- Gear Shop Vars
        local selectedShopGears = config.SelectedGears or {}
        local autoBuySelectedGearsEnabled = config.BuySelectedGears
        local autoBuyAllGearsEnabled = config.BuyAllGears

        -- Event Shop Vars
        local selectedEventSeeds = config.SelectedEvents["seed"] or {}
        local selectedEventGears = config.SelectedEvents["gear"] or {}
        local selectedEventPets = config.SelectedEvents["pet"] or {}
        local selectedEventCosmetics = config.SelectedEvents["cosmetic"] or {}

    -- Settings Vars
    local mutationTimerEnabled = config.ShowMutationTimer
    local originalBillboardPosition = nil
    local billboardGui = nil
    local scalingLoop = nil
    local showEggESPEnabled = config.ShowEggESP
    local eggHatch = nil
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
    
    local item = Backpack:FindFirstChild(itemName)
    if not item then
        warn("Item not found in backpack: " .. itemName)
        return false
    end

    Character.Humanoid:EquipTool(item)
    return true
end

local function extractItem(itemName, pattern, string)
    local match = itemName:match(pattern)
    if match then
        return string and tostring(match) or tonumber(match)
    else
        return nil
    end
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
            
            if matchesAllFilters and (nameFilter ~= "None" and #nameFilter > 0) then
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
            
            if matchesAllFilters and (mutationFilter ~= "None" and #mutationFilter > 0) then
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
                elseif weightMode == "Below" and weight > weightFilter then
                    matchesAllFilters = false
                elseif weightMode == "Above" and weight < weightFilter then
                    matchesAllFilters = false
                end
            end
            
            if matchesAllFilters and ageMode ~= "None" then
                local age = extractItem(child.Name, "%[Age (%d+)%]")
                
                if not age then
                    matchesAllFilters = false
                elseif ageMode == "Below" and age > ageFilter then
                    matchesAllFilters = false
                elseif ageMode == "Above" and age < ageFilter then
                    matchesAllFilters = false
                end
            end
            
            if matchesAllFilters then
                action(child.Name)
                return true
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

    local nameSet = {}
    if nameFilter ~= "None" and #nameFilter > 0 then
        if type(nameFilter) == "table" then
            for _, name in ipairs(nameFilter) do
                nameSet[name] = true
            end
        else
            nameSet[nameFilter] = true
        end
    end

    local mutationSet = {}
    if mutationFilter ~= "None" and #mutationFilter > 0 then
        if type(mutationFilter) == "table" then
            for _, mutation in ipairs(mutationFilter) do
                mutationSet[mutation] = true
            end
        else
            mutationSet[mutationFilter] = true
        end
    end

    local function checkFruit(fruit)
        local Age = fruit:FindFirstChild("Age", true)
        local MaxAge = fruit:GetAttribute("MaxAge")
        if (Age and Age:IsA("NumberVaue") and Age.Value ~= MaxAge then
            return false
        end
            
        if fruit:GetAttribute("Favorited") then
            return false
        end

        if next(nameSet) then
            if not nameSet[fruit.Name] then
                return false
            end
        end

        if next(mutationSet) then
            local hasMutation = false
            
            for mutation, _ in pairs(mutationSet) do
                if fruit:GetAttribute(mutation) then
                    hasMutation = true
                    break
                end
            end
            
            if not hasMutation then
                local variant = fruit:FindFirstChild("Variant")
                if variant then
                    hasMutation = mutationSet[variant.Value]
                end
            end
            
            if not hasMutation then
                return false
            end
        end

        if weightMode ~= "None" then
            local weight = fruit:FindFirstChild("Weight")
            if not weight then
                return false
            else
                local weightValue = tonumber(weight.Value)
                if not weightValue then
                    return false
                end
                
                if weightMode == "Below" and weightValue > weightFilter then
                    return false
                elseif weightMode == "Above" and weightValue < weightFilter then
                    return false
                end
            end
        end

        return true
    end

    local foundFruits = {}
    
    for _, child in ipairs(plants:GetChildren()) do
        if child:IsA("Model") then
            local fruitsFolder = child:FindFirstChild("Fruits")
            if fruitsFolder then
                for _, fruit in ipairs(fruitsFolder:GetChildren()) do
                    if fruit:IsA("Model") and fruit.Parent and checkFruit(fruit) then
                        table.insert(foundFruits, fruit)
                    end
                end
            else
                if child.Parent and checkFruit(child) then
                    table.insert(foundFruits, child)
                end
            end
        end
    end

    return foundFruits
end

-- Tab Functions
    -- Auto Collect
    for _, v_e in ipairs(EventFolder:GetDescendants()) do
        if v_e:IsA("TextLabel") then
            if v_e.Name == "TraitTextLabel" then
                OaklayTrait = v_e
                requestedPlant = extractItem(v_e.Text, "%>([a-zA-Z]+[%s]?[a-zA-Z]+)%<", true)
            elseif v_e.Name == "ProgressionLabel" then
                OaklayProgress = v_e
            end
        end
        if OaklayProgress and OaklayTrait then break end
    end
    
    OaklayTrait:GetPropertyChangedSignal("Text"):Connect(function()
        requestedPlant = extractItem(OaklayTrait.Text, "%>([a-zA-Z]+[%s]?[a-zA-Z]+)%<", true)
    end)
    local function startCollectCrops()
        task.spawn(function()
            while Running.collectCrops and (autoCollectRequestedEnabed or autoCollectSelectedFruitsEnabled) do
                local fruitsToCollect = {}
                if autoCollectRequestedEnabed then
                    if not OaklayProgress.Text:find("Cooldown", 1, true) then
                        if PlantTraits[requestedPlant] then
                            fruitsToCollect = findFruit({
                                name = PlantTraits[requestedPlant],
                                type = "Fruit",
                                action = function(fruit) end
                            })
                        else
                            task.wait(5)
                        end
                    else
                        task.wait(5)
                    end
                elseif autoCollectSelectedFruitsEnabled then
                    fruitsToCollect = findFruit({
                        name = selectedFruitsToCollect,
                        type = "Fruit",
                        mutation = selectedFruitMutations,
                        weight = selectedFruitWeight,
                        weightMode = selectedWeightMode,
                        action = function(fruit) end
                    })
                else
                    task.wait(2)
                end
                
                if #fruitsToCollect > 0 then
                    for _, fruit in ipairs(fruitsToCollect) do
                        if Running.collectCrops and (autoCollectRequestedEnabed or autoCollectSelectedFruitsEnabled) then
                            if not OaklayProgress.Text:find("Cooldown", 1, true) then
                                local success, err = pcall(function()
                                    GameEvents.Crops.Collect:FireServer({fruit})
                                end)
                            
                                if not success then
                                    warn("Failed to collect fruit: " .. err)
                                end
                                task.wait(0.1)
                            else
                                task.wait(5)
                                break
                            end
                        else
                            task.wait(5)
                            break
                        end
                    end
                else
                    task.wait(1)
                end
            end
        end)
    end
    
    if autoCollectRequestedEnabed or autoCollectSelectedFruitsEnabled then
        startCollectCrops()
    end

    -- Auto Make a Wish
    --[[ local Wish = Workspace:FindFirstChild("FairyEvent") 
                    and Workspace.FairyEvent:FindFirstChild("WishFountain") 
                    and Workspace.FairyEvent.WishFountain:FindFirstChild("WishingWellGUI") 
                    and Workspace.FairyEvent.WishFountain.WishingWellGUI:FindFirstChild("ProgressBilboard")
                    and Workspace.FairyEvent.WishFountain.WishingWellGUI.ProgressBilboard:FindFirstChild("TextLabel")

    local function selectButton()
        local ChooseRewards = PlayerGui:FindFirstChild("ChooseFairyRewards_UI")
        if not ChooseRewards then return end
        local Items = ChooseRewards:FindFirstChild("Frame")
                        and ChooseRewards.Frame:FindFirstChild("Main")
                        and ChooseRewards.Frame.Main:FindFirstChild("Items")
        local selected = {}
        local left = {}

		for _, button in ipairs(Items:GetChildren()) do
            if button.Name == "Template" and button:IsA("ImageButton") and button.Selectable and button.Visible then
                table.insert(left, button)
            end
        end
	
        for _, prio in ipairs(selectedFairyWishRewards) do
            for _, button in ipairs(left) do
                local title = button:FindFirstChild("Title") or button:FindFirstChildWhichIsA("TextLabel")
                if title and title.Text == prio then
                    table.insert(selected, title.Text)
                    GuiService.SelectedObject = button
                    if GuiService.SelectedObject then
                        pcall(function()
                            for _, connection in pairs(getconnections(GuiService.SelectedObject.Activated)) do
                                pcall(connection.Function)
                            end
                        end)
                    end
                    return
                end
            end
        end
        
        if #left > 0 then
            local randSelect = left[math.random(#left)]
            GuiService.SelectedObject = randSelect
            if GuiService.SelectedObject then
                pcall(function()
                    for _, connection in pairs(getconnections(GuiService.SelectedObject.Activated)) do
                        pcall(connection.Function)
                    end
                end)
            end
        else
            warn("No selectable buttons found.")
        end
    end
    
    local function startAutoMakeAWish()
        spawn(function()
            while Running.autoMakeAWish and autoMakeAWishEnabled do
                if Wish and Wish.Text == "Claim your wish!" then
                    GameEvents.FairyService.MakeFairyWish:FireServer()
                    task.wait(2)
                    selectButton()
                end
                task.wait(3)
            end
        end)
    end
    
    if autoMakeAWishEnabled then
        startAutoMakeAWish()
    end

    local function startAutoRestartWish()
        spawn(function()
            while Running.autoRestartWish and autoRestartWishEnabled do
                local Progress = Wish.Parent:FindFirstChild("UpgradeBar") 
                                and Wish.Parent.UpgradeBar:FindFirstChild("ProgressionLabel")
                if Progress and Progress.Text == "Out of Wishes" then
                    GameEvents.FairyService.RestartFairyTrack:FireServer()
                end
                task.wait(10)
            end
        end)
    end

    if autoRestartWishEnabled then
        startAutoRestartWish()
    end]]

    -- Auto Feed Requested
    local function startAutoFeedRequested()
        task.spawn(function()
            while Running.autoFeedRequested and (feedRequestedEnabled or feedAllRequestedEnabled) do
                if not OaklayProgress.Text:find("Cooldown", 1, true) then
                    if feedRequestedEnabled then
                        if PlantTraits[requestedPlant] then
                            findItem({
                                name = PlantTraits[requestedPlant],
                                type = "j",
                                action = function(itemName)
                                            if holdItem(itemName) then
                                                GameEvents.FallMarketEvent.SubmitHeldPlant:FireServer()
                                            end
                                        end
                            })
                            task.wait(0.5)
                        else
                            warn("Plant Trait '" .. requestedPlant .. "' Not Found")
                            task.wait(5)
                        end
                    elseif feedAllRequestedEnabled then
                        GameEvents.FallMarketEvent.SubmitAllPlants:FireServer()
                        task.wait(5)
                    end
                else
                    task.wait(10)
                end
            end
        end)
    end
    
    if feedRequestedEnabled or feedAllRequestedEnabled then
        startAutoFeedRequested()
    end

    -- Machine Function
        -- Mutation Machine Timer
    local function getMutationMachine()
        local MutationMachineModel = {}
        local NPCS = Workspace:FindFirstChild("NPCS")
        local MutMachine = NPCS:FindFirstChild("PetMutationMachine")
        
        if MutMachine then
            for _, child in ipairs(MutMachine:GetDescendants()) do
                if child:IsA("TextLabel") and child.Name == "TimerTextLabel" then
                    MutationMachineModel["Text"] = child.Text
                elseif child.Name == "PetModelLocation" then
                    for _, grandkid in ipairs(child:GetChildren()) do
                        if grandkid:IsA("Model") then
                            MutationMachineModel["Mutating"] = grandkid
                            break
                        elseif not MutationMachineModel["Mutating"] then
                            MutationMachineModel["Mutating"] = "None"
                        end
                    end
                end
                if MutationMachineModel["Text"] and MutationMachineModel["Mutating"] then
                    return MutationMachineModel
                end
            end
        end
    
        return nil
    end

    local function findPet(UUID, Mutation)
        UUID = UUID or ""
        Mutation = Mutation or {}
        local activePet = PlayerGui.ActivePetUI:FindFirstChild(UUID, true)
        if activePet then
            local activeMut = activePet:FindFirstChild("PET_TYPE", true)
            local activeAgeLabel = activePet:FindFirstChild("PET_AGE", true)
            local activeAge = activeAgeLabel.Text:match("%d+")
            if activeMut then
                for _, petMut in ipairs(Mutation) do
                    if not activeMut.Text:find(petMut, 1, true) and tonumber(activeAge) >= 50 then
                        GameEvents.PetsService:FireServer("UnequipPet", UUID)
                        break
                    end
                end
            end
        end
        for _, pet in ipairs(Backpack:GetChildren()) do
            if pet:GetAttribute("b") == "l" then
                if not pet:GetAttribute("d") and pet:GetAttribute("PET_UUID") == UUID then
                    local found = true
                    for _, petMut in ipairs(Mutation) do
                        if pet.Name:find(petMut, 1, true) then
                            found = false
                            break
                        end
                    end
                    if found then
                        return pet
                    end
                end
            end
        end
        return nil
    end

    local function getMutTime(Text)
        local parts = {}
        for part in Text:gmatch("[^:]+") do
            table.insert(parts, tonumber(part))
        end

        local result = 5
        if #parts == 3 then
            result = parts[1] * 3600 + parts[2] * 60 + parts[3]
            return result
        elseif #parts == 2 then
            result = parts[1] * 60 + parts[2]
            return result
        elseif #parts == 1 then
            result = parts[1]
            return result
        else
            return 5
        end
    end

    local function startAutoClaimPet()
        task.spawn(function()
            while Running.autoClaimPet and (autoClaimPetEnabled or autoMutatePetEnabled) do
                local MutationMachineModel = getMutationMachine()
                if MutationMachineModel.Text == "READY" and autoClaimPetEnabled then
                    MutationMachine:FireServer("ClaimMutatedPet")
                    task.wait(2)
                elseif autoMutatePetEnabled and MutationMachineModel.Mutating == "None" then
                    local Pet = findPet(selectedPetToMutate, selectedPetMutations)
                    if Pet then
                        Character.Humanoid:EquipTool(Pet)
                        MutationMachine:FireServer("SubmitHeldPet")
                    end
                    task.wait(5)
                else
                    local time = getMutTime(MutationMachineModel.Text)
                    if time then
                        task.wait(time)
                    else
                        task.wait(10)
                    end
                end
            end
        end)
    end
    
    if autoClaimPetEnabled or autoMutatePetEnabled then
       startAutoClaimPet()
    end

        -- Mutation Machine (Vuln)
    local function startAutoStartMachine()
        task.spawn(function()
            while Running.autoStartMachine and autoStartMachineEnabled do
                local timerStatus = getMutationMachine()
                if timerStatus.Text == nil or timerStatus.Text == "" then
                    MutationMachine:FireServer("StartMachine")
                end
                local time = getMutTime(timerStatus.Text)
                if time then
                    task.wait(time)
                else
                    task.wait(10)
                end
            end
        end)
    end
    
    if autoStartMachineEnabled then
        startAutoStartMachine()
    end

    -- Auto Craft
    local function getCraftingTime(object)
        local Timer = object:FindFirstChild("Timer", true)
        if Timer and Timer:IsA("TextLabel") then
            return true
        else
            return false
        end
    end
                    
    local function getCraftingItem(item)
        local Item = itemRecipes[item]
        local ItemData = {}

        for i, v in ipairs(Item) do
            for _, val in ipairs(Backpack:GetChildren()) do
                if val.Name:find(v.ItemName, 1, true) then
                    table.insert(ItemData, {
                        Index = i,
                        ["Type"] = v.ItemType,
                        UUID = val:GetAttribute("c"),
                    })
                    break
                end
            end
        end
        return ItemData
    end        
    
    local function startAutoCraft()
        task.spawn(function()
            while Running.autoCraft and autoCraftEnabled do
                local itemsToCraft = {}
                if selectedGearRecipe ~= "" and not getCraftingTime(CraftingTables.EventCraftingWorkBench) then
                    local gears = getCraftingItem(selectedGearRecipe)
                    if not itemsToCraft["GearEventWorkbench"] then
                        itemsToCraft["GearEventWorkbench"] = {}
                    end
                    itemsToCraft["GearEventWorkbench"] = { Object = CraftingTables.EventCraftingWorkBench, Item = selectedGearRecipe, Recipe = gears }
                end
                if selectedSeedRecipe ~= "" and not getCraftingTime(CraftingTables.SeedEventCraftingWorkBench) then
                    local seeds = getCraftingItem(selectedSeedRecipe)
                    if not itemsToCraft["SeedEventWorkbench"] then
                        itemsToCraft["SeedEventWorkbench"] = {}
                    end
                    itemsToCraft["SeedEventWorkbench"] = { Object = CraftingTables.SeedEventCraftingWorkBench, Item = selectedSeedRecipe, Recipe = seeds }
                end
                if itemsToCraft["GearEventWorkbench"] or itemsToCraft["SeedEventWorkbench"] then
                    for k, v in pairs(itemsToCraft) do
                        if Running.autoCraft and autoCraftEnabled then
                            GameEvents.CraftingGlobalObjectService:FireServer("Claim", v.Object, k, 1)
                            GameEvents.CraftingGlobalObjectService:FireServer("Cancel", v.Object, k)
                            task.wait(0.05)
                            GameEvents.CraftingGlobalObjectService:FireServer("SetRecipe", v.Object, k, v.Item)
                            for _, val in ipairs(v.Recipe) do
                                if Running.autoCraft and autoCraftEnabled then
                                    GameEvents.CraftingGlobalObjectService:FireServer("InputItem", v.Object, k, val.Index, { 
                                            ItemType = val.Type,
                                            ItemData = {
                                                UUID = val.UUID
                                            }
                                    })
                                    task.wait(0.05)
                                else
                                    break
                                end
                            end
                            GameEvents.CraftingGlobalObjectService:FireServer("Craft", v.Object, k)
                        else
                            break                    
                        end
                    end
                end
                task.wait(10)
            end
        end)
    end

    if Running.autoCraft and autoCraftEnabled then
        startAutoCraft()
    end
                    
    -- Shop Function
    local ShopControllers = {}

    local function getShopStock(shopGui, shopType, defaultItemName)
        local stock = {}
        if shopType == "Cosmetics" or shopType == "Crates" then
            local topItems = shopGui:FindFirstChild("TopSegment", true)
            local bottomItems = shopGui:FindFirstChild("BottomSegment", true)
            local table = string.lower(shopType)
        
            for _, items in ipairs(a_c_list[table]) do
                local item = topItems:FindFirstChild(items, true) or bottomItems:FindFirstChild(items, true)
                if not item then continue end
            
                if item:IsDescendantOf(topItems) or item:IsDescendantOf(bottomItems) then
                    local main = item:FindFirstChild("Main").Stock
                    if not main then continue end
                
                    local stockText = main.STOCK_TEXT.Text
                    local stockCount = tonumber(stockText:match("%d+"))
                
                    stock[item.Name] = stockCount
                end
            end
        else
            local items = shopGui:FindFirstChild(defaultItemName, true).Parent
        
            for _, item in next, items:GetChildren() do
                local mainFrame = item:FindFirstChild("Main_Frame")
                if not mainFrame then continue end
        
                local stockText = mainFrame.Stock_Text.Text
                local stockCount = tonumber(stockText:match("%d+"))
                
                stock[item.Name] = stockCount
            end
        end
        return stock
    end
    
    local function createShopController(shopType, shopGui, defaultItemName, fireEvent, tier)
        local controller = {}
        controller.stock = {}
        controller.itemList = {}
        controller.selectedItems = config["Selected" .. shopType] or {}
        controller.autoBuySelected = config["BuySelected" .. shopType]
        controller.autoBuyAll = config["BuyAll" .. shopType]
        
        controller.updateStock = function()
            if shopType ~= "Events" then
                controller.stock = getShopStock(shopGui, shopType, defaultItemName)
                    
                controller.itemList = {}
                for itemName, _ in pairs(controller.stock) do
                    table.insert(controller.itemList, itemName)
                end
            else
                controller.stock = a_e_s_data
            end        
            return controller.stock
        end
            
        controller.updateStock()
        
        controller.startBuying = function()
            task.spawn(function()
                while Running.autoBuyStocks and (controller.autoBuySelected or controller.autoBuyAll) do
                    controller.updateStock()
                    
                    local itemsToBuy = {}
                    
                    if controller.autoBuySelected then
                        if shopType ~= "Events" then
                            if #controller.selectedItems > 0 then
                                for _, itemName in ipairs(controller.selectedItems) do
                                    if controller.stock[itemName] and controller.stock[itemName] > 0 then
                                        table.insert(itemsToBuy, {name = itemName, count = controller.stock[itemName]})
                                    end
                                end
                            end
                        else
                            for shop, items in pairs(controller.selectedItems) do
                                for _, itemName in ipairs(items) do
                                    local item = controller.stock[itemName]
                                    table.insert(itemsToBuy, {name = itemName, count = item.StockAmount, shopIndex = item.ShopIndex})
                                end
                            end
                        end
                    elseif controller.autoBuyAll then
                        for itemName, count in pairs(controller.stock) do
                            if shopType ~= "Events" then
                                if count > 0 then
                                    table.insert(itemsToBuy, {name = itemName, count = count})
                                end
                            else
                                table.insert(itemsToBuy, {name = itemName, count = count.StockAmount, shopIndex = count.ShopIndex})
                            end
                        end
                    end
                    
                    for _, item in ipairs(itemsToBuy) do
                        if shopType ~= "Events" then
                            if tier then
                                for i = 1, item.count do
                                    fireEvent(tier, item.name)
                                    task.wait(0.05)
                                end
                            else
                                for i = 1, item.count do
                                    fireEvent(item.name)
                                    task.wait(0.05)
                                end
                            end
                        else
                            for i = 1, item.count do
                                fireEvent(item.name, item.shopIndex)
                                task.wait(0.05)
                            end
                        end
                    end
                    task.wait(5)
                end
            end)
        end
        
        ShopControllers[shopType] = controller
        return controller
    end
    
    local seedController = createShopController(
        "Seeds", 
        PlayerGui.Seed_Shop, 
        "Blueberry", 
        function(tier, itemName) 
            GameEvents.BuySeedStock:FireServer(tier, itemName) 
        end,
        "Tier 1"
    )
    
    local gearController = createShopController(
        "Gears", 
        PlayerGui.Gear_Shop, 
        "Watering Can", 
        function(itemName) 
            GameEvents.BuyGearStock:FireServer(itemName) 
        end
    )

    local eggController = createShopController(
        "Eggs", 
        PlayerGui.PetShop_UI, 
        "Common Egg", 
        function(itemName) 
            GameEvents.BuyPetEgg:FireServer(itemName) 
        end
    )

    local cosmeticController = createShopController(
        "Cosmetics", 
        PlayerGui.CosmeticShop_UI, 
        "Placeholder", 
        function(itemName) 
            GameEvents.BuyCosmeticItem:FireServer(itemName) 
        end
    )

    local crateController = createShopController(
        "Crates", 
        PlayerGui.CosmeticShop_UI, 
        "Placeholder", 
        function(itemName) 
            GameEvents.BuyCosmeticCrate:FireServer(itemName) 
        end
    )

    local eventController = createShopController(
        "Events", 
        "Placeholder", 
        "Placeholder", 
        function(itemName, shopIndex) 
            GameEvents.BuyEventShopStock:FireServer(itemName, shopIndex) 
        end
    )

    local shopTypes = {
        "Seeds", "Gears", "Eggs", "Cosmetics", "Crates", "Events"
    }
    for _, v in ipairs(shopTypes) do
        if config["BuySelected" .. v] or config["BuyAll" .. v] then
            ShopControllers[v].startBuying()
        end
    end

    --[[ lol why th am I hardcoding it

        if config.BuySelectedSeeds or config.BuyAllSeeds then
            seedController.startBuying()
        end
            
        if config.BuySelectedGears or config.BuyAllGears then
            gearController.startBuying()
        end
    
        if config.BuySelectedEggs or config.BuyAllEggs then
            eggController.startBuying()
        end
    
        if config.BuySelectedCosmetics or config.BuyAllCosmetics then
            cosmeticController.startBuying()
        end
    
        if config.BuySelectedCrates or config.BuyAllCrates then
            crateController.startBuying()
        end
    
        if config.BuySelectedEvents or config.BuyAllEvents then
            eventController.startBuying()
        end
    ]]

    -- Egg ESP
    local DataClient = {}
    function DataClient.GetSaved_Data()
        local ds = DataService
        if not ds or not ds.GetData then return nil end
        local ok, data = pcall(function() return ds:GetData() end)
        if not ok or not data then return nil end
        local saveSlots = data.SaveSlots
        if not saveSlots then return nil end
        local selected = saveSlots.SelectedSlot
        if not selected then return nil end
        local all = saveSlots.AllSlots
        if not all or not all[selected] then return nil end
        return all[selected].SavedObjects
    end
    local Calculator = {}
    do
        local function CalculateWeight(Y, w)
            return Y + Y * 0.1 * w
        end
        function Calculator.CurrentWeight(Y, w)
            local Q = CalculateWeight(Y, w) * 100
            local Yround = math.round(Q) / 100
            return Yround
        end
    end
    
    local ESP = {}
    do
        function ESP.CreateESP(target, opts)
            if not target or not opts then return end
            if target:FindFirstChild("ESP") then return end
    
            local adornee = nil
            if target:IsA("Model") then
                adornee = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
            elseif target:IsA("BasePart") then
                adornee = target
            end
            if not adornee then return end
    
            local folder = Instance.new("Folder")
            folder.Name = "ESP"
            folder.Parent = target
    
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "ESP"
            box.Size = Vector3.new(1, 0, 1)
            box.Transparency = 1
            box.AlwaysOnTop = false
            box.ZIndex = 0
            box.Adornee = adornee
            box.Parent = folder
    
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = adornee
            billboard.Size = UDim2.new(0, 100, 0, 150)
            billboard.StudsOffset = Vector3.new(0, 1, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = box
    
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 0, 0, -50.0)
            label.Size = UDim2.new(0, 100, 0, 100)
            label.TextSize = 10
            label.TextColor3 = opts.Color or Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0
            label.TextYAlignment = Enum.TextYAlignment.Bottom
            label.RichText = true
            label.Text = opts.Text or ""
            label.ZIndex = 15
            label.Parent = billboard
    
            return {
                Folder = folder,
                Adornee = adornee,
                Box = box,
                Gui = billboard,
                Label = label
            }
        end
    
        function ESP.Removes(target)
            if not target then return end
            task.spawn(function()
                local f = target:FindFirstChild("ESP")
                if f then f:Destroy() end
            end)
        end
    end

    local function EggIsVisibleForLocal(egg)
        if not egg then return false end
        if egg:GetAttribute("OWNER") ~= LocalPlayer.Name then
            return false
        end
        local readFlag = egg:GetAttribute("READY")
        if not readFlag then
            return false
        end
        local tth = tonumber(egg:GetAttribute("TimeToHatch")) or 0
        if tth > 0 then
            return false
        end
        return true
    end

    local function AttachOrUpdateEggESP(eggModel)
        if not eggModel then return end
        if not EggIsVisibleForLocal(eggModel) then
            ESP.Removes(eggModel)
            return
        end
        local uuid = eggModel:GetAttribute("OBJECT_UUID")
        if not uuid then
            ESP.Removes(eggModel)
            return
        end
        local saved = DataClient.GetSaved_Data()
        if not saved then
            ESP.Removes(eggModel)
            return
        end
        local entry = saved[uuid]
        if not entry or type(entry) ~= "table" or not entry.Data then
            ESP.Removes(eggModel)
            return
        end
    
        local data = entry.Data
        local eggName   = data.EggName or eggModel:GetAttribute("EggName") or "Egg"
        local eggType   = data.Type or "Unknown"
        local baseWeight= data.BaseWeight or 1
        local scale     = data.Scale or 1
    
        local ok, weightValue = pcall(function()
            return Calculator.CurrentWeight(baseWeight, scale)
        end)
        if not ok or not weightValue then weightValue = baseWeight end
    
        local tier =
            (weightValue > 9 and "Titanic")
            or (weightValue >= 6 and weightValue <= 9 and "Semi Titanic")
            or (weightValue > 3 and "Huge")
            or "Small"
    
        local labelText = string.format(
            "<font color='rgb(3,211,252)'>%s</font>\n<font color='rgb(255,215,0)'>%s</font>\n<font color='rgb(100,255,100)'>%s</font>",
            tostring(eggName),
            tostring(eggType),
            tostring(weightValue) .. " KG " .. tier
        )
    
        ESP.Removes(eggModel)
        ESP.CreateESP(eggModel, { Color = Color3.fromRGB(255, 255, 255), Text = labelText })
    end

    local function ScanAllEggs()
        local farm = PlayerFarm.Important.Objects_Physical
        if not farm then return end
        local saved = DataClient.GetSaved_Data()
        if not saved then return end
    
        for _, inst in ipairs(farm:GetChildren()) do
            if showEggESPEnabled then
                pcall(function()
                    AttachOrUpdateEggESP(inst)
                end)
            else
                pcall(function()
                    ESP.Removes(inst)
                end)
            end
        end
    end
    
    local function startEggESP()
        ScanAllEggs()
    
        local ok, mess = pcall(function()
            local remotes = GameEvents
            local ev = remotes:FindFirstChild("EggReadyToHatch_RE")
            if ev and ev:IsA("RemoteEvent") then
                eggHatch = ev.OnClientEvent:Connect(function(arg1, arg2)
                    task.wait(1)
                    local farm2 = PlayerFarm.Important.Objects_Physical
                    if not farm2 then print("Farm not found") return end
                    for _, inst in ipairs(farm2:GetChildren()) do
                        if inst:GetAttribute("OBJECT_UUID") == arg2 then
                            local ok, er = pcall(function() AttachOrUpdateEggESP(inst) end)
                            print("Egg Hatched: " .. tostring(arg1))
                            break
                        end
                    end
                end)
                UILib:TrackProcess("connections", eggHatch, "EggHatch")
            end
        end)
        print("Connection: " .. tostring(ok) .. " " .. tostring(mess))
    end

    local function stopEggESP()
        ScanAllEggs()
    
        if eggHatch then
            eggHatch:Disconnect()
        end
    end
        
    if showEggESPEnabled then 
        startEggESP()
    end
    
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

CollectFruitSection:Dropdown("Select Fruits: ", a_s_list, selectedFruitsToCollect, function(selected)
    if selected then
        selectedFruitsToCollect = selected
        config.FruitsToCollect = selected
        saveConfig(config)
    end
end, true)

CollectFruitSection:Dropdown("Select Mutations: ", a_s_m_list, selectedFruitMutations, function(selected)
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
		startCollectCrops()
        Window:Notify("Auto Collect Enabled", 2)
        if autoCollectRequestedEnabed then
            autoCollectRequestedEnabed = false
            config.CollectRequested = false
        end
    else
        Window:Notify("Auto Collect Disabled", 2)
    end

    saveConfig(config)
end, {
    default = autoCollectSelectedFruitsEnabled,
    group = "Auto_Collect"
})

-- Event Tab
    --[[ Fairy Event
    local FairyEventSection = EventTab:Section("Fairy Event")
    
     Ex use of findItem(table)
    
    findItem({
        name = "Apple",          -- Optional: looks for names containing "Apple"
        type = "l",              -- Required: checks if type equals "l" (Pet) or "j" (Fruit)
        mutation = "Glimmering", -- Optional: checks if attribute "Glimmering"
        weight = 5,              -- Optional: weight threshold
        weightMode = "Below",     -- Optional: "Below", "Above", or "None"
        age = 10,                -- Optional: age threshold
        ageMode = "Greater",     -- Optional: "Below", "Above", or "None"
        action = function()      -- Required: function to execute if item is found
            -- action to perform
            game:GetService("ReplicatedStorage").PetMutationMachineService_RE:FireServer()
        end
    })
    
    -- Auto submit glimmering
    local function startAutoSubmitGlimmering()
        spawn(function()
            while Running.autoSubmitGlimmering and (submitGlimmeringEnabled or submitAllGlimmeringEnabled) do
                if submitGlimmeringEnabled then
                    findItem({
                        type = "j",
                        mutation = "Glimmering",
                        action = function()
                                    GameEvents.FairyService.SubmitFairyFountainHeldPlant:FireServer()
                                end
                    })
                    task.wait(0.5)
                elseif submitAllGlimmeringEnabled then
                    GameEvents.FairyService.SubmitFairyFountainAllPlants:FireServer()
                    task.wait(5)
                end
            end
        end)
    end
    
    if submitGlimmeringEnabled or submitAllGlimmeringEnabled then
        startAutoSubmitGlimmering()
    end
    
    FairyEventSection:Toggle("Auto Collect Glimmering", function(state)
        autoCollectGlimmeringEnabed = state
        config.CollectGlimmering = state
    
        if state then
            startCollectCrops()
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
            startAutoSubmitGlimmering()
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
            startAutoSubmitGlimmering()
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
    
    FairyEventSection:Dropdown("Select Rewards:", FairyWishRewards, selectedFairyWishRewards, function(selected)
        if selected then
            selectedFairyWishRewards = selected
            config.SelectedRewards = selected
            saveConfig(config)
        end
    end, true)
    
    FairyEventSection:Toggle("Auto Make a Wish", function(state)
        autoMakeAWishEnabled = state
        config.MakeAWish = state
    
        if state then
            startAutoMakeAWish()
            Window:Notify("Auto Make A Wish Enabled", 2)
        else
            Window:Notify("Auto Make A Wish Disabled", 2)
        end
        saveConfig(config)
    end, {
    	default = autoMakeAWishEnabled
    })
    
    FairyEventSection:Toggle("Auto Restart Wish", function(state)
        autoRestartWishEnabled = state
        config.RestartWish = state
    
        if state then
            startAutoRestartWish()
            Window:Notify("Auto Restart Wish Enabled", 2)
        else
            Window:Notify("Auto Restart Wish Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = autoRestartWishEnabled
    }) ]]

    -- Fall Market Event
    local FallEventSection = EventTab:Section("Fall Market Event")

    FallEventSection:Toggle("Auto Collect Requested", function(state)
        autoCollectRequestedEnabed = state
        config.CollectRequested = state
    
        if state then
            startCollectCrops()
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
        default = autoCollectRequestedEnabed,
        group = "Auto_Collect"
    })
    
    FallEventSection:Toggle("Auto Feed Requested", function(state)
        feedRequestedEnabled = state
        config.FeedRequested = state
    
        if state then
            startAutoFeedRequested()
            Window:Notify("Auto Feed Enabled", 2)
            if feedAllRequestedEnabled then
                feedAllRequestedEnabled = false
                config.FeedAllRequested = false
            end            
        else
            Window:Notify("Auto Feed Disabled", 2)
        end
    
        saveConfig(config)
    end, {
        default = feedRequestedEnabled,
        group = "Feed"
    })
    
    FallEventSection:Toggle("Auto Feed All Requested", function(state)
        feedAllRequestedEnabled = state
        config.FeedAllRequested = state
    
        if state then
            startAutoFeedRequested()
            Window:Notify("Auto Feed All Enabled", 2)
            if feedRequestedEnabled then
                feedRequestedEnabled = false
                config.FeedRequested = false
            end   
        else
            Window:Notify("Auto Feed All Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = feedAllRequestedEnabled,
        group = "Feed"
    })

-- Machine Tab
local MutationMachineSection = MachineTab:Section("Mutation Machine")
local CraftingTableSection = MachineTab:Section("Crafting Table")

-- Mutation Machine
    -- Select pet dropdown
    local petSelection = MutationMachineSection:Dropdown("Select Pet: ", ownedPets, selectedPetToMutate, function(selected)
        if selected then
            selectedPetToMutate = selected
            config.PetToMutate = selected
            saveConfig(config)
            Window:Notify("Selected: " .. selected)
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
    
    MutationMachineSection:Button("Refresh Pet Selection", function()
        if getOwnedPets() then
            petSelection:Refresh(ownedPets)
        end
    end)
    
    MutationMachineSection:Toggle("Auto Mutate Pet", function(state)
        local starMut = false
        if state then
            if not autoMutatePetEnabled and not autoClaimPetEnabled then
                startMut = true
            end
            Window:Notify("Auto Mutate Pet Enabled", 2)
        else
            Window:Notify("Auto Mutate Pet Disabled", 2)
        end
            
        autoMutatePetEnabled = state
        config.AutoMutatePet = state
        saveConfig(config)
    
        if startMut then
            startAutoClaimPet()
        end
    end, {
        default = autoMutatePetEnabled
    })

    -- Auto claim toggle
    MutationMachineSection:Toggle("Auto Claim Pet", function(state)
        local starClaim = false
        if state then
            if not autoMutatePetEnabled and not autoClaimPetEnabled then
                starClaim = true
            end
            Window:Notify("Auto Claim Pet Enabled", 2)
        else
            Window:Notify("Auto Claim Pet Disabled", 2)
        end
    
        autoClaimPetEnabled = state
        config.AutoClaimMutatedPet = state
        saveConfig(config)
    
        if starClaim then
            startAutoClaimPet()
        end
    end, {
        default = autoClaimPetEnabled
    })
    
    MutationMachineSection:Label("Mutation Machine Vuln")
    
    MutationMachineSection:Button("Submit Held Pet", function()
        MutationMachine:FireServer("SubmitHeldPet")
    end)
    
    MutationMachineSection:Button("Start Machine", function()
        local timerStatus = getMutationMachineTimer()
        if timerStatus == nil or timerStatus == "" then
            MutationMachine:FireServer("StartMachine")
            Window:Notify("Machine Started", 2)
        else
            Window:Notify("Machine Already Started", 2)
        end
    end)
    
    MutationMachineSection:Toggle("Auto Start Machine", function(state)
        autoStartMachineEnabled = state
        config.AutoStartPetMutation = state
        saveConfig(config)
    
        if state then
            startAutoStartMachine()
            Window:Notify("Auto Start Machine Enabled", 2)
        else
            Window:Notify("Auto Start Machine Disabled", 2)
        end
    end, {
        default = autoStartMachineEnabled
    })

-- Crafting Table
    -- Select Gear Recipe
    CraftingTableSection:Dropdown("Select Gear Recipe", craftingItems.GearEventWorkbench, selectedGearRecipe, function(selected)
        if selected then
            selectedGearRecipe = selected
            config.GearRecipe = selected
            saveConfig(config)
        end
    end)

    CraftingTableSection:Dropdown("Select Seed Recipe", craftingItems.SeedEventWorkbench, selectedSeedRecipe, function(selected)
        if selected then
            selectedSeedRecipe = selected
            config.SeedRecipe = selected
            saveConfig(config)
        end
    end)

    CraftingTableSection:Toggle("Auto Craft", function(state)
        autoCraftEnabled = state
        config.AutoCraft = state
        saveConfig(config)

        if state then
            startAutoCraft()
            Window:Notify("Auto Craft Enabled", 2)
        else
            Window:Notify("Auto Craft Disabled", 2)
        end
    end, {
        default = autoCraftEnabled
    })

-- Shop Tab
local SeedShopSection = ShopTab:Section("Seed Shop")
local GearShopSection = ShopTab:Section("Gear Shop")
local PetShopSection = ShopTab:Section("Pet Egg Shop")
local CosmeticSection = ShopTab:Section("Cosmetic Shop")
local EventShopSection = ShopTab:Section("Event Shop")

    -- Seed Shop
    SeedShopSection:Label("Tier 1")
    
    SeedShopSection:Dropdown("Select Seeds: ", seedController.itemList, seedController.selectedItems, function(selected)
        if selected then
            seedController.selectedItems = selected
            config.SelectedSeeds = selected
            saveConfig(config)
        end
    end, true)
    
    SeedShopSection:Toggle("Auto Buy Selected", function(state)
        seedController.autoBuySelected = state
        config.BuySelectedSeeds = state
    
        if state then
            seedController.startBuying()
            Window:Notify("Auto Buy Selected Enabled", 2)
            if seedController.autoBuyAll then
                seedController.autoBuyAll = false
                config.BuyAllSeeds = false
            end
        else
            Window:Notify("Auto Buy Selected Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = seedController.autoBuySelected,
        group = "Buy_Shop_Seeds"
    })
    
    SeedShopSection:Toggle("Auto Buy All", function(state)
        seedController.autoBuyAll = state
        config.BuyAllSeeds = state
    
        if state then
            seedController.startBuying()
            Window:Notify("Auto Buy All Enabled", 2)
            if seedController.autoBuySelected then
                seedController.autoBuySelected = false
                config.BuySelectedSeeds = false
            end
        else
            Window:Notify("Auto Buy All Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = seedController.autoBuyAll,
        group = "Buy_Shop_Seeds"
    })

    -- Gear Shop
    GearShopSection:Dropdown("Select Gears: ", gearController.itemList, gearController.selectedItems, function(selected)
        if selected then
            gearController.selectedItems = selected
            config.SelectedGears = selected
            saveConfig(config)
        end
    end, true)
    
    GearShopSection:Toggle("Auto Buy Selected", function(state)
        gearController.autoBuySelected = state
        config.BuySelectedGears = state
    
        if state then
            gearController.startBuying()
            Window:Notify("Auto Buy Selected Enabled", 2)
            if gearController.autoBuyAll then
                gearController.autoBuyAll = false
                config.BuyAllGears = false
            end
        else
            Window:Notify("Auto Buy Selected Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = gearController.autoBuySelected,
        group = "Buy_Shop_Gears"
    })
    
    GearShopSection:Toggle("Auto Buy All", function(state)
        gearController.autoBuyAll = state
        config.BuyAllGears = state
    
        if state then
            gearController.startBuying()
            Window:Notify("Auto Buy All Enabled", 2)
            if gearController.autoBuySelected then
                gearController.autoBuySelected = false
                config.BuySelectedGears = false
            end
        else
            Window:Notify("Auto Buy All Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = gearController.autoBuyAll,
        group = "Buy_Shop_Gears"
    })

    -- Pet Egg Shop
    PetShopSection:Label("Tier 1")
    
    PetShopSection:Dropdown("Select Eggs: ", eggController.itemList, eggController.selectedItems, function(selected)
        if selected then
            eggController.selectedItems = selected
            config.SelectedEggs = selected
            saveConfig(config)
        end
    end, true)
    
    PetShopSection:Toggle("Auto Buy Selected", function(state)
        eggController.autoBuySelected = state
        config.BuySelectedEggs = state
    
        if state then
            eggController.startBuying()
            Window:Notify("Auto Buy Selected Enabled", 2)
            if eggController.autoBuyAll then
                eggController.autoBuyAll = false
                config.BuyAllEggs = false
            end
        else
            Window:Notify("Auto Buy Selected Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = eggController.autoBuySelected,
        group = "Buy_Shop_Eggs"
    })
    
    PetShopSection:Toggle("Auto Buy All", function(state)
        eggController.autoBuyAll = state
        config.BuyAllEggs = state
    
        if state then
            eggController.startBuying()
            Window:Notify("Auto Buy All Enabled", 2)
            if eggController.autoBuySelected then
                eggController.autoBuySelected = false
                config.BuySelectedEggs = false
            end
        else
            Window:Notify("Auto Buy All Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = eggController.autoBuyAll,
        group = "Buy_Shop_Eggs"
    })

    -- Cosmetic Shop
    CosmeticSection:Dropdown("Select Crates: ", a_c_list.crates, crateController.selectedItems, function(selected)
        if selected then
            crateController.selectedItems = selected
            config.SelectedCrates = selected
            saveConfig(config)
        end
    end, true)
    
    CosmeticSection:Toggle("Auto Buy Selected", function(state)
        crateController.autoBuySelected = state
        config.BuySelectedCrates = state
    
        if state then
            crateController.startBuying()
            Window:Notify("Auto Buy Selected Enabled", 2)
            if crateController.autoBuyAll then
                crateController.autoBuyAll = false
                config.BuyAllCrates = false
            end
        else
            Window:Notify("Auto Buy Selected Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = crateController.autoBuySelected,
        group = "Buy_Shop_Crates"
    })
    
    CosmeticSection:Toggle("Auto Buy All", function(state)
        crateController.autoBuyAll = state
        config.BuyAllCrates = state
    
        if state then
            cosmeticController.startBuying()
            Window:Notify("Auto Buy All Enabled", 2)
            if crateController.autoBuySelected then
                crateController.autoBuySelected = false
                config.BuySelectedCrates = false
            end
        else
            Window:Notify("Auto Buy All Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = crateController.autoBuyAll,
        group = "Buy_Shop_Crates"
    })

    CosmeticSection:Dropdown("Select Cosmetics: ", a_c_list.cosmetics, cosmeticController.selectedItems, function(selected)
        if selected then
            gearController.selectedItems = selected
            config.SelectedGears = selected
            saveConfig(config)
        end
    end, true)

    CosmeticSection:Toggle("Auto Buy Selected", function(state)
        cosmeticController.autoBuySelected = state
        config.BuySelectedCosmetics = state
    
        if state then
            cosmeticController.startBuying()
            Window:Notify("Auto Buy Selected Enabled", 2)
            if cosmeticController.autoBuyAll then
                cosmeticController.autoBuyAll = false
                config.BuyAllCosmetics = false
            end
        else
            Window:Notify("Auto Buy Selected Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = cosmeticController.autoBuySelected,
        group = "Buy_Shop_Cosmetics"
    })
    
    CosmeticSection:Toggle("Auto Buy All", function(state)
        cosmeticController.autoBuyAll = state
        config.BuyAllCosmetics = state
    
        if state then
            cosmeticController.startBuying()
            Window:Notify("Auto Buy All Enabled", 2)
            if cosmeticController.autoBuySelected then
                cosmeticController.autoBuySelected = false
                config.BuySelectedCosmetics = false
            end
        else
            Window:Notify("Auto Buy All Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = cosmeticController.autoBuyAll,
        group = "Buy_Shop_Cosmetics"
    })

    -- Event Shop
    EventShopSection:Dropdown("Select Seed:", a_e_s_list.seed, selectedEventSeeds, function(selected)
        if selected then
            eventController.selectedItems.seed = selected
            config.SelectedEvents.seed = selected
            saveConfig(config)
        end
    end, true)

    EventShopSection:Dropdown("Select Gear:", a_e_s_list.gear, selectedEventGears, function(selected)
        if selected then
            eventController.selectedItems.gear = selected
            config.SelectedEvents.gear = selected
            saveConfig(config)
        end
    end, true)

    EventShopSection:Dropdown("Select Pet:", a_e_s_list.pet, selectedEventPets, function(selected)
        if selected then
            eventController.selectedItems.pet = selected
            config.SelectedEvents.pet = selected
            saveConfig(config)
        end
    end, true)

    EventShopSection:Dropdown("Select Cosmetic:", a_e_s_list.cosmetic, selectedEventCosmetics, function(selected)
        if selected then
            eventController.selectedItems.cosmetic = selected
            config.SelectedEvents.cosmetic = selected
            saveConfig(config)
        end
    end, true)

    EventShopSection:Toggle("Auto Buy Selected", function(state)
        eventController.autoBuySelected = state
        config.BuySelectedEvents = state
    
        if state then
            eventController.startBuying()
            Window:Notify("Auto Buy Selected Enabled", 2)
            if eventController.autoBuyAll then
                eventController.autoBuyAll = false
                config.BuyAllEvents = false
            end
        else
            Window:Notify("Auto Buy Selected Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = eventController.autoBuySelected,
        group = "Buy_Shop_Events"
    })

    EventShopSection:Toggle("Auto Buy All", function(state)
        eventController.autoBuyAll = state
        config.BuyAllEvents = state
    
        if state then
            eventController.startBuying()
            Window:Notify("Auto Buy All Enabled", 2)
            if eventController.autoBuySelected then
                eventController.autoBuySelected = false
                config.BuySelectedEvents = false
            end
        else
            Window:Notify("Auto Buy All Disabled", 2)
        end
        saveConfig(config)
    end, {
        default = eventController.autoBuyAll,
        group = "Buy_Shop_Events"
    })

-- Settings Tab
local ESPSection = SettingsTab:Section("ESP")
local LocalPlayerSection = SettingsTab:Section("Player")
local RejoinSection = SettingsTab:Section("Rejoin Config")

-- Function to find and store the BillboardGui reference
local function setupBillboard()
    local billboardPart = workspace.NPCS.PetMutationMachine.Model:FindFirstChild("BillboardPart", true)
    if billboardPart and billboardPart:FindFirstChild("BillboardGui") then
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
        local billboardGui = billboardPart.BillboardGui
		local TimerTextLabel = billboardGui.TimerTextLabel
        billboardGui.Adornee = billboardPart
        billboardGui.Size = UDim2.new(7, 0, 4, 0)
        billboardGui.MaxDistance = 10000
		TimerTextLabel.Position = UDim2.new(0.5, -15, 0, 0)
		TimerTextLabel.Size = UDim2.new(0, 30, 0, 14)
        
        return true
    end
    return false
end

-- Function to restore the original position and properties
local function restoreOriginalProperties()
    if originalBillboardPosition then
    	local billboardPart = workspace.NPCS.PetMutationMachine.Model:FindFirstChild("BillboardPart", true)
        billboardPart.Position = originalBillboardPosition
        billboardPart.CanCollide = true

        local gui = billboardPart:FindFirstChild("BillboardGui")
        if gui then
			local label = gui.TimerTextLabel
			gui.Adornee = nil
            gui.MaxDistance = 60
            gui.Size = UDim2.new(7, 0, 4, 0)
			label.Position = UDim2.new(0, 0, 0, 0)
			label.Size = UDim2.new(1, 0, 0.3, 0)
        end
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
            if showEggESPEnabled then
                showEggESPEnabled = false
                stopEggESP()
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
        if setupBillboard() then
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
    setupBillboard()
end

ESPSection:Toggle("Show Egg ESP", function(state)
    showEggESPEnabled = state
    config.ShowEggESP = state
    saveConfig(config)

    if state then
        if startEggESP() then
            Window:Notify("Egg ESP Enabled", 2)
        else
            Window:Notify("Could not find egg", 2)
        end
    else
        stopEggESP()
        Window:Notify("Egg ESP Disabled", 2)
    end
end, {
    default = showEggESPEnabled
})

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
AboutSection:Label("Version: 1.3.252")

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
