local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local placeId = game.PlaceId

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
MainSection:Button("Rejoin", function()
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
    if glimmerGui then
        glimmerGui:Destroy()
    end
    
    local player = game.Players.LocalPlayer
    local rs = game:GetService('ReplicatedStorage')
    
    glimmerGui = Instance.new('ScreenGui', player:WaitForChild('PlayerGui'))
    glimmerGui.Name = 'GlimmerCounter'
    glimmerGui.ResetOnSpawn = false
    glimmerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new('Frame', glimmerGui)
    frame.Size = UDim2.new(0, 380, 0, 70)
    frame.Position = UDim2.new(1, -400, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(150, 50, 200)
    
    local header = Instance.new('TextLabel', frame)
    header.Size = UDim2.new(1, -20, 0, 28)
    header.Position = UDim2.new(0, 10, 0, 5)
    header.BackgroundTransparency = 1
    header.Text = 'Glimmering Fruits'
    header.TextColor3 = Color3.fromRGB(180, 100, 255)
    header.TextSize = 20
    header.Font = Enum.Font.Code
    header.TextXAlignment = Enum.TextXAlignment.Left
    
    local counter = Instance.new('TextLabel', frame)
    counter.Size = UDim2.new(1, -20, 0, 35)
    counter.Position = UDim2.new(0, 10, 0, 28)
    counter.BackgroundTransparency = 1
    counter.Text = 'Count: 0'
    counter.TextColor3 = Color3.fromRGB(230, 230, 230)
    counter.TextSize = 16
    counter.Font = Enum.Font.Code
    counter.TextXAlignment = Enum.TextXAlignment.Left
    
    glimmerCount = 0
    
    local notificationEvent = rs:WaitForChild('GameEvents'):WaitForChild('Notification')
    notificationEvent.OnClientEvent:Connect(function(msg)
        if typeof(msg) == 'string' and msg == 'A Fruit in your garden, mutated to Glimmering!' then
            glimmerCount = glimmerCount + 1
            counter.Text = 'Count: ' .. glimmerCount
        end
    end)
end

local function toggleGlimmerCounter(state)
    glimmerCounterEnabled = state
    config.ShowGlimmerCounter = state
    saveConfig(config)
    
    if state then
        createGlimmerCounter()
        Window:Notify("Glimmer Counter Enabled", 2)
    else
        if glimmerGui then
            glimmerGui:Destroy()
            glimmerGui = nil
        end
        Window:Notify("Glimmer Counter Disabled", 2)
    end
end

-- Add toggle for Glimmering Counter
EventSection:Toggle("Enable Glimmering Counter", glimmerCounterEnabled, function(state)
    toggleGlimmerCounter(state)
end)

-- Initialize glimmer counter if enabled
if glimmerCounterEnabled then
    createGlimmerCounter()
end

-- Info Tab
local AboutSection = InfoTab:Section("About Meowhan")

AboutSection:Label("Meowhan Grow A Garden Exploit")
AboutSection:Label("Version: 1.2.5")

local StatsSection = InfoTab:Section("Session Statistics")

StatsSection:Label("Player: " .. game.Players.LocalPlayer.Name)
StatsSection:Label("Current Job ID: " .. game.JobId)
StatsSection:Label("Current Place ID: " .. game.PlaceId)

StatsSection:Button("Copy Job ID", function()
    setclipboard(game.JobId)
    Window:Notify("Job ID copied to clipboard!", 2)
end)
