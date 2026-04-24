--[[
    MILKYWAY UI v7.0
    Syntax: Milkyway:CreateWindow({...})
    Supports: Title, Icon, Author, Folder, Size, Theme, Transparent
    Executors: Delta (mobile), Solara, Arceus X, KRNL, Synapse, Script-Ware
--]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- =============================== EXECUTOR DETECTION ===============================
local Executor = "Unknown"
local isDelta = false
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
if syn then Executor = "Synapse X" end
if krnl then Executor = "KRNL" end
if isfolder and not syn then Executor = "Delta"; isDelta = true end
if getgenv and getgenv().solara then Executor = "Solara" end
if isreader then Executor = "Arceus X" end

local screenSize = workspace.CurrentCamera.ViewportSize

-- =============================== THEMES ===============================
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
    }
}

local ActiveTheme = Themes.Dark
local CurrentThemeName = "Dark"
local BlurEffect = nil

-- =============================== FILE SYSTEM (for Folder & settings) ===============================
local hasFileSystem = (writefile and readfile and isfile and isfolder and makefolder)
local configData = {}

local function EnsureFolder(folderPath)
    if hasFileSystem and not isfolder(folderPath) then
        makefolder(folderPath)
    end
end

local function LoadConfig(folder, fileName)
    if not hasFileSystem then return end
    EnsureFolder(folder)
    local path = folder .. "/" .. fileName
    if isfile(path) then
        local success, data = pcall(readfile, path)
        if success and data then
            success, configData = pcall(HttpService.JSONDecode, HttpService, data)
            if not success then configData = {} end
        end
    end
end

local function SaveConfig(folder, fileName)
    if not hasFileSystem then return end
    EnsureFolder(folder)
    local path = folder .. "/" .. fileName
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, configData)
    if success then
        pcall(writefile, path, encoded)
    end
end

-- =============================== SMART GUI PARENT ===============================
local function GetBestParent()
    if gethui then
        local success, result = pcall(gethui)
        if success and result then return result end
    end
    return CoreGui
end

local MainParent = GetBestParent()

-- =============================== BLUR SETUP ===============================
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

-- =============================== GLOBAL NOTIFICATION CONTAINER ===============================
local GlobalNotifContainer = Instance.new("Frame")
GlobalNotifContainer.Name = "MilkywayNotifications"
GlobalNotifContainer.Parent = MainParent
GlobalNotifContainer.Size = UDim2.new(0, 320, 0, 500)
GlobalNotifContainer.Position = UDim2.new(1, -330, 0, 10)
GlobalNotifContainer.BackgroundTransparency = 1
GlobalNotifContainer.ZIndex = 100

-- =============================== GLOBAL NOTIFICATION FUNCTION ===============================
local function Notify(title, message, type, duration)
    local notifType = type or "info"
    local notifColor = ActiveTheme[notifType:sub(1,1):upper() .. notifType:sub(2)] or ActiveTheme.Primary

    local Notification = Instance.new("Frame")
    Notification.Parent = GlobalNotifContainer
    Notification.Size = UDim2.new(0, 300, 0, 72)
    Notification.Position = UDim2.new(1, 0, 0, (#GlobalNotifContainer:GetChildren() - 1) * 82)
    Notification.BackgroundColor3 = ActiveTheme.Surface
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

    local AccentBar = Instance.new("Frame")
    AccentBar.Parent = Notification
    AccentBar.Size = UDim2.new(0, 4, 1, 0)
    AccentBar.BackgroundColor3 = notifColor

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
    if notifType == "success" then AvatarIcon.Text = "✓"
    elseif notifType == "error" then AvatarIcon.Text = "✕"
    elseif notifType == "warning" then AvatarIcon.Text = "!"
    else AvatarIcon.Text = "●" end
    AvatarIcon.TextColor3 = notifColor
    AvatarIcon.TextSize = 20
    AvatarIcon.Font = Enum.Font.GothamBold

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Notification
    TitleLabel.Size = UDim2.new(1, -60, 0, 24)
    TitleLabel.Position = UDim2.new(0, 60, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = ActiveTheme.Text
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Timestamp = Instance.new("TextLabel")
    Timestamp.Parent = Notification
    Timestamp.Size = UDim2.new(0, 80, 0, 16)
    Timestamp.Position = UDim2.new(1, -90, 0, 12)
    Timestamp.BackgroundTransparency = 1
    local currentTime = os.date("%I:%M %p"):gsub("^0", "")
    Timestamp.Text = currentTime
    Timestamp.TextColor3 = ActiveTheme.TextSecondary
    Timestamp.TextSize = 10
    Timestamp.Font = Enum.Font.Gotham
    Timestamp.TextXAlignment = Enum.TextXAlignment.Right

    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Parent = Notification
    MsgLabel.Size = UDim2.new(1, -60, 0, 28)
    MsgLabel.Position = UDim2.new(0, 60, 0, 36)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = message
    MsgLabel.TextColor3 = ActiveTheme.TextSecondary
    MsgLabel.TextSize = 12
    MsgLabel.Font = Enum.Font.Gotham
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    MsgLabel.TextWrapped = true

    TweenService:Create(Notification, TweenInfo.new(0.3), {Position = UDim2.new(1, -310, 0, Notification.Position.Y.Offset)}):Play()
    task.wait(duration or 4)

    if Notification and Notification.Parent then
        TweenService:Create(Notification, TweenInfo.new(0.25), {Position = UDim2.new(1, 0, 0, Notification.Position.Y.Offset), BackgroundTransparency = 1}):Play()
        task.wait(0.25)
        Notification:Destroy()
        local i = 0
        for _, n in ipairs(GlobalNotifContainer:GetChildren()) do
            if n:IsA("Frame") then
                TweenService:Create(n, TweenInfo.new(0.2), {Position = UDim2.new(1, -310, 0, i * 82)}):Play()
                i = i + 1
            end
        end
    end
end

-- =============================== CREATEWINDOW FUNCTION (MODERN SYNTAX) ===============================
--[[
    Usage:
    local Window = Milkyway:CreateWindow({
        Title = "NotCoin Hub",
        Icon = "coins",          -- optional: emoji or text
        Author = "Brat1shka",
        Folder = "NotCoinHub",   -- folder for config saving
        Size = UDim2.fromOffset(580, 500),
        Theme = "Dark",
        Transparent = true
    })
--]]

local AllWindows = {}

local function CreateWindow(config)
    config = config or {}
    local title = config.Title or "Milkyway"
    local icon = config.Icon or "🌌"
    local author = config.Author or "Milkyway Team"
    local folder = config.Folder or "MilkywayConfig"
    local size = config.Size or UDim2.fromOffset(isMobile and screenSize.X * 0.85 or 520, isMobile and screenSize.Y * 0.78 or 500)
    local themeName = config.Theme or "Dark"
    local transparent = config.Transparent or false

    -- Load config from folder
    LoadConfig(folder, "settings.json")
    if configData.LastTheme then themeName = configData.LastTheme end

    -- Apply theme locally
    local theme = Themes[themeName] or Themes.Dark
    ActiveTheme = theme
    CurrentThemeName = themeName

    local winWidth = size.X.Offset
    local winHeight = size.Y.Offset
    local cornerRadius = isMobile and 16 or 20
    local spacing = isMobile and 6 or 8

    -- Main Frame
    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = title
    WindowFrame.Parent = MainParent
    WindowFrame.Size = size
    WindowFrame.Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2)
    WindowFrame.BackgroundColor3 = theme.Background
    WindowFrame.BackgroundTransparency = transparent and 0.08 or 0.05
    WindowFrame.BorderSizePixel = 0
    WindowFrame.ClipsDescendants = true
    WindowFrame.ZIndex = 10

    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, cornerRadius)
    WindowCorner.Parent = WindowFrame

    local WindowStroke = Instance.new("UIStroke")
    WindowStroke.Thickness = 1.5
    WindowStroke.Transparency = 0.5
    WindowStroke.Color = theme.Border
    WindowStroke.Parent = WindowFrame

    -- Header
    local Header = Instance.new("Frame")
    Header.Parent = WindowFrame
    Header.Size = UDim2.new(1, 0, 0, isMobile and 50 or 58)
    Header.BackgroundTransparency = 1

    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Primary),
        ColorSequenceKeypoint.new(1, theme.PrimaryDark)
    })
    HeaderGradient.Parent = Header

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, cornerRadius)
    HeaderCorner.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Header
    TitleLabel.Size = UDim2.new(0, 250, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = icon .. " " .. title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = isMobile and 18 or 22
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local AuthorLabel = Instance.new("TextLabel")
    AuthorLabel.Parent = Header
    AuthorLabel.Size = UDim2.new(0, 200, 0, 20)
    AuthorLabel.Position = UDim2.new(0, 14, 0, isMobile and 32 or 38)
    AuthorLabel.BackgroundTransparency = 1
    AuthorLabel.Text = author
    AuthorLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    AuthorLabel.TextSize = isMobile and 10 or 12
    AuthorLabel.Font = Enum.Font.Gotham
    AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Buttons
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Header
    CloseBtn.Size = UDim2.new(0, 34, 0, 34)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, -17)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    CloseBtn.BackgroundTransparency = 0.1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 10)
    CloseCorner.Parent = CloseBtn

    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = Header
    MinBtn.Size = UDim2.new(0, 34, 0, 34)
    MinBtn.Position = UDim2.new(1, -88, 0.5, -17)
    MinBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
    MinBtn.BackgroundTransparency = 0.1
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 24
    MinBtn.Font = Enum.Font.GothamBold
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 10)
    MinCorner.Parent = MinBtn

    -- Dragging
    local Dragging = false
    local DragStart, StartPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = WindowFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            WindowFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        end
    end)

    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Parent = WindowFrame
    TabBar.Size = UDim2.new(0, isMobile and 70 or 140, 1, -(isMobile and 50 or 58))
    TabBar.Position = UDim2.new(0, 0, 0, isMobile and 50 or 58)
    TabBar.BackgroundColor3 = theme.Surface
    TabBar.BackgroundTransparency = 0.1
    TabBar.BorderSizePixel = 0
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabBar
    TabListLayout.Padding = UDim.new(0, spacing)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabBar
    TabPadding.PaddingTop = UDim.new(0, isMobile and 12 or 16)

    -- Content Area
    local ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Parent = WindowFrame
    ContentArea.Size = UDim2.new(1, -(isMobile and 80 or 155), 1, -(isMobile and 64 or 72))
    ContentArea.Position = UDim2.new(0, isMobile and 80 or 155, 0, isMobile and 64 or 72)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentArea.ScrollBarThickness = isMobile and 3 or 4
    ContentArea.ScrollBarImageColor3 = theme.Primary
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = ContentArea
    ContentLayout.Padding = UDim.new(0, spacing)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + spacing*2)
    end)

    -- Tabs system
    local Tabs = {}
    local ActiveTab = nil

    local function CreateTab(icon, name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabBar
        TabBtn.Size = UDim2.new(0, (isMobile and 60 or 130), 0, isMobile and 42 or 48)
        TabBtn.BackgroundColor3 = theme.Surface
        TabBtn.BackgroundTransparency = 0.3
        TabBtn.Text = icon .. "  " .. name
        TabBtn.TextColor3 = theme.TextSecondary
        TabBtn.TextSize = isMobile and 12 or 14
        TabBtn.Font = Enum.Font.GothamSemibold
        local TabCornerBtn = Instance.new("UICorner")
        TabCornerBtn.CornerRadius = UDim.new(0, 10)
        TabCornerBtn.Parent = TabBtn

        local TabFrame = Instance.new("Frame")
        TabFrame.Parent = ContentArea
        TabFrame.Size = UDim2.new(1, -spacing*2, 0, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.AutomaticSize = Enum.AutomaticSize.Y

        table.insert(Tabs, {Button = TabBtn, Frame = TabFrame, Name = name})

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Frame.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, TextColor3 = theme.TextSecondary}):Play()
            end
            TabFrame.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.05, TextColor3 = theme.Text}):Play()
            ActiveTab = name
        end)
        if #Tabs == 1 then TabBtn.MouseButton1Click:Fire() end
        return TabFrame
    end

    -- UI Elements (section, button, toggle, slider, dropdown, input, colorpicker, theme selector)
    local function CreateSection(parent, title, description)
        local Section = Instance.new("Frame")
        Section.Parent = parent
        Section.Size = UDim2.new(1, -spacing*2, 0, description and (isMobile and 60 or 65) or (isMobile and 45 or 50))
        Section.BackgroundTransparency = 1
        Section.AutomaticSize = Enum.AutomaticSize.Y

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Parent = Section
        TitleLabel.Size = UDim2.new(1, -spacing, 0, isMobile and 24 or 28)
        TitleLabel.Position = UDim2.new(0, spacing, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = title
        TitleLabel.TextColor3 = theme.Text
        TitleLabel.TextSize = isMobile and 15 or 16
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

        if description and description ~= "" then
            local DescLabel = Instance.new("TextLabel")
            DescLabel.Parent = Section
            DescLabel.Size = UDim2.new(1, -spacing, 0, isMobile and 20 or 22)
            DescLabel.Position = UDim2.new(0, spacing, 0, isMobile and 26 or 30)
            DescLabel.BackgroundTransparency = 1
            DescLabel.Text = description
            DescLabel.TextColor3 = theme.TextSecondary
            DescLabel.TextSize = isMobile and 11 or 12
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.TextWrapped = true
        end

        local Divider = Instance.new("Frame")
        Divider.Parent = Section
        Divider.Size = UDim2.new(1, -spacing*2, 0, 2)
        Divider.Position = UDim2.new(0, spacing, 0, description and (isMobile and 54 or 59) or (isMobile and 40 or 45))
        Divider.BackgroundColor3 = theme.Primary
        Divider.BackgroundTransparency = 0.4
        local DividerCorner = Instance.new("UICorner")
        DividerCorner.CornerRadius = UDim.new(1, 0)
        DividerCorner.Parent = Divider

        return Section
    end

    local function CreateButton(parent, text, icon, callback)
        local Button = Instance.new("TextButton")
        Button.Parent = parent
        Button.Size = UDim2.new(1, -spacing*2, 0, isMobile and 44 or 48)
        Button.BackgroundColor3 = theme.Surface
        Button.BackgroundTransparency = 0.2
        Button.Text = (icon and icon .. "   " .. text) or text
        Button.TextColor3 = theme.Text
        Button.TextSize = isMobile and 13 or 14
        Button.Font = Enum.Font.GothamSemibold
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 10)
        ButtonCorner.Parent = Button
        Button.MouseButton1Click:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.08), {BackgroundTransparency = 0.5}):Play()
            task.wait(0.08)
            TweenService:Create(Button, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
            if callback then callback() end
        end)
        return Button
    end

    local function CreateToggle(parent, text, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Parent = parent
        ToggleFrame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 48 or 52)
        ToggleFrame.BackgroundColor3 = theme.Surface
        ToggleFrame.BackgroundTransparency = 0.2
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 10)
        ToggleCorner.Parent = ToggleFrame

        local Label = Instance.new("TextLabel")
        Label.Parent = ToggleFrame
        Label.Size = UDim2.new(0.6, 0, 1, 0)
        Label.Position = UDim2.new(0, spacing, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = theme.Text
        Label.TextSize = isMobile and 13 or 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Track = Instance.new("Frame")
        Track.Parent = ToggleFrame
        Track.Size = UDim2.new(0, isMobile and 48 or 54, 0, isMobile and 26 or 30)
        Track.Position = UDim2.new(1, isMobile and -60 or -70, 0.5, isMobile and -13 or -15)
        Track.BackgroundColor3 = default and theme.Primary or Color3.fromRGB(55, 55, 70)
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
            local targetColor = toggled and theme.Primary or Color3.fromRGB(55, 55, 70)
            TweenService:Create(Track, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            local targetPos = toggled and UDim2.new(1, isMobile and -26 or -30, 0.5, isMobile and -10 or -12) or UDim2.new(0, 4, 0.5, isMobile and -10 or -12)
            TweenService:Create(Knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
            if callback then callback(toggled) end
        end)
        return ToggleFrame
    end

    local function CreateSlider(parent, text, min, max, default, suffix, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Parent = parent
        SliderFrame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 82 or 88)
        SliderFrame.BackgroundColor3 = theme.Surface
        SliderFrame.BackgroundTransparency = 0.2
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 10)
        SliderCorner.Parent = SliderFrame

        local Label = Instance.new("TextLabel")
        Label.Parent = SliderFrame
        Label.Size = UDim2.new(0.55, 0, 0, isMobile and 28 or 30)
        Label.Position = UDim2.new(0, spacing, 0, isMobile and 8 or 10)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = theme.Text
        Label.TextSize = isMobile and 13 or 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = SliderFrame
        ValueLabel.Size = UDim2.new(0.35, 0, 0, isMobile and 28 or 30)
        ValueLabel.Position = UDim2.new(0.55, 0, 0, isMobile and 8 or 10)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(default) .. (suffix or "")
        ValueLabel.TextColor3 = theme.Primary
        ValueLabel.TextSize = isMobile and 13 or 14
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

        local Track = Instance.new("Frame")
        Track.Parent = SliderFrame
        Track.Size = UDim2.new(1, -spacing*2, 0, isMobile and 4 or 5)
        Track.Position = UDim2.new(0, spacing, 0, isMobile and 52 or 56)
        Track.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track

        local Fill = Instance.new("Frame")
        Fill.Parent = Track
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = theme.Primary
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

    local function CreateDropdown(parent, text, options, callback)
        local DropFrame = Instance.new("Frame")
        DropFrame.Parent = parent
        DropFrame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 48 or 52)
        DropFrame.BackgroundColor3 = theme.Surface
        DropFrame.BackgroundTransparency = 0.2
        local DropCorner = Instance.new("UICorner")
        DropCorner.CornerRadius = UDim.new(0, 10)
        DropCorner.Parent = DropFrame

        local Label = Instance.new("TextLabel")
        Label.Parent = DropFrame
        Label.Size = UDim2.new(0.45, 0, 1, 0)
        Label.Position = UDim2.new(0, spacing, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = theme.Text
        Label.TextSize = isMobile and 13 or 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local DropBtn = Instance.new("TextButton")
        DropBtn.Parent = DropFrame
        DropBtn.Size = UDim2.new(0, isMobile and 120 or 140, 0, isMobile and 32 or 36)
        DropBtn.Position = UDim2.new(1, isMobile and -130 or -156, 0.5, isMobile and -16 or -18)
        DropBtn.BackgroundColor3 = theme.Secondary
        DropBtn.Text = options[1]
        DropBtn.TextColor3 = theme.Text
        DropBtn.TextSize = isMobile and 12 or 13
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
            if isOpen then closeDropdown() return end
            isOpen = true
            DropList = Instance.new("Frame")
            DropList.Parent = DropFrame
            DropList.Size = UDim2.new(0, isMobile and 120 or 140, 0, #options * (isMobile and 32 or 36))
            DropList.Position = UDim2.new(1, isMobile and -130 or -156, 0, isMobile and 40 or 44)
            DropList.BackgroundColor3 = theme.Surface
            DropList.BackgroundTransparency = 0.1
            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 8)
            ListCorner.Parent = DropList
            local ListStroke = Instance.new("UIStroke")
            ListStroke.Color = theme.Border
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
                OptBtn.TextColor3 = theme.TextSecondary
                OptBtn.TextSize = isMobile and 11 or 12
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.MouseEnter:Connect(function()
                    TweenService:Create(OptBtn, TweenInfo.new(0.08), {BackgroundTransparency = 0.9, TextColor3 = theme.Text}):Play()
                end)
                OptBtn.MouseLeave:Connect(function()
                    TweenService:Create(OptBtn, TweenInfo.new(0.08), {BackgroundTransparency = 1, TextColor3 = theme.TextSecondary}):Play()
                end)
                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    DropBtn.Text = opt
                    if callback then callback(opt) end
                    closeDropdown()
                end)
            end
            TweenService:Create(DropList, TweenInfo.new(0.12), {BackgroundTransparency = 0.05}):Play()
            task.delay(6, function() if DropList and DropList.Parent then closeDropdown() end end)
        end)
        return DropFrame
    end

    local function CreateInput(parent, placeholder, callback)
        local InputFrame = Instance.new("Frame")
        InputFrame.Parent = parent
        InputFrame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 48 or 52)
        InputFrame.BackgroundColor3 = theme.Surface
        InputFrame.BackgroundTransparency = 0.2
        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 10)
        InputCorner.Parent = InputFrame

        local InputBox = Instance.new("TextBox")
        InputBox.Parent = InputFrame
        InputBox.Size = UDim2.new(1, -spacing*2, 0, isMobile and 34 or 38)
        InputBox.Position = UDim2.new(0, spacing, 0.5, isMobile and -17 or -19)
        InputBox.BackgroundColor3 = theme.Secondary
        InputBox.PlaceholderText = placeholder
        InputBox.Text = ""
        InputBox.TextColor3 = theme.Text
        InputBox.PlaceholderColor3 = theme.TextSecondary
        InputBox.TextSize = isMobile and 13 or 14
        InputBox.Font = Enum.Font.Gotham
        InputBox.ClearTextOnFocus = false
        local InputBoxCorner = Instance.new("UICorner")
        InputBoxCorner.CornerRadius = UDim.new(0, 8)
        InputBoxCorner.Parent = InputBox
        InputBox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then callback(InputBox.Text) end
        end)
        return InputFrame
    end

    local function CreateColorPicker(parent, text, defaultColor, callback)
        local ColorFrame = Instance.new("Frame")
        ColorFrame.Parent = parent
        ColorFrame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 48 or 52)
        ColorFrame.BackgroundColor3 = theme.Surface
        ColorFrame.BackgroundTransparency = 0.2
        local ColorCorner = Instance.new("UICorner")
        ColorCorner.CornerRadius = UDim.new(0, 10)
        ColorCorner.Parent = ColorFrame

        local Label = Instance.new("TextLabel")
        Label.Parent = ColorFrame
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.Position = UDim2.new(0, spacing, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = theme.Text
        Label.TextSize = isMobile and 13 or 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local ColorDisplay = Instance.new("Frame")
        ColorDisplay.Parent = ColorFrame
        ColorDisplay.Size = UDim2.new(0, isMobile and 42 or 48, 0, isMobile and 34 or 38)
        ColorDisplay.Position = UDim2.new(1, isMobile and -54 or -62, 0.5, isMobile and -17 or -19)
        ColorDisplay.BackgroundColor3 = defaultColor
        local DisplayCorner = Instance.new("UICorner")
        DisplayCorner.CornerRadius = UDim.new(0, 8)
        DisplayCorner.Parent = ColorDisplay
        local DisplayStroke = Instance.new("UIStroke")
        DisplayStroke.Color = theme.Border
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
            if pickerOpen then closePicker() return end
            pickerOpen = true
            PickerWindow = Instance.new("Frame")
            PickerWindow.Parent = MainParent
            PickerWindow.Size = UDim2.new(0, 300, 0, 320)
            PickerWindow.Position = UDim2.new(0.5, -150, 0.5, -160)
            PickerWindow.BackgroundColor3 = theme.Background
            PickerWindow.BackgroundTransparency = 0.05
            local PickerCorner = Instance.new("UICorner")
            PickerCorner.CornerRadius = UDim.new(0, 16)
            PickerCorner.Parent = PickerWindow
            local PickerStroke = Instance.new("UIStroke")
            PickerStroke.Color = theme.Border
            PickerStroke.Thickness = 1
            PickerStroke.Parent = PickerWindow
            local PickerTitle = Instance.new("TextLabel")
            PickerTitle.Parent = PickerWindow
            PickerTitle.Size = UDim2.new(1, 0, 0, 48)
            PickerTitle.BackgroundTransparency = 1
            PickerTitle.Text = "Color Picker"
            PickerTitle.TextColor3 = theme.Text
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
            ClosePicker.BackgroundColor3 = theme.Primary
            ClosePicker.Text = "Done"
            ClosePicker.TextColor3 = Color3.fromRGB(255, 255, 255)
            ClosePicker.TextSize = 14
            ClosePicker.Font = Enum.Font.GothamBold
            local CloseCornerPicker = Instance.new("UICorner")
            CloseCornerPicker.CornerRadius = UDim.new(0, 8)
            CloseCornerPicker.Parent = ClosePicker
            ClosePicker.MouseButton1Click:Connect(function() closePicker() end)
            TweenService:Create(PickerWindow, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
        end)
        return ColorFrame
    end

    local function CreateThemeSelector(parent)
        local ThemeFrame = Instance.new("Frame")
        ThemeFrame.Parent = parent
        ThemeFrame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 150 or 170)
        ThemeFrame.BackgroundColor3 = theme.Surface
        ThemeFrame.BackgroundTransparency = 0.2
        local ThemeCorner = Instance.new("UICorner")
        ThemeCorner.CornerRadius = UDim.new(0, 10)
        ThemeCorner.Parent = ThemeFrame
        local Label = Instance.new("TextLabel")
        Label.Parent = ThemeFrame
        Label.Size = UDim2.new(1, 0, 0, isMobile and 30 or 34)
        Label.Position = UDim2.new(0, spacing, 0, isMobile and 6 or 8)
        Label.BackgroundTransparency = 1
        Label.Text = "Theme"
        Label.TextColor3 = theme.Text
        Label.TextSize = isMobile and 13 or 14
        Label.Font = Enum.Font.GothamBold
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local themeNames = {"Dark", "Light", "Ocean", "Amethyst", "Sunset"}
        local btnWidth = (ThemeFrame.AbsoluteSize.X - spacing*2) / 3
        for i, name in ipairs(themeNames) do
            local row = math.floor((i-1)/3)
            local col = (i-1) % 3
            local ThemeBtn = Instance.new("TextButton")
            ThemeBtn.Parent = ThemeFrame
            ThemeBtn.Size = UDim2.new(0, btnWidth - spacing, 0, isMobile and 36 or 40)
            ThemeBtn.Position = UDim2.new(0, spacing + col * btnWidth, 0, isMobile and 48 + row * 46 or 54 + row * 48)
            ThemeBtn.BackgroundColor3 = Themes[name].Primary
            ThemeBtn.BackgroundTransparency = 0.2
            ThemeBtn.Text = name
            ThemeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ThemeBtn.TextSize = isMobile and 10 or 11
            ThemeBtn.Font = Enum.Font.GothamBold
            local BtnCornerTheme = Instance.new("UICorner")
            BtnCornerTheme.CornerRadius = UDim.new(0, 8)
            BtnCornerTheme.Parent = ThemeBtn
            ThemeBtn.MouseButton1Click:Connect(function()
                -- Apply theme to this window only
                local newTheme = Themes[name]
                if not newTheme then return end
                theme = newTheme
                CurrentThemeName = name
                TweenService:Create(WindowFrame, TweenInfo.new(0.25), {BackgroundColor3 = newTheme.Background}):Play()
                TweenService:Create(TabBar, TweenInfo.new(0.25), {BackgroundColor3 = newTheme.Surface}):Play()
                TweenService:Create(WindowStroke, TweenInfo.new(0.25), {Color = newTheme.Border}):Play()
                for _, tab in pairs(Tabs) do
                    TweenService:Create(tab.Button, TweenInfo.new(0.25), {BackgroundColor3 = newTheme.Surface, TextColor3 = newTheme.TextSecondary}):Play()
                end
                if ActiveTab then
                    for _, tab in pairs(Tabs) do
                        if tab.Name == ActiveTab and tab.Frame.Visible then
                            TweenService:Create(tab.Button, TweenInfo.new(0.25), {BackgroundColor3 = newTheme.Surface, TextColor3 = newTheme.Text}):Play()
                            break
                        end
                    end
                end
                -- Save to config
                configData.LastTheme = name
                SaveConfig(folder, "settings.json")
            end)
        end
        return ThemeFrame
    end

    -- Window API
    local WindowAPI = {
        Window = WindowFrame,
        CreateTab = CreateTab,
        CreateSection = CreateSection,
        CreateButton = CreateButton,
        CreateToggle = CreateToggle,
        CreateSlider = CreateSlider,
        CreateDropdown = CreateDropdown,
        CreateInput = CreateInput,
        CreateColorPicker = CreateColorPicker,
        CreateThemeSelector = CreateThemeSelector,
        Notify = function(title, msg, type, dur) Notify(title, msg, type, dur) end,
        Minimize = function() MinBtn.MouseButton1Click:Fire() end,
        Close = function() CloseBtn.MouseButton1Click:Fire() end,
        SetTitle = function(newTitle) TitleLabel.Text = icon .. " " .. newTitle end,
        SetSize = function(newSize)
            TweenService:Create(WindowFrame, TweenInfo.new(0.3), {Size = newSize}):Play()
        end,
        Center = function()
            WindowFrame.Position = UDim2.new(0.5, -WindowFrame.Size.X.Offset/2, 0.5, -WindowFrame.Size.Y.Offset/2)
        end
    }

    -- Minimize / Restore
    local minimized = false
    local originalSize = WindowFrame.Size
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(WindowFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, winWidth, 0, isMobile and 50 or 58)}):Play()
            TabBar.Visible = false
            ContentArea.Visible = false
        else
            TweenService:Create(WindowFrame, TweenInfo.new(0.3), {Size = originalSize}):Play()
            TabBar.Visible = true
            ContentArea.Visible = true
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(WindowFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.wait(0.2)
        WindowFrame:Destroy()
        for i, w in pairs(AllWindows) do
            if w.Window == WindowFrame then table.remove(AllWindows, i) break end
        end
    end)

    table.insert(AllWindows, WindowAPI)
    return WindowAPI
end

-- =============================== MAIN LIBRARY EXPORT ===============================
_G.Milkyway = {
    CreateWindow = CreateWindow,
    Notify = Notify,
    Version = "7.0",
    Executor = Executor,
    IsMobile = isMobile,
    DestroyAll = function()
        for _, win in pairs(AllWindows) do win:Close() end
        GlobalNotifContainer:Destroy()
        if BlurEffect then BlurEffect:Destroy() end
    end
}

-- Startup notification
task.wait(0.5)
Notify("Milkyway UI", "Library v7.0 loaded | " .. Executor .. (" | Mobile Mode" if isMobile else ""), "success", 3)

-- End of Library
