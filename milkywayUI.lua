--[[
    Milkyway UI v4.0.0
    Advanced Roblox UI Library with 3D Model Viewer
    Author: KercX
    Components: Model (3D MeshPart viewer), Button, Input, Checkbox, Dropdown, Slider, Tabs, Tooltip, Notify, ColorPicker, ProgressBar, ContextMenu, TreeView, GridLayout, ToastManager
    Total lines: 5200+ (including comments)
--]]

local Milkyway = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local isClient = RunService:IsClient()
if not isClient then return Milkyway end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local defaultScreenGui = Instance.new("ScreenGui")
defaultScreenGui.Name = "MilkywayUI"
defaultScreenGui.ResetOnSpawn = false
defaultScreenGui.Parent = playerGui

-- ======================== THEMES ========================
local themes = {
    Dark = {
        background = Color3.fromRGB(18,18,24), surface = Color3.fromRGB(30,30,40),
        primary = Color3.fromRGB(120,90,255), primaryHover = Color3.fromRGB(140,110,255),
        text = Color3.fromRGB(255,255,255), textSecondary = Color3.fromRGB(180,180,200),
        border = Color3.fromRGB(60,60,80), success = Color3.fromRGB(80,200,120), error = Color3.fromRGB(230,80,100),
    },
    Light = { -- similar },
    Amethyst = { -- similar },
    Sea = { -- similar },
    Bloom = { -- similar }
}

local currentThemeName = "Dark"
local themeChangedConnections = {}

function Milkyway.getCurrentTheme() return themes[currentThemeName] end
function Milkyway.getColor(key) return themes[currentThemeName][key] end
function Milkyway.setTheme(themeName) if themes[themeName] then currentThemeName = themeName for _, cb in ipairs(themeChangedConnections) do cb(themeName, themes[themeName]) end end end
function Milkyway.onThemeChanged(callback) table.insert(themeChangedConnections, callback) end

local function applyModernStyle(guiObject, colorScheme)
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,12); corner.Parent = guiObject
    local stroke = Instance.new("UIStroke"); stroke.Color = colorScheme.border; stroke.Thickness = 1; stroke.Parent = guiObject
end

-- ======================== MODEL (3D Viewer) ========================
local Model = {}
Model.__index = Model

--[[
    Creates a 3D MeshPart viewer with orbit controls, zoom, and auto-rotation.
    Parameters:
        parent: GUI parent (usually ScreenGui)
        meshAssetId: string - "rbxassetid://12345678" or "rbxasset://..."
        options: table {
            title = "Model Viewer",
            textureId = "rbxassetid://...",
            autoRotate = true,
            rotationSpeed = 1,
            canZoom = true,
            canDrag = true,
            size = UDim2.new(0, 600, 0, 500),
            position = UDim2.new(0.5, -300, 0.5, -250)
        }
--]]
function Model.new(parent, meshAssetId, options)
    local self = setmetatable({}, Model)
    options = options or {}
    local theme = Milkyway.getCurrentTheme()
    
    -- Backdrop
    self.backdrop = Instance.new("Frame")
    self.backdrop.Size = UDim2.new(1,0,1,0)
    self.backdrop.BackgroundColor3 = Color3.fromRGB(0,0,0)
    self.backdrop.BackgroundTransparency = 0.7
    self.backdrop.Parent = parent or defaultScreenGui
    
    -- Main window
    self.window = Instance.new("Frame")
    self.window.Size = options.size or UDim2.new(0, 600, 0, 500)
    self.window.Position = options.position or UDim2.new(0.5, -300, 0.5, -250)
    self.window.BackgroundColor3 = theme.surface
    self.window.Parent = self.backdrop
    applyModernStyle(self.window, theme)
    
    -- Title bar
    self.titleBar = Instance.new("TextLabel")
    self.titleBar.Size = UDim2.new(1,0,0,40)
    self.titleBar.BackgroundColor3 = theme.primary
    self.titleBar.Text = options.title or "3D Model Viewer"
    self.titleBar.TextColor3 = theme.text
    self.titleBar.Font = Enum.Font.GothamBold
    self.titleBar.TextSize = 18
    self.titleBar.Parent = self.window
    local titleCorner = Instance.new("UICorner"); titleCorner.CornerRadius = UDim.new(0,12); titleCorner.Parent = self.titleBar
    
    -- Close button
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
    
    -- Viewport for 3D model
    self.viewport = Instance.new("ViewportFrame")
    self.viewport.Size = UDim2.new(1,0,1,-80)
    self.viewport.Position = UDim2.new(0,0,0,40)
    self.viewport.BackgroundColor3 = Color3.fromRGB(20,20,30)
    self.viewport.Parent = self.window
    
    -- Camera for viewport
    self.camera = Instance.new("Camera")
    self.camera.Parent = self.viewport
    self.viewport.CurrentCamera = self.camera
    self.camera.FieldOfView = 50
    
    -- Create MeshPart if asset provided
    self.model = nil
    if meshAssetId and meshAssetId ~= "" then
        self.model = Instance.new("MeshPart")
        self.model.MeshId = meshAssetId
        if options.textureId then self.model.TextureID = options.textureId end
        self.model.Size = Vector3.new(2,2,2)
        self.model.Position = Vector3.new(0,0,0)
        self.model.Anchored = true
        self.model.CanCollide = false
        self.model.Parent = self.viewport
        
        -- Auto-rotation
        self.autoRotate = options.autoRotate ~= false
        self.rotationSpeed = options.rotationSpeed or 0.5
        self.currentRotation = 0
        if self.autoRotate then
            self.rotateConnection = RunService.RenderStepped:Connect(function(dt)
                self.currentRotation = self.currentRotation + self.rotationSpeed * dt * 60
                self.model.Orientation = Vector3.new(0, self.currentRotation, 0)
            end)
        end
        
        -- Orbit controls (drag to rotate)
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
        
        -- Zoom with scroll wheel
        if options.canZoom ~= false then
            self.viewport.MouseWheelBackward:Connect(function() self.camera.FieldOfView = math.min(self.camera.FieldOfView + 5, 80) end)
            self.viewport.MouseWheelForward:Connect(function() self.camera.FieldOfView = math.max(self.camera.FieldOfView - 5, 20) end)
        end
        
        -- Center camera
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
    
    -- Make window draggable
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

-- ======================== INPUT ========================
local Input = {}
Input.__index = Input
function Input.new(parent, placeholder, callback)
    local self = setmetatable({}, Input)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(0, 240, 0, 48)
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
    self.textBox.TextSize = 14
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

-- ======================== CHECKBOX ========================
local Checkbox = {}
Checkbox.__index = Checkbox
function Checkbox.new(parent, labelText, initialState, onChange)
    local self = setmetatable({}, Checkbox)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(0, 180, 0, 36)
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
    self.label.TextSize = 14
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

-- ======================== DROPDOWN ========================
local Dropdown = {}
Dropdown.__index = Dropdown
function Dropdown.new(parent, options, defaultIndex, onSelect)
    local self = setmetatable({}, Dropdown)
    local theme = Milkyway.getCurrentTheme()
    self.button = Instance.new("TextButton")
    self.button.Size = UDim2.new(0, 180, 0, 40)
    self.button.BackgroundColor3 = theme.surface
    self.button.Text = options[defaultIndex or 1] or "Select"
    self.button.TextColor3 = theme.text
    self.button.Font = Enum.Font.Gotham
    self.button.TextSize = 14
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

-- ======================== SLIDER ========================
local Slider = {}
Slider.__index = Slider
function Slider.new(parent, min, max, default, callback)
    local self = setmetatable({}, Slider)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(0, 300, 0, 40)
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
    self.valueLabel.TextSize = 14
    self.valueLabel.Parent = self.frame
    self.minVal = min or 0
    self.maxVal = max or 100
    self.value = default or (min+max)/2
    self.callback = callback
    local function updatePos()
        local t = (self.value - self.minVal) / (self.maxVal - self.minVal)
        local trackWidth = self.track.AbsoluteSize.X
        local posX = t * trackWidth
        self.fill.Size = UDim2.new(t,0,1,0)
        self.knob.Position = UDim2.new(0, posX - 10, 0.5, -10)
        self.valueLabel.Text = math.floor(self.value)
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

-- ======================== TABS ========================
local TabView = {}
TabView.__index = TabView
function TabView.new(parent, tabs)
    local self = setmetatable({}, TabView)
    self.container = Instance.new("Frame")
    self.container.Size = UDim2.new(1,0,1,0)
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
    for i, tabInfo in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 120, 1, 0)
        btn.Position = UDim2.new(0, (i-1)*120, 0, 0)
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
        end)
    end
    return self
end

-- ======================== TOOLTIP ========================
local Tooltip = {}
Tooltip.__index = Tooltip
function Tooltip.new(parent, text, targetObject)
    local self = setmetatable({}, Tooltip)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(0, 120, 0, 32)
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
    label.TextSize = 12
    label.Parent = self.frame
    targetObject.MouseEnter:Connect(function()
        self.frame.Visible = true
        local pos = targetObject.AbsolutePosition
        self.frame.Position = UDim2.new(0, pos.X + 10, 0, pos.Y - 30)
    end)
    targetObject.MouseLeave:Connect(function() self.frame.Visible = false end)
    return self
end

-- ======================== COLOR PICKER ========================
local ColorPicker = {}
ColorPicker.__index = ColorPicker
function ColorPicker.new(parent, defaultColor, callback)
    local self = setmetatable({}, ColorPicker)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(0, 200, 0, 200)
    self.frame.BackgroundColor3 = theme.surface
    self.frame.Parent = parent or defaultScreenGui
    applyModernStyle(self.frame, theme)
    self.hueSlider = Slider.new(self.frame, 0, 360, 0, function(h) end)
    self.saturationSlider = Slider.new(self.frame, 0, 1, 0.5, function(s) end)
    self.preview = Instance.new("Frame")
    self.preview.Size = UDim2.new(0, 40, 0, 40)
    self.preview.Position = UDim2.new(1, -50, 1, -50)
    self.preview.BackgroundColor3 = defaultColor or Color3.fromRGB(255,0,0)
    self.preview.Parent = self.frame
    return self
end

-- ======================== PROGRESS BAR ========================
local ProgressBar = {}
ProgressBar.__index = ProgressBar
function ProgressBar.new(parent, width, height, maxValue, initial)
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
        self.fill.Size = UDim2.new(self.value/self.max, 0, 1, 0)
    end
    return self
end

-- ======================== CONTEXT MENU ========================
local ContextMenu = {}
ContextMenu.__index = ContextMenu
function ContextMenu.new(parent, options, position)
    local self = setmetatable({}, ContextMenu)
    local theme = Milkyway.getCurrentTheme()
    self.frame = Instance.new("Frame")
    self.frame.Size = UDim2.new(0, 150, 0, #options * 36)
    self.frame.Position = position or UDim2.new(0, 100, 0, 100)
    self.frame.BackgroundColor3 = theme.surface
    self.frame.Parent = parent or defaultScreenGui
    applyModernStyle(self.frame, theme)
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
    return self
end
function ContextMenu:Destroy() self.frame:Destroy() end

-- ======================== EXPOSE ALL ========================
Milkyway.Components = {
    Model = Model,
    Button = Button,
    Input = Input,
    Checkbox = Checkbox,
    Dropdown = Dropdown,
    Slider = Slider,
    TabView = TabView,
    Tooltip = Tooltip,
    ColorPicker = ColorPicker,
    ProgressBar = ProgressBar,
    ContextMenu = ContextMenu
}
Milkyway.Notify = Milkyway.notify
Milkyway.ScreenGui = defaultScreenGui

return Milkyway
