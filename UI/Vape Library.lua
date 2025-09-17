

local VapeUI = {}
VapeUI.__index = VapeUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")

-- Vape-Style Dark Purple Theme
local Theme = {
    -- Primary Colors
    Background = Color3.fromRGB(15, 10, 20),
    MainFrame = Color3.fromRGB(25, 18, 35),
    Secondary = Color3.fromRGB(35, 25, 45),
    Accent = Color3.fromRGB(140, 90, 205),
    AccentDark = Color3.fromRGB(110, 70, 165),
    AccentLight = Color3.fromRGB(170, 120, 235),
    
    -- Module Colors
    ModuleOn = Color3.fromRGB(140, 90, 205),
    ModuleOff = Color3.fromRGB(45, 35, 55),
    ModuleHover = Color3.fromRGB(55, 45, 65),
    
    -- Text Colors
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 190),
    TextDark = Color3.fromRGB(120, 120, 130),
    
    -- Status Colors
    Success = Color3.fromRGB(100, 255, 100),
    Warning = Color3.fromRGB(255, 200, 100),
    Error = Color3.fromRGB(255, 100, 100),
    
    -- Fonts
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMono = Enum.Font.Code
}

-- Utility Functions
local function CreateTween(obj, props, duration, style)
    style = style or Enum.EasingStyle.Quart
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration, style, Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local function AddDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main Library
function VapeUI:CreateWindow()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MeowhanHub_Vape"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    local Window = {
        Modules = {},
        ArraylistItems = {},
        Notifications = {}
    }
    
    -- Watermark
    local watermark = Instance.new("Frame")
    watermark.BackgroundColor3 = Theme.MainFrame
    watermark.BorderSizePixel = 0
    watermark.Position = UDim2.new(0, 10, 0, 10)
    watermark.Size = UDim2.new(0, 200, 0, 35)
    watermark.Parent = screenGui
    
    local watermarkCorner = Instance.new("UICorner")
    watermarkCorner.CornerRadius = UDim.new(0, 6)
    watermarkCorner.Parent = watermark
    
    local watermarkStroke = Instance.new("UIStroke")
    watermarkStroke.Color = Theme.Accent
    watermarkStroke.Thickness = 1
    watermarkStroke.Transparency = 0.5
    watermarkStroke.Parent = watermark
    
    local watermarkText = Instance.new("TextLabel")
    watermarkText.BackgroundTransparency = 1
    watermarkText.Position = UDim2.new(0, 10, 0, 0)
    watermarkText.Size = UDim2.new(1, -20, 1, 0)
    watermarkText.Font = Theme.FontBold
    watermarkText.Text = "Meowhan HUB"
    watermarkText.TextColor3 = Theme.Accent
    watermarkText.TextSize = 16
    watermarkText.TextXAlignment = Enum.TextXAlignment.Left
    watermarkText.Parent = watermark
    
    local watermarkSubtext = Instance.new("TextLabel")
    watermarkSubtext.BackgroundTransparency = 1
    watermarkSubtext.Position = UDim2.new(0, 10, 0.5, 0)
    watermarkSubtext.Size = UDim2.new(1, -20, 0.5, 0)
    watermarkSubtext.Font = Theme.Font
    watermarkSubtext.Text = "v3.0 | FPS: 60 | Ping: -- ms"
    watermarkSubtext.TextColor3 = Theme.TextDim
    watermarkSubtext.TextSize = 11
    watermarkSubtext.TextXAlignment = Enum.TextXAlignment.Left
    watermarkSubtext.Parent = watermark
    
    -- Update FPS
    task.spawn(function()
        local lastUpdate = 0
        local fps = 0
        RunService.RenderStepped:Connect(function()
            fps = fps + 1
            if tick() - lastUpdate >= 1 then
                local pingText = "-- ms"
                local ok, result = pcall(function()
                    local item = Stats and Stats.Network and Stats.Network.ServerStatsItem and Stats.Network.ServerStatsItem["Data Ping"]
                    return item and item:GetValueString() or nil
                end)
                if ok and result then
                    pingText = tostring(result)
                end
                watermarkSubtext.Text = string.format("v3.0 | FPS: %d | Ping: %s", fps, pingText)
                fps = 0
                lastUpdate = tick()
            end
        end)
    end)
    
    -- Arraylist Container
    local arraylist = Instance.new("Frame")
    arraylist.BackgroundTransparency = 1
    arraylist.Position = UDim2.new(1, -5, 0, 5)
    arraylist.Size = UDim2.new(0, 200, 1, -10)
    arraylist.Parent = screenGui
    
    local arraylistLayout = Instance.new("UIListLayout")
    arraylistLayout.SortOrder = Enum.SortOrder.LayoutOrder
    arraylistLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    arraylistLayout.Padding = UDim.new(0, 2)
    arraylistLayout.Parent = arraylist
    
    -- Module Windows Container (legacy free-floating modules)
    local moduleContainer = Instance.new("Frame")
    moduleContainer.BackgroundTransparency = 1
    moduleContainer.Size = UDim2.new(1, 0, 1, 0)
    moduleContainer.Parent = screenGui

    -- Optional Vape-like ClickGUI (tabs + modules) - created lazily when a tab is added
    local clickGui = nil
    local tabsBar = nil
    local tabContentHolder = nil
    local activeTab = nil

    local function ensureClickGui()
        if clickGui then return end

        clickGui = Instance.new("Frame")
        clickGui.Name = "ClickGUI"
        clickGui.BackgroundColor3 = Theme.MainFrame
        clickGui.BorderSizePixel = 0
        clickGui.Position = UDim2.new(0.5, -275, 0.5, -200)
        clickGui.Size = UDim2.new(0, 550, 0, 400)
        clickGui.Visible = true
        clickGui.Parent = screenGui

        local cgCorner = Instance.new("UICorner")
        cgCorner.CornerRadius = UDim.new(0, 8)
        cgCorner.Parent = clickGui

        local cgStroke = Instance.new("UIStroke")
        cgStroke.Color = Theme.Accent
        cgStroke.Thickness = 2
        cgStroke.Transparency = 0.25
        cgStroke.Parent = clickGui

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.BackgroundColor3 = Theme.Secondary
        header.BorderSizePixel = 0
        header.Size = UDim2.new(1, 0, 0, 36)
        header.Parent = clickGui

        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 8)
        headerCorner.Parent = header

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 12, 0, 0)
        title.Size = UDim2.new(1, -24, 1, 0)
        title.Font = Theme.FontBold
        title.Text = "Meowhan | Vape"
        title.TextColor3 = Theme.Text
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = header

        -- Draggable header
        AddDraggable(clickGui, header)

        tabsBar = Instance.new("Frame")
        tabsBar.Name = "Tabs"
        tabsBar.BackgroundTransparency = 1
        tabsBar.Position = UDim2.new(0, 8, 0, 40)
        tabsBar.Size = UDim2.new(1, -16, 0, 28)
        tabsBar.Parent = clickGui

        local tabsLayout = Instance.new("UIListLayout")
        tabsLayout.FillDirection = Enum.FillDirection.Horizontal
        tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabsLayout.Padding = UDim.new(0, 6)
        tabsLayout.Parent = tabsBar

        tabContentHolder = Instance.new("Frame")
        tabContentHolder.Name = "ContentHolder"
        tabContentHolder.BackgroundTransparency = 1
        tabContentHolder.Position = UDim2.new(0, 8, 0, 72)
        tabContentHolder.Size = UDim2.new(1, -16, 1, -80)
        tabContentHolder.Parent = clickGui
    end
    
    -- Notification Container
    local notificationContainer = Instance.new("Frame")
    notificationContainer.BackgroundTransparency = 1
    notificationContainer.Position = UDim2.new(0.5, -150, 1, -200)
    notificationContainer.Size = UDim2.new(0, 300, 0, 200)
    notificationContainer.Parent = screenGui
    
    local notificationLayout = Instance.new("UIListLayout")
    notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notificationLayout.Padding = UDim.new(0, 5)
    notificationLayout.Parent = notificationContainer
    
    -- Click GUI Toggle
    local guiVisible = true
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightShift then
            guiVisible = not guiVisible
            for _, module in pairs(Window.Modules) do
                module.Frame.Visible = guiVisible
            end
            watermark.Visible = guiVisible
            if clickGui then
                clickGui.Visible = guiVisible
            end
        end
    end)
    
    function Window:CreateModule(config)
        config = config or {}
        local name = config.Name or "Module"
        local icon = config.Icon or "⚡"
        local posX = config.PosX or 100
        local posY = config.PosY or 100
        
        local Module = {
            Elements = {},
            Toggles = {},
            Expanded = true
        }
        
        -- Main Module Frame
        local moduleFrame = Instance.new("Frame")
        moduleFrame.BackgroundColor3 = Theme.MainFrame
        moduleFrame.BorderSizePixel = 0
        moduleFrame.Position = UDim2.new(0, posX, 0, posY)
        moduleFrame.Size = UDim2.new(0, 200, 0, 35)
        moduleFrame.ClipsDescendants = true
        moduleFrame.Parent = moduleContainer
        
        Module.Frame = moduleFrame
        
        local moduleCorner = Instance.new("UICorner")
        moduleCorner.CornerRadius = UDim.new(0, 8)
        moduleCorner.Parent = moduleFrame
        
        local moduleStroke = Instance.new("UIStroke")
        moduleStroke.Color = Theme.Accent
        moduleStroke.Thickness = 2
        moduleStroke.Transparency = 0.3
        moduleStroke.Parent = moduleFrame
        
        -- Module Header
        local header = Instance.new("Frame")
        header.BackgroundColor3 = Theme.Secondary
        header.BorderSizePixel = 0
        header.Size = UDim2.new(1, 0, 0, 35)
        header.Parent = moduleFrame
        
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 8)
        headerCorner.Parent = header
        
        -- Module Icon
        local moduleIcon = Instance.new("TextLabel")
        moduleIcon.BackgroundTransparency = 1
        moduleIcon.Position = UDim2.new(0, 10, 0, 0)
        moduleIcon.Size = UDim2.new(0, 25, 1, 0)
        moduleIcon.Font = Theme.Font
        moduleIcon.Text = icon
        moduleIcon.TextColor3 = Theme.Accent
        moduleIcon.TextSize = 16
        moduleIcon.Parent = header
        
        -- Module Title
        local moduleTitle = Instance.new("TextLabel")
        moduleTitle.BackgroundTransparency = 1
        moduleTitle.Position = UDim2.new(0, 35, 0, 0)
        moduleTitle.Size = UDim2.new(1, -70, 1, 0)
        moduleTitle.Font = Theme.FontBold
        moduleTitle.Text = name
        moduleTitle.TextColor3 = Theme.Text
        moduleTitle.TextSize = 14
        moduleTitle.TextXAlignment = Enum.TextXAlignment.Left
        moduleTitle.Parent = header
        
        -- Expand/Collapse Button
        local expandButton = Instance.new("TextButton")
        expandButton.BackgroundTransparency = 1
        expandButton.Position = UDim2.new(1, -30, 0, 0)
        expandButton.Size = UDim2.new(0, 30, 1, 0)
        expandButton.Font = Theme.Font
        expandButton.Text = "▼"
        expandButton.TextColor3 = Theme.TextDim
        expandButton.TextSize = 12
        expandButton.Parent = header
        
        -- Content Container
        local content = Instance.new("Frame")
        content.BackgroundTransparency = 1
        content.Position = UDim2.new(0, 0, 0, 35)
        content.Size = UDim2.new(1, 0, 0, 0)
        content.Parent = moduleFrame
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 5)
        contentLayout.Parent = content
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, 10)
        contentPadding.PaddingRight = UDim.new(0, 10)
        contentPadding.PaddingTop = UDim.new(0, 5)
        contentPadding.PaddingBottom = UDim.new(0, 10)
        contentPadding.Parent = content
        
        -- Auto-resize
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 15)
            if Module.Expanded then
                moduleFrame.Size = UDim2.new(0, 200, 0, 35 + content.Size.Y.Offset)
            end
        end)
        
        -- Expand/Collapse
        expandButton.MouseButton1Click:Connect(function()
            Module.Expanded = not Module.Expanded
            if Module.Expanded then
                expandButton.Text = "▼"
                CreateTween(moduleFrame, {Size = UDim2.new(0, 200, 0, 35 + content.Size.Y.Offset)}, 0.2)
            else
                expandButton.Text = "▶"
                CreateTween(moduleFrame, {Size = UDim2.new(0, 200, 0, 35)}, 0.2)
            end
        end)
        
        -- Draggable
        AddDraggable(moduleFrame, header)
        
        -- Module Elements (Vape-style toggle, slider, dropdown)
        function Module:AddToggle(config)
            config = config or {}
            local toggleName = config.Name or "Toggle"
            local default = config.Default or false
            local callback = config.Callback or function() end
            local keybind = config.Keybind
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.BackgroundColor3 = Theme.ModuleOff
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Size = UDim2.new(1, 0, 0, 30)
            toggleFrame.Parent = content
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleFrame
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.Size = UDim2.new(1, -50, 1, 0)
            toggleLabel.Font = Theme.Font
            toggleLabel.Text = toggleName
            toggleLabel.TextColor3 = Theme.Text
            toggleLabel.TextSize = 13
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame

            -- Pill switch (Vape-style)
            local switch = Instance.new("Frame")
            switch.BackgroundColor3 = default and Theme.Accent or Theme.Background
            switch.BorderSizePixel = 0
            switch.Position = UDim2.new(1, -48, 0.5, -8)
            switch.Size = UDim2.new(0, 36, 0, 16)
            switch.Parent = toggleFrame

            local switchCorner = Instance.new("UICorner")
            switchCorner.CornerRadius = UDim.new(1, 0)
            switchCorner.Parent = switch

            local knob = Instance.new("Frame")
            knob.BackgroundColor3 = Theme.Secondary
            knob.BorderSizePixel = 0
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = default and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 1, 0.5, -7)
            knob.Parent = switch

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob
            
            local toggled = default
            local arraylistItem = nil
            
            local function updateToggle()
                if toggled then
                    CreateTween(toggleFrame, {BackgroundColor3 = Theme.ModuleOn}, 0.15)
                    CreateTween(switch, {BackgroundColor3 = Theme.Accent}, 0.15)
                    CreateTween(knob, {Position = UDim2.new(1, -15, 0.5, -7)}, 0.12)
                    
                    -- Add to arraylist
                    if not arraylistItem then
                        arraylistItem = Instance.new("Frame")
                        arraylistItem.BackgroundColor3 = Theme.Accent
                        arraylistItem.BackgroundTransparency = 0.1
                        arraylistItem.BorderSizePixel = 0
                        arraylistItem.Size = UDim2.new(0, 0, 0, 22)
                        arraylistItem.Parent = arraylist
                        
                        local itemCorner = Instance.new("UICorner")
                        itemCorner.CornerRadius = UDim.new(0, 4)
                        itemCorner.Parent = arraylistItem
                        
                        local leftBar = Instance.new("Frame")
                        leftBar.BackgroundColor3 = Theme.AccentLight
                        leftBar.BorderSizePixel = 0
                        leftBar.Size = UDim2.new(0, 2, 1, 0)
                        leftBar.Parent = arraylistItem

                        local itemText = Instance.new("TextLabel")
                        itemText.BackgroundTransparency = 1
                        itemText.Size = UDim2.new(1, 0, 1, 0)
                        itemText.Font = Theme.Font
                        itemText.Text = toggleName
                        itemText.TextColor3 = Theme.Text
                        itemText.TextSize = 13
                        itemText.Parent = arraylistItem
                        
                        local textBounds = itemText.TextBounds
                        arraylistItem.LayoutOrder = -textBounds.X -- wider first
                        CreateTween(arraylistItem, {Size = UDim2.new(0, textBounds.X + 24, 0, 22)}, 0.2)
                    end
                else
                    CreateTween(toggleFrame, {BackgroundColor3 = Theme.ModuleOff}, 0.15)
                    CreateTween(switch, {BackgroundColor3 = Theme.Background}, 0.15)
                    CreateTween(knob, {Position = UDim2.new(0, 1, 0.5, -7)}, 0.12)
                    
                    -- Remove from arraylist
                    if arraylistItem then
                        CreateTween(arraylistItem, {Size = UDim2.new(0, 0, 0, 22)}, 0.2)
                        task.wait(0.2)
                        if arraylistItem then
                            arraylistItem:Destroy()
                            arraylistItem = nil
                        end
                    end
                end
                callback(toggled)
            end
            
            -- Click detection
            local button = Instance.new("TextButton")
            button.BackgroundTransparency = 1
            button.Size = UDim2.new(1, 0, 1, 0)
            button.Text = ""
            button.Parent = toggleFrame
            
            button.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateToggle()
            end)
            
            button.MouseEnter:Connect(function()
                if not toggled then
                    CreateTween(toggleFrame, {BackgroundColor3 = Theme.ModuleHover}, 0.1)
                end
            end)
            
            button.MouseLeave:Connect(function()
                if not toggled then
                    CreateTween(toggleFrame, {BackgroundColor3 = Theme.ModuleOff}, 0.1)
                end
            end)
            
            -- Keybind support
            if keybind then
                UserInputService.InputBegan:Connect(function(input, processed)
                    if not processed and input.KeyCode == keybind then
                        toggled = not toggled
                        updateToggle()
                    end
                end)
                
                local keybindLabel = Instance.new("TextLabel")
                keybindLabel.BackgroundTransparency = 1
                keybindLabel.Position = UDim2.new(1, -90, 0, 0)
                keybindLabel.Size = UDim2.new(0, 50, 1, 0)
                keybindLabel.Font = Theme.Font
                keybindLabel.Text = "[" .. keybind.Name .. "]"
                keybindLabel.TextColor3 = Theme.TextDark
                keybindLabel.TextSize = 11
                keybindLabel.Parent = toggleFrame
            end
            
            if default then
                updateToggle()
            end
            
            Module.Toggles[toggleName] = {Frame = toggleFrame, Toggled = toggled}
            return toggleFrame
    end
        
    function Module:AddSlider(config)
            config = config or {}
            local sliderName = config.Name or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local callback = config.Callback or function() end
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.BackgroundColor3 = Theme.ModuleOff
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Size = UDim2.new(1, 0, 0, 45)
            sliderFrame.Parent = content
            
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 6)
            sliderCorner.Parent = sliderFrame
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Position = UDim2.new(0, 10, 0, 5)
            sliderLabel.Size = UDim2.new(0.6, 0, 0, 15)
            sliderLabel.Font = Theme.Font
            sliderLabel.Text = sliderName
            sliderLabel.TextColor3 = Theme.Text
            sliderLabel.TextSize = 13
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local sliderValue = Instance.new("TextLabel")
            sliderValue.BackgroundTransparency = 1
            sliderValue.Position = UDim2.new(0.6, 0, 0, 5)
            sliderValue.Size = UDim2.new(0.4, -10, 0, 15)
            sliderValue.Font = Theme.FontMono
            sliderValue.Text = tostring(default)
            sliderValue.TextColor3 = Theme.Accent
            sliderValue.TextSize = 13
            sliderValue.TextXAlignment = Enum.TextXAlignment.Right
            sliderValue.Parent = sliderFrame
            
            local sliderBar = Instance.new("Frame")
            sliderBar.BackgroundColor3 = Theme.Background
            sliderBar.BorderSizePixel = 0
            sliderBar.Position = UDim2.new(0, 10, 0, 25)
            sliderBar.Size = UDim2.new(1, -20, 0, 6)
            sliderBar.Parent = sliderFrame
            
            local barCorner = Instance.new("UICorner")
            barCorner.CornerRadius = UDim.new(1, 0)
            barCorner.Parent = sliderBar
            
            local sliderFill = Instance.new("Frame")
            sliderFill.BackgroundColor3 = Theme.Accent
            sliderFill.BorderSizePixel = 0
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.Parent = sliderBar
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = sliderFill
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.BackgroundTransparency = 1
            sliderButton.Size = UDim2.new(1, 0, 1, 0)
            sliderButton.Text = ""
            sliderButton.Parent = sliderBar
            
            local dragging = false
            
            sliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation()
                    local relativePos = mousePos.X - sliderBar.AbsolutePosition.X
                    local percent = math.clamp(relativePos / sliderBar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * percent)
                    
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    sliderValue.Text = tostring(value)
                    callback(value)
                end
            end)
            
            return sliderFrame
    end
        
    function Module:AddDropdown(config)
            config = config or {}
            local dropName = config.Name or "Dropdown"
            local options = config.Options or {}
            local default = config.Default or options[1]
            local callback = config.Callback or function() end
            
            local dropFrame = Instance.new("Frame")
            dropFrame.BackgroundColor3 = Theme.ModuleOff
            dropFrame.BorderSizePixel = 0
            dropFrame.Size = UDim2.new(1, 0, 0, 30)
            dropFrame.ClipsDescendants = true
            dropFrame.Parent = content
            
            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(0, 6)
            dropCorner.Parent = dropFrame
            
            local dropLabel = Instance.new("TextLabel")
            dropLabel.BackgroundTransparency = 1
            dropLabel.Position = UDim2.new(0, 10, 0, 0)
            dropLabel.Size = UDim2.new(1, -30, 0, 30)
            dropLabel.Font = Theme.Font
            dropLabel.Text = dropName .. ": " .. (default or "None")
            dropLabel.TextColor3 = Theme.Text
            dropLabel.TextSize = 13
            dropLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropLabel.Parent = dropFrame
            
            local dropArrow = Instance.new("TextLabel")
            dropArrow.BackgroundTransparency = 1
            dropArrow.Position = UDim2.new(1, -25, 0, 0)
            dropArrow.Size = UDim2.new(0, 20, 0, 30)
            dropArrow.Font = Theme.Font
            dropArrow.Text = "▼"
            dropArrow.TextColor3 = Theme.TextDim
            dropArrow.TextSize = 10
            dropArrow.Parent = dropFrame
            
            local optionContainer = Instance.new("Frame")
            optionContainer.BackgroundTransparency = 1
            optionContainer.Position = UDim2.new(0, 0, 0, 30)
            optionContainer.Size = UDim2.new(1, 0, 0, #options * 25)
            optionContainer.Parent = dropFrame
            
            local optionLayout = Instance.new("UIListLayout")
            optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionLayout.Parent = optionContainer
            
            for i, option in ipairs(options) do
                local optionButton = Instance.new("TextButton")
                optionButton.BackgroundColor3 = Theme.Secondary
                optionButton.BorderSizePixel = 0
                optionButton.Size = UDim2.new(1, 0, 0, 25)
                optionButton.Font = Theme.Font
                optionButton.Text = option
                optionButton.TextColor3 = Theme.TextDim
                optionButton.TextSize = 12
                optionButton.Parent = optionContainer
                
                optionButton.MouseButton1Click:Connect(function()
                    dropLabel.Text = dropName .. ": " .. option
                    callback(option)
                    CreateTween(dropFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.15)
                    dropArrow.Text = "▼"
                end)
                
                optionButton.MouseEnter:Connect(function()
                    CreateTween(optionButton, {BackgroundColor3 = Theme.Accent}, 0.1)
                    CreateTween(optionButton, {TextColor3 = Theme.Text}, 0.1)
                end)
                
                optionButton.MouseLeave:Connect(function()
                    CreateTween(optionButton, {BackgroundColor3 = Theme.Secondary}, 0.1)
                    CreateTween(optionButton, {TextColor3 = Theme.TextDim}, 0.1)
                end)
            end
            
            local expanded = false
            local dropButton = Instance.new("TextButton")
            dropButton.BackgroundTransparency = 1
            dropButton.Size = UDim2.new(1, 0, 0, 30)
            dropButton.Text = ""
            dropButton.Parent = dropFrame
            
            dropButton.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    CreateTween(dropFrame, {Size = UDim2.new(1, 0, 0, 30 + #options * 25)}, 0.15)
                    dropArrow.Text = "▲"
                else
                    CreateTween(dropFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.15)
                    dropArrow.Text = "▼"
                end
            end)
            
            return dropFrame
        end
        
        table.insert(Window.Modules, Module)
        return Module
    end

    -- Vape-like ClickGUI API: Window:CreateTab({ Name = "Combat", Icon = "⚔" })
    function Window:CreateTab(config)
        config = config or {}
        ensureClickGui()

        local tabName = config.Name or "Tab"
        local icon = config.Icon or "●"

        local tabButton = Instance.new("TextButton")
        tabButton.BackgroundColor3 = Theme.Secondary
        tabButton.BorderSizePixel = 0
        tabButton.Size = UDim2.new(0, 90, 1, 0)
        tabButton.Font = Theme.Font
        tabButton.Text = icon .. "  " .. tabName
        tabButton.TextColor3 = Theme.TextDim
        tabButton.TextSize = 12
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabsBar

        local tbCorner = Instance.new("UICorner")
        tbCorner.CornerRadius = UDim.new(0, 6)
        tbCorner.Parent = tabButton

        local tabPage = Instance.new("ScrollingFrame")
        tabPage.BackgroundTransparency = 1
        tabPage.BorderSizePixel = 0
        tabPage.Size = UDim2.new(1, 0, 1, 0)
        tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabPage.ScrollBarThickness = 3
        tabPage.Visible = false
        tabPage.Parent = tabContentHolder

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
        layout.Parent = tabPage

        local pagePadding = Instance.new("UIPadding")
        pagePadding.PaddingLeft = UDim.new(0, 4)
        pagePadding.PaddingRight = UDim.new(0, 4)
        pagePadding.Parent = tabPage

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabPage.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
        end)

        local Tab = { Button = tabButton, Page = tabPage, Modules = {} }

        local function setActive()
            if activeTab then
                activeTab.Button.BackgroundColor3 = Theme.Secondary
                activeTab.Button.TextColor3 = Theme.TextDim
                activeTab.Page.Visible = false
            end
            activeTab = Tab
            Tab.Button.BackgroundColor3 = Theme.Accent
            Tab.Button.TextColor3 = Theme.Text
            Tab.Page.Visible = true
        end

        tabButton.MouseButton1Click:Connect(setActive)

        if not activeTab then setActive() end

        function Tab:AddModule(config)
            config = config or {}
            local name = config.Name or "Module"
            local icon = config.Icon or "⚙"

            local moduleCard = Instance.new("Frame")
            moduleCard.BackgroundColor3 = Theme.MainFrame
            moduleCard.BorderSizePixel = 0
            moduleCard.Size = UDim2.new(1, -4, 0, 35)
            moduleCard.ClipsDescendants = true
            moduleCard.Parent = tabPage

            local mCorner = Instance.new("UICorner")
            mCorner.CornerRadius = UDim.new(0, 8)
            mCorner.Parent = moduleCard

            local mStroke = Instance.new("UIStroke")
            mStroke.Color = Theme.Accent
            mStroke.Thickness = 1
            mStroke.Transparency = 0.5
            mStroke.Parent = moduleCard

            local header = Instance.new("Frame")
            header.BackgroundColor3 = Theme.Secondary
            header.BorderSizePixel = 0
            header.Size = UDim2.new(1, 0, 0, 35)
            header.Parent = moduleCard

            local hCorner = Instance.new("UICorner")
            hCorner.CornerRadius = UDim.new(0, 8)
            hCorner.Parent = header

            local moduleIcon = Instance.new("TextLabel")
            moduleIcon.BackgroundTransparency = 1
            moduleIcon.Position = UDim2.new(0, 10, 0, 0)
            moduleIcon.Size = UDim2.new(0, 25, 1, 0)
            moduleIcon.Font = Theme.Font
            moduleIcon.Text = icon
            moduleIcon.TextColor3 = Theme.Accent
            moduleIcon.TextSize = 16
            moduleIcon.Parent = header

            local moduleTitle = Instance.new("TextLabel")
            moduleTitle.BackgroundTransparency = 1
            moduleTitle.Position = UDim2.new(0, 35, 0, 0)
            moduleTitle.Size = UDim2.new(1, -110, 1, 0)
            moduleTitle.Font = Theme.FontBold
            moduleTitle.Text = name
            moduleTitle.TextColor3 = Theme.Text
            moduleTitle.TextSize = 14
            moduleTitle.TextXAlignment = Enum.TextXAlignment.Left
            moduleTitle.Parent = header

            local expandButton = Instance.new("TextButton")
            expandButton.BackgroundTransparency = 1
            expandButton.Position = UDim2.new(1, -30, 0, 0)
            expandButton.Size = UDim2.new(0, 30, 1, 0)
            expandButton.Font = Theme.Font
            expandButton.Text = "▼"
            expandButton.TextColor3 = Theme.TextDim
            expandButton.TextSize = 12
            expandButton.Parent = header

            local content = Instance.new("Frame")
            content.BackgroundTransparency = 1
            content.Position = UDim2.new(0, 0, 0, 35)
            content.Size = UDim2.new(1, 0, 0, 0)
            content.Parent = moduleCard

            local contentLayout = Instance.new("UIListLayout")
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Padding = UDim.new(0, 5)
            contentLayout.Parent = content

            local contentPadding = Instance.new("UIPadding")
            contentPadding.PaddingLeft = UDim.new(0, 10)
            contentPadding.PaddingRight = UDim.new(0, 10)
            contentPadding.PaddingTop = UDim.new(0, 5)
            contentPadding.PaddingBottom = UDim.new(0, 10)
            contentPadding.Parent = content

            local Expanded = true
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                content.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 15)
                if Expanded then
                    moduleCard.Size = UDim2.new(1, -4, 0, 35 + content.Size.Y.Offset)
                end
            end)

            expandButton.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                if Expanded then
                    expandButton.Text = "▼"
                    CreateTween(moduleCard, {Size = UDim2.new(1, -4, 0, 35 + content.Size.Y.Offset)}, 0.2)
                else
                    expandButton.Text = "▶"
                    CreateTween(moduleCard, {Size = UDim2.new(1, -4, 0, 35)}, 0.2)
                end
            end)

            local Module = { Frame = moduleCard, Elements = {}, Toggles = {} }

            -- Vape-style Toggle
            function Module:AddToggle(opts)
                opts = opts or {}
                local toggleName = opts.Name or "Toggle"
                local default = opts.Default or false
                local cb = opts.Callback or function() end
                local key = opts.Keybind

                local tFrame = Instance.new("Frame")
                tFrame.BackgroundColor3 = Theme.ModuleOff
                tFrame.BorderSizePixel = 0
                tFrame.Size = UDim2.new(1, 0, 0, 30)
                tFrame.Parent = content

                local tCorner = Instance.new("UICorner")
                tCorner.CornerRadius = UDim.new(0, 6)
                tCorner.Parent = tFrame

                local tLabel = Instance.new("TextLabel")
                tLabel.BackgroundTransparency = 1
                tLabel.Position = UDim2.new(0, 10, 0, 0)
                tLabel.Size = UDim2.new(1, -50, 1, 0)
                tLabel.Font = Theme.Font
                tLabel.Text = toggleName
                tLabel.TextColor3 = Theme.Text
                tLabel.TextSize = 13
                tLabel.TextXAlignment = Enum.TextXAlignment.Left
                tLabel.Parent = tFrame

                local switch = Instance.new("Frame")
                switch.BackgroundColor3 = default and Theme.Accent or Theme.Background
                switch.BorderSizePixel = 0
                switch.Position = UDim2.new(1, -48, 0.5, -8)
                switch.Size = UDim2.new(0, 36, 0, 16)
                switch.Parent = tFrame

                local sCorner = Instance.new("UICorner")
                sCorner.CornerRadius = UDim.new(1, 0)
                sCorner.Parent = switch

                local knob = Instance.new("Frame")
                knob.BackgroundColor3 = Theme.Secondary
                knob.BorderSizePixel = 0
                knob.Size = UDim2.new(0, 14, 0, 14)
                knob.Position = default and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 1, 0.5, -7)
                knob.Parent = switch

                local kCorner = Instance.new("UICorner")
                kCorner.CornerRadius = UDim.new(1, 0)
                kCorner.Parent = knob

                local toggled = default
                local arrayItem = nil

                local function apply()
                    if toggled then
                        CreateTween(tFrame, {BackgroundColor3 = Theme.ModuleOn}, 0.15)
                        CreateTween(switch, {BackgroundColor3 = Theme.Accent}, 0.15)
                        CreateTween(knob, {Position = UDim2.new(1, -15, 0.5, -7)}, 0.12)
                        if not arrayItem then
                            arrayItem = Instance.new("Frame")
                            arrayItem.BackgroundColor3 = Theme.Accent
                            arrayItem.BackgroundTransparency = 0.1
                            arrayItem.BorderSizePixel = 0
                            arrayItem.Size = UDim2.new(0, 0, 0, 22)
                            arrayItem.Parent = arraylist

                            local iCorner = Instance.new("UICorner")
                            iCorner.CornerRadius = UDim.new(0, 4)
                            iCorner.Parent = arrayItem

                            local leftBar = Instance.new("Frame")
                            leftBar.BackgroundColor3 = Theme.AccentLight
                            leftBar.BorderSizePixel = 0
                            leftBar.Size = UDim2.new(0, 2, 1, 0)
                            leftBar.Parent = arrayItem

                            local iText = Instance.new("TextLabel")
                            iText.BackgroundTransparency = 1
                            iText.Size = UDim2.new(1, 0, 1, 0)
                            iText.Font = Theme.Font
                            iText.Text = toggleName
                            iText.TextColor3 = Theme.Text
                            iText.TextSize = 13
                            iText.Parent = arrayItem

                            local tb = iText.TextBounds
                            arrayItem.LayoutOrder = -tb.X
                            CreateTween(arrayItem, {Size = UDim2.new(0, tb.X + 24, 0, 22)}, 0.2)
                        end
                    else
                        CreateTween(tFrame, {BackgroundColor3 = Theme.ModuleOff}, 0.15)
                        CreateTween(switch, {BackgroundColor3 = Theme.Background}, 0.15)
                        CreateTween(knob, {Position = UDim2.new(0, 1, 0.5, -7)}, 0.12)
                        if arrayItem then
                            CreateTween(arrayItem, {Size = UDim2.new(0, 0, 0, 22)}, 0.2)
                            task.wait(0.2)
                            if arrayItem then arrayItem:Destroy() arrayItem = nil end
                        end
                    end
                    cb(toggled)
                end

                local btn = Instance.new("TextButton")
                btn.BackgroundTransparency = 1
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.Text = ""
                btn.Parent = tFrame
                btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    apply()
                end)
                btn.MouseEnter:Connect(function()
                    if not toggled then CreateTween(tFrame, {BackgroundColor3 = Theme.ModuleHover}, 0.1) end
                end)
                btn.MouseLeave:Connect(function()
                    if not toggled then CreateTween(tFrame, {BackgroundColor3 = Theme.ModuleOff}, 0.1) end
                end)

                if key then
                    UserInputService.InputBegan:Connect(function(input, processed)
                        if not processed and input.KeyCode == key then
                            toggled = not toggled
                            apply()
                        end
                    end)
                    local keyLabel = Instance.new("TextLabel")
                    keyLabel.BackgroundTransparency = 1
                    keyLabel.Position = UDim2.new(1, -90, 0, 0)
                    keyLabel.Size = UDim2.new(0, 50, 1, 0)
                    keyLabel.Font = Theme.Font
                    keyLabel.Text = "[" .. key.Name .. "]"
                    keyLabel.TextColor3 = Theme.TextDark
                    keyLabel.TextSize = 11
                    keyLabel.Parent = tFrame
                end

                if default then apply() end
                Module.Toggles[toggleName] = { Frame = tFrame, Toggled = toggled }
                return tFrame
            end

            -- Vape-style Slider
            function Module:AddSlider(opts)
                opts = opts or {}
                local sliderName = opts.Name or "Slider"
                local min = opts.Min or 0
                local max = opts.Max or 100
                local default = opts.Default or min
                local callback = opts.Callback or function() end

                local sFrame = Instance.new("Frame")
                sFrame.BackgroundColor3 = Theme.ModuleOff
                sFrame.BorderSizePixel = 0
                sFrame.Size = UDim2.new(1, 0, 0, 45)
                sFrame.Parent = content

                local sCorner = Instance.new("UICorner")
                sCorner.CornerRadius = UDim.new(0, 6)
                sCorner.Parent = sFrame

                local sLabel = Instance.new("TextLabel")
                sLabel.BackgroundTransparency = 1
                sLabel.Position = UDim2.new(0, 10, 0, 5)
                sLabel.Size = UDim2.new(0.6, 0, 0, 15)
                sLabel.Font = Theme.Font
                sLabel.Text = sliderName
                sLabel.TextColor3 = Theme.Text
                sLabel.TextSize = 13
                sLabel.TextXAlignment = Enum.TextXAlignment.Left
                sLabel.Parent = sFrame

                local sValue = Instance.new("TextLabel")
                sValue.BackgroundTransparency = 1
                sValue.Position = UDim2.new(0.6, 0, 0, 5)
                sValue.Size = UDim2.new(0.4, -10, 0, 15)
                sValue.Font = Theme.FontMono
                sValue.Text = tostring(default)
                sValue.TextColor3 = Theme.Accent
                sValue.TextSize = 13
                sValue.TextXAlignment = Enum.TextXAlignment.Right
                sValue.Parent = sFrame

                local sBar = Instance.new("Frame")
                sBar.BackgroundColor3 = Theme.Background
                sBar.BorderSizePixel = 0
                sBar.Position = UDim2.new(0, 10, 0, 25)
                sBar.Size = UDim2.new(1, -20, 0, 6)
                sBar.Parent = sFrame

                local barCorner = Instance.new("UICorner")
                barCorner.CornerRadius = UDim.new(1, 0)
                barCorner.Parent = sBar

                local sFill = Instance.new("Frame")
                sFill.BackgroundColor3 = Theme.Accent
                sFill.BorderSizePixel = 0
                sFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                sFill.Parent = sBar

                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(1, 0)
                fillCorner.Parent = sFill

                local sBtn = Instance.new("TextButton")
                sBtn.BackgroundTransparency = 1
                sBtn.Size = UDim2.new(1, 0, 1, 0)
                sBtn.Text = ""
                sBtn.Parent = sBar

                local dragging = false
                sBtn.MouseButton1Down:Connect(function() dragging = true end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = UserInputService:GetMouseLocation()
                        local relativePos = mousePos.X - sBar.AbsolutePosition.X
                        local percent = math.clamp(relativePos / sBar.AbsoluteSize.X, 0, 1)
                        local value = math.floor(min + (max - min) * percent)
                        sFill.Size = UDim2.new(percent, 0, 1, 0)
                        sValue.Text = tostring(value)
                        callback(value)
                    end
                end)

                return sFrame
            end

            -- Vape-style Dropdown
            function Module:AddDropdown(opts)
                opts = opts or {}
                local dropName = opts.Name or "Dropdown"
                local options = opts.Options or {}
                local default = opts.Default or options[1]
                local callback = opts.Callback or function() end

                local dFrame = Instance.new("Frame")
                dFrame.BackgroundColor3 = Theme.ModuleOff
                dFrame.BorderSizePixel = 0
                dFrame.Size = UDim2.new(1, 0, 0, 30)
                dFrame.ClipsDescendants = true
                dFrame.Parent = content

                local dCorner = Instance.new("UICorner")
                dCorner.CornerRadius = UDim.new(0, 6)
                dCorner.Parent = dFrame

                local dLabel = Instance.new("TextLabel")
                dLabel.BackgroundTransparency = 1
                dLabel.Position = UDim2.new(0, 10, 0, 0)
                dLabel.Size = UDim2.new(1, -30, 0, 30)
                dLabel.Font = Theme.Font
                dLabel.Text = dropName .. ": " .. (default or "None")
                dLabel.TextColor3 = Theme.Text
                dLabel.TextSize = 13
                dLabel.TextXAlignment = Enum.TextXAlignment.Left
                dLabel.Parent = dFrame

                local dArrow = Instance.new("TextLabel")
                dArrow.BackgroundTransparency = 1
                dArrow.Position = UDim2.new(1, -25, 0, 0)
                dArrow.Size = UDim2.new(0, 20, 0, 30)
                dArrow.Font = Theme.Font
                dArrow.Text = "▼"
                dArrow.TextColor3 = Theme.TextDim
                dArrow.TextSize = 10
                dArrow.Parent = dFrame

                local optContainer = Instance.new("Frame")
                optContainer.BackgroundTransparency = 1
                optContainer.Position = UDim2.new(0, 0, 0, 30)
                optContainer.Size = UDim2.new(1, 0, 0, #options * 25)
                optContainer.Parent = dFrame

                local oLayout = Instance.new("UIListLayout")
                oLayout.SortOrder = Enum.SortOrder.LayoutOrder
                oLayout.Parent = optContainer

                for _, option in ipairs(options) do
                    local oBtn = Instance.new("TextButton")
                    oBtn.BackgroundColor3 = Theme.Secondary
                    oBtn.BorderSizePixel = 0
                    oBtn.Size = UDim2.new(1, 0, 0, 25)
                    oBtn.Font = Theme.Font
                    oBtn.Text = option
                    oBtn.TextColor3 = Theme.TextDim
                    oBtn.TextSize = 12
                    oBtn.Parent = optContainer

                    oBtn.MouseButton1Click:Connect(function()
                        dLabel.Text = dropName .. ": " .. option
                        callback(option)
                        CreateTween(dFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.15)
                        dArrow.Text = "▼"
                    end)
                    oBtn.MouseEnter:Connect(function()
                        CreateTween(oBtn, {BackgroundColor3 = Theme.Accent}, 0.1)
                        CreateTween(oBtn, {TextColor3 = Theme.Text}, 0.1)
                    end)
                    oBtn.MouseLeave:Connect(function()
                        CreateTween(oBtn, {BackgroundColor3 = Theme.Secondary}, 0.1)
                        CreateTween(oBtn, {TextColor3 = Theme.TextDim}, 0.1)
                    end)
                end

                local expanded = false
                local dBtn = Instance.new("TextButton")
                dBtn.BackgroundTransparency = 1
                dBtn.Size = UDim2.new(1, 0, 0, 30)
                dBtn.Text = ""
                dBtn.Parent = dFrame
                dBtn.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    if expanded then
                        CreateTween(dFrame, {Size = UDim2.new(1, 0, 0, 30 + #options * 25)}, 0.15)
                        dArrow.Text = "▲"
                    else
                        CreateTween(dFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.15)
                        dArrow.Text = "▼"
                    end
                end)

                return dFrame
            end

            table.insert(Tab.Modules, Module)
            return Module
        end

        return Tab
    end
    
    function Window:Notify(text, duration)
        duration = duration or 3
        
        local notification = Instance.new("Frame")
        notification.BackgroundColor3 = Theme.MainFrame
        notification.BorderSizePixel = 0
        notification.Size = UDim2.new(1, 0, 0, 40)
        notification.BackgroundTransparency = 1
        notification.Parent = notificationContainer
        
        local notifCorner = Instance.new("UICorner")
        notifCorner.CornerRadius = UDim.new(0, 6)
        notifCorner.Parent = notification
        
        local notifStroke = Instance.new("UIStroke")
        notifStroke.Color = Theme.Accent
        notifStroke.Thickness = 1
        notifStroke.Transparency = 1
        notifStroke.Parent = notification
        
        local notifText = Instance.new("TextLabel")
        notifText.BackgroundTransparency = 1
        notifText.Size = UDim2.new(1, 0, 1, 0)
        notifText.Font = Theme.Font
        notifText.Text = text
        notifText.TextColor3 = Theme.Text
        notifText.TextSize = 13
        notifText.TextTransparency = 1
        notifText.Parent = notification
        
        -- Fade in
        CreateTween(notification, {BackgroundTransparency = 0.1}, 0.3)
        CreateTween(notifStroke, {Transparency = 0.3}, 0.3)
        CreateTween(notifText, {TextTransparency = 0}, 0.3)
        
        task.wait(duration)
        
        -- Fade out
        CreateTween(notification, {BackgroundTransparency = 1}, 0.3)
        CreateTween(notifStroke, {Transparency = 1}, 0.3)
        CreateTween(notifText, {TextTransparency = 1}, 0.3)
        
        task.wait(0.3)
        notification:Destroy()
    end
    
    return Window
end

return VapeUI
