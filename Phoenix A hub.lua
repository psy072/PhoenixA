-- Phoenix A Hub (versão adaptada para loadstring)
-- Carregue com: loadstring(game:HttpGet("URL_DO_SEU_SCRIPT"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Cria GUI direto no PlayerGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PhoenixA_Hub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 680, 0, 460)
frame.Position = UDim2.new(0.5, -340, 0.5, -230)
frame.BackgroundColor3 = Color3.fromRGB(12, 18, 34)

-- Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 48)
title.Position = UDim2.new(0, 0, 0, 8)
title.Text = "Phoenix A"
title.TextScaled = true
title.Font = Enum.Font.SourceSansSemibold
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextColor3 = Color3.fromRGB(180,0,180)

-- Abas
local tabsScroll = Instance.new("ScrollingFrame", frame)
tabsScroll.Size = UDim2.new(0, 120, 1, -24)
tabsScroll.Position = UDim2.new(0, 12, 0, 64)
tabsScroll.ScrollBarThickness = 6
tabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local function createTab(name)
    local btn = Instance.new("TextButton", tabsScroll)
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.Text = name
    btn.TextScaled = true
    btn.Font = Enum.Font.SourceSansSemibold
    btn.BackgroundColor3 = Color3.fromRGB(28,48,88)
    btn.TextColor3 = Color3.fromRGB(180,0,180)
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
    sf.ScrollBarThickness = 6
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
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

-- Funções Movimento
local resetBtn = Instance.new("TextButton", movimentoFrame)
resetBtn.Size = UDim2.new(0.9,0,0,44)
resetBtn.Text = "Reset Movement"
resetBtn.TextScaled = true
resetBtn.Font = Enum.Font.SourceSansSemibold
resetBtn.BackgroundColor3 = Color3.fromRGB(36,66,120)
resetBtn.TextColor3 = Color3.fromRGB(255,255,255)
resetBtn.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end)

-- Funções Extras
local noclipBtn = Instance.new("TextButton", extrasFrame)
noclipBtn.Size = UDim2.new(0.9,0,0,44)
noclipBtn.Text = "Toggle Noclip"
noclipBtn.TextScaled = true
noclipBtn.Font = Enum.Font.SourceSansSemibold
noclipBtn.BackgroundColor3 = Color3.fromRGB(36,66,120)
noclipBtn.TextColor3 = Color3.fromRGB(255,255,255)
local noclip = false
noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    RunService.Stepped:Connect(function()
        if noclip and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- Funções Visual
local espBtn = Instance.new("TextButton", visualFrame)
espBtn.Size = UDim2.new(0.9,0,0,44)
espBtn.Text = "Toggle ESP Players"
espBtn.TextScaled = true
espBtn.Font = Enum.Font.SourceSansSemibold
espBtn.BackgroundColor3 = Color3.fromRGB(36,66,120)
espBtn.TextColor3 = Color3.fromRGB(255,255,255)
local espOn = false
espBtn.MouseButton1Click:Connect(function()
    espOn = not espOn
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= player and pl.Character then
            local h = pl.Character:FindFirstChild("Highlight") or Instance.new("Highlight", pl.Character)
            h.Enabled = espOn
            h.FillColor = Color3.fromRGB(255,100,100)
        end
    end
end)
