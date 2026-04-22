--[[
    🌌 MILKYWAY UI - Premium Custom Library
    Style: Discord-like Notifications (under profile icon)
    Version: 3.1
--]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- // Theme Presets
local Themes = {
    Dark = {
        bg = Color3.fromRGB(10, 10, 18),
        surface = Color3.fromRGB(18, 18, 28),
        primary = Color3.fromRGB(88, 101, 242),
        primaryDark = Color3.fromRGB(71, 82, 196),
        secondary = Color3.fromRGB(39, 39, 52),
        text = Color3.fromRGB(250, 250, 255),
        textSec = Color3.fromRGB(161, 161, 180),
        border = Color3.fromRGB(39, 39, 52),
        success = Color3.fromRGB(35, 165, 90),
        error = Color3.fromRGB(237, 66, 69),
        warning = Color3.fromRGB(250, 166, 26),
        hover = Color3.fromRGB(50, 50, 70)
    },
    Light = {
        bg = Color3.fromRGB(248, 250, 252),
        surface = Color3.fromRGB(255, 255, 255),
        primary = Color3.fromRGB(88, 101, 242),
        primaryDark = Color3.fromRGB(71, 82, 196),
        secondary = Color3.fromRGB(241, 245, 249),
        text = Color3.fromRGB(15, 23, 42),
        textSec = Color3.fromRGB(100, 116, 139),
        border = Color3.fromRGB(226, 232, 240),
        success = Color3.fromRGB(35, 165, 90),
        error = Color3.fromRGB(237, 66, 69),
        warning = Color3.fromRGB(250, 166, 26),
        hover = Color3.fromRGB(226, 232, 240)
    },
    Ocean = {
        bg = Color3.fromRGB(4, 30, 45),
        surface = Color3.fromRGB(10, 45, 60),
        primary = Color3.fromRGB(88, 101, 242),
        primaryDark = Color3.fromRGB(71, 82, 196),
        secondary = Color3.fromRGB(25, 60, 75),
        text = Color3.fromRGB(240, 248, 255),
        textSec = Color3.fromRGB(148, 163, 184),
        border = Color3.fromRGB(51, 65, 85),
        success = Color3.fromRGB(35, 165, 90),
        error = Color3.fromRGB(237, 66, 69),
        warning = Color3.fromRGB(250, 166, 26),
        hover = Color3.fromRGB(45, 80, 95)
    },
    Sunset = {
        bg = Color3.fromRGB(45, 20, 35),
        surface = Color3.fromRGB(55, 28, 45),
        primary = Color3.fromRGB(88, 101, 242),
        primaryDark = Color3.fromRGB(71, 82, 196),
        secondary = Color3.fromRGB(65, 38, 55),
        text = Color3.fromRGB(255, 245, 250),
        textSec = Color3.fromRGB(203, 170, 185),
        border = Color3.fromRGB(75, 48, 65),
        success = Color3.fromRGB(35, 165, 90),
        error = Color3.fromRGB(237, 66, 69),
        warning = Color3.fromRGB(250, 166, 26),
        hover = Color3.fromRGB(85, 48, 75)
    },
    Forest = {
        bg = Color3.fromRGB(10, 35, 25),
        surface = Color3.fromRGB(18, 45, 35),
        primary = Color3.fromRGB(88, 101, 242),
        primaryDark = Color3.fromRGB(71, 82, 196),
        secondary = Color3.fromRGB(28, 55, 45),
        text = Color3.fromRGB(240, 255, 245),
        textSec = Color3.fromRGB(148, 180, 165),
        border = Color3.fromRGB(38, 65, 55),
        success = Color3.fromRGB(35, 165, 90),
        error = Color3.fromRGB(237, 66, 69),
        warning = Color3.fromRGB(250, 166, 26),
        hover = Color3.fromRGB(38, 75, 58)
    }
}

local CurrentTheme = "Dark"
local BlurEffect = nil
local NotificationQueue = {}
local NotificationSpacing = 80
local NotifContainer = nil

-- // ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MilkywayUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- // Blur Setup
local function SetupBlur(enabled)
    if enabled and not BlurEffect then
        BlurEffect = Instance.new("BlurEffect")
        BlurEffect.Parent = Lighting
        BlurEffect.Size = 10
    elseif not enabled and BlurEffect then
        BlurEffect:Destroy()
        BlurEffect = nil
    end
end
SetupBlur(true)

-- // LEFT PROFILE SECTION (Discord Style)
local LeftPanel = Instance.new("Frame")
LeftPanel.Parent = ScreenGui
LeftPanel.Size = UDim2.new(0, 80, 0, 500)
LeftPanel.Position = UDim2.new(0, 0, 0.5, -250)
LeftPanel.BackgroundColor3 = Themes[CurrentTheme].surface
LeftPanel.BackgroundTransparency = 0.15
LeftPanel.BorderSizePixel = 0

local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0, 20)
LeftCorner.Parent = LeftPanel

local LeftStroke = Instance.new("UIStroke")
LeftStroke.Thickness = 1.5
LeftStroke.Transparency = 0.6
LeftStroke.Color = Themes[CurrentTheme].border
LeftStroke.Parent = LeftPanel

-- // Profile Icon (Top Left)
local ProfileIcon = Instance.new("ImageButton")
ProfileIcon.Parent = LeftPanel
ProfileIcon.Size = UDim2.new(0, 48, 0, 48)
ProfileIcon.Position = UDim2.new(0.5, -24, 0, 20)
ProfileIcon.BackgroundColor3 = Themes[CurrentTheme].primary
ProfileIcon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
ProfileIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = ProfileIcon

local IconStroke = Instance.new("UIStroke")
IconStroke.Color = Themes[CurrentTheme].primary
IconStroke.Thickness = 3
IconStroke.Parent = ProfileIcon

-- // Profile Name (Under Icon)
local ProfileName = Instance.new("TextLabel")
ProfileName.Parent = LeftPanel
ProfileName.Size = UDim2.new(1, -10, 0, 24)
ProfileName.Position = UDim2.new(0, 5, 0, 78)
ProfileName.BackgroundTransparency = 1
ProfileName.Text = Player.Name
ProfileName.TextColor3 = Themes[CurrentTheme].text
ProfileName.TextSize = 11
ProfileName.Font = Enum.Font.GothamBold
ProfileName.TextWrapped = true

-- // Status Indicator (Green dot for online)
local StatusDot = Instance.new("Frame")
StatusDot.Parent = ProfileIcon
StatusDot.Size = UDim2.new(0, 14, 0, 14)
StatusDot.Position = UDim2.new(1, -8, 1, -8)
StatusDot.BackgroundColor3 = Themes[CurrentTheme].success

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusDot

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = Themes[CurrentTheme].surface
StatusStroke.Thickness = 2
StatusStroke.Parent = StatusDot

-- // NOTIFICATION CONTAINER (Under Profile Name - Discord Style)
NotifContainer = Instance.new("Frame")
NotifContainer.Parent = LeftPanel
NotifContainer.Size = UDim2.new(1, -10, 0, 400)
NotifContainer.Position = UDim2.new(0, 5, 0, 108)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ClipsDescendants = true

local NotifListLayout = Instance.new("UIListLayout")
NotifListLayout.Parent = NotifContainer
NotifListLayout.Padding = UDim.new(0, 8)
NotifListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- // MAIN WINDOW (Shifted right to accommodate left panel)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 520, 0, 500)
MainFrame.Position = UDim2.new(0, 90, 0.5, -250)
MainFrame.BackgroundColor3 = Themes[CurrentTheme].bg
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.6
MainStroke.Color = Themes[CurrentTheme].border
MainStroke.Parent = MainFrame

-- // Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundTransparency = 1

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Themes[CurrentTheme].primary),
    ColorSequenceKeypoint.new(1, Themes[CurrentTheme].primaryDark)
})
HeaderGradient.Parent = Header

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 20)
HeaderCorner.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Parent = Header
HeaderTitle.Size = UDim2.new(0, 150, 1, 0)
HeaderTitle.Position = UDim2.new(0, 20, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "MILKYWAY"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextSize = 20
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

local HeaderBadge = Instance.new("Frame")
HeaderBadge.Parent = Header
HeaderBadge.Size = UDim2.new(0, 50, 0, 22)
HeaderBadge.Position = UDim2.new(0, 155, 0.5, -11)
HeaderBadge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderBadge.BackgroundTransparency = 0.25

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 8)
BadgeCorner.Parent = HeaderBadge

local BadgeText = Instance.new("TextLabel")
BadgeText.Parent = HeaderBadge
BadgeText.Size = UDim2.new(1, 0, 1, 0)
BadgeText.BackgroundTransparency = 1
BadgeText.Text = "v3.1"
BadgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
BadgeText.TextSize = 11
BadgeText.Font = Enum.Font.GothamBold

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 38, 0, 38)
CloseBtn.Position = UDim2.new(1, -50, 0.5, -19)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.BackgroundTransparency = 0.15
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = CloseBtn

-- // Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0, 38, 0, 38)
MinBtn.Position = UDim2.new(1, -96, 0.5, -19)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
MinBtn.BackgroundTransparency = 0.15
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 24
MinBtn.Font = Enum.Font.GothamBold

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 12)
MinCorner.Parent = MinBtn

-- // Dragging
local Dragging = false
local DragStart, StartPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)

-- // Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Parent = MainFrame
TabContainer.Size = UDim2.new(0, 150, 1, -58)
TabContainer.Position = UDim2.new(0, 0, 0, 58)
TabContainer.BackgroundColor3 = Themes[CurrentTheme].surface
TabContainer.BackgroundTransparency = 0.15
TabContainer.BorderSizePixel = 0

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 0)
TabCorner.Parent = TabContainer

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabContainer
TabList.Padding = UDim.new(0, 8)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TabPadding = Instance.new("UIPadding")
TabPadding.Parent = TabContainer
TabPadding.PaddingTop = UDim.new(0, 20)

-- // Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -165, 1, -72)
ContentArea.Position = UDim2.new(0, 165, 0, 64)
ContentArea.BackgroundTransparency = 1

-- // Tab System
local TabsList = {}
local ActiveTab = nil

local function CreateTab(icon, name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = TabContainer
    TabBtn.Size = UDim2.new(0, 130, 0, 46)
    TabBtn.BackgroundColor3 = Themes[CurrentTheme].surface
    TabBtn.BackgroundTransparency = 0.4
    TabBtn.Text = "   " .. icon .. "   " .. name
    TabBtn.TextColor3 = Themes[CurrentTheme].textSec
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left

    local TabCornerBtn = Instance.new("UICorner")
    TabCornerBtn.CornerRadius = UDim.new(0, 12)
    TabCornerBtn.Parent = TabBtn

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Parent = ContentArea
    TabFrame.Size = UDim2.new(1, -10, 1, 0)
    TabFrame.Position = UDim2.new(0, 5, 0, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.ScrollBarThickness = 4
    TabFrame.ScrollBarImageColor3 = Themes[CurrentTheme].primary
    TabFrame.Visible = false

    local FrameLayout = Instance.new("UIListLayout")
    FrameLayout.Parent = TabFrame
    FrameLayout.Padding = UDim.new(0, 12)
    FrameLayout.SortOrder = Enum.SortOrder.LayoutOrder

    FrameLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, FrameLayout.AbsoluteContentSize.Y + 20)
    end)

    table.insert(TabsList, {Btn = TabBtn, Frame = TabFrame, Name = name})

    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(TabsList) do
            tab.Frame.Visible = false
            TweenService:Create(tab.Btn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.4,
                TextColor3 = Themes[CurrentTheme].textSec
            }):Play()
        end
        TabFrame.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            TextColor3 = Themes[CurrentTheme].text
        }):Play()
        ActiveTab = name
    end)

    if #TabsList == 1 then
        TabBtn.MouseButton1Click:Fire()
    end

    return TabFrame
end

-- // Section Header
local function CreateSection(parent, title, description)
    local Section = Instance.new("Frame")
    Section.Parent = parent
    Section.Size = UDim2.new(1, -16, 0, description and 60 or 45)
    Section.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel")
    Title.Parent = Section
    Title.Size = UDim2.new(1, 0, 0, 24)
    Title.Position = UDim2.new(0, 8, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Themes[CurrentTheme].text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left

    if description then
        local Desc = Instance.new("TextLabel")
        Desc.Parent = Section
        Desc.Size = UDim2.new(1, 0, 0, 20)
        Desc.Position = UDim2.new(0, 8, 0, 26)
        Desc.BackgroundTransparency = 1
        Desc.Text = description
        Desc.TextColor3 = Themes[CurrentTheme].textSec
        Desc.TextSize = 12
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
    end

    local Line = Instance.new("Frame")
    Line.Parent = Section
    Line.Size = UDim2.new(1, -16, 0, 2)
    Line.Position = UDim2.new(0, 8, 0, (description and 55 or 40))
    Line.BackgroundColor3 = Themes[CurrentTheme].primary
    Line.BackgroundTransparency = 0.5

    local LineCorner = Instance.new("UICorner")
    LineCorner.CornerRadius = UDim.new(1, 0)
    LineCorner.Parent = Line

    return Section
end

-- // Label
local function CreateLabel(parent, text, color)
    local Label = Instance.new("TextLabel")
    Label.Parent = parent
    Label.Size = UDim2.new(1, -16, 0, 32)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = color or Themes[CurrentTheme].textSec
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    return Label
end

-- // Button
local function CreateButton(parent, text, icon, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, -16, 0, 48)
    Btn.BackgroundColor3 = Themes[CurrentTheme].surface
    Btn.BackgroundTransparency = 0.2
    Btn.Text = icon and icon .. "   " .. text or text
    Btn.TextColor3 = Themes[CurrentTheme].text
    Btn.TextSize = 14
    Btn.Font = Enum.Font.Gotham
    Btn.TextXAlignment = Enum.TextXAlignment.Center

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = Btn

    local Ripple = Instance.new("Frame")
    Ripple.Parent = Btn
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ripple.BackgroundTransparency = 0.8
    Ripple.BorderSizePixel = 0

    local RippleCorner = Instance.new("UICorner")
    RippleCorner.CornerRadius = UDim.new(1, 0)
    RippleCorner.Parent = Ripple

    Btn.MouseButton1Click:Connect(function(input)
        local x, y = input.Position.X - Btn.AbsolutePosition.X, input.Position.Y - Btn.AbsolutePosition.Y
        Ripple.Position = UDim2.new(0, x - 50, 0, y - 50)
        Ripple.Size = UDim2.new(0, 100, 0, 100)
        TweenService:Create(Ripple, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 200), BackgroundTransparency = 1}):Play()
        TweenService:Create(Btn, TweenInfo.new(0.08), {BackgroundTransparency = 0.5}):Play()
        task.wait(0.08)
        TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
        if callback then callback() end
    end)

    return Btn
end

-- // Toggle
local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = parent
    ToggleFrame.Size = UDim2.new(1, -16, 0, 52)
    ToggleFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    ToggleFrame.BackgroundTransparency = 0.2

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Themes[CurrentTheme].text
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Track = Instance.new("Frame")
    Track.Parent = ToggleFrame
    Track.Size = UDim2.new(0, 52, 0, 28)
    Track.Position = UDim2.new(1, -68, 0.5, -14)
    Track.BackgroundColor3 = default and Themes[CurrentTheme].primary or Color3.fromRGB(55, 55, 75)

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Knob = Instance.new("Frame")
    Knob.Parent = Track
    Knob.Size = UDim2.new(0, 22, 0, 22)
    Knob.Position = default and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local toggled = default
    local ClickArea = Instance.new("TextButton")
    ClickArea.Parent = ToggleFrame
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""

    ClickArea.MouseButton1Click:Connect(function()
        toggled = not toggled
        local targetColor = toggled and Themes[CurrentTheme].primary or Color3.fromRGB(55, 55, 75)
        TweenService:Create(Track, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        local targetPos = toggled and UDim2.new(1, -26, 0.5, -11) or UDim2.new(0, 4, 0.5, -11)
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
        if callback then callback(toggled) end
    end)

    return ToggleFrame
end

-- // Slider
local function CreateSlider(parent, text, min, max, default, suffix, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Parent = parent
    SliderFrame.Size = UDim2.new(1, -16, 0, 85)
    SliderFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    SliderFrame.BackgroundTransparency = 0.2

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 12)
    SliderCorner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.Size = UDim2.new(0.55, 0, 0, 28)
    Label.Position = UDim2.new(0, 16, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Themes[CurrentTheme].text
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = SliderFrame
    ValueLabel.Size = UDim2.new(0.35, 0, 0, 28)
    ValueLabel.Position = UDim2.new(0.55, 0, 0, 10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default) .. (suffix or "")
    ValueLabel.TextColor3 = Themes[CurrentTheme].primary
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Track = Instance.new("Frame")
    Track.Parent = SliderFrame
    Track.Size = UDim2.new(1, -32, 0, 5)
    Track.Position = UDim2.new(0, 16, 0, 52)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 70)

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    Fill.Parent = Track
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Themes[CurrentTheme].primary

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local value = default
    local sliding = false

    local function updateSlider(input)
        local relPos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * relPos)
        Fill.Size = UDim2.new(relPos, 0, 1, 0)
        ValueLabel.Text = tostring(value) .. (suffix or "")
        if callback then callback(value) end
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    return SliderFrame
end

-- // Dropdown
local function CreateDropdown(parent, text, options, callback)
    local DropFrame = Instance.new("Frame")
    DropFrame.Parent = parent
    DropFrame.Size = UDim2.new(1, -16, 0, 52)
    DropFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    DropFrame.BackgroundTransparency = 0.2

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, 12)
    DropCorner.Parent = DropFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = DropFrame
    Label.Size = UDim2.new(0.45, 0, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Themes[CurrentTheme].text
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local DropBtn = Instance.new("TextButton")
    DropBtn.Parent = DropFrame
    DropBtn.Size = UDim2.new(0, 140, 0, 36)
    DropBtn.Position = UDim2.new(1, -156, 0.5, -18)
    DropBtn.BackgroundColor3 = Themes[CurrentTheme].secondary
    DropBtn.Text = options[1]
    DropBtn.TextColor3 = Themes[CurrentTheme].text
    DropBtn.TextSize = 13
    DropBtn.Font = Enum.Font.Gotham

    local DropBtnCorner = Instance.new("UICorner")
    DropBtnCorner.CornerRadius = UDim.new(0, 8)
    DropBtnCorner.Parent = DropBtn

    local selected = options[1]
    local isOpen = false
    local DropList = nil

    local function closeDropdown()
        if DropList then
            TweenService:Create(DropList, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
            task.wait(0.12)
            DropList:Destroy()
            DropList = nil
        end
        isOpen = false
    end

    DropBtn.MouseButton1Click:Connect(function()
        if isOpen then
            closeDropdown()
            return
        end

        isOpen = true
        DropList = Instance.new("Frame")
        DropList.Parent = DropFrame
        DropList.Size = UDim2.new(0, 140, 0, #options * 36)
        DropList.Position = UDim2.new(1, -156, 0, 44)
        DropList.BackgroundColor3 = Themes[CurrentTheme].surface
        DropList.BackgroundTransparency = 0.1

        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, 8)
        ListCorner.Parent = DropList

        local ListStroke = Instance.new("UIStroke")
        ListStroke.Color = Themes[CurrentTheme].border
        ListStroke.Thickness = 1
        ListStroke.Parent = DropList

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Parent = DropList
        ListLayout.Padding = UDim.new(0, 2)

        for _, opt in pairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Parent = DropList
            OptBtn.Size = UDim2.new(1, 0, 0, 34)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = opt
            OptBtn.TextColor3 = Themes[CurrentTheme].textSec
            OptBtn.TextSize = 12
            OptBtn.Font = Enum.Font.Gotham

            OptBtn.MouseEnter:Connect(function()
                TweenService:Create(OptBtn, TweenInfo.new(0.08), {BackgroundTransparency = 0.95, TextColor3 = Themes[CurrentTheme].text}):Play()
            end)
            OptBtn.MouseLeave:Connect(function()
                TweenService:Create(OptBtn, TweenInfo.new(0.08), {BackgroundTransparency = 1, TextColor3 = Themes[CurrentTheme].textSec}):Play()
            end)

            OptBtn.MouseButton1Click:Connect(function()
                selected = opt
                DropBtn.Text = opt
                if callback then callback(opt) end
                closeDropdown()
            end)
        end

        TweenService:Create(DropList, TweenInfo.new(0.12), {BackgroundTransparency = 0.05}):Play()

        task.delay(6, function()
            if DropList and DropList.Parent then
                closeDropdown()
            end
        end)
    end)

    return DropFrame
end

-- // Input Field
local function CreateInput(parent, placeholder, callback)
    local InputFrame = Instance.new("Frame")
    InputFrame.Parent = parent
    InputFrame.Size = UDim2.new(1, -16, 0, 52)
    InputFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    InputFrame.BackgroundTransparency = 0.2

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 12)
    InputCorner.Parent = InputFrame

    local InputBox = Instance.new("TextBox")
    InputBox.Parent = InputFrame
    InputBox.Size = UDim2.new(1, -32, 0, 36)
    InputBox.Position = UDim2.new(0, 16, 0.5, -18)
    InputBox.BackgroundColor3 = Themes[CurrentTheme].secondary
    InputBox.PlaceholderText = placeholder
    InputBox.Text = ""
    InputBox.TextColor3 = Themes[CurrentTheme].text
    InputBox.PlaceholderColor3 = Themes[CurrentTheme].textSec
    InputBox.TextSize = 14
    InputBox.Font = Enum.Font.Gotham
    InputBox.ClearTextOnFocus = false

    local InputCornerBox = Instance.new("UICorner")
    InputCornerBox.CornerRadius = UDim.new(0, 8)
    InputCornerBox.Parent = InputBox

    InputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(InputBox.Text)
        end
    end)

    return InputFrame
end

-- // Progress Bar
local function CreateProgress(parent, text, default, callback)
    local ProgFrame = Instance.new("Frame")
    ProgFrame.Parent = parent
    ProgFrame.Size = UDim2.new(1, -16, 0, 75)
    ProgFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    ProgFrame.BackgroundTransparency = 0.2

    local ProgCorner = Instance.new("UICorner")
    ProgCorner.CornerRadius = UDim.new(0, 12)
    ProgCorner.Parent = ProgFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ProgFrame
    Label.Size = UDim2.new(0.7, 0, 0, 28)
    Label.Position = UDim2.new(0, 16, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Themes[CurrentTheme].text
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local PercentLabel = Instance.new("TextLabel")
    PercentLabel.Parent = ProgFrame
    PercentLabel.Size = UDim2.new(0.2, 0, 0, 28)
    PercentLabel.Position = UDim2.new(0.7, 0, 0, 10)
    PercentLabel.BackgroundTransparency = 1
    PercentLabel.Text = tostring(default) .. "%"
    PercentLabel.TextColor3 = Themes[CurrentTheme].primary
    PercentLabel.TextSize = 14
    PercentLabel.Font = Enum.Font.GothamBold
    PercentLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Track = Instance.new("Frame")
    Track.Parent = ProgFrame
    Track.Size = UDim2.new(1, -32, 0, 8)
    Track.Position = UDim2.new(0, 16, 0, 48)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 70)

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    Fill.Parent = Track
    Fill.Size = UDim2.new(default / 100, 0, 1, 0)
    Fill.BackgroundColor3 = Themes[CurrentTheme].primary

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local function updateProgress(value)
        local percent = math.clamp(value, 0, 100)
        TweenService:Create(Fill, TweenInfo.new(0.3), {Size = UDim2.new(percent / 100, 0, 1, 0)}):Play()
        PercentLabel.Text = tostring(math.floor(percent)) .. "%"
        if callback then callback(percent) end
    end

    return updateProgress
end

-- // Color Picker
local function CreateColorPicker(parent, text, defaultColor, callback)
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Parent = parent
    ColorFrame.Size = UDim2.new(1, -16, 0, 52)
    ColorFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    ColorFrame.BackgroundTransparency = 0.2

    local ColorCorner = Instance.new("UICorner")
    ColorCorner.CornerRadius = UDim.new(0, 12)
    ColorCorner.Parent = ColorFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ColorFrame
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Themes[CurrentTheme].text
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ColorDisplay = Instance.new("Frame")
    ColorDisplay.Parent = ColorFrame
    ColorDisplay.Size = UDim2.new(0, 48, 0, 36)
    ColorDisplay.Position = UDim2.new(1, -64, 0.5, -18)
    ColorDisplay.BackgroundColor3 = defaultColor

    local DisplayCorner = Instance.new("UICorner")
    DisplayCorner.CornerRadius = UDim.new(0, 10)
    DisplayCorner.Parent = ColorDisplay

    local DisplayStroke = Instance.new("UIStroke")
    DisplayStroke.Color = Themes[CurrentTheme].border
    DisplayStroke.Thickness = 1
    DisplayStroke.Parent = ColorDisplay

    local selectedColor = defaultColor
    local pickerOpen = false
    local PickerWindow = nil

    local function closePicker()
        if PickerWindow then
            TweenService:Create(PickerWindow, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            task.wait(0.15)
            PickerWindow:Destroy()
            PickerWindow = nil
        end
        pickerOpen = false
    end

    ColorDisplay.MouseButton1Click:Connect(function()
        if pickerOpen then
            closePicker()
            return
        end

        pickerOpen = true
        PickerWindow = Instance.new("Frame")
        PickerWindow.Parent = ScreenGui
        PickerWindow.Size = UDim2.new(0, 300, 0, 320)
        PickerWindow.Position = UDim2.new(0.5, -150, 0.5, -160)
        PickerWindow.BackgroundColor3 = Themes[CurrentTheme].bg
        PickerWindow.BackgroundTransparency = 0.05

        local PickerCorner = Instance.new("UICorner")
        PickerCorner.CornerRadius = UDim.new(0, 16)
        PickerCorner.Parent = PickerWindow

        local PickerStroke = Instance.new("UIStroke")
        PickerStroke.Color = Themes[CurrentTheme].border
        PickerStroke.Thickness = 1
        PickerStroke.Parent = PickerWindow

        local PickerTitle = Instance.new("TextLabel")
        PickerTitle.Parent = PickerWindow
        PickerTitle.Size = UDim2.new(1, 0, 0, 48)
        PickerTitle.BackgroundTransparency = 1
        PickerTitle.Text = "Color Picker"
        PickerTitle.TextColor3 = Themes[CurrentTheme].text
        PickerTitle.TextSize = 18
        PickerTitle.Font = Enum.Font.GothamBold

        local r, g, b = selectedColor.R * 255, selectedColor.G * 255, selectedColor.B * 255

        local RedSlider = CreateSlider(PickerWindow, "Red", 0, 255, r, "", function(val)
            selectedColor = Color3.fromRGB(val, g, b)
            ColorDisplay.BackgroundColor3 = selectedColor
            if callback then callback(selectedColor) end
        end)
        RedSlider.Size = UDim2.new(1, -32, 0, 70)
        RedSlider.Position = UDim2.new(0, 16, 0, 55)

        local GreenSlider = CreateSlider(PickerWindow, "Green", 0, 255, g, "", function(val)
            selectedColor = Color3.fromRGB(r, val, b)
            ColorDisplay.BackgroundColor3 = selectedColor
            if callback then callback(selectedColor) end
        end)
        GreenSlider.Size = UDim2.new(1, -32, 0, 70)
        GreenSlider.Position = UDim2.new(0, 16, 0, 140)

        local BlueSlider = CreateSlider(PickerWindow, "Blue", 0, 255, b, "", function(val)
            selectedColor = Color3.fromRGB(r, g, val)
            ColorDisplay.BackgroundColor3 = selectedColor
            if callback then callback(selectedColor) end
        end)
        BlueSlider.Size = UDim2.new(1, -32, 0, 70)
        BlueSlider.Position = UDim2.new(0, 16, 0, 225)

        local ClosePicker = Instance.new("TextButton")
        ClosePicker.Parent = PickerWindow
        ClosePicker.Size = UDim2.new(0, 80, 0, 36)
        ClosePicker.Position = UDim2.new(1, -96, 1, -48)
        ClosePicker.BackgroundColor3 = Themes[CurrentTheme].primary
        ClosePicker.Text = "Done"
        ClosePicker.TextColor3 = Color3.fromRGB(255, 255, 255)
        ClosePicker.TextSize = 14
        ClosePicker.Font = Enum.Font.GothamBold

        local CloseCornerPicker = Instance.new("UICorner")
        CloseCornerPicker.CornerRadius = UDim.new(0, 8)
        CloseCornerPicker.Parent = ClosePicker

        ClosePicker.MouseButton1Click:Connect(function()
            closePicker()
        end)

        TweenService:Create(PickerWindow, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
    end)

    return ColorFrame
end

-- // Theme Selector
local function CreateThemeSelector(parent)
    local ThemeFrame = Instance.new("Frame")
    ThemeFrame.Parent = parent
    ThemeFrame.Size = UDim2.new(1, -16, 0, 140)
    ThemeFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    ThemeFrame.BackgroundTransparency = 0.2

    local ThemeCorner = Instance.new("UICorner")
    ThemeCorner.CornerRadius = UDim.new(0, 12)
    ThemeCorner.Parent = ThemeFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ThemeFrame
    Label.Size = UDim2.new(1, 0, 0, 32)
    Label.Position = UDim2.new(0, 16, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = "Theme"
    Label.TextColor3 = Themes[CurrentTheme].text
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local themeList = {"Dark", "Light", "Ocean", "Sunset", "Forest"}
    local btnWidth = (ThemeFrame.AbsoluteSize.X - 32) / 5

    for i, name in ipairs(themeList) do
        local ThemeBtn = Instance.new("TextButton")
        ThemeBtn.Parent = ThemeFrame
        ThemeBtn.Size = UDim2.new(0, btnWidth - 8, 0, 44)
        ThemeBtn.Position = UDim2.new(0, 16 + ((i-1) * btnWidth), 0, 58)
        ThemeBtn.BackgroundColor3 = Themes[name].primary
        ThemeBtn.BackgroundTransparency = 0.25
        ThemeBtn.Text = name
        ThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ThemeBtn.TextSize = 11
        ThemeBtn.Font = Enum.Font.GothamBold

        local BtnCornerTheme = Instance.new("UICorner")
        BtnCornerTheme.CornerRadius = UDim.new(0, 8)
        BtnCornerTheme.Parent = ThemeBtn

        ThemeBtn.MouseButton1Click:Connect(function()
            ApplyTheme(name)
        end)
    end

    return ThemeFrame
end

-- // DISCORD-STYLE NOTIFICATION (Under Profile Icon)
local function Notify(title, message, type, duration)
    local notifType = type or "info"
    local notifColor = Themes[CurrentTheme][notifType] or Themes[CurrentTheme].primary
    
    local Notification = Instance.new("Frame")
    Notification.Parent = NotifContainer
    Notification.Size = UDim2.new(1, 0, 0, 72)
    Notification.BackgroundColor3 = Themes[CurrentTheme].surface
    Notification.BackgroundTransparency = 0.05
    Notification.ClipsDescendants = true
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 12)
    NotifCorner.Parent = Notification
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = notifColor
    NotifStroke.Thickness = 1.5
    NotifStroke.Transparency = 0.5
    NotifStroke.Parent = Notification
    
    -- Left accent bar (Discord style)
    local AccentBar = Instance.new("Frame")
    AccentBar.Parent = Notification
    AccentBar.Size = UDim2.new(0, 4, 1, 0)
    AccentBar.BackgroundColor3 = notifColor
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 4)
    AccentCorner.Parent = AccentBar
    
    -- Avatar / Icon
    local Avatar = Instance.new("Frame")
    Avatar.Parent = Notification
    Avatar.Size = UDim2.new(0, 36, 0, 36)
    Avatar.Position = UDim2.new(0, 12, 0.5, -18)
    Avatar.BackgroundColor3 = notifColor
    Avatar.BackgroundTransparency = 0.2
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = Avatar
    
    local AvatarIcon = Instance.new("TextLabel")
    AvatarIcon.Parent = Avatar
    AvatarIcon.Size = UDim2.new(1, 0, 1, 0)
    AvatarIcon.BackgroundTransparency = 1
    if notifType == "success" then
        AvatarIcon.Text = "✓"
    elseif notifType == "error" then
        AvatarIcon.Text = "✕"
    elseif notifType == "warning" then
        AvatarIcon.Text = "!"
    else
        AvatarIcon.Text = "●"
    end
    AvatarIcon.TextColor3 = notifColor
    AvatarIcon.TextSize = 20
    AvatarIcon.Font = Enum.Font.GothamBold
    
    -- Title (like Discord username)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Notification
    TitleLabel.Size = UDim2.new(1, -60, 0, 22)
    TitleLabel.Position = UDim2.new(0, 60, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Themes[CurrentTheme].text
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Timestamp (like Discord)
    local Timestamp = Instance.new("TextLabel")
    Timestamp.Parent = Notification
    Timestamp.Size = UDim2.new(0, 80, 0, 16)
    Timestamp.Position = UDim2.new(1, -90, 0, 12)
    Timestamp.BackgroundTransparency = 1
    local currentTime = os.date("%I:%M %p"):gsub("^0", "")
    Timestamp.Text = currentTime
    Timestamp.TextColor3 = Themes[CurrentTheme].textSec
    Timestamp.TextSize = 10
    Timestamp.Font = Enum.Font.Gotham
    Timestamp.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Message (like Discord message content)
    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Parent = Notification
    MsgLabel.Size = UDim2.new(1, -60, 0, 28)
    MsgLabel.Position = UDim2.new(0, 60, 0, 34)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = message
    MsgLabel.TextColor3 = Themes[CurrentTheme].textSec
    MsgLabel.TextSize = 12
    MsgLabel.Font = Enum.Font.Gotham
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    MsgLabel.TextWrapped = true
    MsgLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Hover effect
    local isHovering = false
    Notification.MouseEnter:Connect(function()
        isHovering = true
        TweenService:Create(Notification, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
    end)
    
    Notification.MouseLeave:Connect(function()
        isHovering = false
        TweenService:Create(Notification, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
    end)
    
    -- Auto dismiss after duration
    task.wait(duration or 5)
    
    if Notification and Notification.Parent then
        TweenService:Create(Notification, TweenInfo.new(0.25), {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, -10)}):Play()
        task.wait(0.25)
        Notification:Destroy()
    end
end

-- // Context Menu
local function CreateContextMenu(options, position)
    local Menu = Instance.new("Frame")
    Menu.Parent = ScreenGui
    Menu.Size = UDim2.new(0, 200, 0, #options * 38)
    Menu.Position = UDim2.new(0, position.X, 0, position.Y)
    Menu.BackgroundColor3 = Themes[CurrentTheme].surface
    Menu.BackgroundTransparency = 0.05
    Menu.ZIndex = 50

    local MenuCorner = Instance.new("UICorner")
    MenuCorner.CornerRadius = UDim.new(0, 12)
    MenuCorner.Parent = Menu

    local MenuStroke = Instance.new("UIStroke")
    MenuStroke.Color = Themes[CurrentTheme].border
    MenuStroke.Thickness = 1
    MenuStroke.Parent = Menu

    local MenuLayout = Instance.new("UIListLayout")
    MenuLayout.Parent = Menu
    MenuLayout.Padding = UDim.new(0, 4)

    for _, opt in pairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Parent = Menu
        OptBtn.Size = UDim2.new(1, 0, 0, 36)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = opt.text
        OptBtn.TextColor3 = opt.color or Themes[CurrentTheme].text
        OptBtn.TextSize = 13
        OptBtn.Font = Enum.Font.Gotham

        OptBtn.MouseEnter:Connect(function()
            TweenService:Create(OptBtn, TweenInfo.new(0.08), {BackgroundTransparency = 0.95, TextColor3 = Themes[CurrentTheme].text}):Play()
        end)
        OptBtn.MouseLeave:Connect(function()
            TweenService:Create(OptBtn, TweenInfo.new(0.08), {BackgroundTransparency = 1, TextColor3 = opt.color or Themes[CurrentTheme].text}):Play()
        end)

        OptBtn.MouseButton1Click:Connect(function()
            if opt.callback then opt.callback() end
            Menu:Destroy()
        end)
    end

    local function closeMenu()
        if Menu then Menu:Destroy() end
    end

    task.delay(5, closeMenu)
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            closeMenu()
        end
    end)

    return Menu
end

-- // Apply Theme Function
local function ApplyTheme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    CurrentTheme = themeName

    TweenService:Create(MainFrame, TweenInfo.new(0.25), {BackgroundColor3 = theme.bg}):Play()
    TweenService:Create(LeftPanel, TweenInfo.new(0.25), {BackgroundColor3 = theme.surface}):Play()
    TweenService:Create(TabContainer, TweenInfo.new(0.25), {BackgroundColor3 = theme.surface}):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.25), {Color = theme.border}):Play()
    TweenService:Create(LeftStroke, TweenInfo.new(0.25), {Color = theme.border}):Play()
    TweenService:Create(ProfileName, TweenInfo.new(0.25), {TextColor3 = theme.text}):Play()

    for _, tab in pairs(TabsList) do
        TweenService:Create(tab.Btn, TweenInfo.new(0.25), {BackgroundColor3 = theme.surface, TextColor3 = theme.textSec}):Play()
    end

    if ActiveTab then
        for _, tab in pairs(TabsList) do
            if tab.Name == ActiveTab and tab.Frame.Visible then
                TweenService:Create(tab.Btn, TweenInfo.new(0.25), {BackgroundColor3 = theme.surface, TextColor3 = theme.text}):Play()
                break
            end
        end
    end
end

-- // Minimize Functionality
local minimized = false
local originalSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 520, 0, 58)}):Play()
        TabContainer.Visible = false
        ContentArea.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = originalSize}):Play()
        TabContainer.Visible = true
        ContentArea.Visible = true
    end
end)

-- // Close Button
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LeftPanel, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    task.wait(0.2)
    if BlurEffect then BlurEffect:Destroy() end
    ScreenGui:Destroy()
end)

-- // Apply Initial Theme
ApplyTheme("Dark")

-- // Global Export
_G.Milkyway = {
    CreateTab = CreateTab,
    CreateSection = CreateSection,
    CreateLabel = CreateLabel,
    CreateButton = CreateButton,
    CreateToggle = CreateToggle,
    CreateSlider = CreateSlider,
    CreateDropdown = CreateDropdown,
    CreateInput = CreateInput,
    CreateProgress = CreateProgress,
    CreateColorPicker = CreateColorPicker,
    CreateThemeSelector = CreateThemeSelector,
    CreateContextMenu = CreateContextMenu,
    Notify = Notify,
    ApplyTheme = ApplyTheme
}

-- // Welcome Notification
task.wait(0.5)
Notify("Milkyway UI", "Welcome back! Library loaded successfully", "success", 3)
