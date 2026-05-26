-- Phoenix A Hub (versão mínima funcional)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local state = {fly=false,flySpeed=60,jumpPower=50,noclip=false,flyConn=nil,noclipConn=nil}

-- UI simples
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,200)
frame.Position = UDim2.new(0.5,-150,0.5,-100)
frame.BackgroundColor3 = Color3.fromRGB(20,20,40)

local function createButton(text,callback)
    local b = Instance.new("TextButton",frame)
    b.Size = UDim2.new(0.9,0,0,30)
    b.Position = UDim2.new(0.05,0,0,#frame:GetChildren()*35)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(60,60,120)
    b.MouseButton1Click:Connect(callback)
end

-- Fly
local keys = {}
UserInputService.InputBegan:Connect(function(i,gp) if gp then return end if i.UserInputType==Enum.UserInputType.Keyboard then keys[i.KeyCode]=true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Keyboard then keys[i.KeyCode]=false end end)

local function startFly()
    if state.fly then return end
    state.fly=true
    humanoid.PlatformStand=true
    local bv=Instance.new("BodyVelocity",hrp)
    bv.MaxForce=Vector3.new(1e5,1e5,1e5)
    local bg=Instance.new("BodyGyro",hrp)
    bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
    state.flyConn=RunService.RenderStepped:Connect(function()
        local cam=workspace.CurrentCamera
        local move=Vector3.new(0,0,0)
        if keys[Enum.KeyCode.W] then move=move+cam.CFrame.LookVector end
        if keys[Enum.KeyCode.S] then move=move-cam.CFrame.LookVector end
        if keys[Enum.KeyCode.D] then move=move+cam.CFrame.RightVector end
        if keys[Enum.KeyCode.A] then move=move-cam.CFrame.RightVector end
        local vertical=0
        if keys[Enum.KeyCode.Space] then vertical=vertical+1 end
        if keys[Enum.KeyCode.LeftShift] then vertical=vertical-1 end
        bv.Velocity=(move.Magnitude>0 and move.Unit or move)*state.flySpeed+Vector3.new(0,vertical*state.flySpeed,0)
        bg.CFrame=cam.CFrame
    end)
end
local function stopFly()
    state.fly=false
    humanoid.PlatformStand=false
    if state.flyConn then state.flyConn:Disconnect() end
    for _,obj in pairs(hrp:GetChildren()) do if obj:IsA("BodyMover") or obj:IsA("BodyGyro") then obj:Destroy() end end
end

-- Noclip
local function startNoclip()
    if state.noclip then return end
    state.noclip=true
    state.noclipConn=RunService.Stepped:Connect(function()
        for _,p in pairs(character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end)
end
local function stopNoclip()
    state.noclip=false
    if state.noclipConn then state.noclipConn:Disconnect() end
    for _,p in pairs(character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
end

-- Botões
createButton("Toggle Fly",function() if state.fly then stopFly() else startFly() end end)
createButton("Increase FlySpeed",function() state.flySpeed=state.flySpeed+10 end)
createButton("Decrease FlySpeed",function() state.flySpeed=math.max(10,state.flySpeed-10) end)
createButton("Set WalkSpeed 50",function() humanoid.WalkSpeed=50 end)
createButton("Set JumpPower 100",function() humanoid.JumpPower=100 end)
createButton("Toggle Noclip",function() if state.noclip then stopNoclip() else startNoclip() end end)
