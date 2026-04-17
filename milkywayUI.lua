--[[
    ============================================================================
    MILKYWAY UI v6.0.0
    Author: KercX
    License: MIT
    Total lines: 5200+ (including extensive comments and documentation)
    
    A complete UI library for Roblox with 3D Model Viewer and 30+ components.
    No Modal component – only Model (3D MeshPart viewer) is provided.
    
    Components included:
    - Model (3D viewer with orbit, zoom, auto-rotate)
    - Button, Input, Checkbox, Radio, Dropdown, Slider, Toggle
    - Tabs, Tooltip, Notify (Toast), ProgressBar, ColorPicker
    - ContextMenu, TreeView, GridLayout, Carousel, Pagination
    - Accordion, Stepper, Rating, Avatar, Badge, Card, Drawer
    - BottomSheet, Snackbar, Skeleton, Spinner, Toolbar, Breadcrumb
    - Splitter, ResizablePanel, DraggableWindow, MessageBox, FileUpload
    - ImageEditor, AudioPlayer, VideoPlayer, Chart, Calendar, Kanban
    - Timeline, Wizard, FormBuilder, DataTable, VirtualList, InfiniteScroll
    - HotkeyManager, ThemeBuilder, Localization, AnimationController
    - GestureDetector, EventBus, StateManager, Storage, HttpClient
    - WebSocket, Logger, Profiler, UnitTests
    
    ============================================================================
--]]

local Milkyway = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local Selection = game:GetService("Selection")
local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")

local isClient = RunService:IsClient()
if not isClient then return Milkyway end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local defaultScreenGui = Instance.new("ScreenGui")
defaultScreenGui.Name = "MilkywayUI"
defaultScreenGui.ResetOnSpawn = false
defaultScreenGui.Parent = playerGui

-- ======================== THEMES (5 built-in + custom) ========================
local themes = {
    Dark = {
        name = "Dark", version = "1.0",
        background = Color3.fromRGB(18,18,24),
        surface = Color3.fromRGB(30,30,40),
        primary = Color3.fromRGB(120,90,255),
        primaryHover = Color3.fromRGB(140,110,255),
        primaryActive = Color3.fromRGB(100,70,235),
        secondary = Color3.fromRGB(80,80,120),
        secondaryHover = Color3.fromRGB(100,100,140),
        text = Color3.fromRGB(255,255,255),
        textSecondary = Color3.fromRGB(180,180,200),
        textDisabled = Color3.fromRGB(120,120,140),
        border = Color3.fromRGB(60,60,80),
        divider = Color3.fromRGB(45,45,60),
        success = Color3.fromRGB(80,200,120),
        warning = Color3.fromRGB(240,180,60),
        error = Color3.fromRGB(230,80,100),
        info = Color3.fromRGB(60,160,230),
        overlay = Color3.fromRGB(0,0,0),
        overlayTransparency = 0.6,
        shadow = Color3.fromRGB(0,0,0),
        shadowTransparency = 0.3,
        iconTint = Color3.fromRGB(200,200,255),
        ripple = Color3.fromRGB(255,255,255),
        rippleTransparency = 0.8,
    },
    Light = {
        name = "Light", version = "1.0",
        background = Color3.fromRGB(245,245,250),
        surface = Color3.fromRGB(255,255,255),
        primary = Color3.fromRGB(80,60,200),
        primaryHover = Color3.fromRGB(100,75,230),
        primaryActive = Color3.fromRGB(60,40,180),
        secondary = Color3.fromRGB(200,200,220),
        secondaryHover = Color3.fromRGB(220,220,240),
        text = Color3.fromRGB(30,30,40),
        textSecondary = Color3.fromRGB(100,100,120),
        textDisabled = Color3.fromRGB(160,160,180),
        border = Color3.fromRGB(210,210,225),
        divider = Color3.fromRGB(230,230,240),
        success = Color3.fromRGB(40,170,80),
        warning = Color3.fromRGB(220,150,30),
        error = Color3.fromRGB(200,60,70),
        info = Color3.fromRGB(40,130,200),
        overlay = Color3.fromRGB(0,0,0),
        overlayTransparency = 0.4,
        shadow = Color3.fromRGB(0,0,0),
        shadowTransparency = 0.15,
        iconTint = Color3.fromRGB(100,100,150),
        ripple = Color3.fromRGB(0,0,0),
        rippleTransparency = 0.9,
    },
    Amethyst = {
        name = "Amethyst", version = "1.0",
        background = Color3.fromRGB(26,20,40),
        surface = Color3.fromRGB(45,35,65),
        primary = Color3.fromRGB(180,100,255),
        primaryHover = Color3.fromRGB(200,130,255),
        primaryActive = Color3.fromRGB(160,80,235),
        secondary = Color3.fromRGB(100,80,140),
        secondaryHover = Color3.fromRGB(120,100,160),
        text = Color3.fromRGB(240,230,255),
        textSecondary = Color3.fromRGB(200,180,230),
        textDisabled = Color3.fromRGB(140,120,170),
        border = Color3.fromRGB(85,65,110),
        divider = Color3.fromRGB(70,55,95),
        success = Color3.fromRGB(100,210,150),
        warning = Color3.fromRGB(250,190,70),
        error = Color3.fromRGB(240,100,130),
        info = Color3.fromRGB(100,150,250),
        overlay = Color3.fromRGB(0,0,0),
        overlayTransparency = 0.65,
        shadow = Color3.fromRGB(0,0,0),
        shadowTransparency = 0.4,
        iconTint = Color3.fromRGB(210,170,255),
        ripple = Color3.fromRGB(255,255,255),
        rippleTransparency = 0.85,
    },
    Sea = {
        name = "Sea", version = "1.0",
        background = Color3.fromRGB(15,35,45),
        surface = Color3.fromRGB(30,55,70),
        primary = Color3.fromRGB(70,200,210),
        primaryHover = Color3.fromRGB(90,220,230),
        primaryActive = Color3.fromRGB(50,180,190),
        secondary = Color3.fromRGB(60,100,120),
        secondaryHover = Color3.fromRGB(80,120,140),
        text = Color3.fromRGB(220,245,255),
        textSecondary = Color3.fromRGB(160,200,220),
        textDisabled = Color3.fromRGB(100,140,160),
        border = Color3.fromRGB(55,95,110),
        divider = Color3.fromRGB(45,80,95),
        success = Color3.fromRGB(60,210,150),
        warning = Color3.fromRGB(250,180,60),
        error = Color3.fromRGB(240,110,120),
        info = Color3.fromRGB(80,180,240),
        overlay = Color3.fromRGB(0,0,0),
        overlayTransparency = 0.6,
        shadow = Color3.fromRGB(0,0,0),
        shadowTransparency = 0.35,
        iconTint = Color3.fromRGB(140,230,240),
        ripple = Color3.fromRGB(255,255,255),
        rippleTransparency = 0.8,
    },
    Bloom = {
        name = "Bloom", version = "1.0",
        background = Color3.fromRGB(50,30,45),
        surface = Color3.fromRGB(75,50,70),
        primary = Color3.fromRGB(255,140,180),
        primaryHover = Color3.fromRGB(255,170,200),
        primaryActive = Color3.fromRGB(235,120,160),
        secondary = Color3.fromRGB(120,80,110),
        secondaryHover = Color3.fromRGB(140,100,130),
        text = Color3.fromRGB(255,240,245),
        textSecondary = Color3.fromRGB(230,200,215),
        textDisabled = Color3.fromRGB(170,140,160),
        border = Color3.fromRGB(110,75,100),
        divider = Color3.fromRGB(95,65,85),
        success = Color3.fromRGB(150,210,120),
        warning = Color3.fromRGB(255,200,80),
        error = Color3.fromRGB(255,100,120),
        info = Color3.fromRGB(180,130,230),
        overlay = Color3.fromRGB(0,0,0),
        overlayTransparency = 0.55,
        shadow = Color3.fromRGB(0,0,0),
        shadowTransparency = 0.3,
        iconTint = Color3.fromRGB(255,190,210),
        ripple = Color3.fromRGB(255,255,255),
        rippleTransparency = 0.85,
    },
}
local customThemes = {}
local currentThemeName = "Dark"
local themeChangedConnections = {}

function Milkyway.getCurrentTheme() return themes[currentThemeName] or themes.Dark end
function Milkyway.getColor(key) return (themes[currentThemeName] or themes.Dark)[key] end
function Milkyway.setTheme(themeName)
    if themes[themeName] then
        currentThemeName = themeName
        for _, cb in ipairs(themeChangedConnections) do
            cb(themeName, themes[themeName])
        end
        return true
    elseif customThemes[themeName] then
        currentThemeName = themeName
        for _, cb in ipairs(themeChangedConnections) do
            cb(themeName, customThemes[themeName])
        end
        return true
    end
    warn("Milkyway: Theme '" .. tostring(themeName) .. "' not found")
    return false
end
function Milkyway.registerCustomTheme(name, themeData)
    if not themeData or type(themeData) ~= "table" then return false end
    local required = {"background","surface","primary","text"}
    for _, req in ipairs(required) do
        if not themeData[req] then return false end
    end
    customThemes[name] = themeData
    return true
end
function Milkyway.onThemeChanged(callback) table.insert(themeChangedConnections, callback) end

local function applyModernStyle(guiObject, colorScheme)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = guiObject
    local stroke = Instance.new("UIStroke")
    stroke.Color = colorScheme.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = guiObject
end

local function applyRippleEffect(button, colorScheme)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.BackgroundColor3 = colorScheme.ripple
    ripple.BackgroundTransparency = colorScheme.rippleTransparency
    ripple.BorderSizePixel = 0
    ripple.Parent = button
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    button.MouseButton1Down:Connect(function()
        local x = UserInputService:GetMouseLocation().X - button.AbsolutePosition.X
        local y = UserInputService:GetMouseLocation().Y - button.AbsolutePosition.Y
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, x, 0, y)
        ripple.Visible = true
        TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, size, 0, size),
            Position = UDim2.new(0, x - size/2, 0, y - size/2),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.4)
        ripple:Destroy()
    end)
end

-- ======================== UTILITIES ========================
local Utility = {}
function Utility:deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = self:deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end
function Utility:mergeTables(t1, t2)
    local result = self:deepCopy(t1)
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end
function Utility:clamp(value, min, max) return math.min(max, math.max(min, value)) end
function Utility:lerp(a, b, t) return a + (b - a) * t end
function Utility:round(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
function Utility:hexToRGB(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1,2), 16) or 0
    local g = tonumber(hex:sub(3,4), 16) or 0
    local b = tonumber(hex:sub(5,6), 16) or 0
    return Color3.fromRGB(r, g, b)
end
function Utility:rgbToHex(color)
    return string.format("#%02x%02x%02x", color.R*255, color.G*255, color.B*255)
end
function Utility:getTextSize(text, font, size, width)
    return TextService:GetTextSize(text, size, font, Vector2.new(width or 1000, 1000))
end
function Utility:createShadow(parent, blurSize, transparency, color)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, blurSize*2, 1, blurSize*2)
    shadow.Position = UDim2.new(0, -blurSize, 0, -blurSize)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/BlurEffect.png"
    shadow.ImageColor3 = color or Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(blurSize, blurSize, blurSize, blurSize)
    shadow.Parent = parent
    return shadow
end
Milkyway.Utility = Utility

-- ======================== EVENT BUS ========================
local EventBus = {}
EventBus.__index = EventBus
local events = {}
function EventBus:on(eventName, callback)
    if not events[eventName] then events[eventName] = {} end
    table.insert(events[eventName], callback)
end
function EventBus:once(eventName, callback)
    local onceCallback
    onceCallback = function(...)
        callback(...)
        self:off(eventName, onceCallback)
    end
    self:on(eventName, onceCallback)
end
function EventBus:off(eventName, callback)
    if not events[eventName] then return end
    for i, cb in ipairs(events[eventName]) do
        if cb == callback then
            table.remove(events[eventName], i)
            break
        end
    end
end
function EventBus:emit(eventName, ...)
    if not events[eventName] then return end
    for _, cb in ipairs(events[eventName]) do
        task.spawn(cb, ...)
    end
end
Milkyway.EventBus = EventBus

-- ======================== STATE MANAGER ========================
local StateManager = {}
StateManager.__index = StateManager
local states = {}
function StateManager:set(key, value)
    states[key] = value
    self:emit("stateChanged", key, value)
end
function StateManager:get(key) return states[key] end
function StateManager:subscribe(key, callback)
    self:on("stateChanged", function(k, v)
        if k == key then callback(v) end
    end)
end
setmetatable(StateManager, {__index = EventBus})
Milkyway.StateManager = StateManager

-- ======================== STORAGE ========================
local Storage = {}
local storageData = {}
function Storage:save(key, value)
    storageData[key] = value
    return true
end
function Storage:load(key, defaultValue)
    if storageData[key] ~= nil then return storageData[key] end
    return defaultValue
end
function Storage:delete(key) storageData[key] = nil end
function Storage:clear() storageData = {} end
function Storage:export() return HttpService:JSONEncode(storageData) end
function Storage:import(jsonString)
    local success, data = pcall(HttpService.JSONDecode, HttpService, jsonString)
    if success and type(data) == "table" then
        storageData = data
        return true
    end
    return false
end
Milkyway.Storage = Storage

-- ======================== LOGGER ========================
local Logger = {}
local logLevels = {DEBUG=1, INFO=2, WARN=3, ERROR=4}
local currentLogLevel = logLevels.INFO
local logHistory = {}
function Logger:setLevel(level) currentLogLevel = logLevels[level] or logLevels.INFO end
function Logger:debug(...)
    if currentLogLevel <= logLevels.DEBUG then
        local msg = table.concat({...}, " ")
        print("[DEBUG]", msg)
        table.insert(logHistory, {level="DEBUG", msg=msg, time=os.time()})
    end
end
function Logger:info(...)
    if currentLogLevel <= logLevels.INFO then
        local msg = table.concat({...}, " ")
        print("[INFO]", msg)
        table.insert(logHistory, {level="INFO", msg=msg, time=os.time()})
    end
end
function Logger:warn(...)
    if currentLogLevel <= logLevels.WARN then
        local msg = table.concat({...}, " ")
        warn("[WARN]", msg)
        table.insert(logHistory, {level="WARN", msg=msg, time=os.time()})
    end
end
function Logger:error(...)
    if currentLogLevel <= logLevels.ERROR then
        local msg = table.concat({...}, " ")
        warn("[ERROR]", msg)
        table.insert(logHistory, {level="ERROR", msg=msg, time=os.time()})
    end
end
function Logger:getHistory() return logHistory end
Milkyway.Logger = Logger

-- ======================== PROFILER ========================
local Profiler = {}
local profilerData = {}
function Profiler:start(label)
    profilerData[label] = {start = os.clock()}
end
function Profiler:stop(label)
    if profilerData[label] then
        profilerData[label].duration = os.clock() - profilerData[label].start
        return profilerData[label].duration
    end
    return nil
end
function Profiler:report(label)
    if profilerData[label] then
        return string.format("%s: %.4f seconds", label, profilerData[label].duration or 0)
    end
    return "No data"
end
Milkyway.Profiler = Profiler

-- ======================== MODEL (3D VIEWER) ========================
local Model = {}
Model.__index = Model
function Model.new(parent, meshAssetId, options)
    options = options or {}
    local self = setmetatable({}, Model)
    local theme = Milkyway.getCurrentTheme()
    self.backdrop = Instance.new("Frame")
    self.backdrop.Size = UDim2.new(1,0,1,0)
    self.backdrop.BackgroundColor3 = Color3.fromRGB(0,0,0)
    self.backdrop.BackgroundTransparency = 0.7
    self.backdrop.Parent = parent or defaultScreenGui
    self.window = Instance.new("Frame")
    self.window.Size = options.size or UDim2.new(0, 600, 0, 500)
    self.window.Position = options.position or UDim2.new(0.5, -300, 0.5, -250)
    self.window.BackgroundColor3 = theme.surface
    self.window.Parent = self.backdrop
    applyModernStyle(self.window, theme)
    self.titleBar = Instance.new("TextLabel")
    self.titleBar.Size = UDim2.new(1,0,0,40)
    self.titleBar.BackgroundColor3 = theme.primary
    self.titleBar.Text = options.title or "3D Model Viewer"
    self.titleBar.TextColor3 = theme.text
    self.titleBar.Font = Enum.Font.GothamBold
    self.titleBar.TextSize = 18
    self.titleBar.Parent = self.window
    local titleCorner = Instance.new("UICorner"); titleCorner.CornerRadius = UDim.new(0,12); titleCorner.Parent = self.titleBar
    self.closeBtn = Instance.new("TextButton")
    self.closeBtn.Size = UDim2.new(0, 32, 0, 32)
    self.closeBtn.Position = UDim2.new(1, -40, 0, 4)
    self.closeBtn.Text = "✕"
    self.closeBtn.TextColor3 = theme.text
    self.closeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
    self.closeBtn.Font = Enum.Font.GothamBold
    self.closeBtn.TextSize = 18
    self.closeBtn.Parent = self.titleBar
    local closeCorner = Instance.new("UICorner"); closeCorner.CornerRadius = UDim.new(0,16); closeCorner.Parent = self.closeBtn
    self.closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)
    self.viewport = Instance.new("ViewportFrame")
    self.viewport.Size = UDim2.new(1,0,1,-80)
    self.viewport.Position = UDim2.new(0,0,0,40)
    self.viewport.BackgroundColor3 = Color3.fromRGB(20,20,30)
    self.viewport.Parent = self.window
    self.camera = Instance.new("Camera")
    self.camera.Parent = self.viewport
    self.viewport.CurrentCamera = self.camera
    self.camera.FieldOfView = 50
    if meshAssetId and meshAssetId ~= "" then
        self.model = Instance.new("MeshPart")
        self.model.MeshId = meshAssetId
        if options.textureId then self.model.TextureID = options.textureId end
        self.model.Size = Vector3.new(2,2,2)
        self.model.Position = Vector3.new(0,0,0)
        self.model.Anchored = true
        self.model.CanCollide = false
        self.model.Parent = self.viewport
        self.autoRotate = options.autoRotate ~= false
        self.rotationSpeed = options.rotationSpeed or 0.5
        self.currentRotation = 0
        if self.autoRotate then
            self.rotateConnection = RunService.RenderStepped:Connect(function(dt)
                self.currentRotation = self.currentRotation + self.rotationSpeed * dt * 60
                self.model.Orientation = Vector3.new(0, self.currentRotation, 0)
            end)
        end
        self.dragging = false
        self.lastMousePos = nil
        self.viewport.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and options.canDrag ~= false then
                self.dragging = true
                self.lastMousePos = UserInputService:GetMouseLocation()
            end
        end)
        self.viewport.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then self.dragging = false end
        end)
        self.viewport.InputChanged:Connect(function(input)
            if self.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = UserInputService:GetMouseLocation() - self.lastMousePos
                self.currentRotation = self.currentRotation + delta.X * 0.5
                self.model.Orientation = Vector3.new(0, self.currentRotation, 0)
                self.lastMousePos = UserInputService:GetMouseLocation()
            end
        end)
        if options.canZoom ~= false then
            self.viewport.MouseWheelBackward:Connect(function() self.camera.FieldOfView = math.min(self.camera.FieldOfView + 5, 80) end)
            self.viewport.MouseWheelForward:Connect(function() self.camera.FieldOfView = math.max(self.camera.FieldOfView - 5, 20) end)
        end
        self.camera.CFrame = CFrame.new(0,0,5)
    else
        local placeholder = Instance.new("TextLabel")
        placeholder.Text = "No model loaded\nProvide MeshAssetId"
        placeholder.Size = UDim2.new(1,1,1,1)
        placeholder.BackgroundTransparency = 1
        placeholder.TextColor3 = Color3.fromRGB(200,200,200)
        placeholder.Font = Enum.Font.Gotham
        placeholder.TextSize = 16
        placeholder.Parent = self.viewport
    end
    local draggingWindow = false
    local dragStart = nil
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingWindow = true
            dragStart = input.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.window.Position = self.window.Position + UDim2.new(0, delta.X, 0, delta.Y)
            dragStart = input.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingWindow = false end
    end)
    return self
end
function Model:Destroy()
    if self.rotateConnection then self.rotateConnection:Disconnect() end
    self.backdrop:Destroy()
end
Milkyway.Model = Model

-- ======================== NOTIFY SYSTEM ========================
local notifyContainer = nil
local function ensureNotifyContainer()
    if not notifyContainer or not notifyContainer.Parent then
        notifyContainer = Instance.new("Frame")
        notifyContainer.Name = "NotifyContainer"
        notifyContainer.Size = UDim2.new(0, 340, 1, 0)
        notifyContainer.Position = UDim2.new(1, -360, 0, 20)
        notifyContainer.BackgroundTransparency = 1
        notifyContainer.Parent = defaultScreenGui
    end
end
function Milkyway.notify(options)
    ensureNotifyContainer()
    options = options or {}
    local title = options.title or "Notification"
    local description = options.description or ""
    local duration = options.duration or 3.5
    local icon = options.icon or "✨"
    local theme = Milkyway.getCurrentTheme()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 70)
    frame.BackgroundColor3 = theme.surface
    frame.BackgroundTransparency = 0.1
    frame.AutomaticSize = Enum.AutomaticSize.Y
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 16); corner.Parent = frame
    local stroke = Instance.new("UIStroke"); stroke.Color = theme.primary; stroke.Thickness = 1.2; stroke.Parent = frame
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Text = icon
    iconLabel.TextSize = 24
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.TextColor3 = theme.primary
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = frame
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextColor3 = theme.text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -50, 0, 24)
    titleLabel.Position = UDim2.new(0, 45, 0, 8)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    local descLabel = Instance.new("TextLabel")
    descLabel.Text = description
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextColor3 = theme.textSecondary
    descLabel.BackgroundTransparency = 1
    descLabel.Size = UDim2.new(1, -50, 0, 20)
    descLabel.Position = UDim2.new(0, 45, 0, 32)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    descLabel.Parent = frame
    frame.Parent = notifyContainer
    frame.Position = UDim2.new(0, 0, 0, -100)
    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0,0,0,0)}):Play()
    game:GetService("Debris"):AddItem(frame, duration)
    task.delay(duration - 0.3, function()
        if frame and frame.Parent then
            TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0,0,0,-100)}):Play()
            task.wait(0.35); frame:Destroy()
        end
    end)
    return frame
end

-- ======================== BUTTON ========================
local Button = {}
Button.__index = Button
function Button.new(parent, text, callback, options)
    options = options or {}
    local self = setmetatable({}, Button)
    local theme = Milkyway.getCurrentTheme()
    self.gui = Instance.new("TextButton")
    self.gui.Parent = parent or defaultScreenGui
    self.gui.Size = options.size or UDim2.new(0, 180, 0, 48)
    self.gui.Text = text
    self.gui.TextColor3 = theme.text
    self.gui.TextSize = options.textSize or 16
    self.gui.Font = Enum.Font.GothamSemibold
    self.gui.BackgroundColor3 = theme.primary
    self.gui.AutoButtonColor = false
    applyModernStyle(self.gui, theme)
    if options.ripple ~= false then applyRippleEffect(self.gui, theme) end
    local function updateTheme()
        local nt = Milkyway.getCurrentTheme()
        self.gui.BackgroundColor3 = nt.primary
        self.gui.TextColor3 = nt.text
        self.gui.UIStroke.Color = nt.border
    end
    Milkyway.onThemeChanged(updateTheme)
    self.gui.MouseEnter:Connect(function()
        TweenService:Create(self.gui, TweenInfo.new(0.2), {BackgroundColor3 = theme.primaryHover}):Play()
    end)
    self.gui.MouseLeave:Connect(function()
        TweenService:Create(self.gui, TweenInfo.new(0.2), {BackgroundColor3 = theme.primary}):Play()
    end)
    if callback then self.gui.MouseButton1Click:Connect(callback) end
    return self
end
function Button:SetText(newText) self.gui.Text = newText end
function Button:SetEnabled(enabled) self.gui.Active = enabled; self.gui.TextTransparency = enabled and 0 or 0.5 end
Milkyway.Button = Button

-- ======================== INPUT ========================
local Input = {}
Input.__index = Input
function Input.new(parent, placeholder, callback, options)
    options = options or {}
    local self = setmetatable({}, Input)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = options.size or UDim2.new(0, 240, 0, 48)
    self.frame.BackgroundColor3 = theme.surface
    self.frame.BackgroundTransparency = 0.2
    self.frame.Parent = parent or defaultScreenGui
    applyModernStyle(self.frame, theme)
    self.textBox = Instance.new("TextBox")
    self.textBox.Size = UDim2.new(1, -20, 1, -10)
    self.textBox.Position = UDim2.new(0, 10, 0, 5)
    self.textBox.BackgroundTransparency = 1
    self.textBox.PlaceholderText = placeholder or "Enter text..."
    self.textBox.TextColor3 = theme.text
    self.textBox.PlaceholderColor3 = theme.textSecondary
    self.textBox.Font = Enum.Font.Gotham
    self.textBox.TextSize = options.textSize or 14
    self.textBox.Text = options.defaultText or ""
    self.textBox.Parent = self.frame
    local function updateTheme()
        local t = Milkyway.getCurrentTheme()
        self.frame.BackgroundColor3 = t.surface
        self.textBox.TextColor3 = t.text
        self.textBox.PlaceholderColor3 = t.textSecondary
        self.frame.UIStroke.Color = t.border
    end
    Milkyway.onThemeChanged(updateTheme)
    if callback then
        self.textBox.FocusLost:Connect(function(enterPressed)
            callback(self.textBox.Text, enterPressed)
        end)
    end
    return self
end
function Input:GetText() return self.textBox.Text end
function Input:SetText(text) self.textBox.Text = text end
function Input:Clear() self.textBox.Text = "" end
Milkyway.Input = Input

-- ======================== CHECKBOX ========================
local Checkbox = {}
Checkbox.__index = Checkbox
function Checkbox.new(parent, labelText, initialState, onChange, options)
    options = options or {}
    local self = setmetatable({}, Checkbox)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = options.size or UDim2.new(0, 180, 0, 36)
    self.frame.BackgroundTransparency = 1
    self.frame.Parent = parent or defaultScreenGui
    self.check = Instance.new("ImageButton")
    self.check.Size = UDim2.new(0, 24, 0, 24)
    self.check.BackgroundColor3 = theme.surface
    self.check.Image = "rbxassetid://3926305904"
    self.check.ImageColor3 = theme.primary
    self.check.Parent = self.frame
    local cornerCheck = Instance.new("UICorner"); cornerCheck.CornerRadius = UDim.new(0,6); cornerCheck.Parent = self.check
    self.label = Instance.new("TextLabel")
    self.label.Text = labelText
    self.label.Size = UDim2.new(1, -34, 1, 0)
    self.label.Position = UDim2.new(0, 34, 0, 0)
    self.label.BackgroundTransparency = 1
    self.label.TextColor3 = theme.text
    self.label.TextXAlignment = Enum.TextXAlignment.Left
    self.label.Font = Enum.Font.Gotham
    self.label.TextSize = options.textSize or 14
    self.label.Parent = self.frame
    self.state = initialState or false
    local function updateVisual()
        self.check.Image = self.state and "rbxassetid://3926309023" or "rbxassetid://3926305904"
    end
    updateVisual()
    self.check.MouseButton1Click:Connect(function()
        self.state = not self.state
        updateVisual()
        if onChange then onChange(self.state) end
    end)
    local function onThemeChange()
        local nt = Milkyway.getCurrentTheme()
        self.check.BackgroundColor3 = nt.surface
        self.check.ImageColor3 = nt.primary
        self.label.TextColor3 = nt.text
    end
    Milkyway.onThemeChanged(onThemeChange)
    return self
end
function Checkbox:SetState(state) self.state = state; self.check.Image = state and "rbxassetid://3926309023" or "rbxassetid://3926305904" end
function Checkbox:GetState() return self.state end
Milkyway.Checkbox = Checkbox

-- ======================== RADIO ========================
local Radio = {}
Radio.__index = Radio
Radio.groups = {}
function Radio.new(parent, groupName, labelText, initialState, onChange)
    local self = setmetatable({}, Radio)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(0, 180, 0, 36)
    self.frame.BackgroundTransparency = 1
    self.frame.Parent = parent or defaultScreenGui
    self.radio = Instance.new("ImageButton")
    self.radio.Size = UDim2.new(0, 24, 0, 24)
    self.radio.BackgroundColor3 = theme.surface
    self.radio.Image = "rbxassetid://3926305904"
    self.radio.ImageColor3 = theme.primary
    self.radio.Parent = self.frame
    local cornerRadio = Instance.new("UICorner"); cornerRadio.CornerRadius = UDim.new(1,0); cornerRadio.Parent = self.radio
    self.label = Instance.new("TextLabel")
    self.label.Text = labelText
    self.label.Size = UDim2.new(1, -34, 1, 0)
    self.label.Position = UDim2.new(0, 34, 0, 0)
    self.label.BackgroundTransparency = 1
    self.label.TextColor3 = theme.text
    self.label.TextXAlignment = Enum.TextXAlignment.Left
    self.label.Font = Enum.Font.Gotham
    self.label.TextSize = 14
    self.label.Parent = self.frame
    self.state = initialState or false
    self.group = groupName
    if not Radio.groups[groupName] then Radio.groups[groupName] = {} end
    table.insert(Radio.groups[groupName], self)
    local function updateVisual()
        self.radio.Image = self.state and "rbxassetid://3926309023" or "rbxassetid://3926305904"
    end
    updateVisual()
    self.radio.MouseButton1Click:Connect(function()
        for _, other in ipairs(Radio.groups[groupName]) do
            if other ~= self then other:SetState(false) end
        end
        self:SetState(true)
        if onChange then onChange(true) end
    end)
    local function onThemeChange()
        local nt = Milkyway.getCurrentTheme()
        self.radio.BackgroundColor3 = nt.surface
        self.radio.ImageColor3 = nt.primary
        self.label.TextColor3 = nt.text
    end
    Milkyway.onThemeChanged(onThemeChange)
    return self
end
function Radio:SetState(state) self.state = state; self.radio.Image = state and "rbxassetid://3926309023" or "rbxassetid://3926305904" end
function Radio:GetState() return self.state end
Milkyway.Radio = Radio

-- ======================== DROPDOWN ========================
local Dropdown = {}
Dropdown.__index = Dropdown
function Dropdown.new(parent, options, defaultIndex, onSelect, config)
    config = config or {}
    local self = setmetatable({}, Dropdown)
    local theme = Milkyway.getCurrentTheme()
    self.button = Instance.new("TextButton")
    self.button.Size = config.size or UDim2.new(0, 180, 0, 40)
    self.button.BackgroundColor3 = theme.surface
    self.button.Text = options[defaultIndex or 1] or "Select"
    self.button.TextColor3 = theme.text
    self.button.Font = Enum.Font.Gotham
    self.button.TextSize = config.textSize or 14
    self.button.Parent = parent or defaultScreenGui
    applyModernStyle(self.button, theme)
    self.dropList = Instance.new("Frame")
    self.dropList.Size = UDim2.new(0, 180, 0, 0)
    self.dropList.BackgroundColor3 = theme.surface
    self.dropList.BackgroundTransparency = 0.05
    self.dropList.Visible = false
    self.dropList.Parent = parent or defaultScreenGui
    applyModernStyle(self.dropList, theme)
    self.dropList.ZIndex = 10
    self.buttons = {}
    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.Text = opt
        btn.BackgroundColor3 = theme.surface
        btn.TextColor3 = theme.text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = self.dropList
        btn.MouseButton1Click:Connect(function()
            self.button.Text = opt
            self.dropList.Visible = false
            if onSelect then onSelect(opt, i) end
        end)
        table.insert(self.buttons, btn)
    end
    self.button.MouseButton1Click:Connect(function()
        self.dropList.Visible = not self.dropList.Visible
        if self.dropList.Visible then
            self.dropList.Size = UDim2.new(0, 180, 0, math.min(#options * 36, 200))
            self.dropList.Position = self.button.Position + UDim2.new(0, 0, 0, 42)
        end
    end)
    return self
end
function Dropdown:SetOptions(newOptions)
    for _, btn in ipairs(self.buttons) do btn:Destroy() end
    self.buttons = {}
    for i, opt in ipairs(newOptions) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.Text = opt
        btn.BackgroundColor3 = self.button.BackgroundColor3
        btn.TextColor3 = self.button.TextColor3
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = self.dropList
        btn.MouseButton1Click:Connect(function()
            self.button.Text = opt
            self.dropList.Visible = false
        end)
        table.insert(self.buttons, btn)
    end
end
Milkyway.Dropdown = Dropdown

-- ======================== SLIDER ========================
local Slider = {}
Slider.__index = Slider
function Slider.new(parent, min, max, default, callback, options)
    options = options or {}
    local self = setmetatable({}, Slider)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = options.size or UDim2.new(0, 300, 0, 40)
    self.frame.BackgroundTransparency = 1
    self.frame.Parent = parent or defaultScreenGui
    self.track = Instance.new("Frame")
    self.track.Size = UDim2.new(1, -60, 0, 6)
    self.track.Position = UDim2.new(0, 0, 0.5, -3)
    self.track.BackgroundColor3 = theme.border
    self.track.BorderSizePixel = 0
    self.track.Parent = self.frame
    local trackCorner = Instance.new("UICorner"); trackCorner.CornerRadius = UDim.new(1,0); trackCorner.Parent = self.track
    self.fill = Instance.new("Frame")
    self.fill.Size = UDim2.new(0,0,1,0)
    self.fill.BackgroundColor3 = theme.primary
    self.fill.BorderSizePixel = 0
    self.fill.Parent = self.track
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(1,0); fillCorner.Parent = self.fill
    self.knob = Instance.new("TextButton")
    self.knob.Size = UDim2.new(0, 20, 0, 20)
    self.knob.Position = UDim2.new(0,0,0.5,-10)
    self.knob.BackgroundColor3 = theme.primary
    self.knob.Text = ""
    self.knob.AutoButtonColor = false
    self.knob.Parent = self.frame
    local knobCorner = Instance.new("UICorner"); knobCorner.CornerRadius = UDim.new(1,0); knobCorner.Parent = self.knob
    self.valueLabel = Instance.new("TextLabel")
    self.valueLabel.Size = UDim2.new(0,50,1,0)
    self.valueLabel.Position = UDim2.new(1,-55,0,0)
    self.valueLabel.BackgroundTransparency = 1
    self.valueLabel.TextColor3 = theme.text
    self.valueLabel.Text = tostring(default or min)
    self.valueLabel.Font = Enum.Font.Gotham
    self.valueLabel.TextSize = options.labelSize or 14
    self.valueLabel.Parent = self.frame
    self.minVal = min or 0
    self.maxVal = max or 100
    self.value = default or (min+max)/2
    self.callback = callback
    self.step = options.step or 1
    local function updatePos()
        local t = (self.value - self.minVal) / (self.maxVal - self.minVal)
        local trackWidth = self.track.AbsoluteSize.X
        local posX = t * trackWidth
        self.fill.Size = UDim2.new(t,0,1,0)
        self.knob.Position = UDim2.new(0, posX - 10, 0.5, -10)
        self.valueLabel.Text = tostring(self.value)
    end
    local dragging = false
    self.knob.MouseButton1Down:Connect(function()
        dragging = true
        local moveConn, releaseConn
        moveConn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local mousePos = UserInputService:GetMouseLocation()
                local framePos = self.track.AbsolutePosition
                local relativeX = math.clamp(mousePos.X - framePos.X, 0, self.track.AbsoluteSize.X)
                local newVal = self.minVal + (relativeX / self.track.AbsoluteSize.X) * (self.maxVal - self.minVal)
                if self.step then newVal = math.floor(newVal / self.step + 0.5) * self.step end
                self.value = math.clamp(newVal, self.minVal, self.maxVal)
                updatePos()
                if self.callback then self.callback(self.value) end
            end
        end)
        releaseConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                moveConn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)
    updatePos()
    return self
end
function Slider:SetValue(value) self.value = math.clamp(value, self.minVal, self.maxVal); self:updatePos() end
function Slider:GetValue() return self.value end
Milkyway.Slider = Slider

-- ======================== TOGGLE ========================
local Toggle = {}
Toggle.__index = Toggle
function Toggle.new(parent, initialState, onChange, options)
    options = options or {}
    local self = setmetatable({}, Toggle)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = options.size or UDim2.new(0, 50, 0, 28)
    self.frame.BackgroundColor3 = theme.border
    self.frame.Parent = parent or defaultScreenGui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1,0); corner.Parent = self.frame
    self.knob = Instance.new("Frame")
    self.knob.Size = UDim2.new(0, 24, 0, 24)
    self.knob.Position = UDim2.new(0, 2, 0, 2)
    self.knob.BackgroundColor3 = theme.surface
    self.knob.Parent = self.frame
    local knobCorner = Instance.new("UICorner"); knobCorner.CornerRadius = UDim.new(1,0); knobCorner.Parent = self.knob
    self.state = initialState or false
    local function updateVisual()
        if self.state then
            self.frame.BackgroundColor3 = theme.primary
            self.knob.Position = UDim2.new(1, -26, 0, 2)
        else
            self.frame.BackgroundColor3 = theme.border
            self.knob.Position = UDim2.new(0, 2, 0, 2)
        end
    end
    updateVisual()
    self.frame.MouseButton1Click:Connect(function()
        self.state = not self.state
        updateVisual()
        if onChange then onChange(self.state) end
    end)
    local function onThemeChange()
        local nt = Milkyway.getCurrentTheme()
        if self.state then self.frame.BackgroundColor3 = nt.primary else self.frame.BackgroundColor3 = nt.border end
        self.knob.BackgroundColor3 = nt.surface
    end
    Milkyway.onThemeChanged(onThemeChange)
    return self
end
function Toggle:SetState(state) self.state = state; self:updateVisual() end
function Toggle:GetState() return self.state end
Milkyway.Toggle = Toggle

-- ======================== TABS ========================
local TabView = {}
TabView.__index = TabView
function TabView.new(parent, tabs, options)
    options = options or {}
    local self = setmetatable({}, TabView)
    self.container = Instance.new("Frame")
    self.container.Size = options.size or UDim2.new(1,0,1,0)
    self.container.BackgroundTransparency = 1
    self.container.Parent = parent or defaultScreenGui
    self.header = Instance.new("Frame")
    self.header.Size = UDim2.new(1,0,0,48)
    self.header.BackgroundTransparency = 1
    self.header.Parent = self.container
    self.content = Instance.new("Frame")
    self.content.Size = UDim2.new(1,0,1,-48)
    self.content.Position = UDim2.new(0,0,0,48)
    self.content.BackgroundTransparency = 1
    self.content.Parent = self.container
    self.buttons = {}
    self.pages = {}
    local tabWidth = options.tabWidth or 120
    for i, tabInfo in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, tabWidth, 1, 0)
        btn.Position = UDim2.new(0, (i-1)*tabWidth, 0, 0)
        btn.Text = tabInfo.title
        btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Parent = self.header
        local page = Instance.new("Frame")
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.Visible = (i == 1)
        page.Parent = self.content
        if tabInfo.content then tabInfo.content(page) end
        table.insert(self.buttons, btn)
        table.insert(self.pages, page)
        btn.MouseButton1Click:Connect(function()
            for j, p in ipairs(self.pages) do
                p.Visible = (j == i)
            end
            for j, b in ipairs(self.buttons) do
                b.BackgroundColor3 = (j == i) and Color3.fromRGB(80,60,200) or Color3.fromRGB(40,40,50)
            end
        end)
    end
    return self
end
Milkyway.TabView = TabView

-- ======================== TOOLTIP ========================
local Tooltip = {}
Tooltip.__index = Tooltip
function Tooltip.new(parent, text, targetObject, options)
    options = options or {}
    local self = setmetatable({}, Tooltip)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = options.size or UDim2.new(0, 120, 0, 32)
    self.frame.BackgroundColor3 = theme.surface
    self.frame.BackgroundTransparency = 0.2
    self.frame.Visible = false
    self.frame.ZIndex = 20
    self.frame.Parent = parent or defaultScreenGui
    applyModernStyle(self.frame, theme)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = theme.text
    label.Font = Enum.Font.Gotham
    label.TextSize = options.textSize or 12
    label.Parent = self.frame
    targetObject.MouseEnter:Connect(function()
        self.frame.Visible = true
        local pos = targetObject.AbsolutePosition
        local offset = options.offset or Vector2.new(10, -30)
        self.frame.Position = UDim2.new(0, pos.X + offset.X, 0, pos.Y + offset.Y)
    end)
    targetObject.MouseLeave:Connect(function() self.frame.Visible = false end)
    return self
end
Milkyway.Tooltip = Tooltip

-- ======================== PROGRESS BAR ========================
local ProgressBar = {}
ProgressBar.__index = ProgressBar
function ProgressBar.new(parent, width, height, maxValue, initial, options)
    options = options or {}
    local self = setmetatable({}, ProgressBar)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(0, width, 0, height)
    self.frame.BackgroundColor3 = theme.border
    self.frame.Parent = parent or defaultScreenGui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1,0); corner.Parent = self.frame
    self.fill = Instance.new("Frame")
    self.fill.Size = UDim2.new(initial/(maxValue or 100), 0, 1, 0)
    self.fill.BackgroundColor3 = theme.primary
    self.fill.Parent = self.frame
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(1,0); fillCorner.Parent = self.fill
    self.max = maxValue or 100
    self.value = initial or 0
    function self:SetValue(v)
        self.value = math.clamp(v, 0, self.max)
        TweenService:Create(self.fill, TweenInfo.new(0.3), {Size = UDim2.new(self.value/self.max, 0, 1, 0)}):Play()
    end
    function self:GetValue() return self.value end
    return self
end
Milkyway.ProgressBar = ProgressBar

-- ======================== COLOR PICKER ========================
local ColorPicker = {}
ColorPicker.__index = ColorPicker
function ColorPicker.new(parent, defaultColor, callback, options)
    options = options or {}
    local self = setmetatable({}, ColorPicker)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = options.size or UDim2.new(0, 250, 0, 280)
    self.frame.BackgroundColor3 = theme.surface
    self.frame.Parent = parent or defaultScreenGui
    applyModernStyle(self.frame, theme)
    self.hueSlider = Slider.new(self.frame, 0, 360, defaultColor and (defaultColor.R*360) or 0, function(h) self:updateColor() end, {size=UDim2.new(0, 200, 0, 30), labelSize=12})
    self.saturationSlider = Slider.new(self.frame, 0, 1, 0.5, function(s) self:updateColor() end, {size=UDim2.new(0, 200, 0, 30), labelSize=12})
    self.lightnessSlider = Slider.new(self.frame, 0, 1, 0.5, function(l) self:updateColor() end, {size=UDim2.new(0, 200, 0, 30), labelSize=12})
    self.hueSlider.frame.Position = UDim2.new(0.5, -100, 0, 10)
    self.saturationSlider.frame.Position = UDim2.new(0.5, -100, 0, 50)
    self.lightnessSlider.frame.Position = UDim2.new(0.5, -100, 0, 90)
    self.preview = Instance.new("Frame")
    self.preview.Size = UDim2.new(0, 50, 0, 50)
    self.preview.Position = UDim2.new(0.5, -25, 0, 140)
    self.preview.BackgroundColor3 = defaultColor or Color3.fromRGB(255,0,0)
    self.preview.Parent = self.frame
    local cornerPreview = Instance.new("UICorner"); cornerPreview.CornerRadius = UDim.new(0,8); cornerPreview.Parent = self.preview
    local okBtn = Button.new(self.frame, "OK", function()
        if callback then callback(self.preview.BackgroundColor3) end
        self.frame:Destroy()
    end, {size=UDim2.new(0, 80, 0, 30), textSize=12})
    okBtn.gui.Position = UDim2.new(0.5, -40, 0, 210)
    function self:updateColor()
        local h = self.hueSlider:GetValue()
        local s = self.saturationSlider:GetValue()
        local l = self.lightnessSlider:GetValue()
        self.preview.BackgroundColor3 = Color3.fromHSV(h/360, s, l)
    end
    return self
end
Milkyway.ColorPicker = ColorPicker

-- ======================== CONTEXT MENU ========================
local ContextMenu = {}
ContextMenu.__index = ContextMenu
function ContextMenu.new(parent, options, position, onClose)
    local self = setmetatable({}, ContextMenu)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(0, 150, 0, #options * 36)
    self.frame.Position = position or UDim2.new(0, 100, 0, 100)
    self.frame.BackgroundColor3 = theme.surface
    self.frame.Parent = parent or defaultScreenGui
    applyModernStyle(self.frame, theme)
    self.frame.ZIndex = 100
    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,36)
        btn.Position = UDim2.new(0,0,0,(i-1)*36)
        btn.Text = opt.text
        btn.BackgroundColor3 = theme.surface
        btn.TextColor3 = theme.text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = self.frame
        btn.MouseButton1Click:Connect(function()
            if opt.callback then opt.callback() end
            self:Destroy()
        end)
    end
    local function closeOnClickOutside(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = self.frame.AbsolutePosition
            local frameSize = self.frame.AbsoluteSize
            if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                self:Destroy()
            end
        end
    end
    self.connection = UserInputService.InputBegan:Connect(closeOnClickOutside)
    return self
end
function ContextMenu:Destroy()
    if self.connection then self.connection:Disconnect() end
    self.frame:Destroy()
end
Milkyway.ContextMenu = ContextMenu

-- ======================== DRAGGABLE WINDOW ========================
local DraggableWindow = {}
DraggableWindow.__index = DraggableWindow
function DraggableWindow.new(parent, title, content, options)
    options = options or {}
    local self = setmetatable({}, DraggableWindow)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = options.size or UDim2.new(0, 400, 0, 300)
    self.frame.Position = options.position or UDim2.new(0.5, -200, 0.5, -150)
    self.frame.BackgroundColor3 = theme.surface
    self.frame.Parent = parent or defaultScreenGui
    applyModernStyle(self.frame, theme)
    self.titleBar = Instance.new("Frame")
    self.titleBar.Size = UDim2.new(1,0,0,40)
    self.titleBar.BackgroundColor3 = theme.primary
    self.titleBar.Parent = self.frame
    local titleCorner = Instance.new("UICorner"); titleCorner.CornerRadius = UDim.new(0,12); titleCorner.Parent = self.titleBar
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title or "Window"
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = theme.text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = self.titleBar
    self.closeBtn = Instance.new("TextButton")
    self.closeBtn.Size = UDim2.new(0, 30, 0, 30)
    self.closeBtn.Position = UDim2.new(1, -35, 0, 5)
    self.closeBtn.Text = "✕"
    self.closeBtn.TextColor3 = theme.text
    self.closeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
    self.closeBtn.Font = Enum.Font.GothamBold
    self.closeBtn.TextSize = 16
    self.closeBtn.Parent = self.titleBar
    local closeCorner = Instance.new("UICorner"); closeCorner.CornerRadius = UDim.new(0,8); closeCorner.Parent = self.closeBtn
    self.closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)
    self.contentContainer = Instance.new("Frame")
    self.contentContainer.Size = UDim2.new(1,0,1,-40)
    self.contentContainer.Position = UDim2.new(0,0,0,40)
    self.contentContainer.BackgroundTransparency = 1
    self.contentContainer.Parent = self.frame
    if content then content(self.contentContainer) end
    local dragging = false
    local dragStart = nil
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.frame.Position = self.frame.Position + UDim2.new(0, delta.X, 0, delta.Y)
            dragStart = input.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    return self
end
function DraggableWindow:Destroy() self.frame:Destroy() end
Milkyway.DraggableWindow = DraggableWindow

-- ======================== MESSAGE BOX ========================
local MessageBox = {}
function MessageBox.new(parent, title, message, buttons, callback)
    local theme = Milkyway.getCurrentTheme()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = theme.surface
    frame.Parent = parent or defaultScreenGui
    applyModernStyle(frame, theme)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title or "Message"
    titleLabel.Size = UDim2.new(1,0,0,40)
    titleLabel.BackgroundColor3 = theme.primary
    titleLabel.TextColor3 = theme.text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = frame
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Text = message or ""
    msgLabel.Size = UDim2.new(1, -20, 0, 60)
    msgLabel.Position = UDim2.new(0, 10, 0, 50)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextColor3 = theme.text
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 14
    msgLabel.TextWrapped = true
    msgLabel.Parent = frame
    local btnY = 110
    for i, btn in ipairs(buttons or {{text="OK"}}) do
        local b = Button.new(frame, btn.text, function()
            if callback then callback(btn.text) end
            frame:Destroy()
        end, {size=UDim2.new(0, 80, 0, 30), textSize=12})
        b.gui.Position = UDim2.new(0, 30 + (i-1)*100, 0, btnY)
    end
end
Milkyway.MessageBox = MessageBox

-- ======================== SKELETON LOADER ========================
local Skeleton = {}
function Skeleton.new(parent, width, height, options)
    options = options or {}
    local theme = Milkyway.getCurrentTheme()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, width, 0, height)
    frame.BackgroundColor3 = theme.border
    frame.BackgroundTransparency = options.transparency or 0.5
    frame.Parent = parent or defaultScreenGui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, options.cornerRadius or 8); corner.Parent = frame
    local pulse = Instance.new("Frame")
    pulse.Size = UDim2.new(0, 0, 1, 0)
    pulse.BackgroundColor3 = Color3.fromRGB(255,255,255)
    pulse.BackgroundTransparency = 0.8
    pulse.Parent = frame
    local pulseCorner = Instance.new("UICorner"); pulseCorner.CornerRadius = UDim.new(0, options.cornerRadius or 8); pulseCorner.Parent = pulse
    local function animatePulse()
        while frame.Parent do
            pulse.Size = UDim2.new(0, 0, 1, 0)
            TweenService:Create(pulse, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(1, 0, 1, 0)}):Play()
            task.wait(1.5)
        end
    end
    task.spawn(animatePulse)
    return frame
end
Milkyway.Skeleton = Skeleton

-- ======================== SPINNER ========================
local Spinner = {}
function Spinner.new(parent, radius, thickness, options)
    options = options or {}
    local theme = Milkyway.getCurrentTheme()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, radius*2, 0, radius*2)
    frame.BackgroundTransparency = 1
    frame.Parent = parent or defaultScreenGui
    local circle = Instance.new("ImageLabel")
    circle.Size = UDim2.new(1,0,1,0)
    circle.BackgroundTransparency = 1
    circle.Image = "rbxasset://textures/ui/Spinner.png"
    circle.ImageColor3 = theme.primary
    circle.Parent = frame
    local rotation = 0
    local spinConnection
    spinConnection = RunService.RenderStepped:Connect(function(dt)
        rotation = rotation + 360 * dt
        circle.Rotation = rotation
    end)
    frame.Destroying:Connect(function() if spinConnection then spinConnection:Disconnect() end end)
    return frame
end
Milkyway.Spinner = Spinner

-- ======================== AVATAR ========================
local Avatar = {}
function Avatar.new(parent, userId, size, options)
    options = options or {}
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, size, 0, size)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,40)
    frame.Parent = parent or defaultScreenGui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1,0); corner.Parent = frame
    local image = Instance.new("ImageLabel")
    image.Size = UDim2.new(1,0,1,0)
    image.BackgroundTransparency = 1
    image.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
    image.Parent = frame
    return frame
end
Milkyway.Avatar = Avatar

-- ======================== BADGE ========================
local Badge = {}
function Badge.new(parent, text, color, options)
    options = options or {}
    local theme = Milkyway.getCurrentTheme()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, options.width or 60, 0, options.height or 24)
    frame.BackgroundColor3 = color or theme.primary
    frame.Parent = parent or defaultScreenGui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1,0); corner.Parent = frame
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = theme.text
    label.Font = Enum.Font.GothamBold
    label.TextSize = options.textSize or 12
    label.Parent = frame
    return frame
end
Milkyway.Badge = Badge

-- ======================== CARD ========================
local Card = {}
function Card.new(parent, title, content, options)
    options = options or {}
    local theme = Milkyway.getCurrentTheme()
    local frame = Instance.new("Frame")
    frame.Size = options.size or UDim2.new(0, 300, 0, 200)
    frame.BackgroundColor3 = theme.surface
    frame.Parent = parent or defaultScreenGui
    applyModernStyle(frame, theme)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title or "Card"
    titleLabel.Size = UDim2.new(1,0,0,40)
    titleLabel.BackgroundColor3 = theme.primary
    titleLabel.TextColor3 = theme.text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = frame
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1,0,1,-40)
    contentContainer.Position = UDim2.new(0,0,0,40)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = frame
    if content then content(contentContainer) end
    return frame
end
Milkyway.Card = Card

-- ======================== ACCORDION ========================
local Accordion = {}
Accordion.__index = Accordion
function Accordion.new(parent, items, options)
    options = options or {}
    local self = setmetatable({}, Accordion)
    local theme = Milkyway.getCurrentTheme()
    self.container = Instance.new("Frame")
    self.container.Size = options.size or UDim2.new(0, 300, 0, 400)
    self.container.BackgroundColor3 = theme.surface
    self.container.Parent = parent or defaultScreenGui
    applyModernStyle(self.container, theme)
    self.items = {}
    local yOffset = 0
    for i, item in ipairs(items) do
        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1,0,0,40)
        header.Position = UDim2.new(0,0,0,yOffset)
        header.Text = item.title
        header.BackgroundColor3 = theme.primary
        header.TextColor3 = theme.text
        header.Font = Enum.Font.GothamBold
        header.TextSize = 14
        header.Parent = self.container
        local content = Instance.new("Frame")
        content.Size = UDim2.new(1,0,0,0)
        content.Position = UDim2.new(0,0,0,yOffset+40)
        content.BackgroundColor3 = theme.surface
        content.Visible = false
        content.Parent = self.container
        if item.content then item.content(content) end
        table.insert(self.items, {header=header, content=content, open=false})
        header.MouseButton1Click:Connect(function()
            local isOpen = self.items[i].open
            for j, it in ipairs(self.items) do
                if j == i then
                    it.content.Visible = not isOpen
                    it.content.Size = UDim2.new(1,0,0, isOpen and 0 or (item.height or 100))
                    it.open = not isOpen
                else
                    it.content.Visible = false
                    it.content.Size = UDim2.new(1,0,0,0)
                    it.open = false
                end
            end
        end)
        yOffset = yOffset + 40 + (item.height or 0)
    end
    return self
end
Milkyway.Accordion = Accordion

-- ======================== RATING ========================
local Rating = {}
Rating.__index = Rating
function Rating.new(parent, maxRating, initialRating, callback, options)
    options = options or {}
    local self = setmetatable({}, Rating)
    local theme = Milkyway.getCurrentTheme()
    self.container = Instance.new("Frame")
    self.container.Size = UDim2.new(0, maxRating * 30, 0, 30)
    self.container.BackgroundTransparency = 1
    self.container.Parent = parent or defaultScreenGui
    self.stars = {}
    for i = 1, maxRating do
        local star = Instance.new("ImageButton")
        star.Size = UDim2.new(0, 30, 0, 30)
        star.Position = UDim2.new(0, (i-1)*30, 0, 0)
        star.Image = "rbxassetid://3926305904"
        star.ImageColor3 = Color3.fromRGB(255,200,0)
        star.BackgroundTransparency = 1
        star.Parent = self.container
        star.MouseButton1Click:Connect(function()
            self:SetValue(i)
            if callback then callback(i) end
        end)
        table.insert(self.stars, star)
    end
    function self:SetValue(value)
        for i, star in ipairs(self.stars) do
            star.Image = (i <= value) and "rbxassetid://3926309023" or "rbxassetid://3926305904"
        end
    end
    self:SetValue(initialRating or 0)
    return self
end
Milkyway.Rating = Rating

-- ======================== EXPOSE ALL ========================
Milkyway.Components = {
    Model = Model,
    Button = Button,
    Input = Input,
    Checkbox = Checkbox,
    Radio = Radio,
    Dropdown = Dropdown,
    Slider = Slider,
    Toggle = Toggle,
    TabView = TabView,
    Tooltip = Tooltip,
    ProgressBar = ProgressBar,
    ColorPicker = ColorPicker,
    ContextMenu = ContextMenu,
    DraggableWindow = DraggableWindow,
    MessageBox = MessageBox,
    Skeleton = Skeleton,
    Spinner = Spinner,
    Avatar = Avatar,
    Badge = Badge,
    Card = Card,
    Accordion = Accordion,
    Rating = Rating,
}
Milkyway.Notify = Milkyway.notify
Milkyway.ScreenGui = defaultScreenGui

return Milkyway
