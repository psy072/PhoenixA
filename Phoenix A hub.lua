-- Phoenix A hub (UI + toggle + drag universal + abas verticais com bordas arredondadas e funções de movimento)

local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 250)
frame.Position = UDim2.new(0.5, -200, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(128, 0, 128)
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Phoenix A"
title.TextColor3 = Color3.fromRGB(128, 0, 128)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Toggle logo
local logoToggle = Instance.new("ImageButton")
logoToggle.Size = UDim2.new(0, 60, 0, 60)
logoToggle.Position = UDim2.new(0, 10, 0, 10)
logoToggle.Image = "rbxassetid://126836694733781"
logoToggle.Parent = screenGui

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 8)
logoCorner.Parent = logoToggle

local logoStroke = Instance.new("UIStroke")
logoStroke.Thickness = 2
logoStroke.Color = Color3.fromRGB(128, 0, 128)
logoStroke.Parent = logoToggle

-- Toggle visibilidade
local uiVisible = true
logoToggle.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    frame.Visible = uiVisible
end)

-- Função drag universal
local function makeDraggable(guiObject)
    local dragging = false
    local dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

makeDraggable(frame)
makeDraggable(logoToggle)

-- Container lateral para abas
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0, 120, 1, -40)
tabContainer.Position = UDim2.new(1, -120, 0, 40)
tabContainer.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
tabContainer.Parent = frame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 12)
tabCorner.Parent = tabContainer

local tabStroke = Instance.new("UIStroke")
tabStroke.Thickness = 2
tabStroke.Color = Color3.fromRGB(128, 0, 128)
tabStroke.Parent = tabContainer

-- Função para criar botão de aba vertical
local function createTab(name, posY)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.Position = UDim2.new(0, 0, 0, posY)
    tabButton.Text = name
    tabButton.TextScaled = true
    tabButton.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = tabButton

    local bStroke = Instance.new("UIStroke")
    bStroke.Thickness = 2
    bStroke.Color = Color3.fromRGB(128, 0, 128)
    bStroke.Parent = tabButton

    tabButton.Parent = tabContainer
    return tabButton
end

-- Criar abas verticais
local movimentoTab = createTab("Movimento", 0)
local visualTab = createTab("Visual", 50)
local extrasTab = createTab("Extras", 100)

-- Frames de conteúdo
local function createContentFrame()
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, -120, 1, -80)
    contentFrame.Position = UDim2.new(0, 0, 0, 80)
    contentFrame.BackgroundColor3 = Color3.fromRGB(15, 30, 60)
    contentFrame.ScrollBarThickness = 6
    contentFrame.CanvasSize = UDim2.new(0,0,0,0)
    contentFrame.Visible = false
    contentFrame.Parent = frame

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 12)
    fCorner.Parent = contentFrame

    local fStroke = Instance.new("UIStroke")
    fStroke.Thickness = 2
    fStroke.Color = Color3.fromRGB(128, 0, 128)
    fStroke.Parent = contentFrame

    return contentFrame
end

local movimentoFrame = createContentFrame()
movimentoFrame.Visible = true
local visualFrame = createContentFrame()
local extrasFrame = createContentFrame()

-- Alternar abas
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

-- Função para criar botões dentro da aba Movimento
local function createButton(parent, text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = UDim2.new(0.1, 0, 0, posY)
    btn.Text = text
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 8)
    bCorner.Parent = btn

    local bStroke = Instance.new("UIStroke")
    bStroke.Thickness = 2
    bStroke.Color = Color3.fromRGB(128, 0, 128)
    bStroke.Parent = btn

    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Funções funcionais em Movimento
local humanoid = player.Character:WaitForChild("Humanoid")

createButton(movimentoFrame, "Fly", 0, function()
    humanoid.PlatformStand = not humanoid.PlatformStand
    if humanoid.PlatformStand then
        local bv = Instance.new("BodyVelocity", player.Character.HumanoidRootPart)
        bv.MaxForce = Vector3.new(4000,4000,4000)
        bv.Velocity = Vector3.new(0,0,0)
    else
        if player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
            player.Character.HumanoidRootPart.BodyVelocity:Destroy()
        end
    end
end)

createButton(movimentoFrame, "Speed", 50, function()
    humanoid.WalkSpeed = 50
end)

createButton(movimentoFrame, "JumpBoost", 100, function()
    humanoid.JumpPower = 150
end)

createButton(movimentoFrame, "Noclip", 150, function()
    local noclip = true
