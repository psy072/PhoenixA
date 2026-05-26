-- Phoenix A hub (versão final unificada)
-- Coloque este LocalScript em StarterPlayerScripts
-- Recursos: Abas horizontais, fonte púrpura, sliders funcionais (mouse + toque),
-- Movimento: Fly (toggle + slider), WalkSpeed (slider), JumpPower (slider), Teleport, Reset
-- Extras: Noclip toggle (funcional)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Character refs (atualiza no respawn)
local function getCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, humanoid, hrp
end

local character, humanoid, hrp = getCharacter()
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- UI root
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "PhoenixA_Hub"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 520, 0, 360)
frame.Position = UDim2.new(0.5, -260, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(12, 18, 34)
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Thickness = 2
frameStroke.Color = Color3.fromRGB(140, 40, 180)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -160, 0, 48)
title.Position = UDim2.new(0, 12, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Phoenix A"
title.TextColor3 = Color3.fromRGB(180, 0, 180) -- fonte púrpura
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold

-- Toggle icon (abre/fecha UI)
local toggleBtn = Instance.new("ImageButton", screenGui)
toggleBtn.Name = "ToggleLogo"
toggleBtn.Size = UDim2.new(0, 56, 0, 56)
toggleBtn.Position = UDim2.new(0, 12, 0, 12)
toggleBtn.Image = "rbxassetid://126836694733781"
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Thickness = 2
toggleStroke.Color = Color3.fromRGB(140, 40, 180)

local uiVisible = true
toggleBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    frame.Visible = uiVisible
end)

-- Drag function
local function makeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(frame)
makeDraggable(toggleBtn)

-- Tabs container (top-right horizontal)
local tabsContainer = Instance.new("Frame", frame)
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(0, 300, 0, 56)
tabsContainer.Position = UDim2.new(1, -312, 0, 8)
tabsContainer.BackgroundTransparency = 1
local tabsLayout = Instance.new("UIListLayout", tabsContainer)
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 8)

local function createTab(name)
    local btn = Instance.new("TextButton", tabsContainer)
    btn.Size = UDim2.new(0, 96, 1, 0)
    btn.Text = name
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansSemibold
    btn.BackgroundColor3 = Color3.fromRGB(28, 48, 88)
    btn.TextColor3 = Color3.fromRGB(180, 0, 180) -- fonte púrpura
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(140, 40, 180)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(44, 74, 140) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(28, 48, 88) end)
    return btn
end

local movimentoTab = createTab("Movimento")
local visualTab = createTab("Visual")
local extrasTab = createTab("Extras")

-- Content frames (scrolling)
local function createContentFrame()
    local sf = Instance.new("ScrollingFrame", frame)
    sf.Size = UDim2.new(1, -24, 1, -80)
    sf.Position = UDim2.new(0, 12, 0, 64)
    sf.BackgroundColor3 = Color3.fromRGB(18, 30, 56)
    sf.ScrollBarThickness = 6
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", sf)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(140, 40, 180)
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return sf, layout
end

local movimentoFrame, movimentoLayout = createContentFrame()
local visualFrame, visualLayout = createContentFrame()
local extrasFrame, extrasLayout = createContentFrame()
movimentoFrame.Visible = true
visualFrame.Visible = false
extrasFrame.Visible = false

movimentoTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = true
    visualFrame.Visible = false
    extrasFrame.Visible = false
end)
visualTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = false
    visualFrame.Visible = true
    extrasFrame.Visible = false
end)
extrasTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = false
    visualFrame.Visible = false
    extrasFrame.Visible = true
end)

-- Styled button helper
local function createButton(parent, text, order, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.92, 0, 0, 44)
    btn.LayoutOrder = order or 1
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSans
    btn.BackgroundColor3 = Color3.fromRGB(36, 66, 120)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(140, 40, 180)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(56,96,180) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(36,66,120) end)
    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(20,40,80)
        task.wait(0.06)
        btn.BackgroundColor3 = Color3.fromRGB(36,66,120)
        if callback then pcall(callback) end
    end)
    return btn
end

-- Numeric slider (funcional para mouse e toque) - retorna container e valueBox (opcional)
local function createSlider(parent, labelText, defaultValue, minVal, maxVal, order, onChange)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(0.95,0,0,64)
    container.LayoutOrder = order or 1
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.45,0,0,20)
    label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(180,0,180)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansSemibold

    local valueBox = Instance.new("TextBox", container)
    valueBox.Size = UDim2.new(0.22,0,0,28)
    valueBox.Position = UDim2.new(0.73,0,0,0)
    valueBox.BackgroundColor3 = Color3.fromRGB(24,44,84)
    valueBox.TextColor3 = Color3.fromRGB(240,240,240)
    valueBox.TextScaled = true
    valueBox.Text = tostring(defaultValue)
    valueBox.PlaceholderText = tostring(defaultValue)
    valueBox.ClearTextOnFocus = false
    Instance.new("UICorner", valueBox).CornerRadius = UDim.new(0, 6)
    local vbStroke = Instance.new("UIStroke", valueBox)
    vbStroke.Thickness = 1
    vbStroke.Color = Color3.fromRGB(140,40,180)

    local bar = Instance.new("Frame", container)
    bar.Size = UDim2.new(0.9,0,0,12)
    bar.Position = UDim2.new(0.05,0,0,34)
    bar.BackgroundColor3 = Color3.fromRGB(40,70,120)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

    local fill = Instance.new("Frame", bar)
    local tInit = (defaultValue - minVal) / math.max(1, (maxVal - minVal))
    fill.Size = UDim2.new(tInit, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(160,80,220)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)

    local knob = Instance.new("ImageButton", bar)
    knob.Size = UDim2.new(0,16,0,16)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new(tInit, 0, 0.5, 0)
    knob.Image = "rbxassetid://3926305904"
    knob.BackgroundTransparency = 1

    -- Drag handling local ao slider
    local dragging = false
    local inputConn = nil

    local function setValueFromX(x)
        local absX = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local t = (bar.AbsoluteSize.X > 0) and (absX / bar.AbsoluteSize.X) or 0
        t = math.clamp(t, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * t + 0.5)
        fill.Size = UDim2.new(t, 0, 1, 0)
        knob.Position = UDim2.new(t, 0, 0.5, 0)
        valueBox.Text = tostring(value)
        if onChange then pcall(onChange, value) end
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            -- connect InputChanged local
            inputConn = UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    setValueFromX(i.Position.X)
                end
            end)
        end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if inputConn then inputConn:Disconnect() inputConn = nil end
        end
    end)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setValueFromX(input.Position.X)
            dragging = true
            inputConn = UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    setValueFromX(i.Position.X)
                end
            end)
        end
    end)

    -- When user types a value manually
    valueBox.FocusLost:Connect(function()
        local v = tonumber(valueBox.Text)
        if v then
            v = math.clamp(math.floor(v + 0.5), minVal, maxVal)
            local t = (v - minVal) / math.max(1, (maxVal - minVal))
            fill.Size = UDim2.new(t, 0, 1, 0)
            knob.Position = UDim2.new(t, 0, 0.5, 0)
            valueBox.Text = tostring(v)
            if onChange then pcall(onChange, v) end
        else
            valueBox.Text = tostring(defaultValue)
        end
    end)

    -- initial callback
    if onChange then pcall(onChange, defaultValue) end

    return container, valueBox
end

-- Movement state
local state = {
    fly = false,
    flySpeed = 60,
    walkSpeed = 16,
    jumpPower = 50,
    noclip = false,
    flyBV = nil,
    flyBG = nil,
    flyConn = nil,
    noclipConn = nil
}

-- Update canvas size helper
local function updateCanvasSize(sf)
    local layout = sf:FindFirstChildOfClass("UIListLayout")
    if layout then
        sf.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end
end
movimentoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvasSize(movimentoFrame) end)
extrasLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvasSize(extrasFrame) end)
visualLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvasSize(visualFrame) end)

-- Key tracking for fly
local keys = {}
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keys[input.KeyCode] = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keys[input.KeyCode] = false
    end
end)

-- Fly implementation (simple, responsivo)
local function startFly()
    if state.fly then return end
    character, humanoid, hrp = getCharacter()
    if not hrp or not humanoid then return end
    state.fly = true
    humanoid.PlatformStand = true

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    state.flyBV = bv
    state.flyBG = bg

    state.flyConn = RunService.RenderStepped:Connect(function()
        if not hrp or not humanoid or not state.fly then return end
        local cam = workspace.CurrentCamera
        local forward = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local moveVec = Vector3.new(0,0,0)
        if keys[Enum.KeyCode.W] then moveVec = moveVec + forward end
        if keys[Enum.KeyCode.S] then moveVec = moveVec - forward end
        if keys[Enum.KeyCode.D] then moveVec = moveVec + right end
        if keys[Enum.KeyCode.A] then moveVec = moveVec - right end
        local vertical = 0
        if keys[Enum.KeyCode.Space] then vertical = vertical + 1 end
        if keys[Enum.KeyCode.LeftShift] or keys[Enum.KeyCode.RightShift] then vertical = vertical - 1 end
        local dir = Vector3.new(moveVec.X, 0, moveVec.Z)
        if dir.Magnitude > 0 then dir = dir.Unit end
        local targetVel = (dir * state.flySpeed) + Vector3.new(0, vertical * state.flySpeed, 0)
        if state.flyBV and state.flyBV.Parent then
            state.flyBV.Velocity = targetVel
        end
        if state.flyBG and state.flyBG.Parent then
            state.flyBG.CFrame = cam.CFrame
        end
    end)
end

local function stopFly()
    state.fly = false
    if humanoid then humanoid.PlatformStand = false end
    if state.flyConn then state.flyConn:Disconnect() state.flyConn = nil end
    if state.flyBV and state.flyBV.Parent then state.flyBV:Destroy() end
    if state.flyBG and state.flyBG.Parent then state.flyBG:Destroy() end
    state.flyBV = nil
    state.flyBG = nil
end

-- Noclip implementation (Extras)
local function startNoclip()
    if state.noclip then return end
    character, humanoid, hrp = getCharacter()
    state.noclip = true
    state.noclipConn = RunService.Stepped:Connect(function()
        if not character then return end
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    state.noclip = false
    if state.noclipConn then state.noclipConn:Disconnect() state.noclipConn = nil end
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Teleport helper
local function teleportToPlayer(name)
    if not name or name == "" then return end
    for _, pl in pairs(Players:GetPlayers()) do
        if pl.Name:lower():find(name:lower()) then
            if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") and hrp then
                hrp.CFrame = pl.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
            end
            break
        end
    end
end

-- Reset movement
local function resetMovement()
    character, humanoid, hrp = getCharacter()
    if humanoid then
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
    end
    state.flySpeed = 60
    stopFly()
    stopNoclip()
end

-- Build Movement UI
local order = 1
createButton(movimentoFrame, "Toggle Fly", order, function()
    if state.fly then stopFly() else startFly() end
end)
order = order + 1

createSlider(movimentoFrame, "Fly Speed", 60, 10, 300, order, function(val)
    state.flySpeed = val
end)
order = order + 1

createSlider(movimentoFrame, "Walk Speed", 16, 8, 200, order, function(val)
    state.walkSpeed = val
    if humanoid then humanoid.WalkSpeed = val end
end)
order = order + 1

createSlider(movimentoFrame, "Jump Power", 50, 10, 300, order, function(val)
    state.jumpPower = val
    if humanoid then humanoid.JumpPower = val end
end)
order = order + 1

-- Teleport input + button
local tpContainer = Instance.new("Frame", movimentoFrame)
tpContainer.Size = UDim2.new(0.95, 0, 0, 44)
tpContainer.LayoutOrder = order
tpContainer.BackgroundTransparency = 1
local tpLabel = Instance.new("TextLabel", tpContainer)
tpLabel.Size = UDim2.new(0.36, 0, 1, 0)
tpLabel.BackgroundTransparency = 1
tpLabel.Text = "Teleport to"
tpLabel.TextColor3 = Color3.fromRGB(230,230,230)
tpLabel.TextScaled = true
local tpBox = Instance.new("TextBox", tpContainer)
tpBox.Size = UDim2.new(0.58, 0, 1, 0)
tpBox.Position = UDim2.new(0.38, 0, 0, 0)
tpBox.PlaceholderText = "player name"
tpBox.Text = ""
tpBox.TextScaled = true
tpBox.BackgroundColor3 = Color3.fromRGB(24,44,84)
Instance.new("UICorner", tpBox).CornerRadius = UDim.new(0,6)
local tpStroke = Instance.new("UIStroke", tpBox)
tpStroke.Thickness = 1
tpStroke.Color = Color3.fromRGB(140,40,180)
order = order + 1

createButton(movimentoFrame, "Teleport", order, function()
    teleportToPlayer(tpBox.Text)
end)
order = order + 1

createButton(movimentoFrame, "Reset Movement", order, function()
    resetMovement()
end)
order = order + 1

-- Extras: Noclip toggle
createButton(extrasFrame, "Toggle Noclip", 1, function()
    if state.noclip then stopNoclip() else startNoclip() end
end)

-- Visual placeholder
local placeholder = Instance.new("TextLabel", visualFrame)
placeholder.Size = UDim2.new(0.9, 0, 0, 44)
placeholder.LayoutOrder = 1
placeholder.BackgroundTransparency = 1
placeholder.Text = "Visuals (ESP, Radar) - em desenvolvimento"
placeholder.TextColor3 = Color3.fromRGB(220,220,220)
placeholder.TextScaled = true
placeholder.Font = Enum.Font.SourceSans

-- Apply initial values
if humanoid then
    humanoid.WalkSpeed = state.walkSpeed
    humanoid.JumpPower = state.jumpPower
end

-- Update canvas sizes initially
task.delay(0.1, function()
    updateCanvasSize(movimentoFrame)
    updateCanvasSize(extrasFrame)
    updateCanvasSize(visualFrame)
end)

-- Cleanup on script removal
script.AncestryChanged:Connect(function()
    if not script:IsDescendantOf(game) then
        stopFly()
        stopNoclip()
    end
end)

-- Safety note: teste em Play Solo antes de usar em servidores públicos
