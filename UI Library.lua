local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- Minimal Color Palette
local Theme = {
    Background = Color3.fromRGB(15, 15, 17),
    Surface = Color3.fromRGB(20, 20, 23),
    Card = Color3.fromRGB(25, 25, 28),
    
    Accent = Color3.fromRGB(120, 80, 255),
    AccentHover = Color3.fromRGB(140, 100, 255),
    AccentDim = Color3.fromRGB(80, 50, 180),
    
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 160, 165),
    TextDark = Color3.fromRGB(100, 100, 105),
    
    Success = Color3.fromRGB(80, 250, 150),
    Warning = Color3.fromRGB(255, 200, 100),
    Error = Color3.fromRGB(255, 100, 100),
    
    Transparent = Color3.fromRGB(0, 0, 0)
}

-- Detect if mobile
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "0verflowMinimal"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

-- Utility Functions
local function Tween(obj, props, duration, easingStyle)
    duration = duration or 0.2
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

-- Main Library
local Library = {}
Library.Windows = {}

-- Global toggle management system
local ToggleManager = {
    toggles = {},
    groups = {},
    keybinds = {}
}

-- Enhanced Toggle Class
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(config)
    local self = setmetatable({}, Toggle)
    
    -- Parse config with defaults
    self.name = config.name or "Toggle"
    self.default = config.default or false
    self.callback = config.callback
    self.color = config.color or Theme.Accent
    self.group = config.group
    self.keybind = config.keybind
    self.tooltip = config.tooltip
    self.icon = config.icon
    self.state = self.default
    
    -- Create UI elements
    self:CreateUI(config.parent)
    
    -- Register with manager
    ToggleManager.toggles[self.name] = self
    
    -- Handle group exclusivity
    if self.group then
        if not ToggleManager.groups[self.group] then
            ToggleManager.groups[self.group] = {}
        end
        table.insert(ToggleManager.groups[self.group], self)
    end
    
    -- Setup keybind
    if self.keybind then
        self:SetKeybind(self.keybind)
    end
    
    -- Initialize state
    if self.default then
        self:Set(true, true)
    end
    
    return self
end

function Toggle:CreateUI(parent)
    -- Main frame
    self.frame = Instance.new("Frame")
    self.frame.Parent = parent
    self.frame.BackgroundTransparency = 1
    self.frame.Size = UDim2.new(1, 0, 0, IsMobile and 36 or 32)
    
    -- Interactive button (covers entire toggle area)
    self.button = Instance.new("TextButton")
    self.button.Parent = self.frame
    self.button.BackgroundColor3 = Theme.Card
    self.button.BackgroundTransparency = 0.5
    self.button.Size = UDim2.new(1, 0, 1, 0)
    self.button.Text = ""
    self.button.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = self.button
    
    -- Icon (optional)
    if self.icon then
        self.iconLabel = Instance.new("TextLabel")
        self.iconLabel.Parent = self.frame
        self.iconLabel.BackgroundTransparency = 1
        self.iconLabel.Position = UDim2.new(0, 8, 0.5, -8)
        self.iconLabel.Size = UDim2.new(0, 16, 0, 16)
        self.iconLabel.Font = Enum.Font.Gotham
        self.iconLabel.Text = self.icon
        self.iconLabel.TextColor3 = Theme.TextDim
        self.iconLabel.TextSize = 14
    end
    
    -- Label
    self.label = Instance.new("TextLabel")
    self.label.Parent = self.frame
    self.label.BackgroundTransparency = 1
    self.label.Position = UDim2.new(0, self.icon and 32 or 12, 0, 0)
    self.label.Size = UDim2.new(1, -56, 1, 0)
    self.label.Font = Enum.Font.Gotham
    self.label.Text = self.name
    self.label.TextColor3 = Theme.Text
    self.label.TextSize = IsMobile and 12 or 13
    self.label.TextXAlignment = Enum.TextXAlignment.Left
    self.label.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Switch
    self.switch = Instance.new("Frame")
    self.switch.Parent = self.frame
    self.switch.BackgroundColor3 = Theme.Card
    self.switch.Position = UDim2.new(1, -44, 0.5, -10)
    self.switch.Size = UDim2.new(0, 36, 0, 20)
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = self.switch
    
    -- Switch knob
    self.knob = Instance.new("Frame")
    self.knob.Parent = self.switch
    self.knob.BackgroundColor3 = Theme.TextDim
    self.knob.Position = UDim2.new(0, 2, 0.5, -8)
    self.knob.Size = UDim2.new(0, 16, 0, 16)
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = self.knob
    
    -- Keybind indicator (if applicable)
    if self.keybind then
        self.keybindLabel = Instance.new("TextLabel")
        self.keybindLabel.Parent = self.frame
        self.keybindLabel.BackgroundTransparency = 1
        self.keybindLabel.Position = UDim2.new(1, -90, 0.5, -8)
        self.keybindLabel.Size = UDim2.new(0, 40, 0, 16)
        self.keybindLabel.Font = Enum.Font.Gotham
        self.keybindLabel.Text = "[" .. self.keybind.Name .. "]"
        self.keybindLabel.TextColor3 = Theme.TextDark
        self.keybindLabel.TextSize = 10
        self.keybindLabel.TextXAlignment = Enum.TextXAlignment.Right
    end
    
    -- Tooltip (if provided)
    if self.tooltip then
        local tooltip = Instance.new("Frame")
        tooltip.Parent = ScreenGui
        tooltip.BackgroundColor3 = Theme.Surface
        tooltip.BorderSizePixel = 0
        tooltip.Size = UDim2.new(0, 200, 0, 30)
        tooltip.Visible = false
        tooltip.ZIndex = 1000
        
        local tooltipCorner = Instance.new("UICorner")
        tooltipCorner.CornerRadius = UDim.new(0, 6)
        tooltipCorner.Parent = tooltip
        
        local tooltipText = Instance.new("TextLabel")
        tooltipText.Parent = tooltip
        tooltipText.BackgroundTransparency = 1
        tooltipText.Size = UDim2.new(1, -10, 1, 0)
        tooltipText.Position = UDim2.new(0, 5, 0, 0)
        tooltipText.Font = Enum.Font.Gotham
        tooltipText.Text = self.tooltip
        tooltipText.TextColor3 = Theme.TextDim
        tooltipText.TextSize = 11
        tooltipText.TextXAlignment = Enum.TextXAlignment.Left
        
        self.button.MouseEnter:Connect(function()
            local mouse = Player:GetMouse()
            tooltip.Position = UDim2.new(0, mouse.X + 10, 0, mouse.Y - 35)
            tooltip.Visible = true
        end)
        
        self.button.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)
    end
    
    -- Interaction events
    self.button.MouseEnter:Connect(function()
        if not self.state then
            Tween(self.button, {BackgroundTransparency = 0.3})
        end
    end)
    
    self.button.MouseLeave:Connect(function()
        if not self.state then
            Tween(self.button, {BackgroundTransparency = 0.5})
        end
    end)
    
    self.button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
end

function Toggle:Set(value, silent)
    self.state = value
    
    -- Handle group exclusivity
    if value and self.group then
        for _, toggle in ipairs(ToggleManager.groups[self.group]) do
            if toggle ~= self and toggle.state then
                toggle:Set(false, true)
            end
        end
    end
    
    -- Update visual state
    if self.state then
        Tween(self.switch, {BackgroundColor3 = self.color})
        Tween(self.knob, {
            Position = UDim2.new(1, -18, 0.5, -8),
            BackgroundColor3 = Theme.Text
        })
        Tween(self.button, {BackgroundTransparency = 0.7})
        if self.iconLabel then
            Tween(self.iconLabel, {TextColor3 = self.color})
        end
    else
        Tween(self.switch, {BackgroundColor3 = Theme.Card})
        Tween(self.knob, {
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Theme.TextDim
        })
        Tween(self.button, {BackgroundTransparency = 0.5})
        if self.iconLabel then
            Tween(self.iconLabel, {TextColor3 = Theme.TextDim})
        end
    end
    
    -- Fire callback
    if not silent and self.callback then
        self.callback(self.state)
    end
end

function Toggle:Toggle()
    self:Set(not self.state)
end

function Toggle:Get()
    return self.state
end

function Toggle:SetKeybind(key)
    self.keybind = key
    ToggleManager.keybinds[key] = self
    
    if self.keybindLabel then
        self.keybindLabel.Text = "[" .. key.Name .. "]"
    end
end

function Toggle:Destroy()
    -- Remove from manager
    ToggleManager.toggles[self.name] = nil
    
    -- Remove from group
    if self.group and ToggleManager.groups[self.group] then
        local index = table.find(ToggleManager.groups[self.group], self)
        if index then
            table.remove(ToggleManager.groups[self.group], index)
        end
    end
    
    -- Remove keybind
    if self.keybind then
        ToggleManager.keybinds[self.keybind] = nil
    end
    
    -- Destroy UI
    self.frame:Destroy()
end

-- Global keybind handler
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then
        local toggle = ToggleManager.keybinds[input.KeyCode]
        if toggle then
            toggle:Toggle()
        end
    end
end)

-- Enhanced Section Toggle API
function Library:CreateWindow(title)
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Minimized = false
    
    -- Calculate responsive sizes
    local screenSize = workspace.CurrentCamera.ViewportSize
    local windowWidth = IsMobile and math.min(screenSize.X - 40, 500) or 560
    local windowHeight = IsMobile and math.min(screenSize.Y - 100, 420) or 480
    
    -- Minimal Floating Bar
    local ToggleBar = Instance.new("Frame")
    ToggleBar.Name = "ToggleBar"
    ToggleBar.Parent = ScreenGui
    ToggleBar.BackgroundColor3 = Theme.Background
    ToggleBar.BackgroundTransparency = 0.1
    ToggleBar.BorderSizePixel = 0
    ToggleBar.Position = UDim2.new(0.5, -60, 1, -50)
    ToggleBar.Size = UDim2.new(0, 120, 0, 32)
    ToggleBar.Visible = false
    ToggleBar.ZIndex = 999
    ToggleBar.ClipsDescendants = true
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 16)
    BarCorner.Parent = ToggleBar
    
    local BarStroke = Instance.new("UIStroke")
    BarStroke.Parent = ToggleBar
    BarStroke.Color = Theme.Accent
    BarStroke.Thickness = 1
    BarStroke.Transparency = 0.7
    
    local TextContainer = Instance.new("Frame")
    TextContainer.Parent = ToggleBar
    TextContainer.BackgroundTransparency = 1
    TextContainer.Size = UDim2.new(1, 0, 1, 0)
    TextContainer.Position = UDim2.new(0, 0, 0, 0)
    
    local Text0verflow = Instance.new("TextLabel")
    Text0verflow.Parent = TextContainer
    Text0verflow.BackgroundTransparency = 1
    Text0verflow.Position = UDim2.new(0.5, -30, 0.5, -8)
    Text0verflow.Size = UDim2.new(0, 50, 0, 16)
    Text0verflow.Font = Enum.Font.GothamBold
    Text0verflow.Text = "Meowhan"
    Text0verflow.TextColor3 = Theme.Accent
    Text0verflow.TextSize = 13
    Text0verflow.TextXAlignment = Enum.TextXAlignment.Right
    Text0verflow.ZIndex = 1000
    
    local TextHub = Instance.new("TextLabel")
    TextHub.Parent = TextContainer
    TextHub.BackgroundTransparency = 1
    TextHub.Position = UDim2.new(0.5, 22, 0.5, -8)
    TextHub.Size = UDim2.new(0, 25, 0, 16)
    TextHub.Font = Enum.Font.Gotham
    TextHub.Text = "Hub"
    TextHub.TextColor3 = Theme.Text
    TextHub.TextSize = 13
    TextHub.TextXAlignment = Enum.TextXAlignment.Left
    TextHub.ZIndex = 1000
    
    local Indicator = Instance.new("Frame")
    Indicator.Parent = ToggleBar
    Indicator.BackgroundColor3 = Theme.Success
    Indicator.BorderSizePixel = 0
    Indicator.Position = UDim2.new(0, 10, 0.5, -3)
    Indicator.Size = UDim2.new(0, 6, 0, 6)
    Indicator.ZIndex = 1000
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator
    
    spawn(function()
        while ToggleBar.Parent do
            if ToggleBar.Visible then
                Tween(Indicator, {BackgroundTransparency = 0.3}, 1)
                wait(1)
                Tween(Indicator, {BackgroundTransparency = 0}, 1)
                wait(1)
            else
                wait(0.5)
            end
        end
    end)
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ToggleBar
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.Text = ""
    ToggleBtn.ZIndex = 1001
    
    ToggleBtn.MouseEnter:Connect(function()
        Tween(ToggleBar, {BackgroundTransparency = 0})
        Tween(BarStroke, {Transparency = 0.3})
        Tween(Text0verflow, {TextColor3 = Theme.AccentHover})
    end)
    
    ToggleBtn.MouseLeave:Connect(function()
        Tween(ToggleBar, {BackgroundTransparency = 0.1})
        Tween(BarStroke, {Transparency = 0.7})
        Tween(Text0verflow, {TextColor3 = Theme.Accent})
    end)
    
    -- Main Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = ScreenGui
    Container.BackgroundColor3 = Theme.Background
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    Container.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    Container.ClipsDescendants = true
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 10)
    ContainerCorner.Parent = Container
    
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = Container
    Header.BackgroundTransparency = 1
    Header.BorderSizePixel = 0
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.ZIndex = 2
    
    local HeaderSeparator = Instance.new("Frame")
    HeaderSeparator.Parent = Container
    HeaderSeparator.BackgroundColor3 = Theme.Accent
    HeaderSeparator.BackgroundTransparency = 0.8
    HeaderSeparator.BorderSizePixel = 0
    HeaderSeparator.Position = UDim2.new(0, 0, 0, 40)
    HeaderSeparator.Size = UDim2.new(1, 0, 0, 1)
    HeaderSeparator.ZIndex = 3
    
    local TitleContainer = Instance.new("Frame")
    TitleContainer.Parent = Header
    TitleContainer.BackgroundTransparency = 1
    TitleContainer.Position = UDim2.new(0, 16, 0, 0)
    TitleContainer.Size = UDim2.new(0.5, 0, 1, 0)
    TitleContainer.ZIndex = 3
    
    local Title0verflow = Instance.new("TextLabel")
    Title0verflow.Parent = TitleContainer
    Title0verflow.BackgroundTransparency = 1
    Title0verflow.Position = UDim2.new(0, 0, 0, 0)
    Title0verflow.Size = UDim2.new(0, 0, 1, 0)
    Title0verflow.AutomaticSize = Enum.AutomaticSize.X
    Title0verflow.Font = Enum.Font.GothamBold
    Title0verflow.Text = "Meowhan"
    Title0verflow.TextColor3 = Theme.Accent
    Title0verflow.TextSize = IsMobile and 13 or 14
    Title0verflow.TextXAlignment = Enum.TextXAlignment.Left
    Title0verflow.ZIndex = 3
    
    local TitleHub = Instance.new("TextLabel")
    TitleHub.Parent = TitleContainer
    TitleHub.BackgroundTransparency = 1
    TitleHub.Position = UDim2.new(0, IsMobile and 52 or 58, 0, 0)
    TitleHub.Size = UDim2.new(0, 0, 1, 0)
    TitleHub.AutomaticSize = Enum.AutomaticSize.X
    TitleHub.Font = Enum.Font.Gotham
    TitleHub.Text = " Hub"
    TitleHub.TextColor3 = Theme.Text
    TitleHub.TextSize = IsMobile and 13 or 14
    TitleHub.TextXAlignment = Enum.TextXAlignment.Left
    TitleHub.ZIndex = 3
    
    -- Window title
    if title then
        local WindowTitle = Instance.new("TextLabel")
        WindowTitle.Parent = TitleContainer
        WindowTitle.BackgroundTransparency = 1
        WindowTitle.Position = UDim2.new(0, IsMobile and 90 or 100, 0, 0)
        WindowTitle.Size = UDim2.new(0, 0, 1, 0)
        WindowTitle.AutomaticSize = Enum.AutomaticSize.X
        WindowTitle.Font = Enum.Font.Gotham
        WindowTitle.Text = " - " .. title
        WindowTitle.TextColor3 = Theme.TextDim
        WindowTitle.TextSize = IsMobile and 12 or 13
        WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
        WindowTitle.ZIndex = 3
    end
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Header
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -12)
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.TextDim
    CloseBtn.TextSize = 20
    CloseBtn.ZIndex = 3
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {TextColor3 = Theme.Error})
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {TextColor3 = Theme.TextDim})
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Container, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        Tween(ToggleBar, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = Header
    MinBtn.BackgroundTransparency = 1
    MinBtn.Position = UDim2.new(1, -70, 0.5, -12)
    MinBtn.Size = UDim2.new(0, 24, 0, 24)
    MinBtn.Font = Enum.Font.Gotham
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Theme.TextDim
    MinBtn.TextSize = 16
    MinBtn.ZIndex = 3
    
    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, {TextColor3 = Theme.Text})
    end)
    
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, {TextColor3 = Theme.TextDim})
    end)
    
    local function Minimize()
        Window.Minimized = true
        Tween(Container, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 1, -25)
        }, 0.3)
        
        wait(0.3)
        Container.Visible = false
        ToggleBar.Visible = true
        
        ToggleBar.Position = UDim2.new(0.5, -60, 1, 0)
        Tween(ToggleBar, {
            Position = UDim2.new(0.5, -60, 1, -50)
        }, 0.3, Enum.EasingStyle.Back)
    end
    
    local function Restore()
        Window.Minimized = false
        Tween(ToggleBar, {
            Position = UDim2.new(0.5, -60, 1, 0)
        }, 0.3)
        
        wait(0.3)
        ToggleBar.Visible = false
        Container.Visible = true
        
        Container.Size = UDim2.new(0, 0, 0, 0)
        Container.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        Tween(Container, {
            Size = UDim2.new(0, windowWidth, 0, windowHeight),
            Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
        }, 0.3, Enum.EasingStyle.Back)
    end
    
    MinBtn.MouseButton1Click:Connect(Minimize)
    ToggleBtn.MouseButton1Click:Connect(Restore)
    
    local HeaderAccent = Instance.new("Frame")
    HeaderAccent.Parent = Container
    HeaderAccent.BackgroundColor3 = Theme.Accent
    HeaderAccent.BorderSizePixel = 0
    HeaderAccent.Position = UDim2.new(0, 16, 0, 39)
    HeaderAccent.Size = UDim2.new(0, 30, 0, 1)
    HeaderAccent.BackgroundTransparency = 0.3
    HeaderAccent.ZIndex = 3
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = Container
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 41)
    TabContainer.Size = UDim2.new(1, 0, 0, 36)
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Parent = TabContainer
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.Position = UDim2.new(0, IsMobile and 8 or 16, 0, 0)
    TabList.Size = UDim2.new(1, IsMobile and -16 or -32, 1, 0)
    TabList.ScrollBarThickness = 0
    TabList.ScrollingDirection = Enum.ScrollingDirection.X
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabList
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, IsMobile and 4 or 8)
    
    local Content = Instance.new("Frame")
    Content.Parent = Container
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 0, 0, 77)
    Content.Size = UDim2.new(1, 0, 1, -77)
    
    -- Dragging
    if not IsMobile then
        local dragging, dragStart, startPos
        
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Container.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Container.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    
    -- Tab Function
    function Window:Tab(name)
        local Tab = {}
        Tab.Name = name
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabList
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(0, 0, 1, 0)
        TabBtn.AutomaticSize = Enum.AutomaticSize.X
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Text = name
        TabBtn.TextColor3 = Theme.TextDim
        TabBtn.TextSize = IsMobile and 12 or 13
        
        local TabPadding = Instance.new("UIPadding")
        TabPadding.Parent = TabBtn
        TabPadding.PaddingLeft = UDim.new(0, IsMobile and 8 or 12)
        TabPadding.PaddingRight = UDim.new(0, IsMobile and 8 or 12)
        
        local Underline = Instance.new("Frame")
        Underline.Parent = TabBtn
        Underline.BackgroundColor3 = Theme.Accent
        Underline.BorderSizePixel = 0
        Underline.Position = UDim2.new(0, 0, 1, -2)
        Underline.Size = UDim2.new(1, 0, 0, 2)
        Underline.Visible = false
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Parent = Content
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Position = UDim2.new(0, IsMobile and 8 or 16, 0, 0)
        TabContent.Size = UDim2.new(1, IsMobile and -16 or -32, 1, IsMobile and -8 or -16)
        TabContent.ScrollBarThickness = IsMobile and 3 or 2
        TabContent.ScrollBarImageColor3 = Theme.Accent
        TabContent.ScrollBarImageTransparency = 0.5
        TabContent.Visible = false
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = TabContent
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.TextColor3 = Theme.TextDim
                tab.Underline.Visible = false
                tab.Content.Visible = false
            end
            
            TabBtn.TextColor3 = Theme.Text
            Underline.Visible = true
            TabContent.Visible = true
            Window.ActiveTab = Tab
        end)
        
        -- Section Function with ALL COMPONENTS
        function Tab:Section(title)
            local Section = {}
            Section.toggles = {}
            Section.expanded = true -- Track if section is expanded
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Parent = TabContent
            SectionFrame.BackgroundColor3 = Theme.Surface
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Size = UDim2.new(1, 0, 0, 32) -- Start with just header height
            SectionFrame.ClipsDescendants = true
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 8)
            SectionCorner.Parent = SectionFrame
            
            -- Make the entire header clickable to toggle expansion
            local HeaderButton = Instance.new("TextButton")
            HeaderButton.Parent = SectionFrame
            HeaderButton.BackgroundTransparency = 1
            HeaderButton.Size = UDim2.new(1, 0, 0, 32)
            HeaderButton.Text = ""
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Parent = HeaderButton
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 12, 0, 0)
            SectionTitle.Size = UDim2.new(1, -40, 1, 0)
            SectionTitle.Font = Enum.Font.Gotham
            SectionTitle.Text = title
            SectionTitle.TextColor3 = Theme.TextDim
            SectionTitle.TextSize = IsMobile and 11 or 12
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Dropdown arrow indicator
            local Arrow = Instance.new("TextLabel")
            Arrow.Parent = HeaderButton
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -28, 0.5, -8)
            Arrow.Size = UDim2.new(0, 16, 0, 16)
            Arrow.Font = Enum.Font.Gotham
            Arrow.Text = "▼"
            Arrow.TextColor3 = Theme.TextDim
            Arrow.TextSize = 10
            Arrow.Rotation = 0
            Arrow.Name = "Arrow"
            
            local SectionAccent = Instance.new("Frame")
            SectionAccent.Parent = HeaderButton
            SectionAccent.BackgroundColor3 = Theme.Accent
            SectionAccent.BorderSizePixel = 0
            SectionAccent.Position = UDim2.new(0, 4, 0, 14)
            SectionAccent.Size = UDim2.new(0, 2, 0, 10)
            
            local AccentCorner = Instance.new("UICorner")
            AccentCorner.CornerRadius = UDim.new(1, 0)
            AccentCorner.Parent = SectionAccent
            
            local Elements = Instance.new("Frame")
            Elements.Parent = SectionFrame
            Elements.BackgroundTransparency = 1
            Elements.Position = UDim2.new(0, 12, 0, 32)
            Elements.Size = UDim2.new(1, -24, 0, 0)
            Elements.AutomaticSize = Enum.AutomaticSize.Y
            Elements.Visible = true
            
            local ElementLayout = Instance.new("UIListLayout")
            ElementLayout.Parent = Elements
            ElementLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementLayout.Padding = UDim.new(0, 6)
            
            local ElementPadding = Instance.new("UIPadding")
            ElementPadding.Parent = Elements
            ElementPadding.PaddingBottom = UDim.new(0, 12)
            
            -- Function to calculate content height
            local function calculateContentHeight()
                return ElementLayout.AbsoluteContentSize.Y + 12 -- Add padding
            end
            
            -- Function to toggle section visibility
            local function toggleSection()
                Section.expanded = not Section.expanded
                
                if Section.expanded then
                    -- Expand section
                    Elements.Visible = true
                    Tween(Arrow, {Rotation = 0}, 0.2)
                    
                    -- Calculate target height
                    local targetHeight = 32 + calculateContentHeight()
                    Tween(SectionFrame, {
                        Size = UDim2.new(1, 0, 0, targetHeight)
                    }, 0.2)
                else
                    -- Collapse section
                    Tween(Arrow, {Rotation = -90}, 0.2)
                    Tween(SectionFrame, {Size = UDim2.new(1, 0, 0, 32)}, 0.2)
                    
                    -- Hide elements after animation completes
                    delay(0.2, function()
                        if not Section.expanded then
                            Elements.Visible = false
                        end
                    end)
                end
            end
            
            -- Update section height when elements change (only if expanded)
            ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if Section.expanded then
                    local targetHeight = 32 + calculateContentHeight()
                    SectionFrame.Size = UDim2.new(1, 0, 0, targetHeight)
                end
            end)
            
            -- Toggle on header click
            HeaderButton.MouseButton1Click:Connect(toggleSection)
            
            -- Toggle
            function Section:Toggle(name, callback, options)
                options = options or {}
                options.name = name
                options.callback = callback
                options.parent = Elements
                
                local toggle = Toggle.new(options)
                Section.toggles[name] = toggle
                return toggle
            end
            
            -- Toggle Group
            function Section:ToggleGroup(groupName, toggles, callback)
                for _, toggleConfig in ipairs(toggles) do
                    local name = toggleConfig.name or toggleConfig[1]
                    local individualCallback = toggleConfig.callback or toggleConfig[2]
                    
                    self:Toggle(name, function(state)
                        if individualCallback then
                            individualCallback(state)
                        end
                        if callback then
                            callback(name, state)
                        end
                    end, {
                        group = groupName,
                        default = toggleConfig.default,
                        color = toggleConfig.color,
                        keybind = toggleConfig.keybind,
                        icon = toggleConfig.icon,
                        tooltip = toggleConfig.tooltip
                    })
                end
            end
            
            -- Label
            function Section:Label(text)
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Parent = Elements
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Size = UDim2.new(1, 0, 0, IsMobile and 24 or 20)
                
                local Label = Instance.new("TextLabel")
                Label.Parent = LabelFrame
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 0, 0, 0)
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.Font = Enum.Font.Gotham
                Label.Text = text
                Label.TextColor3 = Theme.TextDim
                Label.TextSize = IsMobile and 11 or 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextWrapped = true
                
                Label:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    LabelFrame.Size = UDim2.new(1, 0, 0, Label.TextBounds.Y + 4)
                end)
                
                return {
                    SetText = function(newText)
                        Label.Text = newText
                    end,
                    SetColor = function(color)
                        Label.TextColor3 = color
                    end
                }
            end
            
            -- Button
            function Section:Button(name, callback)
                local BtnFrame = Instance.new("TextButton")
                BtnFrame.Parent = Elements
                BtnFrame.BackgroundColor3 = Theme.Card
                BtnFrame.Size = UDim2.new(1, 0, 0, IsMobile and 36 or 32)
                BtnFrame.Font = Enum.Font.Gotham
                BtnFrame.Text = name
                BtnFrame.TextColor3 = Theme.Text
                BtnFrame.TextSize = IsMobile and 12 or 13
                BtnFrame.ClipsDescendants = true
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 6)
                BtnCorner.Parent = BtnFrame
                
                BtnFrame.MouseEnter:Connect(function()
                    Tween(BtnFrame, {BackgroundColor3 = Theme.Accent})
                end)
                
                BtnFrame.MouseLeave:Connect(function()
                    Tween(BtnFrame, {BackgroundColor3 = Theme.Card})
                end)
                
                BtnFrame.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end
            
            -- Slider
            function Section:Slider(name, min, max, default, callback)
                local value = default or min
                local dragging = false
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Parent = Elements
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(1, 0, 0, IsMobile and 56 or 52)
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Parent = SliderFrame
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Position = UDim2.new(0, 0, 0, 0)
                SliderLabel.Size = UDim2.new(0.7, 0, 0, 20)
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.Text = name
                SliderLabel.TextColor3 = Theme.Text
                SliderLabel.TextSize = IsMobile and 12 or 13
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Parent = SliderFrame
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
                ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.Text = tostring(value)
                ValueLabel.TextColor3 = Theme.Accent
                ValueLabel.TextSize = IsMobile and 12 or 13
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                
                local SliderBg = Instance.new("Frame")
                SliderBg.Parent = SliderFrame
                SliderBg.BackgroundColor3 = Theme.Card
                SliderBg.Position = UDim2.new(0, 0, 0, 28)
                SliderBg.Size = UDim2.new(1, 0, 0, 6)
                
                local SliderBgCorner = Instance.new("UICorner")
                SliderBgCorner.CornerRadius = UDim.new(1, 0)
                SliderBgCorner.Parent = SliderBg
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Parent = SliderBg
                SliderFill.BackgroundColor3 = Theme.Accent
                SliderFill.Position = UDim2.new(0, 0, 0, 0)
                SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                
                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill
                
                local SliderKnob = Instance.new("Frame")
                SliderKnob.Parent = SliderBg
                SliderKnob.BackgroundColor3 = Theme.Text
                SliderKnob.Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)
                SliderKnob.Size = UDim2.new(0, 16, 0, 16)
                SliderKnob.ZIndex = 2
                
                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = SliderKnob
                
                local KnobShadow = Instance.new("UIStroke")
                KnobShadow.Parent = SliderKnob
                KnobShadow.Color = Theme.Background
                KnobShadow.Thickness = 2
                KnobShadow.Transparency = 0.5
                
                local SliderButton = Instance.new("TextButton")
                SliderButton.Parent = SliderBg
                SliderButton.BackgroundTransparency = 1
                SliderButton.Position = UDim2.new(0, -5, 0, -10)
                SliderButton.Size = UDim2.new(1, 10, 1, 20)
                SliderButton.Text = ""
                SliderButton.ZIndex = 3
                
                local function UpdateSlider(inputPos)
                    local absPos = SliderBg.AbsolutePosition.X
                    local absSize = SliderBg.AbsoluteSize.X
                    local relPos = math.clamp((inputPos - absPos) / absSize, 0, 1)
                    
                    value = math.floor(min + (max - min) * relPos + 0.5)
                    ValueLabel.Text = tostring(value)
                    
                    Tween(SliderFill, {Size = UDim2.new(relPos, 0, 1, 0)}, 0.1)
                    Tween(SliderKnob, {Position = UDim2.new(relPos, -8, 0.5, -8)}, 0.1)
                    
                    if callback then
                        callback(value)
                    end
                end
                
                SliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                    Tween(SliderKnob, {BackgroundColor3 = Theme.Accent}, 0.1)
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        Tween(SliderKnob, {BackgroundColor3 = Theme.Text}, 0.1)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging then
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateSlider(input.Position.X)
                        elseif input.UserInputType == Enum.UserInputType.Touch then
                            UpdateSlider(input.Position.X)
                        end
                    end
                end)
                
                SliderButton.MouseButton1Click:Connect(function()
                    local mouse = Player:GetMouse()
                    UpdateSlider(mouse.X)
                end)
                
                return {
                    Set = function(newValue)
                        value = math.clamp(newValue, min, max)
                        ValueLabel.Text = tostring(value)
                        local relPos = (value - min) / (max - min)
                        SliderFill.Size = UDim2.new(relPos, 0, 1, 0)
                        SliderKnob.Position = UDim2.new(relPos, -8, 0.5, -8)
                        if callback then
                            callback(value)
                        end
                    end,
                    Get = function()
                        return value
                    end
                }
            end
            
            -- Dropdown (FIXED)
            function Section:Dropdown(name, options, default, callback)
                local selected = default or options[1] or ""
                local opened = false
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Parent = Elements
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(1, 0, 0, IsMobile and 36 or 32)
                DropdownFrame.ClipsDescendants = false
                
                local DropdownBtn = Instance.new("TextButton")
                DropdownBtn.Parent = DropdownFrame
                DropdownBtn.BackgroundColor3 = Theme.Card
                DropdownBtn.Size = UDim2.new(1, 0, 0, IsMobile and 36 or 32)
                DropdownBtn.Text = ""
                DropdownBtn.ClipsDescendants = true
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 6)
                DropdownCorner.Parent = DropdownBtn
                
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Parent = DropdownBtn
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                DropdownLabel.Size = UDim2.new(0.5, -10, 1, 0)
                DropdownLabel.Font = Enum.Font.Gotham
                DropdownLabel.Text = name
                DropdownLabel.TextColor3 = Theme.Text
                DropdownLabel.TextSize = IsMobile and 12 or 13
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local SelectedLabel = Instance.new("TextLabel")
                SelectedLabel.Parent = DropdownBtn
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
                SelectedLabel.Size = UDim2.new(0.5, -30, 1, 0)
                SelectedLabel.Font = Enum.Font.Gotham
                SelectedLabel.Text = selected
                SelectedLabel.TextColor3 = Theme.Accent
                SelectedLabel.TextSize = IsMobile and 11 or 12
                SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
                
                local Arrow = Instance.new("TextLabel")
                Arrow.Parent = DropdownBtn
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(1, -25, 0.5, -8)
                Arrow.Size = UDim2.new(0, 16, 0, 16)
                Arrow.Font = Enum.Font.Gotham
                Arrow.Text = "▼"
                Arrow.TextColor3 = Theme.TextDim
                Arrow.TextSize = 10
                Arrow.Rotation = 0
                
                -- Dropdown List Container
                local ListContainer = Instance.new("Frame")
                ListContainer.Parent = DropdownFrame
                ListContainer.BackgroundColor3 = Theme.Surface
                ListContainer.Position = UDim2.new(0, 0, 0, IsMobile and 40 or 36)
                ListContainer.Size = UDim2.new(1, 0, 0, 0)
                ListContainer.ClipsDescendants = true
                ListContainer.ZIndex = 10
                ListContainer.Visible = false
                
                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 6)
                ListCorner.Parent = ListContainer
                
                local ListStroke = Instance.new("UIStroke")
                ListStroke.Parent = ListContainer
                ListStroke.Color = Theme.Accent
                ListStroke.Thickness = 1
                ListStroke.Transparency = 0.8
                
                local ListScroll = Instance.new("ScrollingFrame")
                ListScroll.Parent = ListContainer
                ListScroll.BackgroundTransparency = 1
                ListScroll.BorderSizePixel = 0
                ListScroll.Position = UDim2.new(0, 4, 0, 4)
                ListScroll.Size = UDim2.new(1, -8, 1, -8)
                ListScroll.ScrollBarThickness = 2
                ListScroll.ScrollBarImageColor3 = Theme.Accent
                ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Parent = ListScroll
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0, 2)
                
                -- Create option buttons
                for _, option in ipairs(options) do
                    local OptionBtn = Instance.new("TextButton")
                    OptionBtn.Parent = ListScroll
                    OptionBtn.BackgroundColor3 = Theme.Card
                    OptionBtn.BackgroundTransparency = 1
                    OptionBtn.Size = UDim2.new(1, 0, 0, IsMobile and 28 or 24)
                    OptionBtn.Font = Enum.Font.Gotham
                    OptionBtn.Text = option
                    OptionBtn.TextColor3 = option == selected and Theme.Accent or Theme.TextDim
                    OptionBtn.TextSize = IsMobile and 11 or 12
                    
                    OptionBtn.MouseEnter:Connect(function()
                        if option ~= selected then
                            Tween(OptionBtn, {BackgroundTransparency = 0.8})
                        end
                    end)
                    
                    OptionBtn.MouseLeave:Connect(function()
                        Tween(OptionBtn, {BackgroundTransparency = 1})
                    end)
                    
                    OptionBtn.MouseButton1Click:Connect(function()
                        selected = option
                        SelectedLabel.Text = option
                        
                        -- Update colors
                        for _, child in ipairs(ListScroll:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.TextColor3 = child.Text == selected and Theme.Accent or Theme.TextDim
                            end
                        end
                        
                        -- Close dropdown
                        opened = false
                        Tween(Arrow, {Rotation = 0}, 0.2)
                        Tween(ListContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        wait(0.2)
                        ListContainer.Visible = false
                        DropdownFrame.Size = UDim2.new(1, 0, 0, IsMobile and 36 or 32)
                        
                        if callback then callback(selected) end
                    end)
                end
                
                -- Update canvas size
                ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
                end)
                
                -- Toggle dropdown
                DropdownBtn.MouseButton1Click:Connect(function()
                    opened = not opened
                    
                    if opened then
                        ListContainer.Visible = true
                        local listHeight = math.min(#options * (IsMobile and 28 or 24) + 8, 150)
                        DropdownFrame.Size = UDim2.new(1, 0, 0, (IsMobile and 36 or 32) + listHeight + 4)
                        Tween(ListContainer, {Size = UDim2.new(1, 0, 0, listHeight)}, 0.2)
                        Tween(Arrow, {Rotation = 180}, 0.2)
                    else
                        Tween(Arrow, {Rotation = 0}, 0.2)
                        Tween(ListContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        wait(0.2)
                        ListContainer.Visible = false
                        DropdownFrame.Size = UDim2.new(1, 0, 0, IsMobile and 36 or 32)
                    end
                end)
                
                if callback and default then
                    callback(selected)
                end
                
                return {
                    Set = function(option)
                        if table.find(options, option) then
                            selected = option
                            SelectedLabel.Text = option
                            for _, child in ipairs(ListScroll:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child.TextColor3 = child.Text == selected and Theme.Accent or Theme.TextDim
                                end
                            end
                            if callback then callback(selected) end
                        end
                    end,
                    Get = function()
                        return selected
                    end,
                    Refresh = function(newOptions)
                        options = newOptions
                        
                        -- Clear existing options
                        for _, child in ipairs(ListScroll:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end
                        
                        -- Add new options
                        for _, option in ipairs(options) do
                            local OptionBtn = Instance.new("TextButton")
                            OptionBtn.Parent = ListScroll
                            OptionBtn.BackgroundColor3 = Theme.Card
                            OptionBtn.BackgroundTransparency = 1
                            OptionBtn.Size = UDim2.new(1, 0, 0, IsMobile and 28 or 24)
                            OptionBtn.Font = Enum.Font.Gotham
                            OptionBtn.Text = option
                            OptionBtn.TextColor3 = option == selected and Theme.Accent or Theme.TextDim
                            OptionBtn.TextSize = IsMobile and 11 or 12
                            
                            OptionBtn.MouseButton1Click:Connect(function()
                                selected = option
                                SelectedLabel.Text = option
                                
                                for _, child in ipairs(ListScroll:GetChildren()) do
                                    if child:IsA("TextButton") then
                                        child.TextColor3 = child.Text == selected and Theme.Accent or Theme.TextDim
                                    end
                                end
                                
                                opened = false
                                Tween(Arrow, {Rotation = 0}, 0.2)
                                Tween(ListContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                                wait(0.2)
                                ListContainer.Visible = false
                                DropdownFrame.Size = UDim2.new(1, 0, 0, IsMobile and 36 or 32)
                                
                                if callback then callback(selected) end
                            end)
                        end
                    end
                }
            end
            
            return Section
        end
        
        Tab.Button = TabBtn
        Tab.Content = TabContent
        Tab.Underline = Underline
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            TabBtn.TextColor3 = Theme.Text
            Underline.Visible = true
            TabContent.Visible = true
            Window.ActiveTab = Tab
        end
        
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabList.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X + 20, 0, 0)
        end)
        
        return Tab
    end
    
    -- Notification Function (FIXED)
    function Window:Notify(text, duration)
        duration = duration or 2
        
        local Notif = Instance.new("Frame")
        Notif.Parent = ScreenGui
        Notif.BackgroundColor3 = Theme.Surface
        Notif.BorderSizePixel = 0
        Notif.Position = UDim2.new(0.5, -100, 1, 0)
        Notif.Size = UDim2.new(0, 200, 0, 40)
        Notif.ZIndex = 1000
        Notif.ClipsDescendants = true
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 8)
        NotifCorner.Parent = Notif
        
        local NotifText = Instance.new("TextLabel")
        NotifText.Parent = Notif
        NotifText.BackgroundTransparency = 1
        NotifText.Size = UDim2.new(1, 0, 1, 0)
        NotifText.Font = Enum.Font.Gotham
        NotifText.Text = text
        NotifText.TextColor3 = Theme.Text
        NotifText.TextSize = IsMobile and 12 or 13
        NotifText.ZIndex = 1001
        
                local AccentLine = Instance.new("Frame")
        AccentLine.Parent = Notif
        AccentLine.BackgroundColor3 = Theme.Accent
        AccentLine.BorderSizePixel = 0
        AccentLine.Position = UDim2.new(0, 0, 0, 0)
        AccentLine.Size = UDim2.new(0, 2, 1, 0)
        AccentLine.ZIndex = 1001
        
        -- Position above toggle bar if minimized
        local yPos = Window.Minimized and -100 or -60
        Tween(Notif, {Position = UDim2.new(0.5, -100, 1, yPos)}, 0.3)
        
        task.wait(duration)
        
        Tween(Notif, {Position = UDim2.new(0.5, -100, 1, 0)}, 0.3)
        task.wait(0.3)
        Notif:Destroy()
    end
    
    -- Entrance animation
    Container.Size = UDim2.new(0, 0, 0, 0)
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    Tween(Container, {
        Size = UDim2.new(0, windowWidth, 0, windowHeight),
        Position = UDim2.new(0.5, -windowWidth/2, 0.5, -windowHeight/2)
    }, 0.4, Enum.EasingStyle.Back)
    
    return Window
end

-- Export toggle manager for advanced users
Library.ToggleManager = ToggleManager

return Library
