local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mocha1530/Meowhan/refs/heads/testing/UI/Test%20Dropdown.lua"))()

-- Create main window
local Window = UILib:CreateWindow("Demo UI")

-- Tab 1: Toggles
local Tab1 = Window:Tab("Toggles")

local Section1 = Tab1:Section("Basic Toggles")
Section1:Toggle("Enable Godmode", function(state) print("Godmode:", state) end)
Section1:Toggle("Infinite Jump", function(state) print("Infinite Jump:", state) end, {default = true})
Section1:Toggle("Speed Hack", function(state) print("Speed Hack:", state) end, {color = Color3.fromRGB(255, 170, 0)})

local Section2 = Tab1:Section("Advanced Toggles")
Section2:Toggle("Toggle with Keybind", function(state) 
    print("Keybind Toggle:", state) 
  end, { 
    keybind = Enum.KeyCode.RightControl,
    tooltip = "Press Right Control to toggle this feature"
})

Section2:Toggle("Toggle with Icon", function(state) 
    print("Icon Toggle:", state) 
  end, {
    icon = "★",
    color = Color3.fromRGB(255, 105, 180)
})

local Section3 = Tab1:Section("ToggleGroup")
Section3:ToggleGroup("Weapon Selection", {
{name = "Sword", default = true},
{name = "Gun"},
{name = "Bow"}
}, function(name, state) print("Selected:", name, state) end)

-- Tab 2: Buttons & Sliders
local Tab2 = Window:Tab("Controls")

local Section3 = Tab2:Section("Buttons")
Section3:Button("Teleport to Base", function() print("Teleporting...") end)
Section3:Button("Collect Resources", function() print("Collecting...") end)
Section3:Button("Reset Character", function() print("Resetting...") end)

local Section4 = Tab2:Section("Sliders")
Section4:Slider("WalkSpeed", 16, 200, 50, function(value) print("WalkSpeed:", value) end)
Section4:Slider("JumpPower", 50, 200, 100, function(value) print("JumpPower:", value) end)
Section4:Slider({
name = "Field of View",
min = 70,
max = 120,
default = 90,
step = 5,
callback = function(value) print("FOV:", value) end
})

-- Tab 3: Inputs & Dropdowns
local Tab3 = Window:Tab("Inputs")

local Section5 = Tab3:Section("Text Inputs")
Section5:TextBox("Player Name", "Enter username...", "", function(text) print("Username:", text) end)
Section5:TextBox("Message", "Type message here...", "Hello!", function(text) print("Message:", text) end, true)

local Section6 = Tab3:Section("Dropdowns")
Section6:Dropdown("Single Select", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selected) print("Selected:", selected) end)
Section6:Dropdown("Multi Select", {"Red", "Green", "Blue"}, {"Red"}, function(selected) print("Selected:", table.concat(selected, ", ")) end, true, 2)

-- Tab 4: Info & Notifications
local Tab4 = Window:Tab("Info")

local Section7 = Tab4:Section("Information")
Section7:Label("Welcome to the Meowhan UI Demo!")
Section7:Label("This showcases all available UI elements")
Section7:Label("Hover over elements to see tooltips")

local Section8 = Tab4:Section("Actions")
Section8:Button("Show Success", function() Window:Notify("Operation completed successfully!", 3) end)
Section8:Button("Show Warning", function() Window:Notify("Warning: Low health!", 3) end)
Section8:Button("Show Error", function() Window:Notify("Error: Connection failed", 3) end)

-- Show a welcome notification
Window:Notify("UI Library loaded successfully!")
