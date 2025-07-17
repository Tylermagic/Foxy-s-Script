loadstring([==[
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Tophertz/Roblox/main/UiLibary.lua"))()

local Window = Library:CreateWindow("Steal a Brainrot Mod Menu")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local FlySpeed = 50
local FlyEnabled = false
local MyNoClipEnabled = false

local autoCollectEnabled = false
local autoBuyEnabled = false
local espEnabled = false

local BrainrotsList = {
    {Name="Odin", Value=5000000},
    {Name="La Vacca", Value=6000000},
    {Name="Renegade", Value=7000000},
    {Name="The Beast", Value=8000000},
    -- Complete com os nomes e valores reais
}

local AutoCollectFilter = {}
local AutoBuyFilter = {}

local collectSection = Window:CreateSection("Auto Coletar - Selecionar Brainrots")
for _, brain in pairs(BrainrotsList) do
    AutoCollectFilter[brain.Name] = false
    collectSection:CreateToggle(brain.Name, function(state)
        AutoCollectFilter[brain.Name] = state
    end)
end

local buySection = Window:CreateSection("Auto Comprar - Selecionar Brainrots")
for _, brain in pairs(BrainrotsList) do
    AutoBuyFilter[brain.Name] = false
    buySection:CreateToggle(brain.Name, function(state)
        AutoBuyFilter[brain.Name] = state
    end)
end

Window:CreateToggle("Auto Coletar", function(state)
    autoCollectEnabled = state
end)

Window:CreateToggle("Auto Comprar", function(state)
    autoBuyEnabled = state
end)

Window:CreateToggle("ESP Brainrots", function(state)
    espEnabled = state
end)

Window:CreateToggle("Meu NoClip", function(state)
    MyNoClipEnabled = state
    if MyNoClipEnabled then
        humanoid.PlatformStand = true
        rootPart.CanCollide = false
    else
        humanoid.PlatformStand = false
        rootPart.CanCollide = true
    end
end)

Window:CreateButton("Ir para Base (voando)", function()
    local base = Workspace:FindFirstChild("Base")
    if base then
        local targetPos = base.Position
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
        bodyVelocity.Velocity = (targetPos - rootPart.Position).Unit * FlySpeed
        bodyVelocity.Parent = rootPart

        -- Tween para suavizar movimento
        local tweenInfo = TweenInfo.new((targetPos - rootPart.Position).Magnitude / FlySpeed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
        tween:Play()
        tween.Completed:Wait()

        bodyVelocity:Destroy()
    end
end)

Window:CreateButton("Minimizar Menu", function()
    Window:SetVisible(not Window.Visible)
end)

local ESPObjects = {}

local function ClearESP()
    for _, esp in pairs(ESPObjects) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    ESPObjects = {}
end

local function CreateESP(part)
    if part and part:IsA("BasePart") then
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = part
        box.Size = part.Size
        box.Transparency = 0.5
        box.Color3 = Color3.new(1, 0, 0)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Parent = part
        table.insert(ESPObjects, box)
    end
end

local function GetBrainrotsOnMap(filter)
    local brains = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and filter[obj.Name] then
            table.insert(brains, obj)
        end
    end
    return brains
end

-- Função para coletar cérebro (com evento remoto do jogo)
local function CollectBrain(brain)
    -- Exemplo: ativar evento remoto para coletar
    local remote = ReplicatedStorage:FindFirstChild("CollectBrainRemote")
    if remote and brain then
        remote:FireServer(brain)
    end
end

-- Função para comprar cérebro na esteira (com evento remoto)
local function BuyBrain(brain)
    local remote = ReplicatedStorage:FindFirstChild("BuyBrainRemote")
    if remote and brain then
        remote:FireServer(brain)
    end
end

RunService.Heartbeat:Connect(function()
    if autoCollectEnabled then
        local brains = GetBrainrotsOnMap(AutoCollectFilter)
        for _, brain in pairs(brains) do
            -- Voar até o cérebro com noclip
            rootPart.CFrame = CFrame.new(brain.Position + Vector3.new(0,3,0))
            wait(0.3)
            CollectBrain(brain)
            wait(0.5)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if autoBuyEnabled then
        local esteira = Workspace:FindFirstChild("Esteira")
        if esteira then
            for _, brain in pairs(esteira:GetChildren()) do
                if brain:IsA("BasePart") and AutoBuyFilter[brain.Name] then
                    -- Vá até o cérebro e compre
                    rootPart.CFrame = CFrame.new(brain.Position + Vector3.new(0,3,0))
                    wait(0.3)
                    BuyBrain(brain)
                    wait(0.5)
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    ClearESP()
    if espEnabled then
        local brains = GetBrainrotsOnMap(AutoCollectFilter)
        for _, brain in pairs(brains) do
            CreateESP(brain)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if MyNoClipEnabled then
        rootPart.CanCollide = false
        humanoid.PlatformStand = true
    else
        rootPart.CanCollide = true
        humanoid.PlatformStand = false
    end
end)
]==])
