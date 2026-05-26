-- Phoenix A Hub (layout vertical de abas)
-- Recursos: WalkSpeed, JumpPower, Noclip, Teleport, Reset
-- Cole este LocalScript em StarterPlayerScripts

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

-- Estado
local state = {
    walkSpeed = 16,
    jumpPower = 50,
    noclip = false,
    noclipConn = nil,
    savedCollisions = {}
}

-- UI helpers
local function makeUICorner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = instance
    return c
end

local function makeStroke(instance, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(140,40,180)
    s.Thickness = thickness or 1
    s.Parent = instance
    return s
end

local function createButton(parent, text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 44)
    btn.LayoutOrder = order or 1
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSans
    btn.BackgroundColor3 = Color3.fromRGB(36, 66, 120)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = parent
    makeUICorner(btn, 8)
    makeStroke(btn)
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
    makeUICorner(valueBox, 6)
    makeStroke(valueBox)

    local bar = Instance.new("Frame", container)
    bar.Size = UDim2.new(0.9,0,0,12)
    bar.Position = UDim2.new(0.05,0,0,34)
    bar.BackgroundColor3 = Color3.fromRGB(40,70,120)
    makeUICorner(bar, 6)

    local tInit = (defaultValue - minVal) / math.max(1, (maxVal - minVal))
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(tInit, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(160,80,220)
    makeUICorner(fill, 6)

    local knob = Instance.new("ImageButton", bar)
    knob.Size = UDim2.new(0,16,0,16)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new(tInit, 0, 0.5, 0)
    knob.Image = "rbxassetid://3926305904"
    knob.BackgroundTransparency = 1

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

    if onChange then pcall(onChange, defaultValue) end
    return container, valueBox
end

-- UI raiz
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "PhoenixA_Hub"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal maior
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 680, 0, 420) -- maior
frame.Position = UDim2.new(0.5, -340, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(12, 18, 34)
makeUICorner(frame, 14)
makeStroke(frame, Color3.fromRGB(140,40,180), 2)

-- Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -200, 0, 48)
title.Position = UDim2.new(0, 12, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Phoenix A"
title.TextColor3 = Color3.fromRGB(180, 0, 180)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold

-- Toggle logo (mantido no mesmo tamanho)
local toggleBtn = Instance.new("ImageButton", screenGui)
toggleBtn.Size = UDim2.new(0, 56, 0, 56)
toggleBtn.Position = UDim2.new(0, 12, 0, 12)
toggleBtn.Image = "rbxassetid://126836694733781"
makeUICorner(toggleBtn, 8)
makeStroke(toggleBtn, Color3.fromRGB(140,40,180), 2)

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

-- Abas verticais à esquerda (compactas)
local tabsContainer = Instance.new("Frame", frame)
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(0, 120, 1, -24)
tabsContainer.Position = UDim2.new(0, 12, 0, 64)
tabsContainer.BackgroundTransparency = 1
local tabsLayout = Instance.new("UIListLayout", tabsContainer)
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 8)

local function createTab(name)
    local btn = Instance.new("TextButton", tabsContainer)
    btn.Size = UDim2.new(1, 0, 0, 44) -- compacto e vertical
    btn.LayoutOrder = 1
    btn.Text = name
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansSemibold
    btn.BackgroundColor3 = Color3.fromRGB(28, 48, 88)
    btn.TextColor3 = Color3.fromRGB(180, 0, 180)
    makeUICorner(btn, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(140,40,180)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(44,74,140) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(28,48,88) end)
    return btn
end

local movimentoTab = createTab("Movimento")
local extrasTab = createTab("Extras")

-- Área de conteúdo expandida à direita das abas
local contentFrame = Instance.new("Frame", frame)
contentFrame.Size = UDim2.new(1, -160, 1, -96) -- ocupa o restante do espaço
contentFrame.Position = UDim2.new(0, 144, 0, 64)
contentFrame.BackgroundTransparency = 1

local function createContentScroll(parent)
    local sf = Instance.new("ScrollingFrame", parent)
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.Position = UDim2.new(0, 0, 0, 0)
    sf.BackgroundColor3 = Color3.fromRGB(18, 30, 56)
    sf.ScrollBarThickness = 6
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    makeUICorner(sf, 10)
    local stroke = Instance.new("UIStroke", sf)
    stroke.Color = Color3.fromRGB(140,40,180)
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return sf, layout
end

local movimentoFrame, movimentoLayout = createContentScroll(contentFrame)
local extrasFrame, extrasLayout = createContentScroll(contentFrame)
movimentoFrame.Visible = true
extrasFrame.Visible = false

movimentoTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = true
    extrasFrame.Visible = false
    -- highlight tab
    movimentoTab.BackgroundColor3 = Color3.fromRGB(44,74,140)
    extrasTab.BackgroundColor3 = Color3.fromRGB(28,48,88)
end)
extrasTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = false
    extrasFrame.Visible = true
    extrasTab.BackgroundColor3 = Color3.fromRGB(44,74,140)
    movimentoTab.BackgroundColor3 = Color3.fromRGB(28,48,88)
end)

-- Update canvas size helper
local function updateCanvasSize(sf)
    local layout = sf:FindFirstChildOfClass("UIListLayout")
    if layout then
        sf.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end
end
movimentoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvasSize(movimentoFrame) end)
extrasLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvasSize(extrasFrame) end)

-- Noclip (salva e restaura colisões)
local function startNoclip()
    if state.noclip then return end
    local char = getCharacter()
    if not char then return end
    state.noclip = true
    state.savedCollisions = {}
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            state.savedCollisions[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    state.noclipConn = RunService.Stepped:Connect(function()
        local c = player.Character
        if not c then return end
        for _, part in pairs(c:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function stopNoclip()
    state.noclip = false
    if state.noclipConn then state.noclipConn:Disconnect() state.noclipConn = nil end
    for part, canCollide in pairs(state.savedCollisions) do
        if part and part:IsA("BasePart") then
            part.CanCollide = canCollide
        end
    end
    state.savedCollisions = {}
end

-- Teleport helper
local function teleportToPlayer(name)
    if not name or name == "" then return end
    local _, _, hrpLocal = getCharacter()
    for _, pl in pairs(Players:GetPlayers()) do
        if pl.Name:lower():find(name:lower()) then
            if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") and hrpLocal then
                hrpLocal.CFrame = pl.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
            end
            break
        end
    end
end

-- Reset movement
local function resetMovement()
    local _, humanoidLocal = getCharacter()
    if humanoidLocal then
        humanoidLocal.WalkSpeed = 16
        humanoidLocal.JumpPower = 50
        pcall(function() humanoidLocal.UseJumpPower = true end)
    end
    state.walkSpeed = 16
    state.jumpPower = 50
    stopNoclip()
end

-- Monta UI: sliders e botões no movimentoFrame
local order = 1
createButton(movimentoFrame, "Reset Movement", order, function() resetMovement() end)
order = order + 1

createSlider(movimentoFrame, "Walk Speed", state.walkSpeed, 8, 300, order, function(val)
    state.walkSpeed = val
    local _, humanoidLocal = getCharacter()
    if humanoidLocal then humanoidLocal.WalkSpeed = val end
end)
order = order + 1

createSlider(movimentoFrame, "Jump Power", state.jumpPower, 10, 300, order, function(val)
    state.jumpPower = val
    local _, humanoidLocal = getCharacter()
    if humanoidLocal then
        humanoidLocal.JumpPower = val
        pcall(function() humanoidLocal.UseJumpPower = true end)
    end
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
makeUICorner(tpBox, 6)
makeStroke(tpBox, Color3.fromRGB(140,40,180), 1)
order = order + 1

createButton(movimentoFrame, "Teleport", order, function()
    teleportToPlayer(tpBox.Text)
end)
order = order + 1

-- Extras: Noclip toggle
createButton(extrasFrame, "Toggle Noclip", 1, function()
    if state.noclip then stopNoclip() else startNoclip() end
end)

-- Visual placeholder (Extras)
local placeholder = Instance.new("TextLabel", extrasFrame)
placeholder.Size = UDim2.new(0.9, 0, 0, 44)
placeholder.LayoutOrder = 2
placeholder.BackgroundTransparency = 1
placeholder.Text = "Extras: Noclip disponível"
placeholder.TextColor3 = Color3.fromRGB(220,220,220)
placeholder.TextScaled = true
placeholder.Font = Enum.Font.SourceSans

-- Apply initial values
local _, humanoidInit = getCharacter()
if humanoidInit then
    humanoidInit.WalkSpeed = state.walkSpeed
    humanoidInit.JumpPower = state.jumpPower
    pcall(function() humanoidInit.UseJumpPower = true end)
end

-- Ajusta CanvasSize dinamicamente
task.delay(0.1, function()
    updateCanvasSize(movimentoFrame)
    updateCanvasSize(extrasFrame)
end)

-- Cleanup on script removal
script.AncestryChanged:Connect(function()
    if not script:IsDescendantOf(game) then
        stopNoclip()
    end
end)

-- Safety note: teste em Play Solo antes de usar em servidores públicos
