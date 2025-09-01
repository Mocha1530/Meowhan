local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
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
    JobId = ""
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

-- Main Tab
local MainSection = MainTab:Section("Rejoin Config")

-- Job ID input with current job as placeholder
local jobIdInput = MainSection:Label("Current Job ID: " .. currentJobId)

-- Delay slider
local delayValue = config.InitialDelay or 5
local delaySlider = MainSection:Slider("Rejoin Delay", 0, 60, delayValue, function(value)
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
MainSection:Button("Auto Rejoin", function()
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

-- Variables for Auto-Buy functionality
local seedStock = {}
local autoBuyAllEnabled = false
local autoBuySelectedEnabled = false
local selectedSeed = ""

  -- Function to get seed stock from the game's GUI
local function getSeedStock(ignoreNoStock)
    local seedShop = PlayerGui.Seed_Shop
    local items = seedShop:FindFirstChild("Blueberry", true).Parent

    local newList = {}

    for _, item in next, items:GetChildren() do
        local mainFrame = item:FindFirstChild("Main_Frame")
        if not mainFrame then continue end

        local stockText = mainFrame.Stock_Text.Text
        local stockCount = tonumber(stockText:match("%d+"))

        if ignoreNoStock then
            if stockCount <= 0 then continue end
            newList[item.Name] = stockCount
            continue
        end

        seedStock[item.Name] = stockCount
    end

    return ignoreNoStock and newList or seedStock
end

  -- Function to buy a specific seed
local function buySeed(seedName)
    GameEvents.BuySeedStock:FireServer(seedName)
end

  -- Create dropdown for seed selection
local seedOptions = {}
local seedDropdown = SeedShopSection:Dropdown("Select Seed", seedOptions, "", function(selected)
    selectedSeed = selected
end)

  -- Function to update the seed dropdown options
local function updateSeedDropdown()
    getSeedStock(false) -- Get all seeds, including out-of-stock
    
    -- Update the dropdown options
    local options = {}
    for seedName, stock in pairs(seedStock) do
        table.insert(options, seedName .. " (" .. stock .. ")")
    end
    
    seedDropdown:Refresh(options)
end

  -- Toggle for auto-buy all stocked seeds
SeedShopSection:Toggle("Auto Buy All Stocked Seeds", function(state)
    autoBuyAllEnabled = state
    if state then
        autoBuySelectedEnabled = false
        Window:Notify("Auto Buy All enabled", 2)
    else
        Window:Notify("Auto Buy All disabled", 2)
    end
end)

  -- Toggle for auto-buy selected seed
SeedShopSection:Toggle("Auto Buy Selected Seed", function(state)
    autoBuySelectedEnabled = state
    if state then
        autoBuyAllEnabled = false
        if selectedSeed == "" then
            Window:Notify("Please select a seed first!", 2)
            autoBuySelectedEnabled = false
            return
        end
        Window:Notify("Auto Buy enabled for " .. selectedSeed, 2)
    else
        Window:Notify("Auto Buy disabled", 2)
    end
end)

  -- Auto-buy loop for all stocked seeds
spawn(function()
    while true do
        if autoBuyAllEnabled then
            -- Get all stocked seeds and buy them
            local stockedSeeds = getSeedStock(true)
            
            for seedName, stock in pairs(stockedSeeds) do
                for i = 1, stock do
                    buySeed(seedName)
                    task.wait(0.1) -- Small delay to prevent rate limiting
                end
            end
            
            -- Wait a bit before checking again
            task.wait(5) -- Check every 5 seconds
        else
            task.wait(1)
        end
    end
end)

  -- Auto-buy loop for selected seed
spawn(function()
    while true do
        if autoBuySelectedEnabled and selectedSeed ~= "" then
            -- Check if we have stock for the selected seed
            getSeedStock(false)
            local stock = seedStock[selectedSeed]
            
            if stock and stock > 0 then
                buySeed(selectedSeed)
            end
            
            -- Wait a bit before checking again
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

  -- Status label to show current stock
local stockStatus = SeedShopSection:Label("Stock Status: Not checked")

  -- Function to update stock status (FIXED VERSION)
local function updateStockStatus()
    local success, stockedSeeds = pcall(function()
        return getSeedStock(true)
    end)
    
    if not success then
        stockStatus:SetText("Stock Status: Error checking stock")
        return
    end
    
    local totalStock = 0
    local seedCount = 0
    
    -- Count seeds properly
    for seedName, stock in pairs(stockedSeeds) do
        totalStock = totalStock + stock
        seedCount = seedCount + 1
    end
    
    -- Ensure we're always passing a string
    local statusText = "Stock Status: "
    
    if seedCount > 0 then
        statusText = statusText .. tostring(totalStock) .. " seeds across " .. tostring(seedCount) .. " types"
    else
        statusText = statusText .. "No seeds in stock"
    end
    
    stockStatus:SetText(statusText)
end

  -- Auto-update stock status periodically
spawn(function()
    while true do
        updateStockStatus()
        task.wait(10) -- Update every 10 seconds
    end
end)

  -- Initial update of seed list and stock status
updateSeedDropdown()
updateStockStatus()

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
