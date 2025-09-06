local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
local GameName = GameInfo.Name
local LocalPlayer = Players.LocalPlayer
local PlayerGui = Players.LocalPlayer.PlayerGui
local placeId = game.PlaceId
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
end)

local MachineMutations = {
    "Ascended", "Frozen", "Golden", "Inverted", "IronSkin", "Mega", "Radiant", "Rainbow", "Shiny", "Shocked", "Tiny", "Windy"
}

-- Create UI
local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Mocha1530/Meowhan/main/UI%20Library.lua'))()
local Window = UILib:CreateWindow("  " .. GameName)
local currentJobId = game.JobId

local MainTab = Window:Tab("Main")
local SettingsTab = Window:Tab("Settings")
local InfoTab = Window:Tab("Info")

-- Initialize

-- Main Tab
local MutationMachineSection = MainTab:Section("Mutation Machine")

-- Mutation Machine Vars
local autoClaimPetEnabled = false
local selectedPetToMutate = ""
local selectedPetMutations = {}

local function toggleAutoClaimPet(state)
    autoClaimPetEnabled = state
    
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
    end
end)

  -- Select mutation
MutationMachineSection:Dropdown("Select Mutation: ", MachineMutations, selectedPetMutations, function(selected)
    if selected then
        selectedPetMutations = selected
    end
end, true)

  -- Auto claim toggle
local autoClaimPet = MutationMachineSection:Toggle("Auto Claim Pet", function(state)
    toggleAutoClaimPet(state)
end, {
    default = autoClaimPetEnabled
})

-- Settings Tab
local LocalPlayerSection = SettingsTab:Section("Player")
local RejoinSection = SettingsTab:Section("Rejoin Config")

-- Settings Vars
local Humanoid = Character:WaitForChild("Humanoid")
local walkSpeedValue = 20
local jumpPowerValue = 50
local infiniteJumpEnabled = false
local noclipEnabled = false
local NoClipping = nil

-- Set walkspeed slider
local function setWalkSpeed(speed)
    Humanoid.WalkSpeed = speed
end

LocalPlayerSection:Slider("Walkspeed", 20, 1000, walkSpeedValue, function(value)
    walkSpeedValue = value

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

if noclipEnabled then
    NoClipping = RunService.Stepped:Connect(noClipLoop)
    UILib:TrackProcess("connections", NoClipping, "NoClipping")
end

-- Job ID input with current job as placeholder
local jobIdInput = RejoinSection:Label("Current Job ID: " .. currentJobId)

  -- Delay slider
local delayValue = 5
local delaySlider = RejoinSection:Slider("Rejoin Delay", 0, 60, delayValue, function(value)
    delayValue = value
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
    -- Determine job ID to use
    local targetJobId = currentJobId
    
    -- Start teleport process
    local success, err = pcall(function()
        persistentTeleport(targetJobId, delayValue)
    end)
    
    if not success then
        warn("CRITICAL ERROR:", err)
        print("Restarting rejoin process...")
        task.wait(5)
        pcall(function()
            persistentTeleport(targetJobId, delayValue)
        end)
    end
end)

-- Info Tab
local AboutSection = InfoTab:Section("About Meowhan")
local StatsSection = InfoTab:Section("Session Statistics")

-- About
AboutSection:Label("Meowhan Global")
AboutSection:Label("Version: 1")

-- Stats
StatsSection:Label("Current Game: " .. GameName)
StatsSection:Label("Player: " .. LocalPlayer.Name)
StatsSection:Label("Current Job ID: " .. game.JobId)
StatsSection:Label("Current Place ID: " .. game.PlaceId)

StatsSection:Button("Copy Job ID", function()
    setclipboard(game.JobId)
    Window:Notify("Job ID copied to clipboard!", 2)
end)