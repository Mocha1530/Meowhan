local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEventsFolder = ReplicatedStorage:WaitForChild("GameEvents")

if not GameEventsFolder then
    warn("GameEvents folder not found!")
    return
end

-- Monitor all existing events in the folder
for _, event in ipairs(GameEventsFolder:GetChildren()) do
    if event:IsA("RemoteEvent") then
        -- Hook FireServer
        local oldFire = event.FireServer
        event.FireServer = function(...)
            print(`[FireServer] {event.Name} fired with:`, ...)
            return oldFire(event, ...)
        end
        -- Listen for server messages
        event.OnClientEvent:Connect(function(...)
            print(`[OnClientEvent] {event.Name} received:`, ...)
        end)
    end
end

-- Monitor for new events added dynamically
GameEventsFolder.ChildAdded:Connect(function(child)
    if child:IsA("RemoteEvent") then
        local oldFire = child.FireServer
        child.FireServer = function(...)
            print(`[FireServer] {child.Name} fired with:`, ...)
            return oldFire(child, ...)
        end
        child.OnClientEvent:Connect(function(...)
            print(`[OnClientEvent] {child.Name} received:`, ...)
        end)
    end
end)

print("Monitoring all events in GameEvents folder...")
