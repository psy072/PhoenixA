-- Phoenix A hub (versão funcional)
-- Coloque este LocalScript em StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local state = {fly=false,flySpeed=60,jumpPower=50,noclip=false,flyConn=nil,noclipConn=nil}

-- Helpers UI
local function createButton(parent,text,callback)
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(0.9,0,0,40)
    btn.Text=text
    btn.TextScaled=true
    btn.BackgroundColor3=Color3.fromRGB(36,66,120)
    btn.TextColor3=Color3.fromRGB(255,255,255)
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

local function createSlider(parent,labelText,defaultValue,minVal,maxVal,callback)
    local container=Instance.new("Frame",parent)
    container.Size=UDim2.new(0.95,0,0,60)
    local label=Instance.new("TextLabel",container)
    label.Size=UDim2.new(0.4,0,0,20)
    label.Text=labelText
    label.TextColor3=Color3.fromRGB(180,0,180)
    label.TextScaled=true
    local bar=Instance.new("Frame",container)
    bar.Size=UDim2.new(0.9,0,0,12)
    bar.Position=UDim2.new(0.05,0,0,30)
    bar.BackgroundColor3=Color3.fromRGB(40,70,120)
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,6)
    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new((defaultValue-minVal)/(maxVal-minVal),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(160,80,220)
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0,6)
    local knob=Instance.new("ImageButton",bar)
    knob.Size=UDim2.new(0,16,0,16)
    knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(fill.Size.X.Scale,0,0.5,0)
    knob.Image="rbxassetid://3926305904"
    knob.BackgroundTransparency=1
    local function setValueFromX(x)
        local absX=math.clamp(x-bar.AbsolutePosition.X,0,bar.AbsoluteSize.X)
        local t=absX/bar.AbsoluteSize.X
        local value=math.floor(minVal+(maxVal-minVal)*t+0.5)
        fill.Size=UDim2.new(t,0,1,0)
        knob.Position=UDim2.new(t,0,0.5,0)
        if callback then callback(value) end
    end
    knob.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            UserInputService.InputChanged:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
                    setValueFromX(i.Position.X)
                end
            end)
        end
    end)
    if callback then callback(defaultValue) end
end

-- Fly
local keys={}
UserInputService.InputBegan:Connect(function(input,gp) if gp then return end if input.UserInputType==Enum.UserInputType.Keyboard then keys[input.KeyCode]=true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.Keyboard then keys[input.KeyCode]=false end end)

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
        for _,part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide=false end
        end
    end)
end
local function stopNoclip()
    state.noclip=false
    if state.noclipConn then state.noclipConn:Disconnect() end
    for _,part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide=true end
    end
end

-- UI Movimento
createButton(frame,"Toggle Fly",function() if state.fly then stopFly() else startFly() end end)
createSlider(frame,"Fly Speed",60,10,300,function(v) state.flySpeed=v end)
createSlider(frame,"Walk Speed",16,8,200,function(v) humanoid.WalkSpeed=v end)
createSlider(frame,"Jump Power",50,10,300,function(v) humanoid.JumpPower=v end)
createButton(frame,"Toggle Noclip",function() if state.noclip then stopNoclip() else startNoclip() end end)
