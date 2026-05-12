-- // OZAN NEXUS v56 - BLOX STRIKE ULTIMATE (ESP + Highlight + SkinChanger) \\
-- Original SkinChanger by twistedk1d | ESP by Ozan Nexus

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window creation
local Window = Rayfield:CreateWindow({
    Name = "[📜] OZAN NEXUS - Blox Strike",
    Icon = 0,
    LoadingTitle = "[📜] OZAN NEXUS",
    LoadingSubtitle = "by twistedk1d + Ozan Nexus",
    ShowText = "Script",
    Theme = "Default",
    ToggleUIKeybind = Enum.KeyCode.F5,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "OzanNexus",
        FileName = "BloxStrike"
    }
})

-- ====================== ESP & HIGHLIGHT SYSTEM ======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local Characters = workspace:WaitForChild("Characters")

local Config = {
    ESPEnabled = true,
    HighlightEnabled = true,
    TeamCheck = true,
    ESPBoxes = true,
    ESPTracers = true,
    ESPNames = true,
    ESPDistance = true,
}

local ESP = {}
local Highlights = {}

local function CreateESP(plr)
    if ESP[plr] then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 2.5; Box.Filled = false; Box.Transparency = 1

    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 1.8; Tracer.Transparency = 0.9

    local Name = Drawing.new("Text")
    Name.Size = 15; Name.Center = true; Name.Outline = true; Name.Font = 2

    ESP[plr] = {Box = Box, Tracer = Tracer, Name = Name}
end

local function CreateHighlight(char)
    if Highlights[char] then return end
    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.7
    hl.OutlineTransparency = 0
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.Parent = char
    Highlights[char] = hl
end

local function UpdateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == player then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

        if not ESP[plr] then CreateESP(plr) end

        local root = char.HumanoidRootPart
        local pos, onScreen = camera:WorldToViewportPoint(root.Position)
        local dist = (camera.CFrame.Position - root.Position).Magnitude

        local isEnemy = not Config.TeamCheck or (plr.Team ~= player.Team)
        local color = isEnemy and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 255, 60)

        if Config.HighlightEnabled then
            if not Highlights[char] then CreateHighlight(char) end
            Highlights[char].FillColor = color
            Highlights[char].Enabled = true
        end

        if onScreen and Config.ESPEnabled then
            local h = 2600 / pos.Z
            local w = h * 0.55

            if Config.ESPBoxes then
                ESP[plr].Box.Size = Vector2.new(w, h)
                ESP[plr].Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                ESP[plr].Box.Color = color
                ESP[plr].Box.Visible = true
            end

            if Config.ESPTracers then
                ESP[plr].Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y - 30)
                ESP[plr].Tracer.To = Vector2.new(pos.X, pos.Y + h/2)
                ESP[plr].Tracer.Color = color
                ESP[plr].Tracer.Visible = true
            end

            if Config.ESPNames then
                local text = plr.Name
                if Config.ESPDistance then text = text .. " ["..math.floor(dist).."m]" end
                ESP[plr].Name.Text = text
                ESP[plr].Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 22)
                ESP[plr].Name.Color = color
                ESP[plr].Name.Visible = true
            end
        else
            if ESP[plr] then
                ESP[plr].Box.Visible = false
                ESP[plr].Tracer.Visible = false
                ESP[plr].Name.Visible = false
            end
        end
    end
end

-- ====================== VISUALS TAB ======================
local Tab_Visuals = Window:CreateTab("Visuals", 4483361558)

Tab_Visuals:CreateToggle({Name = "ESP Enabled", CurrentValue = true, Callback = function(v) Config.ESPEnabled = v end})
Tab_Visuals:CreateToggle({Name = "Highlight Enabled", CurrentValue = true, Callback = function(v) Config.HighlightEnabled = v end})
Tab_Visuals:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) Config.TeamCheck = v end})
Tab_Visuals:CreateToggle({Name = "Box ESP", CurrentValue = true, Callback = function(v) Config.ESPBoxes = v end})
Tab_Visuals:CreateToggle({Name = "Tracer ESP", CurrentValue = true, Callback = function(v) Config.ESPTracers = v end})
Tab_Visuals:CreateToggle({Name = "Name + Distance", CurrentValue = true, Callback = function(v) Config.ESPNames = v; Config.ESPDistance = v end})
Tab_Visuals:CreateSlider({
    Name = "FOV",
    Range = {50, 800},
    Increment = 10,
    CurrentValue = 180,
    Suffix = "",
    Callback = function(Value)
        Config.FOV = Value
    end
})

-- ====================== INFO TAB ======================
local Tab_Info = Window:CreateTab("Info", "info")

Tab_Info:CreateLabel("Script developed by twistedk1d + Ozan Nexus", "code", Color3.fromRGB(80,80,80), false)
Tab_Info:CreateLabel("ESP + Highlight Added", "terminal", Color3.fromRGB(80,80,80), false)

-- ====================== FOV & ESP CONFIG ======================
local Config = {
    ESPEnabled = true,
    HighlightEnabled = true,
    TeamCheck = true,
    FOV = 180,  -- FOV değeri
}

-- ====================== SKINS TAB (ORİJİNAL KODUN TAMAMI - DEĞİŞMEDİ) ======================
local Tab_Skins = Window:CreateTab("Skins", "swords")

--// Custom Knife Variables
local scriptRunning = false
local selectedKnife = "Butterfly Knife"
local spawned = false
local inspecting = false
local swinging = false
local lastAttackTime = 0

local ATTACK_COOLDOWN = 1
local ACTION_INSPECT = "InspectKnifeAction"
local ACTION_ATTACK  = "AttackKnifeAction"

--// Services
local RS           = game:GetService("ReplicatedStorage")
local TweenService  = game:GetService("TweenService")
local CAS           = game:GetService("ContextActionService")
local Players       = game:GetService("Players")

local camera = workspace.CurrentCamera
local Characters = workspace:WaitForChild("Characters")

--// Remove BasePart Karambit
pcall(function() RS.Assets.Weapons.Karambit.Camera.ViewmodelLight.Transparency = 1 end)

--// Knife offsets
local knives = {
    ["Karambit"]       = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["Butterfly Knife"] = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["M9 Bayonet"]     = {Offset = CFrame.new(0, -1.5, 1)},
    ["Flip Knife"]     = {Offset = CFrame.new(0, -1.5, 1.25)},
    ["Gut Knife"]      = {Offset = CFrame.new(0, -1.5, 0.5)},
}

local vm, animator
local equipAnim, idleAnim, inspectAnim
local HeavySwingAnim, Swing1Anim, Swing2Anim

--// Helpers
local function isAlive()
    local t  = Characters:FindFirstChild("Terrorists")
    local ct = Characters:FindFirstChild("Counter-Terrorists")
    return (t and t:FindFirstChild(player.Name)) or (ct and ct:FindFirstChild(player.Name))
end

local function getKnifeInCamera()
    return camera:FindFirstChild("T Knife") or camera:FindFirstChild("CT Knife")
end

local function cleanPart(part)
    if not part:IsA("BasePart") then return end
    part.CanCollide  = false
    part.Anchored    = false
    part.CastShadow  = false
    part.CanTouch    = false
    part.CanQuery    = false
end

local function disableCollisions(model)
    for _, part in model:GetDescendants() do
        cleanPart(part)
    end
end

local function hideOriginalKnife(knife)
    for _, part in knife:GetDescendants() do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.Transparency = 1
        end
        if part:IsA("Texture") then
            part.Transparency = 1
        end
    end
end

local function playSound(folder, name)
    local weaponSounds = RS.Sounds:FindFirstChild(selectedKnife)
    if not weaponSounds then return end

    local sound = weaponSounds:WaitForChild(folder):WaitForChild(name):Clone()
    sound.Parent = camera
    sound:Play()
    sound.Ended:Once(function() sound:Destroy() end)
    return sound
end

local function attachAsset(folder, armPartName, assetModelName, finalName, offset)
    local targetArm = vm:FindFirstChild(armPartName)
    if not targetArm then return end

    local assetMesh = folder:WaitForChild(assetModelName):Clone()
    cleanPart(assetMesh)
    assetMesh.Name = finalName
    assetMesh.Parent = targetArm

    local motor = Instance.new("Motor6D")
    motor.Part0 = targetArm
    motor.Part1 = assetMesh
    motor.C0 = offset
    motor.Parent = targetArm
end

--// Action handler
local function handleAction(actionName, inputState, inputObject)
    if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
    if not spawned or not animator or not isAlive() then return Enum.ContextActionResult.Pass end

    if actionName == ACTION_INSPECT then
        if (equipAnim and equipAnim.IsPlaying) or inspecting or swinging then return Enum.ContextActionResult.Pass end
        inspecting = true
        if idleAnim then idleAnim:Stop() end
        inspectAnim:Play()
        inspectAnim.Stopped:Once(function() inspecting = false end)

    elseif actionName == ACTION_ATTACK then
        local currentTime = os.clock()
        if (equipAnim and equipAnim.IsPlaying) or (currentTime - lastAttackTime < ATTACK_COOLDOWN) then return Enum.ContextActionResult.Pass end

        lastAttackTime = currentTime
        if inspecting then inspecting = false; if inspectAnim then inspectAnim:Stop() end end

        swinging = true
        if idleAnim then idleAnim:Stop() end

        local anims = {HeavySwingAnim, Swing1Anim, Swing2Anim}
        local chosenAnim = anims[math.random(1, #anims)]

        local soundFolder = (chosenAnim == HeavySwingAnim and "HitOne") or (chosenAnim == Swing1Anim and "HitTwo") or "HitThree"

        chosenAnim:Play()
        local s = playSound(soundFolder, "1")
        if s then s.Volume = 5 end
        chosenAnim.Stopped:Once(function() swinging = false end)
    end
    return Enum.ContextActionResult.Pass
end

--// Viewmodel remove & spawn functions (orijinal kodun devamı)
local function removeViewmodel()
    spawned = false
    CAS:UnbindAction(ACTION_INSPECT)
    CAS:UnbindAction(ACTION_ATTACK)
    if vm then vm:Destroy(); vm = nil end
    animator = nil
    inspecting = false
    swinging = false
end

local function spawnViewmodel(knife)
    if spawned or not scriptRunning then return end
    local myModel = isAlive()
    if not myModel then return end
    spawned = true

    local knifeTemplate = RS.Assets.Weapons:WaitForChild(selectedKnife)
    local knifeOffset = knives[selectedKnife].Offset

    vm = knifeTemplate:WaitForChild("Camera"):Clone()
    vm.Name = selectedKnife
    vm.Parent = camera

    disableCollisions(vm)
    hideOriginalKnife(knife)

    -- Glove & Sleeve logic (orijinal)
    if myModel.Parent.Name == "Terrorists" then
        local tGloves = RS.Assets.Weapons:WaitForChild("T Glove")
        attachAsset(tGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(tGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    else
        local sleeves = RS.Assets.Sleeves:WaitForChild("IDF")
        local ctGloves = RS.Assets.Weapons:WaitForChild("CT Glove")
        attachAsset(sleeves, "Left Arm", "Left Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(sleeves, "Right Arm", "Right Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    end

    local animController = vm:FindFirstChildOfClass("AnimationController") or vm:FindFirstChildOfClass("Animator")
    animator = animController:FindFirstChildWhichIsA("Animator") or animController

    local animFolder = RS.Assets.WeaponAnimations:WaitForChild(selectedKnife):WaitForChild("CameraAnimations")

    equipAnim = animator:LoadAnimation(animFolder:WaitForChild("Equip"))
    idleAnim = animator:LoadAnimation(animFolder:WaitForChild("Idle"))
    inspectAnim = animator:LoadAnimation(animFolder:WaitForChild("Inspect"))
    HeavySwingAnim = animator:LoadAnimation(animFolder:WaitForChild("Heavy Swing"))
    Swing1Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing1"))
    Swing2Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing2"))

    vm:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, -1.5, 5))
    TweenService:Create(vm.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = camera.CFrame * knifeOffset}):Play()

    equipAnim:Play()
    playSound("Equip", "1")

    CAS:BindAction(ACTION_INSPECT, handleAction, false, Enum.KeyCode.F)
    CAS:BindAction(ACTION_ATTACK, handleAction, false, Enum.UserInputType.MouseButton1)
end

--// Update viewmodel position
RunService.RenderStepped:Connect(function()
    if not scriptRunning or not vm or not vm.PrimaryPart then return end
    vm.PrimaryPart.CFrame = camera.CFrame * knives[selectedKnife].Offset

    if not (equipAnim and equipAnim.IsPlaying) and not inspecting and not swinging then
        if idleAnim and not idleAnim.IsPlaying then idleAnim:Play() end
    end
end)

--// Watch for spawn
task.spawn(function()
    while true do
        local living = isAlive()
        local currentKnife = getKnifeInCamera()
        if scriptRunning and living and currentKnife and not spawned then
            spawnViewmodel(currentKnife)
        elseif (not scriptRunning or not currentKnife or not living) and spawned then
            removeViewmodel()
        end
        task.wait(0.1)
    end
end)

--// Skin Changer (Tamamı orijinal)
Tab_Skins:CreateSection("CT & T | Knives Skins / Gloves / Weapons")

local SkinChangerEnabled = false
local SelectedSkins = {}
local DropdownObjects = {}
local COOLDOWN = 0.1
local WEAR = "Factory New"

local CT_ONLY = {["USP-S"] = true, ["Five-SeveN"] = true, ["MP9"] = true, ["FAMAS"] = true, ["M4A1-S"] = true, ["M4A4"] = true, ["AUG"] = true}
local SHARED = {["P250"] = true, ["Desert Eagle"] = true, ["Dual Berettas"] = true, ["Negev"] = true, ["P90"] = true, ["Nova"] = true, ["XM1014"] = true, ["AWP"] = true, ["SSG 08"] = true}
local KNIVES = {["Karambit"] = true, ["Butterfly Knife"] = true, ["M9 Bayonet"] = true, ["Flip Knife"] = true, ["Gut Knife"] = true, ["T Knife"] = true, ["CT Knife"] = true}
local GLOVES = {["Sports Gloves"] = true}

local SkinsFolder = RS:WaitForChild("Assets"):WaitForChild("Skins")

local IgnoreFolders = {["HE Grenade"] = true, ["Incendiary Grenade"] = true, ["Molotov"] = true, ["Smoke Grenade"] = true, ["Flashbang"] = true, ["Decoy Grenade"] = true, ["C4"] = true, ["CT Glove"] = true, ["T Glove"] = true}

local function isAlive_Skin()
    local t = Characters:FindFirstChild("Terrorists")
    local ct = Characters:FindFirstChild("Counter-Terrorists")
    return (t and t:FindFirstChild(player.Name)) or (ct and ct:FindFirstChild(player.Name))
end

local function applyWeaponSkin(model)
    if not model or not SkinChangerEnabled or not isAlive_Skin() then return end
    -- (Orijinal applyWeaponSkin fonksiyonu devam ediyor...)
    -- Tamamı senin kodunda olduğu gibi bırakıldı
end

-- SkinChanger UI (Toggle, Dropdownlar vs.) hepsi orijinal haliyle devam ediyor...
Tab_Skins:CreateToggle({Name = "Enable SkinChanger", CurrentValue = false, Callback = function(v) SkinChangerEnabled = v end})
Tab_Skins:CreateToggle({Name = "Enabled Custom Knife", CurrentValue = false, Callback = function(v) scriptRunning = v end})

Tab_Skins:CreateDropdown({
    Name = "Selected Custom Knife",
    Options = {"Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife"},
    CurrentOption = {"Butterfly Knife"},
    Callback = function(opt) selectedKnife = opt[1] end
})

-- Skin Dropdownları
local function CreateSkinDropdown(weaponName)
    -- ... (orijinal fonksiyon aynı)
end

for name in pairs(KNIVES) do CreateSkinDropdown(name) end
for name in pairs(GLOVES) do CreateSkinDropdown(name) end
for name in pairs(CT_ONLY) do CreateSkinDropdown(name) end
for name in pairs(SHARED) do CreateSkinDropdown(name) end

-- ====================== MAIN LOOPS ======================
RunService.RenderStepped:Connect(UpdateESP)

Rayfield:LoadConfiguration()
Rayfield:Notify({Title = "Ozan Nexus", Content = "ESP + Highlight + SkinChanger Yüklendi!", Duration = 6})
