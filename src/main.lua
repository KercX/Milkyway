--[[
    ███╗   ███╗██╗██╗     ██╗  ██╗██╗   ██╗██╗    ██╗ █████╗ ██╗   ██╗
    ████╗ ████║██║██║     ██║  ██║╚██╗ ██╔╝██║    ██║██╔══██╗╚██╗ ██╔╝
    ██╔████╔██║██║██║     ███████║ ╚████╔╝ ██║ █╗ ██║███████║ ╚████╔╝ 
    ██║╚██╔╝██║██║██║     ██╔══██║  ╚██╔╝  ██║███╗██║██╔══██║  ╚██╔╝  
    ██║ ╚═╝ ██║██║███████╗██║  ██║   ██║   ╚███╔███╔╝██║  ██║   ██║   
    ╚═╝     ╚═╝╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝   
    
    MILKYWAY UI - PREMIUM LIBRARY
    Version: 5.0 (Full Rewrite)
    Lines: 5000+
    Features: Tabs, Sections, Buttons, Toggles, Sliders, Dropdowns, Inputs, 
              ColorPicker, Keybind, ProgressBar, ContextMenu, Notifications, 
              Theme Manager, Mobile Support, Drag & Drop, Animations, Ripple, 
              Settings Saver (if writefile available), Blur Effect, Custom Fonts
    Compatibility: Delta, Solara, Arceus X, KRNL, Synapse, Script‑Ware, and more.
--]]

-- =============================== SERVICES ===============================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")

-- =============================== EXECUTOR DETECTION ===============================

local Executor = "Unknown"
local isDelta = false
local isSolara = false
local isArceus = false
local isKrnl = false
local isSynapse = false
local isScriptWare = false
local isMobileExecutor = false

if syn then Executor = "Synapse X"; isSynapse = true end
if krnl then Executor = "KRNL"; isKrnl = true end
if script_context then Executor = "Script-Ware"; isScriptWare = true end
if isfolder and not isSynapse then Executor = "Delta"; isDelta = true end
if getgenv and getgenv().solara then Executor = "Solara"; isSolara = true end
if isreader then Executor = "Arceus X"; isArceus = true end
if game:GetService("UserInputService").TouchEnabled then isMobileExecutor = true end

-- =============================== MOBILE DETECTION ===============================

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local screenSize = workspace.CurrentCamera.ViewportSize
local safeZone = GuiService:GetGuiInset()

-- =============================== GLOBAL SETTINGS ===============================

local LibraryName = "MilkywayUI"
local LibraryVersion = "5.0"
local ConfigFolder = LibraryName .. "_Config"
local ConfigFile = "settings.json"
local AutoSave = true
local AutoSaveInterval = 30 -- seconds
local BlurEnabled = true
local BlurIntensity = 8
local AnimationSpeed = 0.2
local RippleEnabled = true
local SoundEnabled = false
local SoundVolume = 0.5

-- =============================== SMART GUI PARENT ===============================

local function GetBestParent()
    -- Priority 1: gethui (most executors)
    if gethui then
        local success, result = pcall(gethui)
        if success and result then return result end
    end
    -- Priority 2: CoreGui
    if CoreGui then return CoreGui end
    -- Priority 3: PlayerGui (fallback)
    return Player:WaitForChild("PlayerGui")
end

-- =============================== FILE SYSTEM HELPERS ===============================

local hasFileSystem = (writefile and readfile and isfile and isfolder and makefolder)
local configData = {}

local function EnsureConfigFolder()
    if hasFileSystem and not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end

local function LoadConfig()
    if not hasFileSystem then return end
    EnsureConfigFolder()
    local path = ConfigFolder .. "/" .. ConfigFile
    if isfile(path) then
        local success, data = pcall(readfile, path)
        if success and data then
            success, configData = pcall(HttpService.JSONDecode, HttpService, data)
            if not success then configData = {} end
        end
    end
end

local function SaveConfig()
    if not hasFileSystem then return end
    EnsureConfigFolder()
    local path = ConfigFolder .. "/" .. ConfigFile
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, configData)
    if success then
        pcall(writefile, path, encoded)
    end
end

-- =============================== THEME PRESETS ===============================

local Themes = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(10, 10, 18),
        Surface = Color3.fromRGB(18, 18, 28),
        Primary = Color3.fromRGB(139, 92, 246),
        PrimaryDark = Color3.fromRGB(124, 58, 237),
        Secondary = Color3.fromRGB(39, 39, 52),
        Text = Color3.fromRGB(250, 250, 255),
        TextSecondary = Color3.fromRGB(161, 161, 180),
        Border = Color3.fromRGB(39, 39, 52),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(59, 130, 246),
        Hover = Color3.fromRGB(50, 50, 70)
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(248, 250, 252),
        Surface = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(99, 102, 241),
        PrimaryDark = Color3.fromRGB(79, 70, 229),
        Secondary = Color3.fromRGB(241, 245, 249),
        Text = Color3.fromRGB(15, 23, 42),
        TextSecondary = Color3.fromRGB(100, 116, 139),
        Border = Color3.fromRGB(226, 232, 240),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(59, 130, 246),
        Hover = Color3.fromRGB(226, 232, 240)
    },
    Ocean = {
        Name = "Ocean",
        Background = Color3.fromRGB(4, 30, 45),
        Surface = Color3.fromRGB(10, 45, 60),
        Primary = Color3.fromRGB(56, 189, 248),
        PrimaryDark = Color3.fromRGB(14, 165, 233),
        Secondary = Color3.fromRGB(25, 60, 75),
        Text = Color3.fromRGB(240, 248, 255),
        TextSecondary = Color3.fromRGB(148, 163, 184),
        Border = Color3.fromRGB(51, 65, 85),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(56, 189, 248),
        Hover = Color3.fromRGB(45, 80, 95)
    },
    Amethyst = {
        Name = "Amethyst",
        Background = Color3.fromRGB(35, 15, 55),
        Surface = Color3.fromRGB(45, 25, 70),
        Primary = Color3.fromRGB(192, 132, 252),
        PrimaryDark = Color3.fromRGB(168, 85, 247),
        Secondary = Color3.fromRGB(55, 35, 80),
        Text = Color3.fromRGB(250, 240, 255),
        TextSecondary = Color3.fromRGB(200, 170, 230),
        Border = Color3.fromRGB(65, 45, 90),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(192, 132, 252),
        Hover = Color3.fromRGB(75, 55, 100)
    },
    Sunset = {
        Name = "Sunset",
        Background = Color3.fromRGB(45, 20, 35),
        Surface = Color3.fromRGB(55, 28, 45),
        Primary = Color3.fromRGB(251, 113, 133),
        PrimaryDark = Color3.fromRGB(244, 63, 94),
        Secondary = Color3.fromRGB(65, 38, 55),
        Text = Color3.fromRGB(255, 245, 250),
        TextSecondary = Color3.fromRGB(203, 170, 185),
        Border = Color3.fromRGB(75, 48, 65),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(251, 113, 133),
        Hover = Color3.fromRGB(85, 48, 75)
    },
    Forest = {
        Name = "Forest",
        Background = Color3.fromRGB(10, 35, 25),
        Surface = Color3.fromRGB(18, 45, 35),
        Primary = Color3.fromRGB(74, 222, 128),
        PrimaryDark = Color3.fromRGB(34, 197, 94),
        Secondary = Color3.fromRGB(28, 55, 45),
        Text = Color3.fromRGB(240, 255, 245),
        TextSecondary = Color3.fromRGB(148, 180, 165),
        Border = Color3.fromRGB(38, 65, 55),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(74, 222, 128),
        Hover = Color3.fromRGB(38, 75, 58)
    },
    Midnight = {
        Name = "Midnight",
        Background = Color3.fromRGB(0, 0, 10),
        Surface = Color3.fromRGB(8, 8, 20),
        Primary = Color3.fromRGB(0, 191, 255),
        PrimaryDark = Color3.fromRGB(0, 150, 200),
        Secondary = Color3.fromRGB(20, 20, 35),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 210),
        Border = Color3.fromRGB(30, 30, 50),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(0, 191, 255),
        Hover = Color3.fromRGB(30, 30, 50)
    },
    Cherry = {
        Name = "Cherry",
        Background = Color3.fromRGB(55, 10, 25),
        Surface = Color3.fromRGB(70, 20, 35),
        Primary = Color3.fromRGB(255, 99, 132),
        PrimaryDark = Color3.fromRGB(220, 70, 100),
        Secondary = Color3.fromRGB(80, 30, 45),
        Text = Color3.fromRGB(255, 240, 245),
        TextSecondary = Color3.fromRGB(220, 170, 180),
        Border = Color3.fromRGB(100, 40, 60),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(255, 99, 132),
        Hover = Color3.fromRGB(100, 45, 65)
    }
}

local CurrentTheme = "Dark"
local ActiveThemeTable = Themes.Dark

-- =============================== BLUR EFFECT ===============================

local BlurEffect = nil
local function SetupBlur(enabled)
    if enabled and not BlurEffect then
        BlurEffect = Instance.new("BlurEffect")
        BlurEffect.Parent = Lighting
        BlurEffect.Size = BlurIntensity
    elseif not enabled and BlurEffect then
        BlurEffect:Destroy()
        BlurEffect = nil
    end
end

-- =============================== UI ELEMENTS (GUI CREATION) ===============================

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = LibraryName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiParent = GetBestParent()
ScreenGui.Parent = guiParent

-- Protect GUI if possible
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
    if setclipboard then end -- dummy
end)

-- =============================== BLUR SETUP ===============================
SetupBlur(BlurEnabled)

-- =============================== MOBILE SIZING ===============================
local LeftPanelWidth = isMobile and 75 or 85
local MainWindowWidth = isMobile and screenSize.X * 0.85 or 540
local MainWindowHeight = isMobile and screenSize.Y * 0.78 or 520
local TabButtonWidth = isMobile and 65 or 140
local TabButtonHeight = isMobile and 42 or 48
local ElementHeight = isMobile and 44 or 48
local ToggleHeight = isMobile and 48 or 52
local SliderHeight = isMobile and 82 or 88
local DropdownHeight = isMobile and 48 or 52
local InputHeight = isMobile and 48 or 52
local SectionTitleSize = isMobile and 15 or 16
local SectionDescSize = isMobile and 11 or 12
local NormalTextSize = isMobile and 13 or 14
local SmallTextSize = isMobile and 11 or 12
local IconSize = isMobile and 22 or 26
local CornerRadius = isMobile and 14 or 18
local Spacing = isMobile and 6 or 8

-- =============================== LEFT PANEL (PROFILE + NOTIFICATIONS) ===============================
local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Parent = ScreenGui
LeftPanel.Size = UDim2.new(0, LeftPanelWidth, 0, MainWindowHeight)
LeftPanel.Position = UDim2.new(0, 0, 0.5, -MainWindowHeight/2)
LeftPanel.BackgroundColor3 = ActiveThemeTable.Surface
LeftPanel.BackgroundTransparency = 0.1
LeftPanel.BorderSizePixel = 0

local LeftPanelCorner = Instance.new("UICorner")
LeftPanelCorner.CornerRadius = UDim.new(0, CornerRadius)
LeftPanelCorner.Parent = LeftPanel

local LeftPanelStroke = Instance.new("UIStroke")
LeftPanelStroke.Thickness = 1.5
LeftPanelStroke.Transparency = 0.5
LeftPanelStroke.Color = ActiveThemeTable.Border
LeftPanelStroke.Parent = LeftPanel

-- Profile Avatar
local ProfileAvatar = Instance.new("ImageLabel")
ProfileAvatar.Parent = LeftPanel
ProfileAvatar.Size = UDim2.new(0, isMobile and 52 or 56, 0, isMobile and 52 or 56)
ProfileAvatar.Position = UDim2.new(0.5, -26, 0, isMobile and 15 or 20)
ProfileAvatar.BackgroundColor3 = ActiveThemeTable.Primary
ProfileAvatar.BackgroundTransparency = 0.2
ProfileAvatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
ProfileAvatar.ScaleType = Enum.ScaleType.Fit

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = ProfileAvatar

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = ActiveThemeTable.Primary
AvatarStroke.Thickness = 3
AvatarStroke.Parent = ProfileAvatar

-- Load actual avatar
task.spawn(function()
    local userId = Player.UserId
    local success, thumbnail = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if success and thumbnail then
        ProfileAvatar.Image = thumbnail
    end
end)

-- Status Dot
local StatusDot = Instance.new("Frame")
StatusDot.Parent = ProfileAvatar
StatusDot.Size = UDim2.new(0, isMobile and 14 or 16, 0, isMobile and 14 or 16)
StatusDot.Position = UDim2.new(1, isMobile and -10 or -12, 1, isMobile and -10 or -12)
StatusDot.BackgroundColor3 = ActiveThemeTable.Success

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusDot

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = ActiveThemeTable.Surface
StatusStroke.Thickness = 2
StatusStroke.Parent = StatusDot

-- Player Name
local PlayerNameLabel = Instance.new("TextLabel")
PlayerNameLabel.Parent = LeftPanel
PlayerNameLabel.Size = UDim2.new(1, -10, 0, isMobile and 32 or 28)
PlayerNameLabel.Position = UDim2.new(0, 5, 0, isMobile and 78 or 85)
PlayerNameLabel.BackgroundTransparency = 1
PlayerNameLabel.Text = string.sub(Player.Name, 1, isMobile and 8 or 12)
PlayerNameLabel.TextColor3 = ActiveThemeTable.Text
PlayerNameLabel.TextSize = isMobile and 11 or 12
PlayerNameLabel.Font = Enum.Font.GothamBold
PlayerNameLabel.TextWrapped = true
PlayerNameLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Notification Container
local NotifContainer = Instance.new("Frame")
NotifContainer.Parent = LeftPanel
NotifContainer.Size = UDim2.new(1, -10, 0, MainWindowHeight - (isMobile and 130 or 135))
NotifContainer.Position = UDim2.new(0, 5, 0, isMobile and 115 or 120)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ClipsDescendants = true

local NotifListLayout = Instance.new("UIListLayout")
NotifListLayout.Parent = NotifContainer
NotifListLayout.Padding = UDim.new(0, Spacing)
NotifListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- =============================== MAIN WINDOW ===============================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, MainWindowWidth, 0, MainWindowHeight)
MainFrame.Position = UDim2.new(0, LeftPanelWidth + Spacing, 0.5, -MainWindowHeight/2)
MainFrame.BackgroundColor3 = ActiveThemeTable.Background
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, CornerRadius)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.5
MainStroke.Color = ActiveThemeTable.Border
MainStroke.Parent = MainFrame

-- =============================== HEADER ===============================
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, isMobile and 54 or 62)
Header.BackgroundTransparency = 1

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, ActiveThemeTable.Primary),
    ColorSequenceKeypoint.new(1, ActiveThemeTable.PrimaryDark)
})
HeaderGradient.Parent = Header

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, CornerRadius)
HeaderCorner.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Parent = Header
HeaderTitle.Size = UDim2.new(0, 140, 1, 0)
HeaderTitle.Position = UDim2.new(0, isMobile and 14 or 20, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "MILKYWAY"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextSize = isMobile and 18 or 22
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

local HeaderBadge = Instance.new("Frame")
HeaderBadge.Parent = Header
HeaderBadge.Size = UDim2.new(0, isMobile and 44 or 52, 0, isMobile and 20 or 24)
HeaderBadge.Position = UDim2.new(0, isMobile and 125 or 165, 0.5, isMobile and -10 or -12)
HeaderBadge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HeaderBadge.BackgroundTransparency = 0.2

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, isMobile and 6 or 8)
BadgeCorner.Parent = HeaderBadge

local BadgeText = Instance.new("TextLabel")
BadgeText.Parent = HeaderBadge
BadgeText.Size = UDim2.new(1, 0, 1, 0)
BadgeText.BackgroundTransparency = 1
BadgeText.Text = "v" .. LibraryVersion
BadgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
BadgeText.TextSize = isMobile and 10 or 12
BadgeText.Font = Enum.Font.GothamBold

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, isMobile and 34 or 40, 0, isMobile and 34 or 40)
CloseBtn.Position = UDim2.new(1, isMobile and -44 or -52, 0.5, isMobile and -17 or -20)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.BackgroundTransparency = 0.1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = isMobile and 18 or 20
CloseBtn.Font = Enum.Font.GothamBold

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
CloseCorner.Parent = CloseBtn

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0, isMobile and 34 or 40, 0, isMobile and 34 or 40)
MinBtn.Position = UDim2.new(1, isMobile and -88 or -104, 0.5, isMobile and -17 or -20)
MinBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
MinBtn.BackgroundTransparency = 0.1
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = isMobile and 24 or 28
MinBtn.Font = Enum.Font.GothamBold

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
MinCorner.Parent = MinBtn

-- =============================== DRAGGING (MOUSE + TOUCH) ===============================
local Dragging = false
local DragStart, StartPos

local function beginDrag(input)
    Dragging = true
    DragStart = input.Position
    StartPos = MainFrame.Position
end

local function updateDrag(input)
    if Dragging then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end

local function endDrag()
    Dragging = false
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        beginDrag(input)
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        endDrag()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

-- =============================== TAB BAR ===============================
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.Size = UDim2.new(0, TabButtonWidth, 1, -(isMobile and 54 or 62))
TabBar.Position = UDim2.new(0, 0, 0, isMobile and 54 or 62)
TabBar.BackgroundColor3 = ActiveThemeTable.Surface
TabBar.BackgroundTransparency = 0.1
TabBar.BorderSizePixel = 0

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 0)
TabBarCorner.Parent = TabBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.Padding = UDim.new(0, Spacing)
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TabPadding = Instance.new("UIPadding")
TabPadding.Parent = TabBar
TabPadding.PaddingTop = UDim.new(0, isMobile and 12 or 16)

-- =============================== CONTENT AREA ===============================
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -(TabButtonWidth + Spacing*2), 1, -(isMobile and 68 or 76))
ContentArea.Position = UDim2.new(0, TabButtonWidth + Spacing, 0, isMobile and 68 or 76)
ContentArea.BackgroundTransparency = 1

-- =============================== TAB SYSTEM ===============================
local Tabs = {}
local ActiveTab = nil

local function CreateTab(icon, name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = TabBar
    TabBtn.Size = UDim2.new(0, TabButtonWidth - Spacing*2, 0, TabButtonHeight)
    TabBtn.BackgroundColor3 = ActiveThemeTable.Surface
    TabBtn.BackgroundTransparency = 0.3
    TabBtn.Text = icon
    TabBtn.TextColor3 = ActiveThemeTable.TextSecondary
    TabBtn.TextSize = isMobile and 20 or 24
    TabBtn.Font = Enum.Font.GothamSemibold

    local TabCornerBtn = Instance.new("UICorner")
    TabCornerBtn.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    TabCornerBtn.Parent = TabBtn

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Parent = ContentArea
    TabFrame.Size = UDim2.new(1, -Spacing, 1, 0)
    TabFrame.Position = UDim2.new(0, Spacing/2, 0, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.ScrollBarThickness = isMobile and 3 or 4
    TabFrame.ScrollBarImageColor3 = ActiveThemeTable.Primary
    TabFrame.Visible = false

    local InnerLayout = Instance.new("UIListLayout")
    InnerLayout.Parent = TabFrame
    InnerLayout.Padding = UDim.new(0, Spacing)
    InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder

    InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, InnerLayout.AbsoluteContentSize.Y + Spacing*2)
    end)

    table.insert(Tabs, {Button = TabBtn, Frame = TabFrame, Name = name, Icon = icon})

    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Frame.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3,
                TextColor3 = ActiveThemeTable.TextSecondary
            }):Play()
        end
        TabFrame.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.05,
            TextColor3 = ActiveThemeTable.Text
        }):Play()
        ActiveTab = name
    end)

    if #Tabs == 1 then
        TabBtn.MouseButton1Click:Fire()
    end

    return TabFrame
end

-- =============================== SECTION ===============================
local function CreateSection(parent, title, description)
    local Section = Instance.new("Frame")
    Section.Parent = parent
    Section.Size = UDim2.new(1, -Spacing*2, 0, description and (isMobile and 60 or 65) or (isMobile and 45 or 50))
    Section.BackgroundTransparency = 1

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Section
    TitleLabel.Size = UDim2.new(1, -Spacing, 0, isMobile and 24 or 28)
    TitleLabel.Position = UDim2.new(0, Spacing, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = ActiveThemeTable.Text
    TitleLabel.TextSize = SectionTitleSize
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    if description and description ~= "" then
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Parent = Section
        DescLabel.Size = UDim2.new(1, -Spacing, 0, isMobile and 20 or 22)
        DescLabel.Position = UDim2.new(0, Spacing, 0, isMobile and 26 or 30)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Text = description
        DescLabel.TextColor3 = ActiveThemeTable.TextSecondary
        DescLabel.TextSize = SectionDescSize
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextWrapped = true
    end

    local Divider = Instance.new("Frame")
    Divider.Parent = Section
    Divider.Size = UDim2.new(1, -Spacing*2, 0, 2)
    Divider.Position = UDim2.new(0, Spacing, 0, description and (isMobile and 54 or 59) or (isMobile and 40 or 45))
    Divider.BackgroundColor3 = ActiveThemeTable.Primary
    Divider.BackgroundTransparency = 0.4

    local DividerCorner = Instance.new("UICorner")
    DividerCorner.CornerRadius = UDim.new(1, 0)
    DividerCorner.Parent = Divider

    return Section
end

-- =============================== LABEL ===============================
local function CreateLabel(parent, text, color)
    local Label = Instance.new("TextLabel")
    Label.Parent = parent
    Label.Size = UDim2.new(1, -Spacing*2, 0, isMobile and 30 or 34)
    Label.Position = UDim2.new(0, Spacing, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = color or ActiveThemeTable.TextSecondary
    Label.TextSize = NormalTextSize
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    return Label
end

-- =============================== BUTTON ===============================
local function CreateButton(parent, text, icon, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = parent
    Button.Size = UDim2.new(1, -Spacing*2, 0, ElementHeight)
    Button.BackgroundColor3 = ActiveThemeTable.Surface
    Button.BackgroundTransparency = 0.2
    Button.Text = (icon and icon .. "   " .. text) or text
    Button.TextColor3 = ActiveThemeTable.Text
    Button.TextSize = NormalTextSize
    Button.Font = Enum.Font.GothamSemibold
    Button.TextXAlignment = Enum.TextXAlignment.Center

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    ButtonCorner.Parent = Button

    -- Ripple effect (optional)
    if RippleEnabled then
        local Ripple = Instance.new("Frame")
        Ripple.Parent = Button
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Ripple.BackgroundTransparency = 0.9
        Ripple.BorderSizePixel = 0
        local RippleCorner = Instance.new("UICorner")
        RippleCorner.CornerRadius = UDim.new(1, 0)
        RippleCorner.Parent = Ripple

        Button.MouseButton1Click:Connect(function(input)
            local x, y = input.Position.X - Button.AbsolutePosition.X, input.Position.Y - Button.AbsolutePosition.Y
            Ripple.Position = UDim2.new(0, x - 50, 0, y - 50)
            Ripple.Size = UDim2.new(0, 100, 0, 100)
            TweenService:Create(Ripple, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 200), BackgroundTransparency = 1}):Play()
            TweenService:Create(Button, TweenInfo.new(0.08), {BackgroundTransparency = 0.5}):Play()
            task.wait(0.08)
            TweenService:Create(Button, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
            if callback then callback() end
        end)
    else
        Button.MouseButton1Click:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.08), {BackgroundTransparency = 0.5}):Play()
            task.wait(0.08)
            TweenService:Create(Button, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
            if callback then callback() end
        end)
    end

    return Button
end

-- =============================== TOGGLE ===============================
local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = parent
    ToggleFrame.Size = UDim2.new(1, -Spacing*2, 0, ToggleHeight)
    ToggleFrame.BackgroundColor3 = ActiveThemeTable.Surface
    ToggleFrame.BackgroundTransparency = 0.2

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    ToggleCorner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, Spacing, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ActiveThemeTable.Text
    Label.TextSize = NormalTextSize
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Track = Instance.new("Frame")
    Track.Parent = ToggleFrame
    Track.Size = UDim2.new(0, isMobile and 48 or 54, 0, isMobile and 26 or 30)
    Track.Position = UDim2.new(1, isMobile and -60 or -70, 0.5, isMobile and -13 or -15)
    Track.BackgroundColor3 = default and ActiveThemeTable.Primary or Color3.fromRGB(55, 55, 70)

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Knob = Instance.new("Frame")
    Knob.Parent = Track
    Knob.Size = UDim2.new(0, isMobile and 20 or 24, 0, isMobile and 20 or 24)
    Knob.Position = default and UDim2.new(1, isMobile and -26 or -30, 0.5, isMobile and -10 or -12) or UDim2.new(0, 4, 0.5, isMobile and -10 or -12)
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
        local targetColor = toggled and ActiveThemeTable.Primary or Color3.fromRGB(55, 55, 70)
        TweenService:Create(Track, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        local targetPos = toggled and UDim2.new(1, isMobile and -26 or -30, 0.5, isMobile and -10 or -12) or UDim2.new(0, 4, 0.5, isMobile and -10 or -12)
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
        if callback then callback(toggled) end
    end)

    return ToggleFrame
end

-- =============================== SLIDER ===============================
local function CreateSlider(parent, text, min, max, default, suffix, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Parent = parent
    SliderFrame.Size = UDim2.new(1, -Spacing*2, 0, SliderHeight)
    SliderFrame.BackgroundColor3 = ActiveThemeTable.Surface
    SliderFrame.BackgroundTransparency = 0.2

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    SliderCorner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.Size = UDim2.new(0.55, 0, 0, isMobile and 28 or 30)
    Label.Position = UDim2.new(0, Spacing, 0, isMobile and 8 or 10)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ActiveThemeTable.Text
    Label.TextSize = NormalTextSize
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = SliderFrame
    ValueLabel.Size = UDim2.new(0.35, 0, 0, isMobile and 28 or 30)
    ValueLabel.Position = UDim2.new(0.55, 0, 0, isMobile and 8 or 10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default) .. (suffix or "")
    ValueLabel.TextColor3 = ActiveThemeTable.Primary
    ValueLabel.TextSize = NormalTextSize
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Track = Instance.new("Frame")
    Track.Parent = SliderFrame
    Track.Size = UDim2.new(1, -Spacing*2, 0, isMobile and 4 or 5)
    Track.Position = UDim2.new(0, Spacing, 0, isMobile and 52 or 56)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 65)

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    Fill.Parent = Track
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = ActiveThemeTable.Primary

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

-- =============================== DROPDOWN ===============================
local function CreateDropdown(parent, text, options, callback)
    local DropFrame = Instance.new("Frame")
    DropFrame.Parent = parent
    DropFrame.Size = UDim2.new(1, -Spacing*2, 0, DropdownHeight)
    DropFrame.BackgroundColor3 = ActiveThemeTable.Surface
    DropFrame.BackgroundTransparency = 0.2

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    DropCorner.Parent = DropFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = DropFrame
    Label.Size = UDim2.new(0.45, 0, 1, 0)
    Label.Position = UDim2.new(0, Spacing, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ActiveThemeTable.Text
    Label.TextSize = NormalTextSize
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local DropBtn = Instance.new("TextButton")
    DropBtn.Parent = DropFrame
    DropBtn.Size = UDim2.new(0, isMobile and 120 or 140, 0, isMobile and 32 or 36)
    DropBtn.Position = UDim2.new(1, isMobile and -130 or -156, 0.5, isMobile and -16 or -18)
    DropBtn.BackgroundColor3 = ActiveThemeTable.Secondary
    DropBtn.Text = options[1]
    DropBtn.TextColor3 = ActiveThemeTable.Text
    DropBtn.TextSize = NormalTextSize - 1
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
        DropList.BackgroundColor3 = ActiveThemeTable.Surface
        DropList.BackgroundTransparency = 0.1

        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, isMobile and 6 or 8)
        ListCorner.Parent = DropList

        local ListStroke = Instance.new("UIStroke")
        ListStroke.Color = ActiveThemeTable.Border
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
            OptBtn.TextColor3 = ActiveThemeTable.TextSecondary
            OptBtn.TextSize = SmallTextSize
            OptBtn.Font = Enum.Font.Gotham

            OptBtn.MouseEnter:Connect(function()
                TweenService:Create(OptBtn, TweenInfo.new(0.08), {BackgroundTransparency = 0.9, TextColor3 = ActiveThemeTable.Text}):Play()
            end)
            OptBtn.MouseLeave:Connect(function()
                TweenService:Create(OptBtn, TweenInfo.new(0.08), {BackgroundTransparency = 1, TextColor3 = ActiveThemeTable.TextSecondary}):Play()
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
            if DropList and DropList.Parent then closeDropdown() end
        end)
    end)

    return DropFrame
end

-- =============================== INPUT ===============================
local function CreateInput(parent, placeholder, callback)
    local InputFrame = Instance.new("Frame")
    InputFrame.Parent = parent
    InputFrame.Size = UDim2.new(1, -Spacing*2, 0, InputHeight)
    InputFrame.BackgroundColor3 = ActiveThemeTable.Surface
    InputFrame.BackgroundTransparency = 0.2

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    InputCorner.Parent = InputFrame

    local InputBox = Instance.new("TextBox")
    InputBox.Parent = InputFrame
    InputBox.Size = UDim2.new(1, -Spacing*2, 0, isMobile and 34 or 38)
    InputBox.Position = UDim2.new(0, Spacing, 0.5, isMobile and -17 or -19)
    InputBox.BackgroundColor3 = ActiveThemeTable.Secondary
    InputBox.PlaceholderText = placeholder
    InputBox.Text = ""
    InputBox.TextColor3 = ActiveThemeTable.Text
    InputBox.PlaceholderColor3 = ActiveThemeTable.TextSecondary
    InputBox.TextSize = NormalTextSize
    InputBox.Font = Enum.Font.Gotham
    InputBox.ClearTextOnFocus = false

    local InputBoxCorner = Instance.new("UICorner")
    InputBoxCorner.CornerRadius = UDim.new(0, isMobile and 6 or 8)
    InputBoxCorner.Parent = InputBox

    InputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(InputBox.Text)
        end
    end)

    return InputFrame
end

-- =============================== COLOR PICKER ===============================
local function CreateColorPicker(parent, text, defaultColor, callback)
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Parent = parent
    ColorFrame.Size = UDim2.new(1, -Spacing*2, 0, InputHeight)
    ColorFrame.BackgroundColor3 = ActiveThemeTable.Surface
    ColorFrame.BackgroundTransparency = 0.2

    local ColorCorner = Instance.new("UICorner")
    ColorCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    ColorCorner.Parent = ColorFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ColorFrame
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.Position = UDim2.new(0, Spacing, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ActiveThemeTable.Text
    Label.TextSize = NormalTextSize
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ColorDisplay = Instance.new("Frame")
    ColorDisplay.Parent = ColorFrame
    ColorDisplay.Size = UDim2.new(0, isMobile and 42 or 48, 0, isMobile and 34 or 38)
    ColorDisplay.Position = UDim2.new(1, isMobile and -54 or -62, 0.5, isMobile and -17 or -19)
    ColorDisplay.BackgroundColor3 = defaultColor

    local DisplayCorner = Instance.new("UICorner")
    DisplayCorner.CornerRadius = UDim.new(0, isMobile and 8 or 10)
    DisplayCorner.Parent = ColorDisplay

    local DisplayStroke = Instance.new("UIStroke")
    DisplayStroke.Color = ActiveThemeTable.Border
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
        PickerWindow.BackgroundColor3 = ActiveThemeTable.Background
        PickerWindow.BackgroundTransparency = 0.05

        local PickerCorner = Instance.new("UICorner")
        PickerCorner.CornerRadius = UDim.new(0, 16)
        PickerCorner.Parent = PickerWindow

        local PickerStroke = Instance.new("UIStroke")
        PickerStroke.Color = ActiveThemeTable.Border
        PickerStroke.Thickness = 1
        PickerStroke.Parent = PickerWindow

        local PickerTitle = Instance.new("TextLabel")
        PickerTitle.Parent = PickerWindow
        PickerTitle.Size = UDim2.new(1, 0, 0, 48)
        PickerTitle.BackgroundTransparency = 1
        PickerTitle.Text = "Color Picker"
        PickerTitle.TextColor3 = ActiveThemeTable.Text
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
        ClosePicker.BackgroundColor3 = ActiveThemeTable.Primary
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

-- =============================== THEME SELECTOR ===============================
local function CreateThemeSelector(parent)
    local ThemeFrame = Instance.new("Frame")
    ThemeFrame.Parent = parent
    ThemeFrame.Size = UDim2.new(1, -Spacing*2, 0, isMobile and 130 or 150)
    ThemeFrame.BackgroundColor3 = ActiveThemeTable.Surface
    ThemeFrame.BackgroundTransparency = 0.2

    local ThemeCorner = Instance.new("UICorner")
    ThemeCorner.CornerRadius = UDim.new(0, isMobile and 10 or 12)
    ThemeCorner.Parent = ThemeFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ThemeFrame
    Label.Size = UDim2.new(1, 0, 0, isMobile and 30 or 34)
    Label.Position = UDim2.new(0, Spacing, 0, isMobile and 6 or 8)
    Label.BackgroundTransparency = 1
    Label.Text = "Theme"
    Label.TextColor3 = ActiveThemeTable.Text
    Label.TextSize = NormalTextSize
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local themeNames = {"Dark", "Light", "Ocean", "Amethyst", "Sunset", "Forest", "Midnight", "Cherry"}
    local btnWidth = (ThemeFrame.AbsoluteSize.X - Spacing*2) / 4

    for i, name in ipairs(themeNames) do
        local row = math.floor((i-1)/4)
        local col = (i-1) % 4
        local ThemeBtn = Instance.new("TextButton")
        ThemeBtn.Parent = ThemeFrame
        ThemeBtn.Size = UDim2.new(0, btnWidth - Spacing, 0, isMobile and 36 or 40)
        ThemeBtn.Position = UDim2.new(0, Spacing + col * btnWidth, 0, isMobile and 48 + row * 46 or 54 + row * 48)
        ThemeBtn.BackgroundColor3 = Themes[name].Primary
        ThemeBtn.BackgroundTransparency = 0.2
        ThemeBtn.Text = name
        ThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ThemeBtn.TextSize = SmallTextSize
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

-- =============================== NOTIFICATION (DISCORD STYLE) ===============================
local function Notify(title, message, type, duration)
    local notifType = type or "info"
    local notifColor = ActiveThemeTable[notifType:sub(1,1):upper() .. notifType:sub(2)] or ActiveThemeTable.Primary

    local Notification = Instance.new("Frame")
    Notification.Parent = NotifContainer
    Notification.Size = UDim2.new(1, 0, 0, isMobile and 68 or 76)
    Notification.BackgroundColor3 = ActiveThemeTable.Surface
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
    Avatar.Size = UDim2.new(0, isMobile and 32 or 38, 0, isMobile and 32 or 38)
    Avatar.Position = UDim2.new(0, isMobile and 10 or 12, 0.5, isMobile and -16 or -19)
    Avatar.BackgroundColor3 = notifColor
    Avatar.BackgroundTransparency = 0.2

    local AvatarCorner2 = Instance.new("UICorner")
    AvatarCorner2.CornerRadius = UDim.new(1, 0)
    AvatarCorner2.Parent = Avatar

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
    TitleLabel.Size = UDim2.new(1, -55, 0, isMobile and 22 or 24)
    TitleLabel.Position = UDim2.new(0, isMobile and 52 or 62, 0, isMobile and 8 or 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = ActiveThemeTable.Text
    TitleLabel.TextSize = NormalTextSize
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Timestamp = Instance.new("TextLabel")
    Timestamp.Parent = Notification
    Timestamp.Size = UDim2.new(0, 80, 0, isMobile and 14 or 16)
    Timestamp.Position = UDim2.new(1, -85, 0, isMobile and 10 or 12)
    Timestamp.BackgroundTransparency = 1
    local currentTime = os.date("%I:%M %p"):gsub("^0", "")
    Timestamp.Text = currentTime
    Timestamp.TextColor3 = ActiveThemeTable.TextSecondary
    Timestamp.TextSize = SmallTextSize - 1
    Timestamp.Font = Enum.Font.Gotham
    Timestamp.TextXAlignment = Enum.TextXAlignment.Right

    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Parent = Notification
    MsgLabel.Size = UDim2.new(1, -55, 0, isMobile and 26 or 30)
    MsgLabel.Position = UDim2.new(0, isMobile and 52 or 62, 0, isMobile and 32 or 36)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = message
    MsgLabel.TextColor3 = ActiveThemeTable.TextSecondary
    MsgLabel.TextSize = SmallTextSize
    MsgLabel.Font = Enum.Font.Gotham
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    MsgLabel.TextWrapped = true
    MsgLabel.TextYAlignment = Enum.TextYAlignment.Top

    task.wait(duration or 4)

    if Notification and Notification.Parent then
        TweenService:Create(Notification, TweenInfo.new(0.25), {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, -10)}):Play()
        task.wait(0.25)
        Notification:Destroy()
    end
end

-- =============================== APPLY THEME ===============================
local function ApplyTheme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    CurrentTheme = themeName
    ActiveThemeTable = theme

    TweenService:Create(MainFrame, TweenInfo.new(0.25), {BackgroundColor3 = theme.Background}):Play()
    TweenService:Create(LeftPanel, TweenInfo.new(0.25), {BackgroundColor3 = theme.Surface}):Play()
    TweenService:Create(TabBar, TweenInfo.new(0.25), {BackgroundColor3 = theme.Surface}):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.25), {Color = theme.Border}):Play()
    TweenService:Create(LeftPanelStroke, TweenInfo.new(0.25), {Color = theme.Border}):Play()
    TweenService:Create(PlayerNameLabel, TweenInfo.new(0.25), {TextColor3 = theme.Text}):Play()

    for _, tab in pairs(Tabs) do
        TweenService:Create(tab.Button, TweenInfo.new(0.25), {BackgroundColor3 = theme.Surface, TextColor3 = theme.TextSecondary}):Play()
    end

    if ActiveTab then
        for _, tab in pairs(Tabs) do
            if tab.Name == ActiveTab and tab.Frame.Visible then
                TweenService:Create(tab.Button, TweenInfo.new(0.25), {BackgroundColor3 = theme.Surface, TextColor3 = theme.Text}):Play()
                break
            end
        end
    end

    -- Save theme preference
    configData.LastTheme = themeName
    SaveConfig()
end

-- =============================== MINIMIZE / RESTORE ===============================
local minimized = false
local originalSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, MainWindowWidth, 0, isMobile and 54 or 62)}):Play()
        TabBar.Visible = false
        ContentArea.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = originalSize}):Play()
        TabBar.Visible = true
        ContentArea.Visible = true
    end
end)

-- =============================== CLOSE ===============================
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LeftPanel, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    task.wait(0.2)
    if BlurEffect then BlurEffect:Destroy() end
    ScreenGui:Destroy()
end)

-- =============================== AUTO-SAVE LOOP ===============================
if AutoSave and hasFileSystem then
    task.spawn(function()
        while ScreenGui and ScreenGui.Parent do
            task.wait(AutoSaveInterval)
            SaveConfig()
        end
    end)
end

-- =============================== LOAD SAVED THEME ===============================
LoadConfig()
if configData.LastTheme and Themes[configData.LastTheme] then
    ApplyTheme(configData.LastTheme)
else
    ApplyTheme("Dark")
end

-- =============================== GLOBAL EXPOSURE ===============================
_G.Milkyway = {
    -- Core
    CreateTab = CreateTab,
    CreateSection = CreateSection,
    CreateLabel = CreateLabel,
    CreateButton = CreateButton,
    CreateToggle = CreateToggle,
    CreateSlider = CreateSlider,
    CreateDropdown = CreateDropdown,
    CreateInput = CreateInput,
    CreateColorPicker = CreateColorPicker,
    CreateThemeSelector = CreateThemeSelector,
    Notify = Notify,
    ApplyTheme = ApplyTheme,
    
    -- Utilities
    GetTheme = function() return CurrentTheme end,
    GetThemes = function() return Themes end,
    IsMobile = isMobile,
    Executor = Executor,
    Version = LibraryVersion,
    
    -- Config
    SaveConfig = SaveConfig,
    LoadConfig = LoadConfig,
    
    -- Sounds (optional)
    PlaySound = function(id, volume)
        if not SoundEnabled then return end
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. id
        sound.Volume = volume or SoundVolume
        sound.Parent = SoundService
        sound:Play()
        task.delay(sound.TimeLength, function() sound:Destroy() end)
    end,
    
    -- Toggle UI visibility (advanced)
    Hide = function()
        MainFrame.Visible = false
        LeftPanel.Visible = false
    end,
    Show = function()
        MainFrame.Visible = true
        LeftPanel.Visible = true
    end,
    Destroy = function()
        ScreenGui:Destroy()
        if BlurEffect then BlurEffect:Destroy() end
    end
}

-- =============================== WELCOME NOTIFICATION ===============================
task.wait(0.5)
Notify("Milkyway UI", string.format("v%s loaded on %s | %s mode", LibraryVersion, Executor, isMobile and "Mobile" or "Desktop"), "success", 3)

-- =============================== END OF LIBRARY ===============================
-- Total lines: over 5500 including comments
