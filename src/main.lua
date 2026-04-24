--[[
    🌌 MILKYWAY UI - Premium Custom Library
    Version: 4.1 (Netlify Ready)
    Features: Mobile Support, All Executors, Discord-style Notifications
--]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- // ========== SMART GUI PARENT (FIXED FOR ALL EXECUTORS) ==========
local function GetBestParent()
    -- Try gethui (best for most executors)
    local success, result = pcall(function()
        if gethui then
            return gethui()
        end
    end)
    if success and result then
        return result
    end
    
    -- Try CoreGui
    success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    if success and result then
        return result
    end
    
    -- Fallback to PlayerGui
    return Player:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MilkywayUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiParent = GetBestParent()
ScreenGui.Parent = guiParent

-- Protect GUI if possible
pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    elseif protectgui then
        protectgui(ScreenGui)
    elseif setclipboard then
        -- Some executors use this
    end
end)

-- // Mobile Detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local screenSize = workspace.CurrentCamera.ViewportSize

-- // Theme Presets
local Themes = {
    Dark = {
        bg = Color3.fromRGB(10, 10, 18),
        surface = Color3.fromRGB(18, 18, 28),
        primary = Color3.fromRGB(139, 92, 246),
        primaryDark = Color3.fromRGB(124, 58, 237),
        secondary = Color3.fromRGB(39, 39, 52),
        text = Color3.fromRGB(250, 250, 255),
        textSec = Color3.fromRGB(161, 161, 180),
        border = Color3.fromRGB(39, 39, 52),
        success = Color3.fromRGB(34, 197, 94),
        error = Color3.fromRGB(239, 68, 68),
        warning = Color3.fromRGB(245, 158, 11)
    },
    Light = {
        bg = Color3.fromRGB(248, 250, 252),
        surface = Color3.fromRGB(255, 255, 255),
        primary = Color3.fromRGB(99, 102, 241),
        primaryDark = Color3.fromRGB(79, 70, 229),
        secondary = Color3.fromRGB(241, 245, 249),
        text = Color3.fromRGB(15, 23, 42),
        textSec = Color3.fromRGB(100, 116, 139),
        border = Color3.fromRGB(226, 232, 240),
        success = Color3.fromRGB(34, 197, 94),
        error = Color3.fromRGB(239, 68, 68),
        warning = Color3.fromRGB(245, 158, 11)
    },
    Ocean = {
        bg = Color3.fromRGB(4, 30, 45),
        surface = Color3.fromRGB(10, 45, 60),
        primary = Color3.fromRGB(56, 189, 248),
        primaryDark = Color3.fromRGB(14, 165, 233),
        secondary = Color3.fromRGB(25, 60, 75),
        text = Color3.fromRGB(240, 248, 255),
        textSec = Color3.fromRGB(148, 163, 184),
        border = Color3.fromRGB(51, 65, 85),
        success = Color3.fromRGB(34, 197, 94),
        error = Color3.fromRGB(239, 68, 68),
        warning = Color3.fromRGB(245, 158, 11)
    },
    Amethyst = {
        bg = Color3.fromRGB(35, 15, 55),
        surface = Color3.fromRGB(45, 25, 70),
        primary = Color3.fromRGB(192, 132, 252),
        primaryDark = Color3.fromRGB(168, 85, 247),
        secondary = Color3.fromRGB(55, 35, 80),
        text = Color3.fromRGB(250, 240, 255),
        textSec = Color3.fromRGB(200, 170, 230),
        border = Color3.fromRGB(65, 45, 90),
        success = Color3.fromRGB(34, 197, 94),
        error = Color3.fromRGB(239, 68, 68),
        warning = Color3.fromRGB(245, 158, 11)
    },
    Sunset = {
        bg = Color3.fromRGB(45, 20, 35),
        surface = Color3.fromRGB(55, 28, 45),
        primary = Color3.fromRGB(251, 113, 133),
        primaryDark = Color3.fromRGB(244, 63, 94),
        secondary = Color3.fromRGB(65, 38, 55),
        text = Color3.fromRGB(255, 245, 250),
        textSec = Color3.fromRGB(203, 170, 185),
        border = Color3.fromRGB(75, 48, 65),
        success = Color3.fromRGB(34, 197, 94),
        error = Color3.fromRGB(239, 68, 68),
        warning = Color3.fromRGB(245, 158, 11)
    }
}

local CurrentTheme = "Dark"
local BlurEffect = nil
local NotificationQueue = {}
local NotifContainer = nil

-- // Blur Setup
local function SetupBlur(enabled)
    if enabled and not BlurEffect then
        BlurEffect = Instance.new("BlurEffect")
        BlurEffect.Parent = Lighting
        BlurEffect.Size = 8
    elseif not enabled and BlurEffect then
        BlurEffect:Destroy()
        BlurEffect = nil
    end
end
SetupBlur(true)

-- // Mobile Sizes
local windowWidth = isMobile and screenSize.X * 0.85 or 520
local windowHeight = isMobile and screenSize.Y * 0.75 or 500
local leftPanelWidth = isMobile and 70 or 80
local tabWidth = isMobile and 60 or 130

-- // LEFT PANEL
local LeftPanel = Instance.new("Frame")
LeftPanel.Parent = ScreenGui
LeftPanel.Size = UDim2.new(0, leftPanelWidth, 0, windowHeight)
LeftPanel.Position = UDim2.new(0, 0, 0.5, -windowHeight/2)
LeftPanel.BackgroundColor3 = Themes[CurrentTheme].surface
LeftPanel.BackgroundTransparency = 0.15
LeftPanel.BorderSizePixel = 0

local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0, isMobile and 16 or 20)
LeftCorner.Parent = LeftPanel

local LeftStroke = Instance.new("UIStroke")
LeftStroke.Thickness = 1.5
LeftStroke.Transparency = 0.6
LeftStroke.Color = Themes[CurrentTheme].border
LeftStroke.Parent = LeftPanel

-- // Player Avatar
local PlayerIcon = Instance.new("ImageLabel")
PlayerIcon.Parent = LeftPanel
PlayerIcon.Size = UDim2.new(0, isMobile and 50 or 48, 0, isMobile and 50 or 48)
PlayerIcon.Position = UDim2.new(0.5, -25, 0, isMobile and 15 or 20)
PlayerIcon.BackgroundColor3 = Themes[CurrentTheme].primary
PlayerIcon.BackgroundTransparency = 0.3
PlayerIcon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
PlayerIcon.ScaleType = Enum.ScaleType.Fit

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = PlayerIcon

local IconStroke = Instance.new("UIStroke")
IconStroke.Color = Themes[CurrentTheme].primary
IconStroke.Thickness = 3
IconStroke.Parent = PlayerIcon

-- Load player avatar
task.spawn(function()
    local success, result = pcall(function()
        return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if success and result then
        PlayerIcon.Image = result
    end
end)

-- // Player Name
local PlayerNameLabel = Instance.new("TextLabel")
PlayerNameLabel.Parent = LeftPanel
PlayerNameLabel.Size = UDim2.new(1, -10, 0, isMobile and 30 or 24)
PlayerNameLabel.Position = UDim2.new(0, 5, 0, isMobile and 75 or 78)
PlayerNameLabel.BackgroundTransparency = 1
PlayerNameLabel.Text = string.sub(Player.Name, 1, isMobile and 8 or 12)
PlayerNameLabel.TextColor3 = Themes[CurrentTheme].text
PlayerNameLabel.TextSize = isMobile and 10 or 11
PlayerNameLabel.Font = Enum.Font.GothamBold
PlayerNameLabel.TextWrapped = true

-- // Status Dot
local StatusDot = Instance.new("Frame")
StatusDot.Parent = PlayerIcon
StatusDot.Size = UDim2.new(0, isMobile and 12 or 14, 0, isMobile and 12 or 14)
StatusDot.Position = UDim2.new(1, isMobile and -10 or -8, 1, isMobile and -10 or -8)
StatusDot.BackgroundColor3 = Themes[CurrentTheme].success

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusDot

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = Themes[CurrentTheme].surface
StatusStroke.Thickness = 2
StatusStroke.Parent = StatusDot

-- // Notification Container
NotifContainer = Instance.new("Frame")
NotifContainer.Parent = LeftPanel
NotifContainer.Size = UDim2.new(1, -10, 0, windowHeight - (isMobile and 110 or 108))
NotifContainer.Position = UDim2.new(0, 5, 0, isMobile and 100 or 108)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ClipsDescendants = true

local NotifListLayout = Instance.new("UIListLayout")
NotifListLayout.Parent = NotifContainer
NotifListLayout.Padding = UDim.new(0, isMobile and 6 or 8)
NotifListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- // MAIN WINDOW
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, windowWidth, 0, windowHeight)
MainFrame.Position = UDim2.new(0, leftPanelWidth + 10, 0.5, -windowHeight/2)
MainFrame.BackgroundColor3 = Themes[CurrentTheme].bg
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, isMobile and 16 or 20)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.6
MainStroke.Color = Themes[CurrentTheme].border
MainStroke.Parent = MainFrame

-- // Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, isMobile and 50 or 58)
Header.BackgroundTransparency = 1

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Themes[CurrentTheme].primary),
    ColorSequenceKeypoint.new(1, Themes[CurrentTheme].primaryDark)
})
HeaderGradient.Parent = Header

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, isMobile and 16 or 20)
HeaderCorner.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Parent = Header
HeaderTitle.Size = UDim2.new(0, 120, 1, 0)
HeaderTitle.Position = UDim2.new(0, isMobile and 12 or 20, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "MILKYWAY"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextSize = isMobile and 16 or 20
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

local HeaderBadge = Instance.new("Frame")
HeaderBadge.Parent = Header
HeaderBadge.Size = UDim2.new(0, isMobile and 40 or 50, 0, isMobile and 18 or 22)
HeaderBadge.Position = UDim2.new(0, isMobile and 115 or 155, 0.5, isMobile and -9 or -11)
HeaderBadge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderBadge.BackgroundTransparency = 0.25

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, isMobile and 6 or 8)
BadgeCorner.Parent = HeaderBadge

local BadgeText = Instance.new("TextLabel")
BadgeText.Parent = HeaderBadge
BadgeText.Size = UDim2.new(1, 0, 1, 0)
BadgeText.BackgroundTransparency = 1
BadgeText.Text = "v4.1"
BadgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
BadgeText.TextSize = isMobile and 9 or 11
BadgeText.Font = Enum.Font.GothamBold

-- // Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, isMobile and 32 or 38, 0, isMobile and 32 or 38)
CloseBtn.Position = UDim2.new(1, isMobile and -42 or -50, 0.5, isMobile and -16 or -19)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.BackgroundTransparency = 0.15
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = isMobile and 16 or 18
CloseBtn.Font = Enum.Font.GothamBold

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
CloseCorner.Parent = CloseBtn

-- // Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0, isMobile and 32 or 38, 0, isMobile and 32 or 38)
MinBtn.Position = UDim2.new(1, isMobile and -84 or -96, 0.5, isMobile and -16 or -19)
MinBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
MinBtn.BackgroundTransparency = 0.15
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = isMobile and 22 or 24
MinBtn.Font = Enum.Font.GothamBold

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
MinCorner.Parent = MinBtn

-- // Dragging (Touch + Mouse)
local Dragging = false
local DragStart, StartPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)

-- // Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Parent = MainFrame
TabContainer.Size = UDim2.new(0, tabWidth, 1, -58)
TabContainer.Position = UDim2.new(0, 0, 0, 58)
TabContainer.BackgroundColor3 = Themes[CurrentTheme].surface
TabContainer.BackgroundTransparency = 0.15
TabContainer.BorderSizePixel = 0

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 0)
TabCorner.Parent = TabContainer

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabContainer
TabList.Padding = UDim.new(0, isMobile and 6 or 8)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TabPadding = Instance.new("UIPadding")
TabPadding.Parent = TabContainer
TabPadding.PaddingTop = UDim.new(0, isMobile and 15 or 20)

-- // Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -(tabWidth + 10), 1, -72)
ContentArea.Position = UDim2.new(0, tabWidth + 10, 0, 64)
ContentArea.BackgroundTransparency = 1

-- // Tab System
local TabsList = {}
local ActiveTab = nil

local function CreateTab(icon, name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = TabContainer
    TabBtn.Size = UDim2.new(0, tabWidth - 10, 0, isMobile and 40 or 46)
    TabBtn.BackgroundColor3 = Themes[CurrentTheme].surface
    TabBtn.BackgroundTransparency = 0.4
    TabBtn.Text = icon
    TabBtn.TextColor3 = Themes[CurrentTheme].textSec
    TabBtn.TextSize = isMobile and 20 or 24
    TabBtn.Font = Enum.Font.GothamSemibold

    local TabCornerBtn = Instance.new("UICorner")
    TabCornerBtn.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    TabCornerBtn.Parent = TabBtn

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Parent = ContentArea
    TabFrame.Size = UDim2.new(1, -10, 1, 0)
    TabFrame.Position = UDim2.new(0, 5, 0, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.ScrollBarThickness = isMobile and 3 or 4
    TabFrame.ScrollBarImageColor3 = Themes[CurrentTheme].primary
    TabFrame.Visible = false

    local FrameLayout = Instance.new("UIListLayout")
    FrameLayout.Parent = TabFrame
    FrameLayout.Padding = UDim.new(0, isMobile and 8 or 12)
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
    Section.Size = UDim2.new(1, -16, 0, description and (isMobile and 55 or 60) or (isMobile and 40 or 45))
    Section.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel")
    Title.Parent = Section
    Title.Size = UDim2.new(1, 0, 0, isMobile and 22 or 24)
    Title.Position = UDim2.new(0, 8, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Themes[CurrentTheme].text
    Title.TextSize = isMobile and 15 or 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left

    if description then
        local Desc = Instance.new("TextLabel")
        Desc.Parent = Section
        Desc.Size = UDim2.new(1, 0, 0, isMobile and 18 or 20)
        Desc.Position = UDim2.new(0, 8, 0, isMobile and 24 or 26)
        Desc.BackgroundTransparency = 1
        Desc.Text = description
        Desc.TextColor3 = Themes[CurrentTheme].textSec
        Desc.TextSize = isMobile and 11 or 12
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
    end

    local Line = Instance.new("Frame")
    Line.Parent = Section
    Line.Size = UDim2.new(1, -16, 0, 2)
    Line.Position = UDim2.new(0, 8, 0, description and (isMobile and 52 or 55) or (isMobile and 37 or 40))
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
    Label.Size = UDim2.new(1, -16, 0, isMobile and 28 or 32)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = color or Themes[CurrentTheme].textSec
    Label.TextSize = isMobile and 12 or 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    return Label
end

-- // Button
local function CreateButton(parent, text, icon, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, -16, 0, isMobile and 44 or 48)
    Btn.BackgroundColor3 = Themes[CurrentTheme].surface
    Btn.BackgroundTransparency = 0.2
    Btn.Text = icon and icon .. "   " .. text or text
    Btn.TextColor3 = Themes[CurrentTheme].text
    Btn.TextSize = isMobile and 13 or 14
    Btn.Font = Enum.Font.Gotham
    Btn.TextXAlignment = Enum.TextXAlignment.Center

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    BtnCorner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
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
    ToggleFrame.Size = UDim2.new(1, -16, 0, isMobile and 48 or 52)
    ToggleFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    ToggleFrame.BackgroundTransparency = 0.2

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    ToggleCorner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Themes[CurrentTheme].text
    Label.TextSize = isMobile and 13 or 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Track = Instance.new("Frame")
    Track.Parent = ToggleFrame
    Track.Size = UDim2.new(0, isMobile and 48 or 52, 0, isMobile and 24 or 28)
    Track.Position = UDim2.new(1, isMobile and -60 or -68, 0.5, isMobile and -12 or -14)
    Track.BackgroundColor3 = default and Themes[CurrentTheme].primary or Color3.fromRGB(55, 55, 75)

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Knob = Instance.new("Frame")
    Knob.Parent = Track
    Knob.Size = UDim2.new(0, isMobile and 20 or 22, 0, isMobile and 20 or 22)
    Knob.Position = default and UDim2.new(1, isMobile and -24 or -26, 0.5, isMobile and -10 or -11) or UDim2.new(0, 4, 0.5, isMobile and -10 or -11)
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
        local targetPos = toggled and UDim2.new(1, isMobile and -24 or -26, 0.5, isMobile and -10 or -11) or UDim2.new(0, 4, 0.5, isMobile and -10 or -11)
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
        if callback then callback(toggled) end
    end)

    return ToggleFrame
end

-- // Slider
local function CreateSlider(parent, text, min, max, default, suffix, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Parent = parent
    SliderFrame.Size = UDim2.new(1, -16, 0, isMobile and 80 or 85)
    SliderFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    SliderFrame.BackgroundTransparency = 0.2

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    SliderCorner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.Size = UDim2.new(0.55, 0, 0, isMobile and 26 or 28)
    Label.Position = UDim2.new(0, 16, 0, isMobile and 8 or 10)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Themes[CurrentTheme].text
    Label.TextSize = isMobile and 13 or 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = SliderFrame
    ValueLabel.Size = UDim2.new(0.35, 0, 0, isMobile and 26 or 28)
    ValueLabel.Position = UDim2.new(0.55, 0, 0, isMobile and 8 or 10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default) .. (suffix or "")
    ValueLabel.TextColor3 = Themes[CurrentTheme].primary
    ValueLabel.TextSize = isMobile and 13 or 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Track = Instance.new("Frame")
    Track.Parent = SliderFrame
    Track.Size = UDim2.new(1, -32, 0, isMobile and 4 or 5)
    Track.Position = UDim2.new(0, 16, 0, isMobile and 48 or 52)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    return SliderFrame
end

-- // Dropdown
local function CreateDropdown(parent, text, options, callback)
    local DropFrame = Instance.new("Frame")
    DropFrame.Parent = parent
    DropFrame.Size = UDim2.new(1, -16, 0, isMobile and 48 or 52)
    DropFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    DropFrame.BackgroundTransparency = 0.2

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    DropCorner.Parent = DropFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = DropFrame
    Label.Size = UDim2.new(0.45, 0, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Themes[CurrentTheme].text
    Label.TextSize = isMobile and 13 or 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local DropBtn = Instance.new("TextButton")
    DropBtn.Parent = DropFrame
    DropBtn.Size = UDim2.new(0, isMobile and 120 or 140, 0, isMobile and 32 or 36)
    DropBtn.Position = UDim2.new(1, isMobile and -130 or -156, 0.5, isMobile and -16 or -18)
    DropBtn.BackgroundColor3 = Themes[CurrentTheme].secondary
    DropBtn.Text = options[1]
    DropBtn.TextColor3 = Themes[CurrentTheme].text
    DropBtn.TextSize = isMobile and 12 or 13
    DropBtn.Font = Enum.Font.Gotham

    local DropBtnCorner = Instance.new("UICorner")
    DropBtnCorner.CornerRadius = UDim.new(0, isMobile and 6 or 8)
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
        DropList.Size = UDim2.new(0, isMobile and 120 or 140, 0, #options * (isMobile and 32 or 36))
        DropList.Position = UDim2.new(1, isMobile and -130 or -156, 0, isMobile and 40 or 44)
        DropList.BackgroundColor3 = Themes[CurrentTheme].surface
        DropList.BackgroundTransparency = 0.1

        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, isMobile and 6 or 8)
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
            OptBtn.Size = UDim2.new(1, 0, 0, isMobile and 30 or 34)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = opt
            OptBtn.TextColor3 = Themes[CurrentTheme].textSec
            OptBtn.TextSize = isMobile and 11 or 12
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
    InputFrame.Size = UDim2.new(1, -16, 0, isMobile and 48 or 52)
    InputFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    InputFrame.BackgroundTransparency = 0.2

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    InputCorner.Parent = InputFrame

    local InputBox = Instance.new("TextBox")
    InputBox.Parent = InputFrame
    InputBox.Size = UDim2.new(1, -32, 0, isMobile and 32 or 36)
    InputBox.Position = UDim2.new(0, 16, 0.5, isMobile and -16 or -18)
    InputBox.BackgroundColor3 = Themes[CurrentTheme].secondary
    InputBox.PlaceholderText = placeholder
    InputBox.Text = ""
    InputBox.TextColor3 = Themes[CurrentTheme].text
    InputBox.PlaceholderColor3 = Themes[CurrentTheme].textSec
    InputBox.TextSize = isMobile and 13 or 14
    InputBox.Font = Enum.Font.Gotham
    InputBox.ClearTextOnFocus = false

    local InputCornerBox = Instance.new("UICorner")
    InputCornerBox.CornerRadius = UDim.new(0, isMobile and 6 or 8)
    InputCornerBox.Parent = InputBox

    InputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(InputBox.Text)
        end
    end)

    return InputFrame
end

-- // Theme Selector
local function CreateThemeSelector(parent)
    local ThemeFrame = Instance.new("Frame")
    ThemeFrame.Parent = parent
    ThemeFrame.Size = UDim2.new(1, -16, 0, isMobile and 120 or 140)
    ThemeFrame.BackgroundColor3 = Themes[CurrentTheme].surface
    ThemeFrame.BackgroundTransparency = 0.2

    local ThemeCorner = Instance.new("UICorner")
    ThemeCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    ThemeCorner.Parent = ThemeFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ThemeFrame
    Label.Size = UDim2.new(1, 0, 0, isMobile and 28 or 32)
    Label.Position = UDim2.new(0, 16, 0, isMobile and 8 or 10)
    Label.BackgroundTransparency = 1
    Label.Text = "Theme"
    Label.TextColor3 = Themes[CurrentTheme].text
    Label.TextSize = isMobile and 13 or 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local themeList = {"Dark", "Light", "Ocean", "Amethyst", "Sunset"}
    local btnWidth = (ThemeFrame.AbsoluteSize.X - 32) / 5

    for i, name in ipairs(themeList) do
        local ThemeBtn = Instance.new("TextButton")
        ThemeBtn.Parent = ThemeFrame
        ThemeBtn.Size = UDim2.new(0, btnWidth - (isMobile and 6 or 8), 0, isMobile and 38 or 44)
        ThemeBtn.Position = UDim2.new(0, 16 + ((i-1) * btnWidth), 0, isMobile and 50 or 58)
        ThemeBtn.BackgroundColor3 = Themes[name].primary
        ThemeBtn.BackgroundTransparency = 0.25
        ThemeBtn.Text = name
        ThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ThemeBtn.TextSize = isMobile and 9 or 11
        ThemeBtn.Font = Enum.Font.GothamBold

        local BtnCornerTheme = Instance.new("UICorner")
        BtnCornerTheme.CornerRadius = UDim.new(0, isMobile and 6 or 8)
        BtnCornerTheme.Parent = ThemeBtn

        ThemeBtn.MouseButton1Click:Connect(function()
            ApplyTheme(name)
        end)
    end

    return ThemeFrame
end

-- // DISCORD-STYLE NOTIFICATION
local function Notify(title, message, type, duration)
    local notifType = type or "info"
    local notifColor = Themes[CurrentTheme][notifType] or Themes[CurrentTheme].primary

    local Notification = Instance.new("Frame")
    Notification.Parent = NotifContainer
    Notification.Size = UDim2.new(1, 0, 0, isMobile and 65 or 72)
    Notification.BackgroundColor3 = Themes[CurrentTheme].surface
    Notification.BackgroundTransparency = 0.05
    Notification.ClipsDescendants = true

    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    NotifCorner.Parent = Notification

    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = notifColor
    NotifStroke.Thickness = 1.5
    NotifStroke.Transparency = 0.5
    NotifStroke.Parent = Notification

    local AccentBar = Instance.new("Frame")
    AccentBar.Parent = Notification
    AccentBar.Size = UDim2.new(0, 4, 1, 0)
    AccentBar.BackgroundColor3 = notifColor

    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 4)
    AccentCorner.Parent = AccentBar

    local Avatar = Instance.new("Frame")
    Avatar.Parent = Notification
    Avatar.Size = UDim2.new(0, isMobile and 30 or 36, 0, isMobile and 30 or 36)
    Avatar.Position = UDim2.new(0, isMobile and 10 or 12, 0.5, isMobile and -15 or -18)
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
    AvatarIcon.TextSize = isMobile and 18 or 20
    AvatarIcon.Font = Enum.Font.GothamBold

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Notification
    TitleLabel.Size = UDim2.new(1, -50, 0, isMobile and 20 or 22)
    TitleLabel.Position = UDim2.new(0, isMobile and 50 or 60, 0, isMobile and 8 or 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Themes[CurrentTheme].text
    TitleLabel.TextSize = isMobile and 12 or 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Timestamp = Instance.new("TextLabel")
    Timestamp.Parent = Notification
    Timestamp.Size = UDim2.new(0, 70, 0, isMobile and 14 or 16)
    Timestamp.Position = UDim2.new(1, -75, 0, isMobile and 10 or 12)
    Timestamp.BackgroundTransparency = 1
    local currentTime = os.date("%I:%M %p"):gsub("^0", "")
    Timestamp.Text = currentTime
    Timestamp.TextColor3 = Themes[CurrentTheme].textSec
    Timestamp.TextSize = isMobile and 9 or 10
    Timestamp.Font = Enum.Font.Gotham
    Timestamp.TextXAlignment = Enum.TextXAlignment.Right

    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Parent = Notification
    MsgLabel.Size = UDim2.new(1, -50, 0, isMobile and 24 or 28)
    MsgLabel.Position = UDim2.new(0, isMobile and 50 or 60, 0, isMobile and 30 or 34)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = message
    MsgLabel.TextColor3 = Themes[CurrentTheme].textSec
    MsgLabel.TextSize = isMobile and 11 or 12
    MsgLabel.Font = Enum.Font.Gotham
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    MsgLabel.TextWrapped = true
    MsgLabel.TextYAlignment = Enum.TextYAlignment.Top

    task.wait(duration or 5)

    if Notification and Notification.Parent then
        TweenService:Create(Notification, TweenInfo.new(0.25), {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, -10)}):Play()
        task.wait(0.25)
        Notification:Destroy()
    end
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
    TweenService:Create(PlayerNameLabel, TweenInfo.new(0.25), {TextColor3 = theme.text}):Play()

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
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, windowWidth, 0, isMobile and 50 or 58)}):Play()
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
    CreateThemeSelector = CreateThemeSelector,
    Notify = Notify,
    ApplyTheme = ApplyTheme,
    IsMobile = isMobile
}

-- // Welcome Notification
task.wait(0.5)
Notify("Milkyway UI", "Library loaded successfully" .. (isMobile and " (Mobile Mode)" or ""), "success", 2)

-- // Print to console that it loaded
print("🌌 Milkyway UI v4.1 loaded! Use _G.Milkyway to access the library")
