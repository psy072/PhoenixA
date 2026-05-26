-- Phoenix A Hub (UI final revisada)
-- LocalScript -> StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Character refs
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
    espPlayersConn = nil,
    npcConn = nil,
    npcRemovedConn = nil,
    fovEnabled = false,
    fovRadius = 150,
    fovDrawing = nil,
    fovConn = nil
}

-- Helpers visuais
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

-- UI raiz
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

-- Abas com scroll (lateral)
local tabsScroll = Instance.new("ScrollingFrame", frame)
tabsScroll.Size = UDim2.new(0, 120, 1, -24)
tabsScroll.Position = UDim2.new(0, 12, 0, 64)
tabsScroll.BackgroundTransparency = 1
tabsScroll.ScrollBarThickness = 6
tabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local tabsLayout = Instance.new("UIListLayout", tabsScroll)
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 8)

local function createTab(name)
    local btn = Instance.new("TextButton", tabsScroll)
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.Text = name
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansSemibold
    btn.BackgroundColor3 = Color3.fromRGB(28, 48, 88)
    btn.TextColor3 = Color3.fromRGB(180, 0, 180)
    makeUICorner(btn, 8)
    makeStroke(btn, Color3.fromRGB(140,40,180), 1)
    return btn
end

local movimentoTab = createTab("Movimento")
local extrasTab = createTab("Extras")
local visualTab = createTab("Visual")

-- Área de conteúdo
local contentFrame = Instance.new("Frame", frame)
contentFrame.Size = UDim2.new(1, -160, 1, -96)
contentFrame.Position = UDim2.new(0, 144, 0, 64)
contentFrame.BackgroundTransparency = 1

local function createContentScroll(parent)
    local sf = Instance.new("ScrollingFrame", parent)
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundColor3 = Color3.fromRGB(18, 30, 56)
    sf.ScrollBarThickness = 6
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    makeUICorner(sf, 10)
    makeStroke(sf, Color3.fromRGB(140,40,180), 1)
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return sf, layout
end

local movimentoFrame, movimentoLayout = createContentScroll(contentFrame)
local extrasFrame, extrasLayout = createContentScroll(contentFrame)
local visualFrame, visualLayout = createContentScroll(contentFrame)
movimentoFrame.Visible = true
extrasFrame.Visible = false
visualFrame.Visible = false

-- Alternância de abas
movimentoTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = true
    extrasFrame.Visible = false
    visualFrame.Visible = false
end)
extrasTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = false
    extrasFrame.Visible = true
    visualFrame.Visible = false
end)
visualTab.MouseButton1Click:Connect(function()
    movimentoFrame.Visible = false
    extrasFrame.Visible = false
    visualFrame.Visible = true
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
visualLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() updateCanvasSize(visualFrame) end)

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

-- Monta UI: Movimento (garante LayoutOrder e visibilidade)
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

    -- Teleport input + button (organizado dentro do movimentoFrame)
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
    tpLabel.TextXAlignment = Enum.TextXAlignment.Left

    local tpBox = Instance.new("TextBox", tpContainer)
    tpBox.Size = UDim2.new(0.58, 0, 1, 0)
    tpBox.Position = UDim2.new(0.38, 0, 0, 0)
    tpBox.PlaceholderText = "player name"
    tpBox.Text = ""
    tpBox.TextScaled = true
    tpBox.BackgroundColor3 = Color3.fromRGB(24,44,84)
    tpBox.Font = Enum.Font.SourceSansSemibold
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

-- ESP NPCs
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

-- FOV Circle (Drawing API if available)
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
    if state.fovEnabled then return end
    local ok, Drawing = pcall(function() return Drawing end)
    if not ok or not Drawing then
        -- Drawing not available in this environment
        return
    end
    state.fovEnabled = true
    if not state.fovDrawing then
        state.fovDrawing = cr
