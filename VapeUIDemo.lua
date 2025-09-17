local VapeUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mocha1530/Meowhan/refs/heads/testing/UI/Vape%20Library.lua"))()

-- Create the main window
local Window = VapeUI:CreateWindow()

-- Create legacy free-floating modules
local CombatModule = Window:CreateModule({
    Name = "Combat",
    Icon = "⚔️",
    PosX = 100,
    PosY = 100
})

CombatModule:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(state) 
        print("Kill Aura:", state)
        if state then
            Window:Notify("Kill Aura enabled", 2)
        end
    end,
    Keybind = Enum.KeyCode.F
})

CombatModule:AddSlider({
    Name = "Reach Distance",
    Min = 0,
    Max = 50,
    Default = 20,
    Callback = function(value)
        print("Reach Distance:", value)
    end
})

CombatModule:AddDropdown({
    Name = "Target Mode",
    Options = {"Players", "NPCs", "Both"},
    Default = "Players",
    Callback = function(option)
        print("Target Mode:", option)
    end
})

local MovementModule = Window:CreateModule({
    Name = "Movement",
    Icon = "🏃",
    PosX = 320,
    PosY = 100
})

MovementModule:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(state)
        print("Speed Hack:", state)
    end
})

MovementModule:AddSlider({
    Name = "Speed Multiplier",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(value)
        print("Speed Multiplier:", value)
    end
})

MovementModule:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(state)
        print("Infinite Jump:", state)
        if state then
            Window:Notify("Infinite Jump enabled - Press Space to fly!", 3)
        end
    end
})

-- Create Vape-style ClickGUI with tabs
local CombatTab = Window:CreateTab({
    Name = "Combat",
    Icon = "⚔️"
})

local CombatTabModule = CombatTab:AddModule({
    Name = "Weapons",
    Icon = "🔫"
})

CombatTabModule:AddToggle({
    Name = "Auto Reload",
    Default = true,
    Callback = function(state)
        print("Auto Reload:", state)
    end
})

CombatTabModule:AddSlider({
    Name = "Fire Rate",
    Min = 0.1,
    Max = 2.0,
    Default = 1.0,
    Callback = function(value)
        print("Fire Rate:", value)
    end
})

CombatTabModule:AddDropdown({
    Name = "Weapon Preference",
    Options = {"Rifle", "Shotgun", "Sniper", "Pistol"},
    Default = "Rifle",
    Callback = function(option)
        print("Weapon Preference:", option)
    end
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "👁️"
})

local ESPModule = VisualsTab:AddModule({
    Name = "ESP",
    Icon = "🎯"
})

ESPModule:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(state)
        print("Player ESP:", state)
        if state then
            Window:Notify("Player ESP enabled", 2)
        end
    end
})

ESPModule:AddToggle({
    Name = "Item ESP",
    Default = false,
    Callback = function(state)
        print("Item ESP:", state)
    end
})

ESPModule:AddDropdown({
    Name = "ESP Style",
    Options = {"Box", "Tracer", "Skeleton", "Name Only"},
    Default = "Box",
    Callback = function(option)
        print("ESP Style:", option)
    end
})

local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "⚙️"
})

local SettingsModule = MiscTab:AddModule({
    Name = "Settings",
    Icon = "🔧"
})

SettingsModule:AddToggle({
    Name = "Auto Update",
    Default = true,
    Callback = function(state)
        print("Auto Update:", state)
    end
})

SettingsModule:AddSlider({
    Name = "UI Scale",
    Min = 80,
    Max = 120,
    Default = 100,
    Callback = function(value)
        print("UI Scale:", value)
    end
})

SettingsModule:AddDropdown({
    Name = "Theme",
    Options = {"Dark Purple", "Blue", "Red", "Green"},
    Default = "Dark Purple",
    Callback = function(option)
        print("Theme:", option)
        Window:Notify("Theme changed to " .. option, 2)
    end
})

-- Add some notifications to demonstrate the notification system
task.spawn(function()
    task.wait(2)
    Window:Notify("Welcome to 0verflow Hub V3!", 3)
    
    task.wait(4)
    Window:Notify("Press RightShift to toggle UI", 3)
    
    task.wait(6)
    Window:Notify("Config loaded successfully", 2)
end)

-- Example of arraylist functionality (toggles will automatically appear in arraylist when enabled)
task.spawn(function()
    while true do
        task.wait(5)
        -- This is just to show the arraylist functionality
        -- In a real scenario, you'd enable/disable toggles through user interaction
    end
end)
