-- Phoenix A Hub (versão final consolidada)
-- LocalScript pronto para rodar em StarterPlayerScripts ou via loadstring

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
    fovConn = nil
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
    s.Color = color or Color3.fromRGB(140,40,180) -- borda púrpura
    s.Thickness = thickness or 1
    s.Parent = instance
    return s
end

local function createButton(parent, text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 44)
    btn.LayoutOrder = order or 1
    btn.Text = text
    btn.TextScaled = false
    btn.FontSize = Enum.FontSize.Size14
    btn.Font = Enum.Font.SourceSansSemibold
    btn.BackgroundColor3 = Color3.fromRGB(36, 66, 120)
    btn.TextColor3 = Color3.fromRGB(255,255,255) -- branco
    btn.Parent = parent
    makeUICorner(btn, 8)
    makeStroke(btn)
    btn.MouseButton1Click:Connect(function()
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
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255,255,255) -- branco
    label.FontSize = Enum.FontSize.Size14
    label.Font = Enum.Font.SourceSansSemibold

    local valueBox = Instance.new("TextBox", container)
    valueBox.Size = UDim2.new(0.22,0,0,28)
    valueBox.Position = UDim2.new(0.73,0,0,0)
    valueBox.BackgroundColor3 = Color3.fromRGB(24,44,84)
    valueBox.TextColor3 = Color3.fromRGB(255,255,255) -- branco
    valueBox.FontSize = Enum.FontSize.Size14
    valueBox.Text = tostring(defaultValue)
    makeUICorner(valueBox, 6)
    makeStroke(valueBox)

    if onChange then pcall(onChange, defaultValue) end
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
title.TextColor3 = Color3.fromRGB(180,0,180) -- púrpura imutável
title.TextScaled = true
title.Font = Enum.Font.SourceSansSemibold

-- Toggle logo (mostrar/ocultar UI)
local toggleBtn = Instance.new("ImageButton", screenGui)
toggleBtn.Size = UDim2.new(0, 56, 0, 56)
toggleBtn.Position = UDim2.new(0, 12, 0, 12)
toggleBtn.Image = "" -- opcional: coloque asset id se quiser
makeUICorner(toggleBtn, 8)
makeStroke(toggleBtn) -- borda púrpura

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
    btn.TextColor3 = Color3.fromRGB(255,255,255) -- branco
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
end)

visualTab.MouseButton1Click:Connect(function()
    extrasFrame.Visible = false
    visualFrame.Visible = true
end)

-- Funções de movimento
local function startNoclip()
    if state.noclip then return end
    state.noclip = true
    state.noclipConn = RunService.Stepped:Connect(function()
        local char = player.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function stopNoclip()
    state.noclip = false
    if state.noclipConn then
        state.noclipConn:Disconnect()
        state.noclipConn = nil
    end
end

local function resetMovement()
    local char = player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = 16
        char.Humanoid.JumpPower = 50
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

-- UI Extras (todos os controles aqui)
do
    local order = 1

    local btnNoclip = createButton(extrasFrame, "Noclip OFF", order, function()
        if state.noclip then
            stopNoclip()
            btnNoclip.Text = "Noclip OFF"
        else
            startNoclip()
            btnNoclip.Text = "Noclip ON"
        end
    end)
    order = order + 1

    local btnReset = createButton(extrasFrame, "Reset Movement", order, function()
        resetMovement()
    end)
    order = order + 1

    local wsContainer, wsBox = createSlider(extrasFrame, "Walk Speed", state.walkSpeed, 8, 300, order, function(val)
        state.walkSpeed = val
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = val end
        end
    end)
    order = order + 1

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
    order = order + 1

    local tpContainer = Instance.new("Frame", extrasFrame)
    tpContainer.Size = UDim2.new(0.95, 0, 0, 44)
    tpContainer.LayoutOrder = order
    tpContainer.BackgroundTransparency = 1

    local tpLabel = Instance.new("TextLabel", tpContainer)
    tpLabel.Size = UDim2.new(0.36, 0, 1, 0)
    tpLabel.BackgroundTransparency = 1
    tpLabel.Text = "Teleport to"
    tpLabel.TextColor3 = Color3.fromRGB(255,255,255)
    tpLabel.FontSize = Enum.FontSize.Size14
    tpLabel.Font = Enum.Font.SourceSansSemibold

    local tpBox = Instance.new("TextBox", tpContainer)
    tpBox.Size = UDim2.new(0.58, 0, 1, 0)
    tpBox.Position = UDim2.new(0.38, 0, 0, 0)
    tpBox.PlaceholderText = "player name"
    tpBox.TextColor3 = Color3.fromRGB(255,255,255)
    tpBox.FontSize = Enum.FontSize.Size14
    tpBox.BackgroundColor3 = Color3.fromRGB(24,44,84)
    makeUICorner(tpBox, 6)
    makeStroke(tpBox)
    order = order + 1

    local btnTeleport = createButton(extrasFrame, "Teleport", order, function()
        teleportToPlayer(tpBox.Text)
    end)
    order = order + 1

    local placeholderExtras = Instance.new("TextLabel", extrasFrame)
    placeholderExtras.Size = UDim2.new(0.9, 0, 0, 44)
    placeholderExtras.LayoutOrder = order
    placeholderExtras.BackgroundTransparency = 1
    placeholderExtras.Text = "Extras e controles de Movimento"
    placeholderExtras.TextColor3 = Color3.fromRGB(255,255,255)
    placeholderExtras.FontSize = Enum.FontSize.Size14
    placeholderExtras.Font = Enum.Font.SourceSansSemibold
end

-- UI Visual (ESP e FOV)
do
    local vOrder = 1
    local btnPlayers = createButton(visualFrame, "Toggle ESP Players", vOrder, function()
        state.espPlayers = not state.espPlayers
        -- aqui você pode ligar/desligar highlights
    end)
    vOrder = vOrder + 1

    local btnNPCs = createButton(visualFrame, "Toggle ESP NPCs", vOrder, function()
        state.espNPCs = not state.espNPCs
        -- aqui você pode ligar/desligar highlights de NPC
    end)
    vOrder = vOrder + 1

    local btnFOV = createButton(visualFrame, "Toggle FOV Circle", vOrder, function()
        state.fovEnabled = not state.fovEnabled
        -- aqui você pode ligar/desligar círculo FOV
    end)
    vOrder = vOrder + 1

    local fovContainer, fovBox = createSlider(visualFrame, "FOV Radius", state.fovRadius, 50, 600, vOrder, function(val)
        state.fovRadius = val
        -- ajuste do raio do círculo FOV
    end)
    vOrder = vOrder + 1

    local placeholderVisual = Instance.new("TextLabel", visualFrame)
    placeholderVisual.Size = UDim2.new(0.9, 0, 0, 44)
    placeholderVisual.LayoutOrder = vOrder
    placeholderVisual.BackgroundTransparency = 1
    placeholderVisual.Text = "Visual features: ESP e FOV"
    placeholderVisual.TextColor3 = Color3.fromRGB(255,255,255)
    placeholderVisual.FontSize = Enum.FontSize.Size14
    placeholderVisual.Font = Enum.Font.SourceSansSemibold
end

-- Ajusta CanvasSize automaticamente
extrasLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    extrasFrame.CanvasSize = UDim2.new(0,0,0, extrasLayout.AbsoluteContentSize.Y + 12)
end)
visualLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    visualFrame.CanvasSize = UDim2.new(0,0,0, visualLayout.AbsoluteContentSize.Y + 12)
end)

-- Inicializa humanoid quando personagem aparece
player.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = state.walkSpeed
        humanoid.JumpPower = state.jumpPower
        pcall(function() humanoid.UseJumpPower = true end)
    end
end)

-- Aplica valores iniciais se personagem já existir
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
if typeof(script) == "Instance" then
    script.AncestryChanged:Connect(function()
        if not script:IsDescendantOf(game) then
            stopNoclip()
            -- desligar ESP e FOV se necessário
        end
    end)
end
