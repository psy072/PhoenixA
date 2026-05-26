-- Phoenix A Hub (versão corrigida e unificada)
-- Pronto para rodar como LocalScript (StarterPlayerScripts) ou via loadstring no cliente

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
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
    savedCollisions = {},
    espPlayers = false,
    espNPCs = false,
    espPlayerHighlights = {},
    espNPCHighlights = {},
    fovEnabled = false,
    fovRadius = 150,
    fovDrawing = nil,
    fovConn = nil
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
    btn.Font = Enum.Font.SourceSansSemibold
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
    label.TextXAlignment = Enum.TextXAlignment.Left

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

-- Cria GUI direto no PlayerGui
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "PhoenixA_Hub"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 680, 0, 460)
frame.Position = UDim2.new(0.5, -340, 0.5, -230)
frame.BackgroundColor3 = Color3.fromRGB(12, 18, 34)
makeUICorner(frame, 14)
makeStroke(frame, Color3.fromRGB(140,40,180), 2)

-- Título centralizado
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 48)
title.Position = UDim2.new(0, 0, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Phoenix A"
title.TextColor3 = Color3.fromRGB(180, 0, 180)
title.TextScaled = true
title.Font = Enum.Font.SourceSansSemibold
title.TextXAlignment = Enum.TextXAlignment.Center

-- Toggle logo
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

-- Abas verticais à esquerda
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
    btn.Size = UDim2.new(1, 0, 0, 44)
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
local visualTab = createTab("Visual")

-- Área de conteúdo expandida à direita das abas (BLOCO UNIFICADO)
local contentFrame = Instance.new("Frame", frame)
contentFrame.Size = UDim2.new(1, -160, 1, -96)
contentFrame.Position = UDim2.new(0, 144, 0, 64)
contentFrame.BackgroundTransparency = 1

-- Função auxiliar para criar ScrollingFrame padronizado
local function makeContentScrolling(parent)
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

-- Cria as abas de conteúdo como ScrollingFrames
local movimentoFrame, movimentoLayout = makeContentScrolling(contentFrame)
local extrasFrame, extrasLayout = makeContentScrolling(contentFrame)
local visualFrame, visualLayout = makeContentScrolling(contentFrame)
movimentoFrame.Visible = true
extrasFrame.Visible = false
visualFrame.Visible = false

-- Alternância de abas com highlight visual
movimentoTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = true
    extrasFrame.Visible = false
    visualFrame.Visible = false
    movimentoTab.BackgroundColor3 = Color3.fromRGB(44,74,140)
    extrasTab.BackgroundColor3 = Color3.fromRGB(28,48,88)
    visualTab.BackgroundColor3 = Color3.fromRGB(28,48,88)
end)

extrasTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = false
    extrasFrame.Visible = true
    visualFrame.Visible = false
    extrasTab.BackgroundColor3 = Color3.fromRGB(44,74,140)
    movimentoTab.BackgroundColor3 = Color3.fromRGB(28,48,88)
    visualTab.BackgroundColor3 = Color3.fromRGB(28,48,88)
end)

visualTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = false
    extrasFrame.Visible = false
    visualFrame.Visible = true
    visualTab.BackgroundColor3 = Color3.fromRGB(44,74,140)
    movimentoTab.BackgroundColor3 = Color3.fromRGB(28,48,88)
    extrasTab.BackgroundColor3 = Color3.fromRGB(28,48,88)
end)

-- Atualiza CanvasSize automaticamente (evita problemas de scroll)
movimentoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if movimentoFrame and movimentoLayout then
        movimentoFrame.CanvasSize = UDim2.new(0, 0, 0, movimentoLayout.AbsoluteContentSize.Y + 12)
    end
end)

extrasLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if extrasFrame and extrasLayout then
        extrasFrame.CanvasSize = UDim2.new(0, 0, 0, extrasLayout.AbsoluteContentSize.Y + 12)
    end
end)

visualLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if visualFrame and visualLayout then
        visualFrame.CanvasSize = UDim2.new(0, 0, 0, visualLayout.AbsoluteContentSize.Y + 12)
    end
end)

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

-- Monta UI: sliders e botões no movimentoFrame (todos parentados corretamente)
do
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
    tpLabel.Font = Enum.Font.SourceSansSemibold

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
end

-- Monta UI: Extras
do
    createButton(extrasFrame, "Toggle Noclip", 1, function()
        if state.noclip then stopNoclip() else startNoclip() end
    end)

    local placeholderExtras = Instance.new("TextLabel", extrasFrame)
    placeholderExtras.Size = UDim2.new(0.9, 0, 0, 44)
    placeholderExtras.LayoutOrder = 2
    placeholderExtras.BackgroundTransparency = 1
    placeholderExtras.Text = "Extras: Noclip disponível"
    placeholderExtras.TextColor3 = Color3.fromRGB(220,220,220)
    placeholderExtras.TextScaled = true
    placeholderExtras.Font = Enum.Font.SourceSansSemibold
end

-- Visual functions: Highlight helper
local function createHighlight(targetModel, color)
    if not targetModel or not targetModel:IsA("Model") then return nil end
    local ok, highlight = pcall(function()
        local h = Instance.new("Highlight")
        h.Adornee = targetModel
        h.FillColor = color
        h.OutlineColor = Color3.new(0,0,0)
        h.FillTransparency = 0.6
        h.OutlineTransparency = 0
        h.Parent = targetModel
        return h
    end)
    if ok then return highlight end
    return nil
end

-- ESP Players
local function enableESPPlayers()
    if state.espPlayers then return end
    state.espPlayers = true
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= player and pl.Character and pl.Character:FindFirstChildOfClass("Humanoid") then
            local h = createHighlight(pl.Character, Color3.fromRGB(255, 100, 100))
            if h then state.espPlayerHighlights[pl] = h end
        end
    end
    state.espPlayersConn = Players.PlayerAdded:Connect(function(pl)
        task.wait(0.5)
        if state.espPlayers and pl.Character and pl.Character:FindFirstChildOfClass("Humanoid") then
            local h = createHighlight(pl.Character, Color3.fromRGB(255, 100, 100))
            if h then state.espPlayerHighlights[pl] = h end
        end
    end)
    Players.PlayerRemoving:Connect(function(pl)
        if state.espPlayerHighlights[pl] then
            pcall(function() state.espPlayerHighlights[pl]:Destroy() end)
            state.espPlayerHighlights[pl] = nil
        end
    end)
end

local function disableESPPlayers()
    state.espPlayers = false
    if state.espPlayersConn then state.espPlayersConn:Disconnect() state.espPlayersConn = nil end
    for pl, h in pairs(state.espPlayerHighlights) do
        if h and h.Parent then pcall(function() h:Destroy() end) end
        state.espPlayerHighlights[pl] = nil
    end
end

-- -- ESP NPCs
local function isNPCModel(m)
    if not m or not m:IsA("Model") then return false end
    if m:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(m) then
        return true
    end
    return false
end

local function addNPCHighlight(m)
    if not isNPCModel(m) then return end
    if state.espNPCHighlights[m] then return end
    local h = createHighlight(m, Color3.fromRGB(100, 200, 255))
    if h then state.espNPCHighlights[m] = h end
end

local function removeNPCHighlight(m)
    local h = state.espNPCHighlights[m]
    if h and h.Parent then pcall(function() h:Destroy() end) end
    state.espNPCHighlights[m] = nil
end

local function enableESPNPCs()
    if state.espNPCs then return end
    state.espNPCs = true
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isNPCModel(obj) then
            addNPCHighlight(obj)
        end
    end
    state.npcConn = Workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("Model") and isNPCModel(desc) then
            addNPCHighlight(desc)
        end
    end)
    state.npcRemovedConn = Workspace.DescendantRemoving:Connect(function(desc)
        if state.espNPCHighlights[desc] then
            removeNPCHighlight(desc)
        end
    end)
end

local function disableESPNPCs()
    state.espNPCs = false
    if state.npcConn then state.npcConn:Disconnect() state.npcConn = nil end
    if state.npcRemovedConn then state.npcRemovedConn:Disconnect() state.npcRemovedConn = nil end
    for m, h in pairs(state.espNPCHighlights) do
        if h and h.Parent then pcall(function() h:Destroy() end) end
        state.espNPCHighlights[m] = nil
    end
end

-- FOV Circle (Drawing API if disponível)
local function createFOVDrawing()
    local ok, Drawing = pcall(function() return Drawing end)
    if not ok or not Drawing then return nil end
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Radius = state.fovRadius
    circle.Color = Color3.new(1, 1, 1)
    circle.Thickness = 2
    circle.Filled = false
    circle.Transparency = 1
    return circle
end

local function enableFOV()
    local ok, Drawing = pcall(function() return Drawing end)
    if not ok or not Drawing then return end
    if state.fovEnabled then return end
    state.fovEnabled = true
    if not state.fovDrawing then
        state.fovDrawing = createFOVDrawing()
    end
    if state.fovDrawing then
        state.fovDrawing.Visible = true
        state.fovDrawing.Radius = state.fovRadius
    end
    state.fovConn = RunService.RenderStepped:Connect(function()
        if not state.fovDrawing then return end
        local mouse = player:GetMouse()
        local x, y = mouse.X, mouse.Y
        state.fovDrawing.Position = Vector2.new(x, y)
        state.fovDrawing.Radius = state.fovRadius
    end)
end

local function disableFOV()
    state.fovEnabled = false
    if state.fovConn then state.fovConn:Disconnect() state.fovConn = nil end
    if state.fovDrawing then
        pcall(function() state.fovDrawing.Visible = false end)
    end
end

-- Monta UI na aba Visual
do
    local vOrder = 1
    createButton(visualFrame, "Toggle ESP Players", vOrder, function()
        if state.espPlayers then disableESPPlayers() else enableESPPlayers() end
    end)
    vOrder = vOrder + 1

    createButton(visualFrame, "Toggle ESP NPCs", vOrder, function()
        if state.espNPCs then disableESPNPCs() else enableESPNPCs() end
    end)
    vOrder = vOrder + 1

    createButton(visualFrame, "Toggle FOV Circle", vOrder, function()
        if state.fovEnabled then disableFOV() else enableFOV() end
    end)
    vOrder = vOrder + 1

    createSlider(visualFrame, "FOV Radius", state.fovRadius, 50, 600, vOrder, function(val)
        state.fovRadius = val
        if state.fovDrawing then
            pcall(function() state.fovDrawing.Radius = val end)
        end
    end)
    vOrder = vOrder + 1

    local placeholderVisual = Instance.new("TextLabel", visualFrame)
    placeholderVisual.Size = UDim2.new(0.9, 0, 0, 44)
    placeholderVisual.LayoutOrder = vOrder
    placeholderVisual.BackgroundTransparency = 1
    placeholderVisual.Text = "Visual features: ESP e FOV"
    placeholderVisual.TextColor3 = Color3.fromRGB(220,220,220)
    placeholderVisual.TextScaled = true
    placeholderVisual.Font = Enum.Font.SourceSansSemibold
end

-- Ajusta CanvasSize dinamicamente (inicial)
task.delay(0.1, function()
    if visualLayout then visualFrame.CanvasSize = UDim2.new(0,0,0, visualLayout.AbsoluteContentSize.Y + 12) end
end)

-- Cleanup on script removal (protegido caso script seja nil)
if script and typeof(script) == "Instance" then
    script.AncestryChanged:Connect(function()
        if not script:IsDescendantOf(game) then
            stopNoclip()
            disableESPPlayers()
            disableESPNPCs()
            disableFOV()
        end
    end)
end
