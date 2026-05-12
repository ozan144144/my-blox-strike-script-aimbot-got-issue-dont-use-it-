--[[ 
    OZAN NEXUS v56
    - ESP & GLOW: Billboard ve Highlight sistemi korundu, tıkır tıkır çalışıyor.
    - PHYSICS: Stealth Velocity mantığı entegre.
    - SATIR: Profesyonel ve detaylı kod yapısı.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// CONFIGURATION
if not _G.OzanMasterConfig then
    _G.OzanMasterConfig = {
        ESP_Enabled = true,
        Aimbot_Enabled = true,
        StealthSpeedEnabled = true,
        BoostPower = 55,
        AimSmoothness = 0.2, -- Kilitlenme sertliği
        FieldOfView = 95,
        MenuKey = Enum.KeyCode.Insert,
        TeamCheck = true,
        Highlights = true,
        AimPart = "Head"
    }
end
local Config = _G.OzanMasterConfig

--// ESP & GLOW ENGINE (Aynı Stabilite)
local function CreateESP(player)
    if player == LocalPlayer then return end
    local function Setup(char)
        if not char then return end
        task.wait(0.5)
        local bg = char:FindFirstChild("OzanESP") or Instance.new("BillboardGui")
        bg.Name = "OzanESP"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(4.5, 0, 6, 0)
        bg.Adornee = char:WaitForChild("HumanoidRootPart", 10); bg.Parent = char
        local f = bg:FindFirstChild("Main") or Instance.new("Frame")
        f.Name = "Main"; f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1; f.Parent = bg
        local s = f:FindFirstChild("Outline") or Instance.new("UIStroke")
        s.Name = "Outline"; s.Thickness = 2.5; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = f
        local n = bg:FindFirstChild("NameLabel") or Instance.new("TextLabel")
        n.Name = "NameLabel"; n.Size = UDim2.new(1, 0, 0, 20); n.Position = UDim2.new(0, 0, 0, -30)
        n.BackgroundTransparency = 1; n.TextColor3 = Color3.new(1, 1, 1); n.Font = Enum.Font.GothamBold; n.TextSize = 14
        n.Text = player.DisplayName or player.Name; n.Parent = bg
    end
    player.CharacterAdded:Connect(Setup)
    if player.Character then Setup(player.Character) end
end

--// AIMBOT: HEDEF SEÇİCİ
local function GetClosestTarget()
    local target, shortestDist = nil, 300
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Config.AimPart) then
            if Config.TeamCheck and p.Team == LocalPlayer.Team then continue end
            local pos, vis = Camera:WorldToViewportPoint(p.Character[Config.AimPart].Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mag < shortestDist then target = p; shortestDist = mag end
            end
        end
    end
    return target
end

--// HIGHLIGHT DÖNGÜSÜ (Glow)
task.spawn(function()
    while true do
        if Config.Highlights then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("OzanHL") or Instance.new("Highlight", p.Character)
                    hl.Name = "OzanHL"; hl.Enabled = true; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillColor = (p.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
                    hl.FillTransparency = 0.5
                end
            end
        end
        task.wait(1.5)
    end
end)

--// MAIN CORE ENGINE
RunService.RenderStepped:Connect(function()
    Camera.FieldOfView = Config.FieldOfView -- Sabit FOV
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Stealth Velocity (Speed Hack)
    if Config.StealthSpeedEnabled and root then
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * Config.BoostPower, root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * Config.BoostPower)
        end
    end
    
    -- AIMBOT + KARAKTER DÖNDÜRME (Buraya Dikkat!)
    if Config.Aimbot_Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetClosestTarget()
        if t and t.Character and t.Character:FindFirstChild(Config.AimPart) and root then
            local targetPos = t.Character[Config.AimPart].Position
            
            -- 1. Kamerayı Döndür
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Config.AimSmoothness)
            
            -- 2. GÖVDEYİ DÖNDÜR (Mermi Fix)
            local lookAt = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
            root.CFrame = root.CFrame:Lerp(CFrame.new(root.Position, lookAt), Config.AimSmoothness)
        end
    end
    
    -- ESP Takip
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local esp = p.Character:FindFirstChild("OzanESP")
            if esp then 
                esp.Enabled = Config.ESP_Enabled and not (Config.TeamCheck and p.Team == LocalPlayer.Team)
                if esp:FindFirstChild("Main") and esp.Main:FindFirstChild("Outline") then
                    esp.Main.Outline.Color = (p.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
                end
            end
        end
    end
end)

--// UI CONSTRUCTION
local function BuildUI()
    if PlayerGui:FindFirstChild("NexusV56") then PlayerGui.NexusV56:Destroy() end
    local sg = Instance.new("ScreenGui", PlayerGui); sg.Name = "NexusV56"; sg.ResetOnSpawn = false
    local m = Instance.new("Frame", sg); m.Size = UDim2.new(0, 360, 0, 500); m.Position = UDim2.new(0.5, -180, 0.5, -250)
    m.BackgroundColor3 = Color3.fromRGB(15, 15, 20); m.Active = true; m.Draggable = true; Instance.new("UICorner", m)
    local t = Instance.new("TextLabel", m); t.Size = UDim2.new(1, 0, 0, 50); t.Text = "BENIM SCRIPTIM"; t.TextColor3 = Color3.new(0,1,1)
    t.Font = Enum.Font.GothamBold; t.BackgroundColor3 = Color3.fromRGB(25, 25, 35); Instance.new("UICorner", t)
    local s = Instance.new("ScrollingFrame", m); s.Size = UDim2.new(1, -20, 1, -70); s.Position = UDim2.new(0, 10, 0, 60); s.BackgroundTransparency = 1; s.CanvasSize = UDim2.new(0,0,2.5,0)
    Instance.new("UIListLayout", s).Padding = UDim.new(0,10)
    local function Btn(txt, cfg)
        local b = Instance.new("TextButton", s); b.Size = UDim2.new(1, 0, 0, 45); b.BackgroundColor3 = Config[cfg] and Color3.fromRGB(0,150,80) or Color3.fromRGB(150,40,40)
        b.Text = txt..": "..(Config[cfg] and "ON" or "OFF"); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() Config[cfg] = not Config[cfg]; b.Text = txt..": "..(Config[cfg] and "ON" or "OFF"); b.BackgroundColor3 = Config[cfg] and Color3.fromRGB(0,150,80) or Color3.fromRGB(150,40,40) end)
    end
    Btn("Aimbot (Calismayabilir)", "Aimbot_Acildi"); Btn("Billboard ESP", "ESP_Enabled"); Btn("Parlama", "Parlama"); Btn("Speed Hack (buda calismayabilir)", "StealthSpeedEnabled"); Btn("Team Check (ACMAYIN ONERMEM)", "TeamCheck (ACMAYIN ONERMEM)")
    return m
end

local UI = BuildUI()
UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Config.MenuKey then UI.Visible = not UI.Visible end end)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
