-- Phoenix A Hub (consolidado e funcional)
-- LocalScript para StarterPlayerScripts ou execução via loadstring

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

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
    fovConn = nil,
    espPlayersConn = nil,
    espPlayersRemovingConn = nil,
    npcConn = nil,
    npcRemovedConn = nil
}

-- Helpers UI
local function makeUICorner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = instance
    return c
end

local function makeStroke(instance, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(140,40,180) -- púrpura padrão
    s.Thickness = thickness or 1
    s.Parent = instance
    return s
end

-- Cria botão padronizado (texto em azul marinho)
local function createButton(parent, text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 44)
    btn.LayoutOrder = order or 1
    btn.Text = text
    btn.TextScaled = false
    btn.FontSize = Enum.FontSize.Size14
    btn.Font = Enum.Font.SourceSansSemibold
    btn.BackgroundColor3 = Color3.fromRGB(36, 66, 120)
    btn.TextColor3 = Color3.fromRGB(0,0,128) -- azul marinho
    btn.Parent = parent
    makeUICorner(btn, 8)
    makeStroke(btn) -- borda púrpura
    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)
    return btn
end

-- Slider completo (com interação por clique/arraste e TextBox)
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
    label.TextColor3 = Color3.fromRGB(0,0,128) -- azul marinho
    label.FontSize = Enum.FontSize.Size14
    label.TextScaled = false
    label.Font = Enum.Font.SourceSansSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueBox = Instance.new("TextBox", container)
    valueBox.Size = UDim2.new(0.22,0,0,28)
    valueBox.Position = UDim2.new(0.73,0,0,0)
    valueBox.BackgroundColor3 = Color3.fromRGB(24,44,84)
    valueBox.TextColor3 = Color3.fromRGB(0,0,128) -- azul marinho
    valueBox.FontSize = Enum.FontSize.Size14
    valueBox.TextScaled = false
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

    local tInit = 0
    if maxVal > minVal then
        tInit = (defaultValue - minVal) / (maxVal - minVal)
    end
    tInit = math.clamp(tInit, 0, 1)

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

    local function setValueFromT(t)
        t = math.clamp(t, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * t + 0.5)
        fill.Size = UDim2.new(t, 0, 1, 0)
        knob.Position = UDim2.new(t, 0, 0.5, 0)
        valueBox.Text = tostring(value)
        if onChange then pcall(onChange, value) end
    end

    local function setValueFromX(x)
        local absX = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local t = (bar.AbsoluteSize.X > 0) and (absX / bar.AbsoluteSize.X) or 0
        setValueFromT(t)
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
            setValueFromT(t)
        else
            valueBox.Text = tostring(defaultValue)
            setValueFromT((defaultValue - minVal) / math.max(1, (maxVal - minVal)))
        end
    end)

    -- inicializa
    setValueFromT(tInit)
    return container, valueBox
end

-- GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "PhoenixA_Hub"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 680, 0, 460)
frame.Position = UDim2.new(0.5, -340, 0.5, -230)
frame.BackgroundColor3 = Color3.fromRGB(12, 18, 34)
makeUICorner(frame, 14)
makeStroke(frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 48)
title.Position = UDim2.new(0, 0, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Phoenix A"
title.TextColor3 = Color3.fromRGB(180,0,180) -- púrpura
title.TextScaled = true
title.Font = Enum.Font.SourceSansSemibold

-- Toggle logo (pequeno botão para esconder UI)
local toggleBtn = Instance.new("ImageButton", screenGui)
toggleBtn.Size = UDim2.new(0, 56, 0, 56)
toggleBtn.Position = UDim2.new(0, 12, 0, 12)
toggleBtn.Image = "" -- opcional: coloque asset id se quiser
makeUICorner(toggleBtn, 8)
makeStroke(toggleBtn)
local uiVisible = true
toggleBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    frame.Visible = uiVisible
end)

-- Abas
local tabsContainer = Instance.new("Frame", frame)
tabsContainer.Size = UDim2.new(0, 120, 1, -24)
tabsContainer.Position = UDim2.new(0, 12, 0, 64)
tabsContainer.BackgroundTransparency = 1
local tabsLayout = Instance.new("UIListLayout", tabsContainer)
tabsLayout.Padding = UDim.new(0, 8)

local function createTab(name)
    local btn = Instance.new("TextButton", tabsContainer)
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.Text = name
    btn.TextScaled = false
    btn.FontSize = Enum.FontSize.Size14
    btn.Font = Enum.Font.SourceSansSemibold
    btn.BackgroundColor3 = Color3.fromRGB(28, 48, 88)
    btn.TextColor3 = Color3.fromRGB(0,0,128) -- azul marinho
    makeUICorner(btn, 8)
    makeStroke(btn)
    return btn
end

local extrasTab = createTab("Extras")
local visualTab = createTab("Visual")

-- Content frames
local contentFrame = Instance.new("Frame", frame)
contentFrame.Size = UDim2.new(1, -160, 1, -96)
contentFrame.Position = UDim2.new(0, 144, 0, 64)
contentFrame.BackgroundTransparency = 1

local function makeContentScrolling(parent)
    local sf = Instance.new("ScrollingFrame", parent)
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundColor3 = Color3.fromRGB(18, 30, 56)
    sf.ScrollBarThickness = 6
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    makeUICorner(sf, 10)
    makeStroke(sf)
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return sf, layout
end

local extrasFrame, extrasLayout = makeContentScrolling(contentFrame)
local visualFrame, visualLayout = makeContentScrolling(contentFrame)
extrasFrame.Visible = true
visualFrame.Visible = false

extrasTab.MouseButton1Click:Connect(function()
    extrasFrame.Visible = true
    visualFrame.Visible = false
    extrasTab.BackgroundColor3 = Color3.fromRGB(44,74,140)
    visualTab.BackgroundColor3 = Color3.fromRGB(28,48,88)
end)

visualTab.MouseButton1Click:Connect(function()
    extrasFrame.Visible = false
    visualFrame.Visible = true
    visualTab.BackgroundColor3 = Color3.fromRGB(44,74,140)
    extrasTab.BackgroundColor3 = Color3.fromRGB(28,48,88)
end)

-- Funções de movimento (noclip com restauração de colisões)
local function saveAndDisableCollisions()
    local char = player.Character
    if not char then return end
    state.savedCollisions = {}
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            state.savedCollisions[part] = part.CanCollide
            part.CanCollide = false
        end
    end
end

local function restoreCollisions()
    for part, canCollide in pairs(state.savedCollisions) do
        if part and part:IsA("BasePart") then
            pcall(function() part.CanCollide = canCollide end)
        end
    end
    state.savedCollisions = {}
end

local function startNoclip()
    if state.noclip then return end
    state.noclip = true
    saveAndDisableCollisions()
    if state.noclipConn then state.noclipConn:Disconnect() state.noclipConn = nil end
    state.noclipConn = RunService.Stepped:Connect(function()
        local char = player.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end)
end

local function stopNoclip()
    if not state.noclip then return end
    state.noclip = false
    if state.noclipConn then state.noclipConn:Disconnect() state.noclipConn = nil end
    restoreCollisions()
end

local function resetMovement()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            pcall(function() humanoid.UseJumpPower = true end)
        end
    end
    state.walkSpeed = 16
    state.jumpPower = 50
    stopNoclip()
end

local function teleportToPlayer(name)
    if not name or name == "" then return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= player and pl.Name:lower():find(name:lower()) then
            if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") and hrp then
                hrp.CFrame = pl.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
            end
            break
        end
    end
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
            local h = createHighlight(pl.Character, Color3.fromRGB(255,100,100))
            if h then state.espPlayerHighlights[pl] = h end
        end
    end
    state.espPlayersConn = Players.PlayerAdded:Connect(function(pl)
        task.wait(0.5)
        if state.espPlayers and pl.Character and pl.Character:FindFirstChildOfClass("Humanoid") then
            local h = createHighlight(pl.Character, Color3.fromRGB(255,100,100))
            if h then state.espPlayerHighlights[pl] = h end
        end
    end)
    state.espPlayersRemovingConn = Players.PlayerRemoving:Connect(function(pl)
        if state.espPlayerHighlights[pl] then
            pcall(function() state.espPlayerHighlights[pl]:Destroy() end)
            state.espPlayerHighlights[pl] = nil
        end
    end)
end

local function disableESPPlayers()
    state.espPlayers = false
    if state.espPlayersConn then state.espPlayersConn:Disconnect() state.espPlayersConn = nil end
    if state.espPlayersRemovingConn then state.espPlayersRemovingConn:Disconnect() state.espPlayersRemovingConn = nil end
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
    local h = createHighlight(m, Color3.fromRGB(100,200,255))
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
    local ok, Drawing = pcall(function() return Drawing end)
    if not ok or not Drawing then return end
    if state.fovEnabled then return end
    state.fovEnabled = true
    if not state.fovDrawing then state.fovDrawing = createFOVDrawing() end
    if state.fovDrawing then
        state.fovDrawing.Visible = true
        state.fovDrawing.Radius = state.fovRadius
    end
    state.fovConn = RunService.RenderStepped:Connect(function()
        if not state.fovDrawing then return end
        local mouse = player:GetMouse()
        state.fovDrawing.Position = Vector2.new(mouse.X, mouse.Y)
        state.fovDrawing.Radius = state.fovRadius
    end)
end

local function disableFOV()
    state.fovEnabled = false
    if state.fovConn then state.fovConn:Disconnect() state.fovConn = nil end
    if state.fovDrawing then pcall(function() state.fovDrawing.Visible = false end) end
end

-- Monta UI na aba Visual
do
    local vOrder = 1
    local btnPlayers = createButton(visualFrame, "Toggle ESP Players", vOrder, function()
        if state.espPlayers then disableESPPlayers() else enableESPPlayers() end
    end)
    vOrder = vOrder + 1

    local btnNPCs = createButton(visualFrame, "Toggle ESP NPCs", vOrder, function()
        if state.espNPCs then disableESPNPCs() else enableESPNPCs() end
    end)
    vOrder = vOrder + 1

    local btnFOV = createButton(visualFrame, "Toggle FOV Circle", vOrder, function()
        if state.fovEnabled then disableFOV() else enableFOV() end
    end)
    vOrder = vOrder + 1

    local fovContainer, fovBox = createSlider(visualFrame, "FOV Radius", state.fovRadius, 50, 600, vOrder, function(val)
        state.fovRadius = val
        if state.fovDrawing then pcall(function() state.fovDrawing.Radius = val end) end
    end)
    fovContainer.LayoutOrder = vOrder
    vOrder = vOrder + 1

    local placeholderVisual = Instance.new("TextLabel", visualFrame)
    placeholderVisual.Size = UDim2.new(0.9, 0, 0, 44)
    placeholderVisual.LayoutOrder = vOrder
    placeholderVisual.BackgroundTransparency = 1
    placeholderVisual.Text = "Visual features: ESP e FOV"
    placeholderVisual.TextColor3 = Color3.fromRGB(0,0,128)
    placeholderVisual.FontSize = Enum.FontSize.Size14
    placeholderVisual.TextScaled = false
    placeholderVisual.Font = Enum.Font.SourceSansSemibold
end

-- UI Extras (controles de movimento e noclip)
do
    local order = 1

    -- Noclip ON/OFF (botão interativo)
    local btnNoclip = createButton(extrasFrame, state.noclip and "Noclip ON" or "Noclip OFF", order, function()
        if state.noclip then
            stopNoclip()
            btnNoclip.Text = "Noclip OFF"
        else
            startNoclip()
            btnNoclip.Text = "Noclip ON"
        end
    end)
    btnNoclip.LayoutOrder = order
    order = order + 1

    -- Reset Movement
    local btnReset = createButton(extrasFrame, "Reset Movement", order, function()
        resetMovement()
    end)
    btnReset.LayoutOrder = order
    order = order + 1

    -- Walk Speed slider
    local wsContainer, wsBox = createSlider(extrasFrame, "Walk Speed", state.walkSpeed, 8, 300, order, function(val)
        state.walkSpeed = val
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = val end
        end
    end)
    wsContainer.LayoutOrder = order
    order = order + 1

    -- -- Jump Power slider
    local jpContainer, jpBox = createSlider(extrasFrame, "Jump Power", state.jumpPower, 10, 300, order, function(val)
        state.jumpPower = val
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = val
                pcall(function() humanoid.UseJumpPower = true end)
            end
        end
    end)
    jpContainer.LayoutOrder = order
    order = order + 1

    -- Teleport input + botão
    local tpContainer = Instance.new("Frame", extrasFrame)
    tpContainer.Size = UDim2.new(0.95, 0, 0, 44)
    tpContainer.LayoutOrder = order
    tpContainer.BackgroundTransparency = 1

    local tpLabel = Instance.new("TextLabel", tpContainer)
    tpLabel.Size = UDim2.new(0.36, 0, 1, 0)
    tpLabel.BackgroundTransparency = 1
    tpLabel.Text = "Teleport to"
    tpLabel.TextColor3 = Color3.fromRGB(0,0,128)
    tpLabel.FontSize = Enum.FontSize.Size14
    tpLabel.TextScaled = false
    tpLabel.Font = Enum.Font.SourceSansSemibold

    local tpBox = Instance.new("TextBox", tpContainer)
    tpBox.Size = UDim2.new(0.58, 0, 1, 0)
    tpBox.Position = UDim2.new(0.38, 0, 0, 0)
    tpBox.PlaceholderText = "player name"
    tpBox.Text = ""
    tpBox.TextColor3 = Color3.fromRGB(0,0,128)
    tpBox.FontSize = Enum.FontSize.Size14
    tpBox.TextScaled = false
    tpBox.BackgroundColor3 = Color3.fromRGB(24,44,84)
    makeUICorner(tpBox, 6)
    makeStroke(tpBox)
    order = order + 1

    local btnTeleport = createButton(extrasFrame, "Teleport", order, function()
        teleportToPlayer(tpBox.Text)
    end)
    btnTeleport.LayoutOrder = order
    order = order + 1

    -- Placeholder / nota
    local placeholderExtras = Instance.new("TextLabel", extrasFrame)
    placeholderExtras.Size = UDim2.new(0.9, 0, 0, 44)
    placeholderExtras.LayoutOrder = order
    placeholderExtras.BackgroundTransparency = 1
    placeholderExtras.Text = "Extras e controles de Movimento"
    placeholderExtras.TextColor3 = Color3.fromRGB(0,0,128)
    placeholderExtras.FontSize = Enum.FontSize.Size14
    placeholderExtras.TextScaled = false
    placeholderExtras.Font = Enum.Font.SourceSansSemibold
end

-- Ajusta CanvasSize automaticamente
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

-- Aplica valores iniciais ao humanoid (se existir)
task.defer(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = state.walkSpeed
        humanoid.JumpPower = state.jumpPower
        pcall(function() humanoid.UseJumpPower = true end)
    end
end)

-- Cleanup ao remover o script
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
