-- Phoenix A hub (UI + toggle + drag universal + abas verticais)

local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
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

-- Botão toggle (logo)
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
tabContainer.Size = UDim2.new(0, 100, 1, -40)
tabContainer.Position = UDim2.new(1, -100, 0, 40)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

-- Função para criar botão de aba vertical
local function createTab(name, posY)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.Position = UDim2.new(0, 0, 0, posY)
    tabButton.Text = name
    tabButton.TextScaled = true
    tabButton.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Parent = tabContainer
    return tabButton
end

-- Criar abas verticais
local movimentoTab = createTab("Movimento", 0)
local visualTab = createTab("Visual", 50)
local extrasTab = createTab("Extras", 100)

-- Frames de conteúdo
local movimentoFrame = Instance.new("Frame")
movimentoFrame.Size = UDim2.new(1, -100, 1, -80)
movimentoFrame.Position = UDim2.new(0, 0, 0, 80)
movimentoFrame.BackgroundColor3 = Color3.fromRGB(15, 30, 60)
movimentoFrame.Visible = true
movimentoFrame.Parent = frame

local visualFrame = movimentoFrame:Clone()
visualFrame.Visible = false
visualFrame.Parent = frame

local extrasFrame = movimentoFrame:Clone()
extrasFrame.Visible = false
extrasFrame.Parent = frame

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
