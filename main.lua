-- dumped by AdukyyMor v2.0.1
-- tag: loadstring
-- bytes: 145119
-- extra: 
--========================================================--
--              IMP SG
--       FLUENT STYLE UI + FULL ENGINE (INTEGRATED)
--========================================================--

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--========================================================--
-- CONFIGURACIÓN
--========================================================--

local KEY_CORRECTA = "angel0011"
local DISCORD_LINK = "https://discord.gg/97CdEyDhm"
local CFG_FILE = "IMPERIO SG_settings.txt"
local HasEnteredPanel = false

--========================================================--
-- AUDIO DE TOGGLES
--========================================================--

local function playToggleSound()
    task.spawn(function()
        local url = "https://files.catbox.moe/so5gi0.mp3"
        local fileName = "chinohub_toggle.mp3"

        if isfile and writefile and not isfile(fileName) then
            pcall(function()
                local audioData = game:HttpGet(url)
                writefile(fileName, audioData)
            end)
        end

        local sound = Instance.new("Sound")
        sound.Parent = workspace.CurrentCamera
        sound.SoundId = (getcustomasset and isfile and isfile(fileName) and getcustomasset(fileName)) or url
        sound.Volume = 1.1
        sound.TimePosition = 0.28
        sound:Play()

        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

--========================================================--
-- LIMPIEZA PREVIA
--========================================================--

pcall(function()
    if Lighting:FindFirstChild("CHINO_BlurEffect") then Lighting.CHINO_BlurEffect:Destroy() end
    if Lighting:FindFirstChild("InfiernoGlassBlur") then Lighting.InfiernoGlassBlur:Destroy() end
    if CoreGui:FindFirstChild("CHINOHUB_ModernUI") then CoreGui.CHINOHUB_ModernUI:Destroy() end
    if CoreGui:FindFirstChild("FloatingSnapGui") then CoreGui.FloatingSnapGui:Destroy() end
    if CoreGui:FindFirstChild("AstralProjectionGui") then CoreGui.AstralProjectionGui:Destroy() end
    if PlayerGui:FindFirstChild("CHINOHUB_ModernUI") then PlayerGui.CHINOHUB_ModernUI:Destroy() end
    if workspace:FindFirstChild("AK_SurfaceCamPart") then workspace.AK_SurfaceCamPart:Destroy() end
end)

--========================================================--
-- BLUR
--========================================================--

local Blur = Instance.new("BlurEffect")
Blur.Name = "CHINO_BlurEffect"
Blur.Size = 22
Blur.Parent = Lighting

--========================================================--
-- SCREEN GUI
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IMPERIOSG_ModernUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = gethui and gethui() or CoreGui
end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

--========================================================--
-- ELEMENTOS VISUALES MIGRADOS
--========================================================--

local SettingsVisual = {
    Box = false,
    Lines = false,
    FOV = false,
    TargetLine = false,

    FOVRadius = 150,
    FOVMin = 145,
    FOVMax = 155,
    FOVSpeed = 2,

    LineOriginY = 1,
    LineTargetOffset = 0,

    TargetLineThickness = 1,
    TargetMarkerSize = 7
}

local CurrentTarget = nil
local FOVTime = 0

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(SettingsVisual.FOVRadius * 2, SettingsVisual.FOVRadius * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.ZIndex = 50
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.15
FOVStroke.Color = Color3.fromRGB(135, 150, 255)
FOVStroke.Parent = FOVCircle

local TargetLine = Instance.new("Frame")
TargetLine.Name = "TargetLine"
TargetLine.AnchorPoint = Vector2.new(0.5, 0.5)
TargetLine.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
TargetLine.BackgroundTransparency = 0.05
TargetLine.BorderSizePixel = 0
TargetLine.Size = UDim2.fromOffset(0, SettingsVisual.TargetLineThickness)
TargetLine.Visible = false
TargetLine.ZIndex = 20
TargetLine.Parent = ScreenGui

local TargetMarker = Instance.new("Frame")
TargetMarker.Name = "TargetMarker"
TargetMarker.Size = UDim2.fromOffset(SettingsVisual.TargetMarkerSize, SettingsVisual.TargetMarkerSize)
TargetMarker.AnchorPoint = Vector2.new(0.5, 0.5)
TargetMarker.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
TargetMarker.BorderSizePixel = 0
TargetMarker.Visible = false
TargetMarker.ZIndex = 30
TargetMarker.Parent = ScreenGui

local MarkerCorner = Instance.new("UICorner")
MarkerCorner.CornerRadius = UDim.new(1, 0)
MarkerCorner.Parent = TargetMarker

local MarkerStroke = Instance.new("UIStroke")
MarkerStroke.Thickness = 1
MarkerStroke.Color = Color3.fromRGB(255, 255, 255)
MarkerStroke.Parent = TargetMarker

local VisualPlayerObjects = {}

local function CreateVisualPlayerObjects(player)
    if player == LocalPlayer then return end
    local data = {}

    local box = Instance.new("SelectionBox")
    box.Name = "ESPBox"
    box.LineThickness = 0.015
    box.Color3 = Color3.fromRGB(135, 150, 255)
    box.SurfaceTransparency = 1
    box.Visible = false
    box.Parent = ScreenGui
    data.Box = box

    local line = Instance.new("Frame")
    line.Name = "ESPLine"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(135, 150, 255)
    line.BackgroundTransparency = 0.1
    line.BorderSizePixel = 0
    line.Size = UDim2.fromOffset(0, 1)
    line.Visible = false
    line.ZIndex = 10
    line.Parent = ScreenGui
    data.Line = line

    VisualPlayerObjects[player] = data
end

local function RemoveVisualPlayerObjects(player)
    if CurrentTarget == player then
        CurrentTarget = nil
        TargetLine.Visible = false
        TargetMarker.Visible = false
    end

    local data = VisualPlayerObjects[player]
    if not data then return end

    for _, object in pairs(data) do
        if object then object:Destroy() end
    end
    VisualPlayerObjects[player] = nil
end

for _, pl in ipairs(Players:GetPlayers()) do
    CreateVisualPlayerObjects(pl)
end
Players.PlayerAdded:Connect(CreateVisualPlayerObjects)
Players.PlayerRemoving:Connect(RemoveVisualPlayerObjects)

local function HasLineOfSight(targetCharacter, targetHead)
    local myCharacter = LocalPlayer.Character
    if not myCharacter then return false end

    local myHead = myCharacter:FindFirstChild("Head")
    if not myHead then return false end

    local origin = myHead.Position
    local direction = targetHead.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {myCharacter, targetCharacter}
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)
    return result == nil
end

local function GetBestVisualTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestPlayer = nil
    local bestDistance = SettingsVisual.FOVRadius

    for player in pairs(VisualPlayerObjects) do
        local character = player.Character
        if character then
            local head = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

            if head then
                local position, visible = Camera:WorldToViewportPoint(head.Position)
                if visible and position.Z > 0 then
                    local screenPosition = Vector2.new(position.X, position.Y)
                    local distance = (screenPosition - center).Magnitude

                    if distance <= SettingsVisual.FOVRadius and distance < bestDistance then
                        bestDistance = distance
                        bestPlayer = player
                    end
                end
            end
        end
    end
    return bestPlayer
end

local function UpdateTargetLine()
    if not SettingsVisual.TargetLine or not CurrentTarget then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local myCharacter = LocalPlayer.Character
    local targetCharacter = CurrentTarget.Character
    if not myCharacter or not targetCharacter then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local myHead = myCharacter:FindFirstChild("Head")
    local targetHead = targetCharacter:FindFirstChild("Head") or targetCharacter:FindFirstChild("UpperTorso") or targetCharacter:FindFirstChild("Torso")
    if not myHead or not targetHead then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local myPosition, myVisible = Camera:WorldToViewportPoint(myHead.Position)
    local targetPosition, targetVisible = Camera:WorldToViewportPoint(targetHead.Position)

    if not myVisible or not targetVisible or myPosition.Z <= 0 or targetPosition.Z <= 0 then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local from = Vector2.new(myPosition.X, myPosition.Y)
    local target = Vector2.new(targetPosition.X, targetPosition.Y)
    local difference = target - from
    local length = difference.Magnitude

    if length <= 0 then return end

    local visible = HasLineOfSight(targetCharacter, targetHead)
    if visible then
        TargetLine.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        TargetMarker.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    else
        TargetLine.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
        TargetMarker.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
    end

    TargetLine.Position = UDim2.fromOffset((from.X + target.X) / 2, (from.Y + target.Y) / 2)
    TargetLine.Size = UDim2.fromOffset(length, SettingsVisual.TargetLineThickness)
    TargetLine.Rotation = math.deg(math.atan2(difference.Y, difference.X))
    TargetLine.Visible = true

    TargetMarker.Position = UDim2.fromOffset(target.X, target.Y)
    TargetMarker.Visible = true
end

--========================================================--
-- FONDO
--========================================================--

local Background = Instance.new("Frame")
Background.Name = "Background"
Background.Size = UDim2.new(1,0,1,0)
Background.Position = UDim2.new(0,0,0,0)
Background.BackgroundColor3 = Color3.fromRGB(12,9,19)
Background.BorderSizePixel = 0
Background.ClipsDescendants = true
Background.Parent = ScreenGui

--========================================================--
-- ORBES AMBIENTALES
--========================================================--

local OrbFolder = Instance.new("Folder")
OrbFolder.Name = "AmbientOrbs"
OrbFolder.Parent = Background

local RegisteredOrbs = {}

local function CreateOrb(position, size, color)
    local holder = Instance.new("Frame")
    holder.Size = size
    holder.Position = position
    holder.AnchorPoint = Vector2.new(.5, .5)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Parent = OrbFolder

    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 100, 1, 100)
    glow.Position = UDim2.new(.5, 0, .5, 0)
    glow.AnchorPoint = Vector2.new(.5, .5)
    glow.BackgroundColor3 = color
    glow.BackgroundTransparency = .84
    glow.BorderSizePixel = 0
    glow.Parent = holder

    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow

    local core = Instance.new("Frame")
    core.Name = "Core"
    core.Size = UDim2.new(.6, 0, .6, 0)
    core.Position = UDim2.new(.5, 0, .5, 0)
    core.AnchorPoint = Vector2.new(.5, .5)
    core.BackgroundColor3 = color
    core.BackgroundTransparency = .78
    core.BorderSizePixel = 0
    core.Parent = holder

    local coreCorner = Instance.new("UICorner")
    coreCorner.CornerRadius = UDim.new(1, 0)
    coreCorner.Parent = core

    table.insert(RegisteredOrbs, {Glow = glow, Core = core})
    return holder
end

local RedOrb = CreateOrb(UDim2.new(.50, 0, .25, 0), UDim2.new(0, 520, 0, 520), Color3.fromRGB(190, 25, 55))
local PurpleOrb = CreateOrb(UDim2.new(.25, 0, .55, 0), UDim2.new(0, 560, 0, 560), Color3.fromRGB(105, 20, 135))
local BlueOrb = CreateOrb(UDim2.new(.75, 0, .78, 0), UDim2.new(0, 650, 0, 650), Color3.fromRGB(65, 105, 205))

task.spawn(function()
    local t = 0
    while ScreenGui.Parent do
        t = t + 0.015
        RedOrb.Position = UDim2.new(0.50 + math.sin(t * 0.45) * 0.14, 0, 0.28 + math.cos(t * 0.35) * 0.12, 0)
        PurpleOrb.Position = UDim2.new(0.28 + math.cos(t * 0.32) * 0.16, 0, 0.58 + math.sin(t * 0.40) * 0.14, 0)
        BlueOrb.Position = UDim2.new(0.72 + math.sin(t * 0.38) * 0.15, 0, 0.74 + math.cos(t * 0.48) * 0.13, 0)
        RunService.RenderStepped:Wait()
    end
end)

--========================================================--
-- INTRO (WELCOME -> IMPERIOSGHUB)
--========================================================--

local Intro = Instance.new("TextLabel")
Intro.Size = UDim2.new(1, 0, 0, 70)
Intro.Position = UDim2.new(.5, 0, .5, 0)
Intro.AnchorPoint = Vector2.new(.5, .5)
Intro.BackgroundTransparency = 1
Intro.Text = "WELCOME"
Intro.TextColor3 = Color3.fromRGB(255, 255, 255)
Intro.TextTransparency = 1
Intro.TextSize = 32
Intro.Font = Enum.Font.GothamMedium
Intro.Parent = Background

task.wait(0.8)
TweenService:Create(Intro, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
task.wait(1.4)
TweenService:Create(Intro, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
task.wait(1.0)

Intro.Text = "ANGXL_SG''
Intro.Font = Enum.Font.GothamMedium
TweenService:Create(Intro, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
task.wait(1.4)
TweenService:Create(Intro, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
task.wait(1.0)
Intro:Destroy()

--========================================================--
-- KEY CARD
--========================================================--

local Card = Instance.new("Frame")
Card.Name = "KeyCard"
Card.Size = UDim2.new(0, 320, 0, 420)
Card.Position = UDim2.new(.5, 0, .5, 30)
Card.AnchorPoint = Vector2.new(.5, .5)
Card.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
Card.BackgroundTransparency = 1
Card.BorderSizePixel = 0
Card.ClipsDescendants = true
Card.Active = true
Card.Draggable = true
Card.Parent = Background

local CardScale = Instance.new("UIScale")
CardScale.Parent = Card

local function UpdateKeyScale()
    local cam = workspace.CurrentCamera
    if cam then
        local v = cam.ViewportSize
        if v.X < 600 then
            CardScale.Scale = math.clamp(v.X / 600, .72, .95)
        else
            CardScale.Scale = 1
        end
    end
end
UpdateKeyScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateKeyScale)
end

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 24)
CardCorner.Parent = Card

local CardStroke = Instance.new("UIStroke")
CardStroke.Color = Color3.fromRGB(255, 255, 255)
CardStroke.Transparency = .88
CardStroke.Thickness = 1.1
CardStroke.Parent = Card

local AvatarBg = Instance.new("Frame")
AvatarBg.Size = UDim2.new(0, 80, 0, 80)
AvatarBg.Position = UDim2.new(.5, 0, 0, 22)
AvatarBg.AnchorPoint = Vector2.new(.5, 0)
AvatarBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AvatarBg.BackgroundTransparency = .92
AvatarBg.BorderSizePixel = 0
AvatarBg.Parent = Card

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarBg

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = Color3.fromRGB(135, 150, 255)
AvatarStroke.Transparency = .45
AvatarStroke.Thickness = 1.5
AvatarStroke.Parent = AvatarBg

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(1, -8, 1, -8)
Avatar.Position = UDim2.new(.5, 0, .5, 0)
Avatar.AnchorPoint = Vector2.new(.5, .5)
Avatar.BackgroundTransparency = 1
Avatar.Parent = AvatarBg

local AvatarImageCorner = Instance.new("UICorner")
AvatarImageCorner.CornerRadius = UDim.new(1, 0)
AvatarImageCorner.Parent = Avatar

task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    end)
    if ok and image then Avatar.Image = image end
end)

local Title = Instance.new("TextLabel")
Title.Text = "IMPERIOSG"
Title.Size = UDim2.new(1, 0, 0, 24)
Title.Position = UDim2.new(0, 0, 0, 114)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamMedium
Title.Parent = Card

local Subtitle = Instance.new("TextLabel")
Subtitle.Text = "Enter your key to continue"
Subtitle.Size = UDim2.new(1, 0, 0, 18)
Subtitle.Position = UDim2.new(0, 0, 0, 138)
Subtitle.BackgroundTransparency = 1
Subtitle.TextColor3 = Color3.fromRGB(160, 165, 185)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = Card

local InputHolder = Instance.new("Frame")
InputHolder.Size = UDim2.new(0, 240, 0, 36)
InputHolder.Position = UDim2.new(.5, 0, 0, 180)
InputHolder.AnchorPoint = Vector2.new(.5, 0)
InputHolder.BackgroundTransparency = 1
InputHolder.Parent = Card

local Lock = Instance.new("ImageLabel")
Lock.Size = UDim2.new(0, 14, 0, 14)
Lock.Position = UDim2.new(0, 3, .5, -7)
Lock.BackgroundTransparency = 1
Lock.Image = "rbxassetid://6031082533"
Lock.ImageColor3 = Color3.fromRGB(255, 255, 255)
Lock.ImageTransparency = .45
Lock.Parent = InputHolder

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -26, 1, -4)
KeyInput.Position = UDim2.new(0, 26, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = "Pega tu Key aquí..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(140, 145, 165)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 13
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = InputHolder

local Underline = Instance.new("Frame")
Underline.Size = UDim2.new(1, 0, 0, 1)
Underline.Position = UDim2.new(0, 0, 1, -1)
Underline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Underline.BackgroundTransparency = .65
Underline.BorderSizePixel = 0
Underline.Parent = InputHolder

local Login = Instance.new("TextButton")
Login.Size = UDim2.new(0, 240, 0, 40)
Login.Position = UDim2.new(.5, 0, 0, 245)
Login.AnchorPoint = Vector2.new(.5, 0)
Login.BackgroundColor3 = Color3.fromRGB(65, 85, 205)
Login.BackgroundTransparency = .32
Login.Text = "LOGIN"
Login.TextColor3 = Color3.fromRGB(255, 255, 255)
Login.TextSize = 12
Login.Font = Enum.Font.GothamMedium
Login.BorderSizePixel = 0
Login.Parent = Card

local LoginCorner = Instance.new("UICorner")
LoginCorner.CornerRadius = UDim.new(0, 14)
LoginCorner.Parent = Login

local LoginGradient = Instance.new("UIGradient")
LoginGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 50, 160)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 110, 230))
}
LoginGradient.Parent = Login

local Discord = Instance.new("TextButton")
Discord.Size = UDim2.new(0, 240, 0, 18)
Discord.Position = UDim2.new(.5, 0, 0, 315)
Discord.AnchorPoint = Vector2.new(.5, 0)
Discord.BackgroundTransparency = 1
Discord.Text = DISCORD_LINK
Discord.TextColor3 = Color3.fromRGB(150, 185, 240)
Discord.TextSize = 11
Discord.Font = Enum.Font.Gotham
Discord.Parent = Card

Discord.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(DISCORD_LINK) end
    Discord.Text = "COPIED!"
    task.wait(1.5)
    if Discord.Parent then Discord.Text = DISCORD_LINK end
end)

local Hint = Instance.new("TextLabel")
Hint.Size = UDim2.new(1, 0, 0, 15)
Hint.Position = UDim2.new(0, 0, 0, 338)
Hint.BackgroundTransparency = 1
Hint.Text = "Click to copy Discord"
Hint.TextColor3 = Color3.fromRGB(130, 135, 155)
Hint.TextSize = 10
Hint.Font = Enum.Font.Gotham
Hint.Parent = Card

local StatusLabel = Instance.new("TextLabel", Card)
StatusLabel.Size = UDim2.new(1, 0, 0, 18)
StatusLabel.Position = UDim2.new(0, 0, 0, 365)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham

TweenService:Create(
    Card,
    TweenInfo.new(.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    {BackgroundTransparency = .75, Position = UDim2.new(.5, 0, .5, 0)}
):Play()

--========================================================--
-- VARIABLES DE ESTADOS Y CONTROL
--========================================================--

local ThemeColor = Color3.fromRGB(135, 150, 255)
local DynamicColorElements = {}
local MainHubFrameRef = nil

local SilentAimEnabled = false
local TargetHitPart = "Neck" -- POR DEFECTO NECK
local CurrentLockedTarget = nil
local WallbangEnabled = false

local P = {}

local InfiniteJumpEnabled = false
local JumpPowerBypassValue = 50
local InfStaminaEnabled = false
local OriginalSprintUpdate = nil
local AutoSprintLoop = nil

local SpeedHackEnabled = false
local SpeedValue = 4
local HeadHidingAntiAim = false

local SkipCratesEnabled = false
local PotatoBoostEnabled = false
local OriginalCameraFOV = Camera.FieldOfView

local AutoSafeDamageEnabled = false
local AutoSafeActive = false
local AutoSafeDepth = 25
local SavedAutoSafeY = nil
local TargetAutoSafeY = nil
local FrozenCameraCFrame = nil

local PlayerESP_Name = false
local PlayerESP_Health = false
local PlayerESP_Dist = false
local PlayerESP_Highlight = false
local WeaponESPEnabled = false
local ItemESPEnabled = false

local GunModsActive = false
local FireRateVal = 1000
local AccuracyVal = 1
local RecoilVal = 0
local ReloadVal = 0.1
local AutomaticVal = true
local DurabilityVal = 999999999

local MeleeAuraEnabled = false
local AutoAttackEnabled = false
local SavedMeleeAttributes = {}

-- TUNING DE VEHÍCULOS
local VehAcceleration = 20
local VehBraking = 40
local VehDeceleration = 10
local VehForwardMaxSpeed = 120
local VehReverseMaxSpeed = 45
local VehSuspension = 2

local VehAcceleration_Enabled = true
local VehBraking_Enabled = true
local VehDeceleration_Enabled = true
local VehForwardMaxSpeed_Enabled = true
local VehReverseMaxSpeed_Enabled = true
local VehSuspension_Enabled = true

local AutoPickupEnabled = false
local AutoPickupRadius = 85
local AutoInteractEnabled = false
local HideNameEnabled = false

local HighlightCache = {}
local PlayerBillboards = {}
local WeaponBillboardCache = {}
local WeaponCacheTokens = {}
local ItemDrawingsCache = {}
local RegisteredWeaponDB = {}
local VelocityHistory = {}

local FloatingSnapActive = false
local FloatingSnapDepth = 15
local FloatingSavedSurfaceY = nil
local FloatingTargetY = nil

local AstralActive = false
local AstralOrb = nil
local AstralConnection = nil
local AstralSpeed = 40
local FrozenCharCF = nil

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
local SendRemote = RemotesFolder and RemotesFolder:FindFirstChild("Send")
local GetRemote = RemotesFolder and RemotesFolder:FindFirstChild("Get")
local DroppedItems = workspace:WaitForChild("DroppedItems", 10)
local ItemsFolder = ReplicatedStorage:WaitForChild("Items", 10)
local GunsFolder = ItemsFolder and ItemsFolder:FindFirstChild("gun")
local MeleeFolder = ItemsFolder and ItemsFolder:FindFirstChild("melee")
local ThrowableFolder = ItemsFolder and ItemsFolder:FindFirstChild("throwable")

local RemoteCounter
pcall(function()
    for _, obj in ipairs(getgc(true)) do
        if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then
            RemoteCounter = obj
            break
        end
    end
end)

local RawCallCount = 0
local function FireServerHook(...)
    if not SendRemote then return end
    local args = {...}
    if RemoteCounter and type(RemoteCounter.event) == "number" then
        RemoteCounter.event = RemoteCounter.event + 1
        pcall(function() SendRemote:FireServer(RemoteCounter.event, unpack(args)) end)
    else
        RawCallCount = RawCallCount + 1
        pcall(function() SendRemote:FireServer(RawCallCount, unpack(args)) end)
    end
end

local function InvokeServerHook(...)
    if not GetRemote then return end
    local args = {...}
    if RemoteCounter and type(RemoteCounter.func) == "number" then
        RemoteCounter.func = RemoteCounter.func + 1
        local ok, res = pcall(function() return GetRemote:InvokeServer(RemoteCounter.func, unpack(args)) end)
        return res
    else
        local ok, res = pcall(function() return GetRemote:InvokeServer(unpack(args)) end)
        return res
    end
end

--========================================================--
-- SISTEMA DE NIEVE
--========================================================--

local ActiveSnowContainers = {}

local function AttachSnowEffect(parentFrame)
    local container = Instance.new("Frame")
    container.Name = "SnowContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.ZIndex = 2
    container.Parent = parentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 16)
    
    table.insert(ActiveSnowContainers, container)

    task.spawn(function()
        while container.Parent do
            task.wait(math.random(7, 18) / 100)
            task.spawn(function()
                if not container.Parent then return end
                local startX = math.random()
                local size = math.random(2, 5)
                local flake = Instance.new("Frame", container)
                flake.Size = UDim2.new(0, size, 0, size)
                flake.Position = UDim2.new(startX, 0, -0.1, 0)
                flake.BackgroundColor3 = (math.random(1, 3) == 1 and Color3.fromRGB(255, 255, 255)) or ThemeColor
                flake.BackgroundTransparency = math.random(20, 50) / 100
                flake.BorderSizePixel = 0
                flake.ZIndex = 2
                Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)

                local fallTime = math.random(18, 35) / 10
                local tw = TweenService:Create(flake, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(startX + (math.random(-4, 4) / 100), 0, 1.1, 0),
                    BackgroundTransparency = 1
                })
                tw:Play()
                tw.Completed:Connect(function()
                    flake:Destroy()
                end)
            end)
        end
    end)
end

--========================================================--
-- BASE DE DATOS Y ENGINES
--========================================================--

local RarityColors = {
    Common = Color3.fromRGB(255, 255, 255),
    Uncommon = Color3.fromRGB(99, 255, 52),
    Rare = Color3.fromRGB(51, 170, 255),
    Epic = Color3.fromRGB(237, 44, 255),
    Legendary = Color3.fromRGB(255, 150, 0),
    Omega = Color3.fromRGB(255, 20, 51)
}

local function registerFolderItems(folder)
    if not folder then return end
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            local dName = item:GetAttribute("DisplayName") or item.Name
            local iId = item:GetAttribute("ItemId") or item:GetAttribute("Id") or item.Name
            local rarity = item:GetAttribute("RarityName") or "Common"
            local img = item:GetAttribute("ImageId") or "rbxassetid://7072725737"
            local key
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshId ~= "" then
                    key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
                elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                    key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
                end
            end
            if not key and iId ~= "" and iId ~= item.Name then key = "ITEMID_" .. iId .. "_RARITY_" .. rarity end
            if not key then key = "NAME_" .. dName .. "_" .. item.Name .. "_RARITY_" .. rarity end
            RegisteredWeaponDB[key] = {Name = dName, Rarity = rarity, ImageId = img, ToolName = item.Name}
        end
    end
end

if ItemsFolder then
    for _, sub in ipairs({"gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish"}) do
        registerFolderItems(ItemsFolder:FindFirstChild(sub))
    end
end

local function getWeaponData(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local handle = tool:FindFirstChild("Handle")
    local dName = tool:GetAttribute("DisplayName") or tool.Name
    local iId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
    local rarity = tool:GetAttribute("RarityName") or "Common"
    local key
    if handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and mesh.MeshId ~= "" then key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
        elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity end
    end
    if not key and iId ~= "" and iId ~= tool.Name then key = "ITEMID_" .. iId .. "_RARITY_" .. rarity end
    if not key then key = "NAME_" .. dName .. "_" .. tool.Name .. "_RARITY_" .. rarity end
    return RegisteredWeaponDB[key]
end

local function getPing()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return 0.08 end
    local netStats = pGui:FindFirstChild("NetworkStats")
    if not netStats then return 0.08 end
    local pingLabel = netStats:FindFirstChild("PingLabel")
    if not pingLabel then return 0.08 end
    local text = pingLabel.Text
    if typeof(text) ~= "string" then return 0.08 end
    local ms = tonumber(text:match("%d+"))
    if not ms then return 0.08 end
    local s = ms / 1000
    if s < 0 or s > 1.5 then s = 0.08 end
    return s
end

--========================================================--
-- MOTOR DE SELECCIÓN Y PREDICCIÓN CON LÓGICA DE YA.TXT
--========================================================--

local function getBypassedTargetPart(character)
    if not character then return nil, Vector3.zero end
    local head = character:FindFirstChild("Head")
    local upperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local root = character:FindFirstChild("HumanoidRootPart")

    if TargetHitPart == "Head" then
        return (head or upperTorso or root), Vector3.zero
    elseif TargetHitPart == "Neck" then
        if head then
            return head, Vector3.new(0, -0.65, 0)
        elseif upperTorso then
            return upperTorso, Vector3.new(0, 0.3, 0)
        end
        return (head or upperTorso or root), Vector3.new(0, -0.4, 0)
    elseif TargetHitPart == "Chest" then
        return (upperTorso or root or head), Vector3.zero
    end
    return (head or upperTorso or root), Vector3.zero
end

RunService.Heartbeat:Connect(function()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local root = pl.Character:FindFirstChild("HumanoidRootPart")
            if root then
                VelocityHistory[pl] = VelocityHistory[pl] or {}
                table.insert(VelocityHistory[pl], {time = os.clock(), pos = root.Position})
                if #VelocityHistory[pl] > 6 then
                    table.remove(VelocityHistory[pl], 1)
                end
            else
                VelocityHistory[pl] = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(pl)
    VelocityHistory[pl] = nil
end)

local function calculateTargetVelocity(pl, rootPart)
    if rootPart and rootPart.AssemblyLinearVelocity.Magnitude > 22 then
        return rootPart.AssemblyLinearVelocity
    end

    local history = VelocityHistory[pl]
    if not history or #history < 2 then return Vector3.zero end

    local totalVel = Vector3.zero
    local count = 0
    for i = 2, #history do
        local dt = history[i].time - history[i - 1].time
        if dt > 0 then
            totalVel = totalVel + (history[i].pos - history[i - 1].pos) / dt
            count = count + 1
        end
    end
    if count == 0 then return Vector3.zero end

    local avg = totalVel / count
    if avg.Y > 150 then
        return Vector3.new(avg.X * 1.15, math.clamp(avg.Y * 0.85, 0, 400), avg.Z * 1.15)
    end
    return avg
end

local function predictPosition(targetPart, customOffset, rootPart)
    if not targetPart then return Vector3.zero end
    local offset = customOffset or Vector3.zero
    local basePos = targetPart.Position + offset
    local pl = Players:GetPlayerFromCharacter(targetPart.Parent)
    if not pl then return basePos end

    local targetChar = targetPart.Parent
    local hum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    local isDowned = hum and (hum:GetAttribute("HasBeenDowned") or hum:GetAttribute("IsDead") or hum.Health <= 0)

    if isDowned then return basePos end

    local vel = calculateTargetVelocity(pl, rootPart) or Vector3.zero
    local ping = getPing()

    return basePos + (vel * ping * 1.2)
end

local function isShotgun()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local ammo = item:GetAttribute("AmmoType")
            if ammo == "shotgun" or ammo == "shootgun" then return true end
        end
    end
    return false
end

--========================================================--
-- MODAL DE ADVERTENCIA (DE YA.TXT)
--========================================================--

local function ShowWarningModal(titleText, bodyText, confirmText, onConfirm)
    local alertOverlay = Instance.new("Frame", ScreenGui)
    alertOverlay.Size = UDim2.new(1, 0, 1, 0)
    alertOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    alertOverlay.BackgroundTransparency = 0.55
    alertOverlay.BorderSizePixel = 0
    alertOverlay.ZIndex = 9999

    local alertBox = Instance.new("Frame", alertOverlay)
    alertBox.Size = UDim2.new(0, 320, 0, 160)
    alertBox.Position = UDim2.new(0.5, -160, 0.5, -80)
    alertBox.BackgroundColor3 = Color3.fromRGB(18, 15, 27)
    alertBox.BackgroundTransparency = 0.1
    alertBox.BorderSizePixel = 0
    alertBox.ZIndex = 10000
    Instance.new("UICorner", alertBox).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", alertBox)
    stroke.Color = ThemeColor
    stroke.Thickness = 1.4
    table.insert(DynamicColorElements, {Type = "Stroke", Element = stroke})

    local title = Instance.new("TextLabel", alertBox)
    title.Size = UDim2.new(1, -24, 0, 26)
    title.Position = UDim2.new(0, 12, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "⚠️ " .. titleText
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 10001

    local desc = Instance.new("TextLabel", alertBox)
    desc.Size = UDim2.new(1, -24, 0, 60)
    desc.Position = UDim2.new(0, 12, 0, 42)
    desc.BackgroundTransparency = 1
    desc.Text = bodyText
    desc.TextColor3 = Color3.fromRGB(185, 190, 210)
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 10001

    local actionBtn = Instance.new("TextButton", alertBox)
    actionBtn.Size = UDim2.new(0.68, 0, 0, 30)
    actionBtn.Position = UDim2.new(0, 12, 1, -40)
    actionBtn.BackgroundColor3 = ThemeColor
    actionBtn.BackgroundTransparency = 0.2
    actionBtn.BorderSizePixel = 0
    actionBtn.Text = confirmText or "ENTENDIDO"
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.TextSize = 10
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.ZIndex = 10001
    Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 8)
    table.insert(DynamicColorElements, {Type = "Background", Element = actionBtn})

    local closeBtn = Instance.new("TextButton", alertBox)
    closeBtn.Size = UDim2.new(0.26, 0, 0, 30)
    closeBtn.Position = UDim2.new(1, -12 - (alertBox.AbsoluteSize.X * 0.26), 1, -40)
    closeBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "CERRAR"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    closeBtn.TextSize = 10
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.ZIndex = 10001
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    actionBtn.MouseButton1Click:Connect(function()
        alertOverlay:Destroy()
        if onConfirm then onConfirm() end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        alertOverlay:Destroy()
    end)
end

--========================================================--
-- SILENT AIM HOOK
--========================================================--

if SendRemote and hookfunction then
    local originalFireServer
    originalFireServer = hookfunction(SendRemote.FireServer, function(self, ...)
        if self ~= SendRemote then return originalFireServer(self, ...) end
        local args = {...}
        
        local remoteMethod = args[2]
        if typeof(remoteMethod) == "string" then
            local checkLower = string.lower(remoteMethod)
            if checkLower:find("blacklist") or checkLower:find("punish") or checkLower:find("cheat") or checkLower:find("report") or checkLower:find("flag") then
                return nil
            end
        end

        if SilentAimEnabled and args[2] == "shoot_gun" and CurrentLockedTarget then
            local targetChar = CurrentLockedTarget.Character
            local hitPart, hitOffset = getBypassedTargetPart(targetChar)
            local root = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            local hum = targetChar and targetChar:FindFirstChild("Humanoid")
            local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            
            if hitPart and myHead then
                local targetPos = predictPosition(hitPart, hitOffset, root)
                local originPos = myHead.Position
                
                if isShotgun() then
                    args[4] = CFrame.new(originPos, targetPos)
                    local pellets = {}
                    for i = 1, 6 do
                        local spreadOffset = Vector3.new(
                            math.random(-2, 2) * 0.02,
                            math.random(-2, 2) * 0.02,
                            math.random(-2, 2) * 0.02
                        )
                        table.insert(pellets, {
                            [1] = {
                                Instance = hitPart,
                                Normal = Vector3.new(0, 1, 0),
                                Position = targetPos + spreadOffset
                            }
                        })
                    end
                    args[5] = pellets
                else
                    args[4] = CFrame.new(originPos, targetPos)
                    args[5] = {
                        [1] = {
                            [1] = {
                                Instance = hitPart,
                                Normal = Vector3.new(0, 1, 0),
                                Position = targetPos
                            }
                        }
                    }
                end

                pcall(function()
                    local tracerPart = Instance.new("Part")
                    tracerPart.Anchored = true
                    tracerPart.CanCollide = false
                    tracerPart.Size = Vector3.new(0.08, 0.08, (targetPos - originPos).Magnitude)
                    tracerPart.CFrame = CFrame.new(originPos, targetPos) * CFrame.new(0, 0, -tracerPart.Size.Z / 2)
                    tracerPart.Material = Enum.Material.Neon
                    tracerPart.Transparency = 0.35
                    tracerPart.Color = ThemeColor
                    tracerPart.Parent = workspace
                    Debris:AddItem(tracerPart, 4)

                    local currentHealth = hum and hum.Health or 100
                    task.spawn(function()
                        task.wait(0.08)
                        if hum and hum.Health < currentHealth then
                            if tracerPart and tracerPart.Parent then
                                tracerPart.Color = Color3.fromRGB(0, 255, 0)
                            end
                            for _, descendant in ipairs(targetChar:GetDescendants()) do
                                if descendant:IsA("BasePart") then
                                    local glowPart = Instance.new("Part")
                                    glowPart.Size = descendant.Size + Vector3.new(0.05, 0.05, 0.05)
                                    glowPart.CFrame = descendant.CFrame
                                    glowPart.Anchored = true
                                    glowPart.CanCollide = false
                                    glowPart.Material = Enum.Material.Neon
                                    glowPart.Color = Color3.fromRGB(0, 255, 0)
                                    glowPart.Transparency = 0.5
                                    glowPart.Parent = workspace
                                    TweenService:Create(glowPart, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
                                    Debris:AddItem(glowPart, 1.5)
                                end
                            end
                        end
                    end)
                end)
            end
        end
        return originalFireServer(self, unpack(args))
    end)
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if head then
            for _, item in ipairs(head:GetChildren()) do
                if item:IsA("BillboardGui") and (item.Name:lower():find("punish") or item.Name:lower():find("blacklist") or item.Name:lower():find("warn") or item.Name:lower():find("stun")) then
                    item:Destroy()
                end
            end
        end

        if hum then
            if hum.PlatformStand then hum.PlatformStand = false end
            for _, attr in ipairs({"Blacklisted", "InBlacklist", "IsPunished", "Stunned", "CannotWalk", "NoJump"}) do
                if hum:GetAttribute(attr) then
                    hum:SetAttribute(attr, false)
                end
            end
        end
    end
end)

--========================================================--
-- GUN MODS & MELEE AURA
--========================================================--

local function isMeleeTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool.Name == "Fists" then return true end
    if MeleeFolder and ThrowableFolder then
        if MeleeFolder:FindFirstChild(tool.Name) and not ThrowableFolder:FindFirstChild(tool.Name) then
            return true
        end
    end
    return false
end

local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return (GunsFolder and GunsFolder:FindFirstChild(tool.Name) ~= nil) or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
end

local function applyGodGun(tool)
    if not tool or not isGunTool(tool) then return end
    pcall(function()
        tool:SetAttribute("fire_rate", FireRateVal)
        tool:SetAttribute("accuracy", AccuracyVal)
        tool:SetAttribute("Recoil", RecoilVal)
        tool:SetAttribute("recoil", RecoilVal)
        tool:SetAttribute("reload_time", ReloadVal)
        tool:SetAttribute("Durability", DurabilityVal)
        tool:SetAttribute("automatic", AutomaticVal)
        tool:SetAttribute("Spread", 0)
        tool:SetAttribute("spread", 0)
    end)
end

local function modifyFists(tool, state)
    if not tool then return end
    local attrs = tool:GetAttributes()
    local keys = {}
    for k in pairs(attrs) do table.insert(keys, k) end
    table.sort(keys)
    if #keys >= 7 then
        local k6, k7 = keys[6], keys[7]
        if state then
            if SavedMeleeAttributes[k6] == nil then SavedMeleeAttributes[k6] = tool:GetAttribute(k6) end
            if SavedMeleeAttributes[k7] == nil then SavedMeleeAttributes[k7] = tool:GetAttribute(k7) end
            tool:SetAttribute(k6, 360)
            tool:SetAttribute(k7, 20)
        else
            if SavedMeleeAttributes[k6] then tool:SetAttribute(k6, SavedMeleeAttributes[k6]) end
            if SavedMeleeAttributes[k7] then tool:SetAttribute(k7, SavedMeleeAttributes[k7]) end
        end
    end
end

local function updateMeleeTools()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return end
    for _, t in ipairs(char:GetChildren()) do
        if isMeleeTool(t) then modifyFists(t, MeleeAuraEnabled) end
    end
    for _, t in ipairs(backpack:GetChildren()) do
        if isMeleeTool(t) then modifyFists(t, MeleeAuraEnabled) end
    end
end

RunService.Heartbeat:Connect(function()
    if GunModsActive and LocalPlayer.Character then
        for _, t in ipairs(LocalPlayer.Character:GetChildren()) do
            if isGunTool(t) then applyGodGun(t) end
        end
    end
    if MeleeAuraEnabled then
        updateMeleeTools()
    end
end)

task.spawn(function()
    while true do
        task.wait(0.35)
        if AutoAttackEnabled and LocalPlayer.Character and SendRemote then
            local char = LocalPlayer.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local tool = char:FindFirstChildOfClass("Tool")
            if root and tool and isMeleeTool(tool) then
                local targets = {}
                local positions = {}
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        local eHead = pl.Character:FindFirstChild("Head") or pl.Character:FindFirstChild("UpperTorso") or pl.Character:FindFirstChild("Torso")
                        local eRoot = pl.Character.HumanoidRootPart
                        if eHead and eRoot then
                            local dist = (eRoot.Position - root.Position).Magnitude
                            if dist <= 20 then
                                table.insert(targets, pl)
                                table.insert(positions, eHead.Position)
                            end
                        end
                    end
                end
                if #targets > 0 then
                    local lookCF = CFrame.lookAt(root.Position, positions[1])
                    FireServerHook("melee_attack", tool, targets, lookCF, 0.75)
                end
            end
