-- Config
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local placeId = game.PlaceId

local configFilename = "Eviscerator_Config.json"
local DEFAULT_CONFIG = {
    InitialDelay = 30,
    JobId = ""
}

-- Load configuration
local function loadConfig()
    if not pcall(function() readfile(configFilename) end) then
        return DEFAULT_CONFIG
    end
    
    local success, config = pcall(function()
        return HttpService:JSONDecode(readfile(configFilename))
    end)
    
    return success and config or DEFAULT_CONFIG
end

-- Save configuration
local function saveConfig(config)
    local success, err = pcall(function()
        writefile(configFilename, HttpService:JSONEncode(config))
    end)
    if not success then
        warn("Failed to save config:", err)
    end
end

-- Create UI
local config = loadConfig()
local currentJobId = game.JobId

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EvisceratorConfig"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "Eviscerator Configuration"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = Frame

local JobIdBox = Instance.new("TextBox")
JobIdBox.PlaceholderText = "Job ID (leave blank for current)"
JobIdBox.Text = config.JobId
JobIdBox.Size = UDim2.new(0.9, 0, 0, 30)
JobIdBox.Position = UDim2.new(0.05, 0, 0.2, 0)
JobIdBox.Parent = Frame

local DelayBox = Instance.new("TextBox")
DelayBox.PlaceholderText = "Rejoin Delay (seconds)"
DelayBox.Text = tostring(config.InitialDelay)
DelayBox.Size = UDim2.new(0.9, 0, 0, 30)
DelayBox.Position = UDim2.new(0.05, 0, 0.4, 0)
DelayBox.Parent = Frame

local StartButton = Instance.new("TextButton")
StartButton.Text = "Rejoin"
StartButton.Size = UDim2.new(0.9, 0, 0, 40)
StartButton.Position = UDim2.new(0.05, 0, 0.7, 0)
StartButton.Parent = Frame

-- Countdown function
local function countdown(seconds)
    for i = seconds, 1, -1 do
        print("Eviscerating in " .. i .. " seconds...")
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

-- Start button handler
StartButton.MouseButton1Click:Connect(function()
    -- Update and save config
    local newConfig = {
        InitialDelay = tonumber(DelayBox.Text) or DEFAULT_CONFIG.InitialDelay,
        JobId = JobIdBox.Text
    }
    saveConfig(newConfig)
    
    -- Determine job ID to use
    local targetJobId = #newConfig.JobId > 0 and newConfig.JobId or currentJobId
    
    -- Remove UI
    ScreenGui:Destroy()
    
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
