-- Phoenix A hub (versão completa e revisada)
-- Requisitos: LocalScript em StarterPlayerScripts ou similar

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local function waitForCharacter()
    if player.Character and player.Character.Parent then
        return player.Character
    end
    return player.CharacterAdded:Wait()
end

local character = waitForCharacter()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Re-attach on respawn
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- UI root
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 460, 0, 320)
frame.Position = UDim2.new(0.5, -230, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(10,20,40)
frame.Parent = screenGui
local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0,12)
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Thickness = 2
frameStroke.Color = Color3.fromRGB(128,0,128)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -140, 0, 44)
title.Position = UDim2.new(0, 12, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Phoenix A"
title.TextColor3 = Color3.fromRGB(200,120,255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold

-- Toggle logo (abre/fecha UI)
local logoToggle = Instance.new("ImageButton", screenGui)
logoToggle.Size = UDim2.new(0,56,0,56)
logoToggle.Position = UDim2.new(0,12,0,12)
logoToggle.Image = "rbxassetid://126836694733781"
local logoCorner = Instance.new("UICorner", logoToggle)
logoCorner.CornerRadius = UDim.new(0,8)
local logoStroke = Instance.new("UIStroke", logoToggle)
logoStroke.Thickness = 2
logoStroke.Color = Color3.fromRGB(128,0,128)

local uiVisible = true
logoToggle.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    frame.Visible = uiVisible
end)

-- Drag universal
local function makeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(frame)
makeDraggable(logoToggle)

-- Tab container (direita)
local tabContainer = Instance.new("Frame", frame)
tabContainer.Size = UDim2.new(0,140,1,-60)
tabContainer.Position = UDim2.new(1,-140,0,56)
tabContainer.BackgroundColor3 = Color3.fromRGB(10,20,40)
local tabCorner = Instance.new("UICorner", tabContainer)
tabCorner.CornerRadius = UDim.new(0,12)
local tabStroke = Instance.new("UIStroke", tabContainer)
tabStroke.Thickness = 2
tabStroke.Color = Color3.fromRGB(128,0,128)

-- Create tab button helper (aplica estilo e hover)
local function createTab(name, y)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(1, -12, 0, 44)
    btn.Position = UDim2.new(0,6,0,y)
    btn.Text = name
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(20,40,80)
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(128,0,128)
    -- hover effect
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(40,70,120) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(20,40,80) end)
    return btn
end

local movimentoTab = createTab("Movimento", 6)
local visualTab = createTab("Visual", 56)
local extrasTab = createTab("Extras", 106)

-- Content frames (com cantos arredondados e UIListLayout)
local function createContent()
    local sf = Instance.new("ScrollingFrame", frame)
    sf.Size = UDim2.new(1, -160, 1, -80)
    sf.Position = UDim2.new(0,12,0,56)
    sf.BackgroundColor3 = Color3.fromRGB(15,30,60)
    sf.ScrollBarThickness = 6
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", sf).CornerRadius = UDim.new(0,12)
    local stroke = Instance.new("UIStroke", sf)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(128,0,128)
    local layout = Instance.new("UIListLayout", sf)
    layout.Padding = UDim.new(0,8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    return sf, layout
end

local movimentoFrame, movimentoLayout = createContent()
local visualFrame, _ = createContent()
local extrasFrame, _ = createContent()
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

-- Helper: criar botão estilizado (adiciona hover e clique visual)
local function createButton(parent, text, order, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 44)
    btn.LayoutOrder = order or 1
    btn.Text = text
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(30,60,120)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(128,0,128)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45,85,160) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(30,60,120) end)
    btn.MouseButton1Click:Connect(function()
        -- clique visual rápido
        btn.BackgroundColor3 = Color3.fromRGB(20,40,80)
        task.wait(0.06)
        btn.BackgroundColor3 = Color3.fromRGB(30,60,120)
        if callback then pcall(callback) end
    end)
    return btn
end

-- Input box helper (para Teleport)
local function createInputRow(parent, labelText, placeholder, order)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(0.95,0,0,44)
    container.LayoutOrder = order or 1
    container.BackgroundTransparency = 1
    local txt = Instance.new("TextLabel", container)
    txt.Size = UDim2.new(0.35,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = labelText
    txt.TextColor3 = Color3.fromRGB(220,220,220)
    txt.TextScaled = true
    txt.Font = Enum.Font.SourceSans
    local box = Instance.new("TextBox", container)
    box.Size = UDim2.new(0.62,0,1,0)
    box.Position = UDim2.new(0.37,0,0,0)
    box.PlaceholderText = placeholder or ""
    box.Text = ""
    box.TextScaled = true
    box.BackgroundColor3 = Color3.fromRGB(25,45,85)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
    local stroke = Instance.new("UIStroke", box)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(128,0,128)
    return container, box
end

-- Movement state
local state = {
    fly = false,
    flySpeed = 60,
    speed = 16,
    jumpPower = 50,
    noclip = false,
    flyBV = nil,
    flyBG = nil,
    noclipConnection = nil,
    flyConnection = nil
}

-- Utility: update CanvasSize (ensures scroll funciona)
local function updateCanvasSize(scrollingFrame)
    local layout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
    if not layout then return end
    local contentSize = layout.AbsoluteContentSize
    scrollingFrame.CanvasSize = UDim2.new(0,0,0, contentSize.Y + 12)
end

-- Connect automatic CanvasSize update
movimentoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    updateCanvasSize(movimentoFrame)
end)

-- Fly implementation (WASD + space/shift)
local keys = {W=false,A=false,S=false,D=false,Space=false,LeftShift=false}
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keys[input.KeyCode.Name] = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keys[input.KeyCode.Name] = false
    end
end)

local function startFly()
    if not hrp then return end
    if state.flyConnection then return end
    state.fly = true
    humanoid.PlatformStand = true
    -- BodyVelocity and BodyGyro for smoother control
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    state.flyBV = bv
    state.flyBG = bg

    state.flyConnection = RunService.RenderStepped:Connect(function(dt)
        if not hrp or not humanoid or not state.fly then return end
        local cam = workspace.CurrentCamera
        local forward = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local move = Vector3.new(0,0,0)
        if keys.W then move = move + forward end
        if keys.S then move = move - forward end
        if keys.D then move = move + right end
        if keys.A then move = move - right end
        local vertical = 0
        if keys.Space then vertical = vertical + 1 end
        if keys.LeftShift then vertical = vertical - 1 end
        local direction = (move.Unit ~= move.Unit and Vector3.new(0,0,0) or move).Unit
        local speedVec = (direction * state.flySpeed) + Vector3.new(0, vertical * state.flySpeed, 0)
        bv.Velocity = speedVec
        bg.CFrame = cam.CFrame
    end)
end

local function stopFly()
    state.fly = false
    humanoid.PlatformStand = false
    if state.flyConnection then
        state.flyConnection:Disconnect()
        state.flyConnection = nil
    end
    if state.flyBV and state.flyBV.Parent then state.flyBV:Destroy() end
    if state.flyBG and state.flyBG.Parent then state.flyBG:Destroy() end
    state.flyBV = nil
    state.flyBG = nil
end

-- Noclip implementation
local function startNoclip()
    if state.noclip then return end
    state.noclip = true
    state.noclipConnection = RunService.Stepped:Connect(function()
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
    if state.noclipConnection then
        state.noclipConnection:Disconnect()
        state.noclipConnection = nil
    end
    -- restore collisions (best-effort)
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Teleport to player helper
local function teleportToPlayer(name)
    if not name or name == "" then return end
    local target = nil
    for _, pl in pairs(Players:GetPlayers()) do
        if pl.Name:lower():find(name:lower()) then
            target = pl
            break
        end
    end
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
    end
end

-- Reset function
local function resetMovement()
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    stopFly()
    stopNoclip()
end

-- Create movement buttons and inputs
local order = 1
createButton(movimentoFrame, "Toggle Fly (WASD + Space/Shift)", order, function()
    if state.fly then stopFly() else startFly() end
end); order = order + 1

-- Fly speed slider-like quick options (small buttons)
createButton(movimentoFrame, "Fly Speed: 30", order, function() state.flySpeed = 30 end); order = order + 1
createButton(movimentoFrame, "Fly Speed: 60", order, function() state.flySpeed = 60 end); order = order + 1
createButton(movimentoFrame, "Fly Speed: 120", order, function() state.flySpeed = 120 end); order = order + 1

createButton(movimentoFrame, "Set WalkSpeed 50", order, function() humanoid.WalkSpeed = 50 end); order = order + 1
createButton(movimentoFrame, "Set WalkSpeed 16 (default)", order, function() humanoid.WalkSpeed = 16 end); order = order + 1

createButton(movimentoFrame, "JumpBoost (150)", order, function() humanoid.JumpPower = 150 end); order = order + 1
createButton(movimentoFrame, "Set JumpPower 50 (default)", order, function() humanoid.JumpPower = 50 end); order = order + 1

createButton(movimentoFrame, "Toggle Noclip", order, function()
    if state.noclip then stopNoclip() else startNoclip() end
end); order = order + 1

-- Teleport input + button
local row, tpBox = createInputRow(movimentoFrame, "Teleport to", "player name", order); order = order + 1
local tpBtn = createButton(movimentoFrame, "Teleport", order, function()
    teleportToPlayer(tpBox.Text)
end); order = order + 1

createButton(movimentoFrame, "Reset Movement", order, function()
    resetMovement()
end); order = order + 1

-- Ensure CanvasSize initial update
task.delay(0.1, function() updateCanvasSize(movimentoFrame) end)

-- Safety: cleanup on script disable
script.Disabled = false
script.AncestryChanged:Connect(function()
    if not script:IsDescendantOf(game) then
        stopFly()
        stopNoclip()
    end
end)
