local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- =============================== EXECUTOR & MOBILE DETECTION ===============================
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local screenSize = workspace.CurrentCamera.ViewportSize
local Executor = "Unknown"
if syn then Executor = "Synapse X" end
if krnl then Executor = "KRNL" end
if isfolder and not syn then Executor = "Delta" end
if getgenv and getgenv().solara then Executor = "Solara" end
if isreader then Executor = "Arceus X" end

-- =============================== UNIVERSAL GUI PARENT ===============================
local function getBestParent()
    if gethui then
        local success, result = pcall(gethui)
        if success and result then return result end
    end
    if CoreGui then return CoreGui end
    return Player:WaitForChild("PlayerGui")
end

local MAIN_PARENT = getBestParent()

-- =============================== THEMES ===============================
local Themes = {
    Dark = {
        Name = "Dark", Background = Color3.fromRGB(10,10,18), Surface = Color3.fromRGB(18,18,28),
        Primary = Color3.fromRGB(139,92,246), PrimaryDark = Color3.fromRGB(124,58,237),
        Secondary = Color3.fromRGB(39,39,52), Text = Color3.fromRGB(250,250,255),
        TextSecondary = Color3.fromRGB(161,161,180), Border = Color3.fromRGB(39,39,52),
        Success = Color3.fromRGB(34,197,94), Error = Color3.fromRGB(239,68,68),
        Warning = Color3.fromRGB(245,158,11), Info = Color3.fromRGB(59,130,246)
    },
    Light = {
        Name = "Light", Background = Color3.fromRGB(248,250,252), Surface = Color3.fromRGB(255,255,255),
        Primary = Color3.fromRGB(99,102,241), PrimaryDark = Color3.fromRGB(79,70,229),
        Secondary = Color3.fromRGB(241,245,249), Text = Color3.fromRGB(15,23,42),
        TextSecondary = Color3.fromRGB(100,116,139), Border = Color3.fromRGB(226,232,240),
        Success = Color3.fromRGB(34,197,94), Error = Color3.fromRGB(239,68,68),
        Warning = Color3.fromRGB(245,158,11), Info = Color3.fromRGB(59,130,246)
    },
    Ocean = {
        Name = "Ocean", Background = Color3.fromRGB(4,30,45), Surface = Color3.fromRGB(10,45,60),
        Primary = Color3.fromRGB(56,189,248), PrimaryDark = Color3.fromRGB(14,165,233),
        Secondary = Color3.fromRGB(25,60,75), Text = Color3.fromRGB(240,248,255),
        TextSecondary = Color3.fromRGB(148,163,184), Border = Color3.fromRGB(51,65,85),
        Success = Color3.fromRGB(34,197,94), Error = Color3.fromRGB(239,68,68),
        Warning = Color3.fromRGB(245,158,11), Info = Color3.fromRGB(56,189,248)
    },
    Amethyst = {
        Name = "Amethyst", Background = Color3.fromRGB(35,15,55), Surface = Color3.fromRGB(45,25,70),
        Primary = Color3.fromRGB(192,132,252), PrimaryDark = Color3.fromRGB(168,85,247),
        Secondary = Color3.fromRGB(55,35,80), Text = Color3.fromRGB(250,240,255),
        TextSecondary = Color3.fromRGB(200,170,230), Border = Color3.fromRGB(65,45,90),
        Success = Color3.fromRGB(34,197,94), Error = Color3.fromRGB(239,68,68),
        Warning = Color3.fromRGB(245,158,11), Info = Color3.fromRGB(192,132,252)
    },
    Sunset = {
        Name = "Sunset", Background = Color3.fromRGB(45,20,35), Surface = Color3.fromRGB(55,28,45),
        Primary = Color3.fromRGB(251,113,133), PrimaryDark = Color3.fromRGB(244,63,94),
        Secondary = Color3.fromRGB(65,38,55), Text = Color3.fromRGB(255,245,250),
        TextSecondary = Color3.fromRGB(203,170,185), Border = Color3.fromRGB(75,48,65),
        Success = Color3.fromRGB(34,197,94), Error = Color3.fromRGB(239,68,68),
        Warning = Color3.fromRGB(245,158,11), Info = Color3.fromRGB(251,113,133)
    }
}

local CurrentTheme = Themes.Dark
local BlurEffect = nil

-- =============================== BLUR SETUP ===============================
local function setupBlur(enabled)
    if enabled and not BlurEffect then
        BlurEffect = Instance.new("BlurEffect")
        BlurEffect.Parent = Lighting
        BlurEffect.Size = 8
    elseif not enabled and BlurEffect then
        BlurEffect:Destroy()
        BlurEffect = nil
    end
end
setupBlur(true)

-- =============================== FILE SYSTEM ===============================
local hasFileSystem = (writefile and readfile and isfile and isfolder and makefolder)
local configs = {}
local function ensureFolder(folder)
    if hasFileSystem and not isfolder(folder) then makefolder(folder) end
end
local function loadConfig(folder, fileName)
    if not hasFileSystem then return {} end
    ensureFolder(folder)
    local path = folder .. "/" .. fileName
    if isfile(path) then
        local success, data = pcall(readfile, path)
        if success and data then
            success, configs = pcall(HttpService.JSONDecode, HttpService, data)
            if not success then configs = {} end
        end
    end
    return configs
end
local function saveConfig(folder, fileName)
    if not hasFileSystem then return end
    ensureFolder(folder)
    local path = folder .. "/" .. fileName
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, configs)
    if success then pcall(writefile, path, encoded) end
end

-- =============================== NOTIFICATION CONTAINER ===============================
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "MilkywayNotifications"
NotificationContainer.Parent = MAIN_PARENT
NotificationContainer.Size = UDim2.new(0, 320, 0, 500)
NotificationContainer.Position = UDim2.new(1, -330, 0, 10)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ZIndex = 100

-- =============================== NOTIFICATION FUNCTION ===============================
local function Notify(title, message, type, duration)
    local notifType = type or "info"
    local color = CurrentTheme[notifType:sub(1,1):upper() .. notifType:sub(2)] or CurrentTheme.Primary
    local notif = Instance.new("Frame")
    notif.Parent = NotificationContainer
    notif.Size = UDim2.new(0, 300, 0, 72)
    notif.Position = UDim2.new(1, 0, 0, (#NotificationContainer:GetChildren() - 1) * 82)
    notif.BackgroundColor3 = CurrentTheme.Surface
    notif.BackgroundTransparency = 0.05
    notif.ClipsDescendants = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notif
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.Parent = notif
    local accent = Instance.new("Frame")
    accent.Parent = notif
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color
    local avatar = Instance.new("Frame")
    avatar.Parent = notif
    avatar.Size = UDim2.new(0, 36, 0, 36)
    avatar.Position = UDim2.new(0, 12, 0.5, -18)
    avatar.BackgroundColor3 = color
    avatar.BackgroundTransparency = 0.2
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatar
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Parent = avatar
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    if notifType == "success" then iconLabel.Text = "✓"
    elseif notifType == "error" then iconLabel.Text = "✕"
    elseif notifType == "warning" then iconLabel.Text = "!"
    else iconLabel.Text = "●" end
    iconLabel.TextColor3 = color
    iconLabel.TextSize = 20
    iconLabel.Font = Enum.Font.GothamBold
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = notif
    titleLabel.Size = UDim2.new(1, -60, 0, 24)
    titleLabel.Position = UDim2.new(0, 60, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = CurrentTheme.Text
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Parent = notif
    timeLabel.Size = UDim2.new(0, 80, 0, 16)
    timeLabel.Position = UDim2.new(1, -90, 0, 12)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%I:%M %p"):gsub("^0", "")
    timeLabel.TextColor3 = CurrentTheme.TextSecondary
    timeLabel.TextSize = 10
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Parent = notif
    msgLabel.Size = UDim2.new(1, -60, 0, 28)
    msgLabel.Position = UDim2.new(0, 60, 0, 36)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = CurrentTheme.TextSecondary
    msgLabel.TextSize = 12
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, -310, 0, notif.Position.Y.Offset)}):Play()
    task.wait(duration or 4)
    if notif and notif.Parent then
        TweenService:Create(notif, TweenInfo.new(0.25), {Position = UDim2.new(1, 0, 0, notif.Position.Y.Offset), BackgroundTransparency = 1}):Play()
        task.wait(0.25)
        notif:Destroy()
        local i = 0
        for _, n in ipairs(NotificationContainer:GetChildren()) do
            if n:IsA("Frame") then
                TweenService:Create(n, TweenInfo.new(0.2), {Position = UDim2.new(1, -310, 0, i * 82)}):Play()
                i = i + 1
            end
        end
    end
end

-- =============================== CREATE WINDOW ===============================
local AllWindows = {}
local function CreateWindow(config)
    config = config or {}
    local title = config.Title or "Milkyway"
    local icon = config.Icon or "🌌"
    local author = config.Author or ""
    local folder = config.Folder or "MilkywayConfig"
    local size = config.Size or UDim2.fromOffset(isMobile and screenSize.X * 0.9 or 540, isMobile and screenSize.Y * 0.8 or 500)
    local themeName = config.Theme or "Dark"
    local transparent = config.Transparent or false
    local settings = loadConfig(folder, "settings.json")
    if settings.LastTheme then themeName = settings.LastTheme end
    local theme = Themes[themeName] or Themes.Dark
    CurrentTheme = theme
    local winWidth = size.X.Offset
    local winHeight = size.Y.Offset
    local cornerRadius = isMobile and 16 or 20
    local spacing = isMobile and 6 or 8
    local Window = Instance.new("Frame")
    Window.Name = title
    Window.Parent = MAIN_PARENT
    Window.Size = size
    Window.Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2)
    Window.BackgroundColor3 = theme.Background
    Window.BackgroundTransparency = transparent and 0.08 or 0.05
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    local winCorner = Instance.new("UICorner")
    winCorner.CornerRadius = UDim.new(0, cornerRadius)
    winCorner.Parent = Window
    local winStroke = Instance.new("UIStroke")
    winStroke.Thickness = 1.5
    winStroke.Transparency = 0.5
    winStroke.Color = theme.Border
    winStroke.Parent = Window
    local Header = Instance.new("Frame")
    Header.Parent = Window
    Header.Size = UDim2.new(1, 0, 0, isMobile and 50 or 58)
    Header.BackgroundTransparency = 1
    local headerGrad = Instance.new("UIGradient")
    headerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Primary),
        ColorSequenceKeypoint.new(1, theme.PrimaryDark)
    })
    headerGrad.Parent = Header
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, cornerRadius)
    headerCorner.Parent = Header
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Header
    TitleLabel.Size = UDim2.new(0, 250, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = icon .. " " .. title
    TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLabel.TextSize = isMobile and 18 or 22
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    if author and author ~= "" then
        local AuthorLabel = Instance.new("TextLabel")
        AuthorLabel.Parent = Header
        AuthorLabel.Size = UDim2.new(0, 200, 0, 20)
        AuthorLabel.Position = UDim2.new(0, 14, 0, isMobile and 32 or 38)
        AuthorLabel.BackgroundTransparency = 1
        AuthorLabel.Text = author
        AuthorLabel.TextColor3 = Color3.fromRGB(200,200,255)
        AuthorLabel.TextSize = isMobile and 10 or 12
        AuthorLabel.Font = Enum.Font.Gotham
        AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left
    end
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Header
    CloseBtn.Size = UDim2.new(0, 34, 0, 34)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, -17)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(239,68,68)
    CloseBtn.BackgroundTransparency = 0.1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = CloseBtn
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = Header
    MinBtn.Size = UDim2.new(0, 34, 0, 34)
    MinBtn.Position = UDim2.new(1, -88, 0.5, -17)
    MinBtn.BackgroundColor3 = Color3.fromRGB(245,158,11)
    MinBtn.BackgroundTransparency = 0.1
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
    MinBtn.TextSize = 24
    MinBtn.Font = Enum.Font.GothamBold
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 10)
    minCorner.Parent = MinBtn
    local dragging = false
    local dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    local TabBar = Instance.new("Frame")
    TabBar.Parent = Window
    TabBar.Size = UDim2.new(0, isMobile and 70 or 140, 1, -(isMobile and 50 or 58))
    TabBar.Position = UDim2.new(0, 0, 0, isMobile and 50 or 58)
    TabBar.BackgroundColor3 = theme.Surface
    TabBar.BackgroundTransparency = 0.1
    local tabList = Instance.new("UIListLayout")
    tabList.Parent = TabBar
    tabList.Padding = UDim.new(0, spacing)
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local tabPadding = Instance.new("UIPadding")
    tabPadding.Parent = TabBar
    tabPadding.PaddingTop = UDim.new(0, isMobile and 12 or 16)
    local Content = Instance.new("ScrollingFrame")
    Content.Parent = Window
    Content.Size = UDim2.new(1, -(isMobile and 80 or 155), 1, -(isMobile and 64 or 72))
    Content.Position = UDim2.new(0, isMobile and 80 or 155, 0, isMobile and 64 or 72)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.ScrollBarThickness = isMobile and 3 or 4
    Content.ScrollBarImageColor3 = theme.Primary
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = Content
    contentLayout.Padding = UDim.new(0, spacing)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + spacing*2)
    end)
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
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = TabBtn
        local TabFrame = Instance.new("Frame")
        TabFrame.Parent = Content
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
        local divCorner = Instance.new("UICorner")
        divCorner.CornerRadius = UDim.new(1, 0)
        divCorner.Parent = Divider
        return Section
    end
    local function CreateButton(parent, text, icon, callback)
        local btn = Instance.new("TextButton")
        btn.Parent = parent
        btn.Size = UDim2.new(1, -spacing*2, 0, isMobile and 44 or 48)
        btn.BackgroundColor3 = theme.Surface
        btn.BackgroundTransparency = 0.2
        btn.Text = (icon and icon .. "   " .. text) or text
        btn.TextColor3 = theme.Text
        btn.TextSize = isMobile and 13 or 14
        btn.Font = Enum.Font.GothamSemibold
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundTransparency = 0.5}):Play()
            task.wait(0.08)
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.2}):Play()
            if callback then callback() end
        end)
        return btn
    end
    local function CreateToggle(parent, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 48 or 52)
        frame.BackgroundColor3 = theme.Surface
        frame.BackgroundTransparency = 0.2
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 10)
        frameCorner.Parent = frame
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, spacing, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = theme.Text
        label.TextSize = isMobile and 13 or 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        local track = Instance.new("Frame")
        track.Parent = frame
        track.Size = UDim2.new(0, isMobile and 48 or 54, 0, isMobile and 26 or 30)
        track.Position = UDim2.new(1, isMobile and -60 or -70, 0.5, isMobile and -13 or -15)
        track.BackgroundColor3 = default and theme.Primary or Color3.fromRGB(55,55,70)
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = track
        local knob = Instance.new("Frame")
        knob.Parent = track
        knob.Size = UDim2.new(0, isMobile and 20 or 24, 0, isMobile and 20 or 24)
        knob.Position = default and UDim2.new(1, isMobile and -26 or -30, 0.5, isMobile and -10 or -12) or UDim2.new(0, 4, 0.5, isMobile and -10 or -12)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob
        local toggled = default
        local click = Instance.new("TextButton")
        click.Parent = frame
        click.Size = UDim2.new(1, 0, 1, 0)
        click.BackgroundTransparency = 1
        click.Text = ""
        click.MouseButton1Click:Connect(function()
            toggled = not toggled
            local targetColor = toggled and theme.Primary or Color3.fromRGB(55,55,70)
            TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            local targetPos = toggled and UDim2.new(1, isMobile and -26 or -30, 0.5, isMobile and -10 or -12) or UDim2.new(0, 4, 0.5, isMobile and -10 or -12)
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
            if callback then callback(toggled) end
        end)
        return frame
    end
    local function CreateSlider(parent, text, min, max, default, suffix, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 82 or 88)
        frame.BackgroundColor3 = theme.Surface
        frame.BackgroundTransparency = 0.2
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 10)
        frameCorner.Parent = frame
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.55, 0, 0, isMobile and 28 or 30)
        label.Position = UDim2.new(0, spacing, 0, isMobile and 8 or 10)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = theme.Text
        label.TextSize = isMobile and 13 or 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Parent = frame
        valueLabel.Size = UDim2.new(0.35, 0, 0, isMobile and 28 or 30)
        valueLabel.Position = UDim2.new(0.55, 0, 0, isMobile and 8 or 10)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default) .. (suffix or "")
        valueLabel.TextColor3 = theme.Primary
        valueLabel.TextSize = isMobile and 13 or 14
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        local track = Instance.new("Frame")
        track.Parent = frame
        track.Size = UDim2.new(1, -spacing*2, 0, isMobile and 4 or 5)
        track.Position = UDim2.new(0, spacing, 0, isMobile and 52 or 56)
        track.BackgroundColor3 = Color3.fromRGB(50,50,65)
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = track
        local fill = Instance.new("Frame")
        fill.Parent = track
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = theme.Primary
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill
        local value = default
        local sliding = false
        local function update(input)
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(value) .. (suffix or "")
            if callback then callback(value) end
        end
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        return frame
    end
    local function CreateDropdown(parent, text, options, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 48 or 52)
        frame.BackgroundColor3 = theme.Surface
        frame.BackgroundTransparency = 0.2
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 10)
        frameCorner.Parent = frame
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.45, 0, 1, 0)
        label.Position = UDim2.new(0, spacing, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = theme.Text
        label.TextSize = isMobile and 13 or 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        local button = Instance.new("TextButton")
        button.Parent = frame
        button.Size = UDim2.new(0, isMobile and 120 or 140, 0, isMobile and 32 or 36)
        button.Position = UDim2.new(1, isMobile and -130 or -156, 0.5, isMobile and -16 or -18)
        button.BackgroundColor3 = theme.Secondary
        button.Text = options[1]
        button.TextColor3 = theme.Text
        button.TextSize = isMobile and 12 or 13
        button.Font = Enum.Font.Gotham
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = button
        local selected = options[1]
        local isOpen = false
        local list = nil
        local function close()
            if list then
                TweenService:Create(list, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
                task.wait(0.12)
                list:Destroy()
                list = nil
            end
            isOpen = false
        end
        button.MouseButton1Click:Connect(function()
            if isOpen then close() return end
            isOpen = true
            list = Instance.new("Frame")
            list.Parent = frame
            list.Size = UDim2.new(0, isMobile and 120 or 140, 0, #options * (isMobile and 32 or 36))
            list.Position = UDim2.new(1, isMobile and -130 or -156, 0, isMobile and 40 or 44)
            list.BackgroundColor3 = theme.Surface
            list.BackgroundTransparency = 0.1
            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 8)
            listCorner.Parent = list
            local listStroke = Instance.new("UIStroke")
            listStroke.Color = theme.Border
            listStroke.Thickness = 1
            listStroke.Parent = list
            local listLayout = Instance.new("UIListLayout")
            listLayout.Parent = list
            listLayout.Padding = UDim.new(0, 2)
            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Parent = list
                optBtn.Size = UDim2.new(1, 0, 0, isMobile and 30 or 34)
                optBtn.BackgroundTransparency = 1
                optBtn.Text = opt
                optBtn.TextColor3 = theme.TextSecondary
                optBtn.TextSize = isMobile and 11 or 12
                optBtn.Font = Enum.Font.Gotham
                optBtn.MouseEnter:Connect(function()
                    TweenService:Create(optBtn, TweenInfo.new(0.08), {BackgroundTransparency = 0.9, TextColor3 = theme.Text}):Play()
                end)
                optBtn.MouseLeave:Connect(function()
                    TweenService:Create(optBtn, TweenInfo.new(0.08), {BackgroundTransparency = 1, TextColor3 = theme.TextSecondary}):Play()
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    button.Text = opt
                    if callback then callback(opt) end
                    close()
                end)
            end
            TweenService:Create(list, TweenInfo.new(0.12), {BackgroundTransparency = 0.05}):Play()
            task.delay(6, function() if list and list.Parent then close() end end)
        end)
        return frame
    end
    local function CreateInput(parent, placeholder, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 48 or 52)
        frame.BackgroundColor3 = theme.Surface
        frame.BackgroundTransparency = 0.2
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 10)
        frameCorner.Parent = frame
        local box = Instance.new("TextBox")
        box.Parent = frame
        box.Size = UDim2.new(1, -spacing*2, 0, isMobile and 34 or 38)
        box.Position = UDim2.new(0, spacing, 0.5, isMobile and -17 or -19)
        box.BackgroundColor3 = theme.Secondary
        box.PlaceholderText = placeholder
        box.Text = ""
        box.TextColor3 = theme.Text
        box.PlaceholderColor3 = theme.TextSecondary
        box.TextSize = isMobile and 13 or 14
        box.Font = Enum.Font.Gotham
        box.ClearTextOnFocus = false
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 8)
        boxCorner.Parent = box
        box.FocusLost:Connect(function(enter)
            if enter and callback then callback(box.Text) end
        end)
        return frame
    end
    local function CreateColorPicker(parent, text, defaultColor, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 48 or 52)
        frame.BackgroundColor3 = theme.Surface
        frame.BackgroundTransparency = 0.2
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 10)
        frameCorner.Parent = frame
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.Position = UDim2.new(0, spacing, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = theme.Text
        label.TextSize = isMobile and 13 or 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        local display = Instance.new("Frame")
        display.Parent = frame
        display.Size = UDim2.new(0, isMobile and 42 or 48, 0, isMobile and 34 or 38)
        display.Position = UDim2.new(1, isMobile and -54 or -62, 0.5, isMobile and -17 or -19)
        display.BackgroundColor3 = defaultColor
        local displayCorner = Instance.new("UICorner")
        displayCorner.CornerRadius = UDim.new(0, 8)
        displayCorner.Parent = display
        local displayStroke = Instance.new("UIStroke")
        displayStroke.Color = theme.Border
        displayStroke.Thickness = 1
        displayStroke.Parent = display
        local selected = defaultColor
        local open = false
        local picker = nil
        local function closePicker()
            if picker then
                TweenService:Create(picker, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                task.wait(0.15)
                picker:Destroy()
                picker = nil
            end
            open = false
        end
        display.MouseButton1Click:Connect(function()
            if open then closePicker() return end
            open = true
            picker = Instance.new("Frame")
            picker.Parent = MAIN_PARENT
            picker.Size = UDim2.new(0, 300, 0, 320)
            picker.Position = UDim2.new(0.5, -150, 0.5, -160)
            picker.BackgroundColor3 = theme.Background
            picker.BackgroundTransparency = 0.05
            local pickerCorner = Instance.new("UICorner")
            pickerCorner.CornerRadius = UDim.new(0, 16)
            pickerCorner.Parent = picker
            local pickerStroke = Instance.new("UIStroke")
            pickerStroke.Color = theme.Border
            pickerStroke.Thickness = 1
            pickerStroke.Parent = picker
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Parent = picker
            titleLabel.Size = UDim2.new(1, 0, 0, 48)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = "Color Picker"
            titleLabel.TextColor3 = theme.Text
            titleLabel.TextSize = 18
            titleLabel.Font = Enum.Font.GothamBold
            local r, g, b = selected.R * 255, selected.G * 255, selected.B * 255
            local redSlider = CreateSlider(picker, "Red", 0, 255, r, "", function(val)
                selected = Color3.fromRGB(val, g, b)
                display.BackgroundColor3 = selected
                if callback then callback(selected) end
            end)
            redSlider.Size = UDim2.new(1, -32, 0, 70)
            redSlider.Position = UDim2.new(0, 16, 0, 55)
            local greenSlider = CreateSlider(picker, "Green", 0, 255, g, "", function(val)
                selected = Color3.fromRGB(r, val, b)
                display.BackgroundColor3 = selected
                if callback then callback(selected) end
            end)
            greenSlider.Size = UDim2.new(1, -32, 0, 70)
            greenSlider.Position = UDim2.new(0, 16, 0, 140)
            local blueSlider = CreateSlider(picker, "Blue", 0, 255, b, "", function(val)
                selected = Color3.fromRGB(r, g, val)
                display.BackgroundColor3 = selected
                if callback then callback(selected) end
            end)
            blueSlider.Size = UDim2.new(1, -32, 0, 70)
            blueSlider.Position = UDim2.new(0, 16, 0, 225)
            local doneBtn = Instance.new("TextButton")
            doneBtn.Parent = picker
            doneBtn.Size = UDim2.new(0, 80, 0, 36)
            doneBtn.Position = UDim2.new(1, -96, 1, -48)
            doneBtn.BackgroundColor3 = theme.Primary
            doneBtn.Text = "Done"
            doneBtn.TextColor3 = Color3.fromRGB(255,255,255)
            doneBtn.TextSize = 14
            doneBtn.Font = Enum.Font.GothamBold
            local doneCorner = Instance.new("UICorner")
            doneCorner.CornerRadius = UDim.new(0, 8)
            doneCorner.Parent = doneBtn
            doneBtn.MouseButton1Click:Connect(closePicker)
            TweenService:Create(picker, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
        end)
        return frame
    end
    local function CreateThemeSelector(parent)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -spacing*2, 0, isMobile and 150 or 170)
        frame.BackgroundColor3 = theme.Surface
        frame.BackgroundTransparency = 0.2
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 10)
        frameCorner.Parent = frame
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(1, 0, 0, isMobile and 30 or 34)
        label.Position = UDim2.new(0, spacing, 0, isMobile and 6 or 8)
        label.BackgroundTransparency = 1
        label.Text = "Theme"
        label.TextColor3 = theme.Text
        label.TextSize = isMobile and 13 or 14
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        local themeNames = {"Dark", "Light", "Ocean", "Amethyst", "Sunset"}
        local btnWidth = (frame.AbsoluteSize.X - spacing*2) / 3
        for i, name in ipairs(themeNames) do
            local row = math.floor((i-1)/3)
            local col = (i-1) % 3
            local btn = Instance.new("TextButton")
            btn.Parent = frame
            btn.Size = UDim2.new(0, btnWidth - spacing, 0, isMobile and 36 or 40)
            btn.Position = UDim2.new(0, spacing + col * btnWidth, 0, isMobile and 48 + row * 46 or 54 + row * 48)
            btn.BackgroundColor3 = Themes[name].Primary
            btn.BackgroundTransparency = 0.2
            btn.Text = name
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.TextSize = isMobile and 10 or 11
            btn.Font = Enum.Font.GothamBold
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn
            btn.MouseButton1Click:Connect(function()
                local newTheme = Themes[name]
                if not newTheme then return end
                theme = newTheme
                CurrentTheme = newTheme
                TweenService:Create(Window, TweenInfo.new(0.25), {BackgroundColor3 = newTheme.Background}):Play()
                TweenService:Create(TabBar, TweenInfo.new(0.25), {BackgroundColor3 = newTheme.Surface}):Play()
                TweenService:Create(winStroke, TweenInfo.new(0.25), {Color = newTheme.Border}):Play()
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
                settings.LastTheme = name
                saveConfig(folder, "settings.json")
            end)
        end
        return frame
    end
    local minimized = false
    local originalSize = Window.Size
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(Window, TweenInfo.new(0.3), {Size = UDim2.new(0, winWidth, 0, isMobile and 50 or 58)}):Play()
            TabBar.Visible = false
            Content.Visible = false
        else
            TweenService:Create(Window, TweenInfo.new(0.3), {Size = originalSize}):Play()
            TabBar.Visible = true
            Content.Visible = true
        end
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(Window, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.wait(0.2)
        Window:Destroy()
        for i, w in pairs(AllWindows) do if w.Window == Window then table.remove(AllWindows, i) break end end
    end)
    local windowAPI = {
        Window = Window,
        CreateTab = CreateTab,
        CreateSection = CreateSection,
        CreateButton = CreateButton,
        CreateToggle = CreateToggle,
        CreateSlider = CreateSlider,
        CreateDropdown = CreateDropdown,
        CreateInput = CreateInput,
        CreateColorPicker = CreateColorPicker,
        CreateThemeSelector = CreateThemeSelector,
        Notify = function(t, m, typ, dur) Notify(t, m, typ, dur) end,
        Minimize = function() MinBtn.MouseButton1Click:Fire() end,
        Close = function() CloseBtn.MouseButton1Click:Fire() end,
        SetTitle = function(newTitle) TitleLabel.Text = icon .. " " .. newTitle end,
        SetSize = function(newSize) TweenService:Create(Window, TweenInfo.new(0.3), {Size = newSize}):Play() end,
        Center = function() Window.Position = UDim2.new(0.5, -Window.Size.X.Offset/2, 0.5, -Window.Size.Y.Offset/2) end
    }
    table.insert(AllWindows, windowAPI)
    return windowAPI
end

-- =============================== GLOBAL EXPORT ===============================
_G.Milkyway = {
    CreateWindow = CreateWindow,
    Notify = Notify,
    Version = "9.0",
    Executor = Executor,
    IsMobile = isMobile,
    DestroyAll = function()
        for _, win in pairs(AllWindows) do win:Close() end
        NotificationContainer:Destroy()
        if BlurEffect then BlurEffect:Destroy() end
    end
}
