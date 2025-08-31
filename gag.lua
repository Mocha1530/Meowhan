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
local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/pwd0kernel/0verflow/refs/heads/main/ui2.lua'))()
local Window = UILib:CreateWindow("   Grow A Garden - Meowhan")
local config = loadConfig()
local currentJobId = game.JobId

local MainTab = Window:Tab("Main")
local SettingsTab = Window:Tab("Settings")
local InfoTab = Window:Tab("Information")

-- Main Tab
local MainSection = MainTab:Section("Rejoin Configuration")

-- Job ID input with current job as placeholder
local jobIdInput = MainSection:Label("Current Job ID: " .. currentJobId)

-- Job ID text box
local jobIdText = ""
local jobIdButton = MainSection:Button("Set Job ID (Leave blank for current)", function()
    jobIdText = game:GetService("CoreGui"):FindFirstChild("JobIdInput") and "" or jobIdText
    -- Implementation for job ID input would go here
end)

-- Delay slider
local delayValue = config.InitialDelay or 5
local delaySlider = MainSection:Slider("Rejoin Delay (seconds)", 0, 60, delayValue, function(value)
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
            print("Congrats, you've been eviscerated!")
            return
        end

        if not success then
            warn("Evisceration call failed:", err)
        elseif teleportError ~= "" then
            warn("Evisceration failed:", teleportError)
        else
            warn("Evisceration failed for unknown reason")
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
MainSection:Button("Start Rejoin Process", function()
    -- Update and save config
    local newConfig = {
        InitialDelay = delayValue,
        JobId = jobIdText
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
    Window:Notify("Rejoin process started!", 3)
end)

-- Info Tab
local AboutSection = InfoTab:Section("About Meowhan")

AboutSection:Label("Meowhan Rejoin System")
AboutSection:Label("Version: 1.2.0")

local StatsSection = InfoTab:Section("Session Statistics")

StatsSection:Label("Current Job ID: " .. game.JobId)
StatsSection:Label("Player: " .. game.Players.LocalPlayer.Name)
StatsSection:Label("Place: " .. game.PlaceId)

StatsSection:Button("Copy Job ID", function()
    setclipboard(game.JobId)
    Window:Notify("Job ID copied to clipboard!", 2)
end)
