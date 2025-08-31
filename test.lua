local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for the GameEvents folder with a timeout
local GameEventsFolder
local success, err = pcall(function()
    GameEventsFolder = ReplicatedStorage:WaitForChild("GameEvents", 10) -- 10 second timeout
end)

if not success or not GameEventsFolder then
    warn("GameEvents folder not found or inaccessible:", err)
    return
end

-- Function to safely hook a RemoteEvent
local function hookRemoteEvent(event)
    if not event:IsA("RemoteEvent") then
        return
    end
    
    -- Hook FireServer with error protection
    local oldFire = event.FireServer
    event.FireServer = function(...)
        local args = {...}
        local success, result = pcall(function()
            print(`[FireServer] {event.Name} fired with:`, unpack(args))
        end)
        
        if not success then
            warn(`Error logging FireServer for {event.Name}:`, result)
        end
        
        -- Always call the original function
        return oldFire(event, unpack(args))
    end
    
    -- Listen for server messages with error protection
    event.OnClientEvent:Connect(function(...)
        local args = {...}
        local success, result = pcall(function()
            print(`[OnClientEvent] {event.Name} received:`, unpack(args))
        end)
        
        if not success then
            warn(`Error in OnClientEvent handler for {event.Name}:`, result)
        end
    end)
end

-- Monitor all existing events in the folder with error protection
for _, event in ipairs(GameEventsFolder:GetChildren()) do
    local success, result = pcall(hookRemoteEvent, event)
    if not success then
        warn(`Failed to hook event {event.Name}:`, result)
    end
end

-- Monitor for new events added dynamically with error protection
GameEventsFolder.ChildAdded:Connect(function(child)
    local success, result = pcall(function()
        if child:IsA("RemoteEvent") then
            hookRemoteEvent(child)
        end
    end)
    
    if not success then
        warn(`Failed to handle new child {child.Name}:`, result)
    end
end)

print("Monitoring all events in GameEvents folder with error protection...")
