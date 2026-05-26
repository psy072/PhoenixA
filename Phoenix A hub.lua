-- Phoenix A Hub (UI atualizada com scroll e aba Visual)
-- Recursos: WalkSpeed, JumpPower, Noclip, Teleport, Reset
-- UI: abas verticais com scroll, título centralizado
-- Cole este LocalScript em StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
    savedCollisions = {}
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

-- UI raiz
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "PhoenixA_Hub"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 680, 0, 420)
frame.Position = UDim2.new(0.5, -340, 0.5, -210)
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

-- Abas com scroll
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
    return sf
end

local movimentoFrame = createContentScroll(contentFrame)
local extrasFrame = createContentScroll(contentFrame)
local visualFrame = createContentScroll(contentFrame)
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

-- Placeholder Visual
local placeholder = Instance.new("TextLabel", visualFrame)
placeholder.Size = UDim2.new(0.9, 0, 0, 44)
placeholder.BackgroundTransparency = 1
placeholder.Text = "Visual features coming soon"
placeholder.TextColor3 = Color3.fromRGB(220,220,220)
placeholder.TextScaled = true
placeholder.Font = Enum.Font.SourceSansSemibold
