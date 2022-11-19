local Player = require("modules/exploit/Player")
local Modules = require("games/Jailbreak/managers/ModuleManager")
local Maid = require("modules/util/Maid")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local flyingMaid = Maid.new()

local isFlying = false

local localPlayer = Player:GetLocalPlayer() ---@type Player
local character = Player:GetChar() ---@type Model
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 3) ---@type Humanoid
local camera = game:GetService("Workspace").CurrentCamera

local PlayerUtils = Modules.PlayerUtils
local CircleSpecs = Modules.UI.CircleAction.Specs

local oldSpecs = {}

for _, v in pairs(CircleSpecs) do
    if not oldSpecs[v] then
        oldSpecs[v] = v
    end
end

local oldPointInTag = PlayerUtils.isPointInTag;
PlayerUtils.isPointInTag = function(point, tag)
    if tag == "NoRagdoll" then
        return Toggles.AntiRagdoll.Value;
    end

    if tag == "NoFallDamage" then
        return Toggles.AntiFallDamage.Value
    end

    if tag == "NoParachute" then
        return Toggles.AntiSkydive.Value
    end

    return oldPointInTag(point, tag);
end

local function flyingOnRenderStepped()
    local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")

    if root and not humanoid.PlatformStand and not humanoid.Sit then
        local flyingVector = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            flyingVector = flyingVector + camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            flyingVector = flyingVector - camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            flyingVector = flyingVector - camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            flyingVector = flyingVector + camera.CFrame.RightVector
        end

        flyingVector = flyingVector == Vector3.new() and Vector3.new(0, 9e-10, 0) or flyingVector

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
           flyingVector = flyingVector + Vector3.new(0, 1, 0)
        elseif flykeys.LeftShift and not flykeys.Space then
           flyingVector = flyingVector + Vector3.new(0, -1, 0)
        end

        root.Velocity = flyingVector.Unit * Options.FlySpeed and Options.FlySpeedAmount.Value or 100
        root.Anchored = flyingVector == Vector3.new(0, 9e-10, 0)
    end
end

local function playerTab(PlayerTab, Library)
    local MovementGroupBox = PlayerTab:AddLeftGroupbox("Movement")
    do
        MovementGroupBox:AddToggle("WalkSpeedToggle", { Text = "WalkSpeed" })
        MovementGroupBox:AddSlider("WalkSpeedAmount", { Text = "WalkSpeed Amount", Rounding = 0, Min = 16, Max = 200, Default = 60 })
        MovementGroupBox:AddToggle("JumpPowerToggle", { Text = "JumpPower" })
        MovementGroupBox:AddSlider("JumpPowerAmount", { Text = "JumpPower Amount", Rounding = 0, Min = 50, Max = 300, Default = 100 })
        MovementGroupBox:AddToggle("FlyToggle", { Text = "Fly" })
        MovementGroupBox:AddSlider("FlySpeedAmount", { Text = "Fly Speed Amount", Rounding = 0, Min = 25, Max = 300, Default = 125 })
    end

    local CharacterGroupBox = PlayerTab:AddRightGroupbox("Character")
    do
        CharacterGroupBox:AddToggle("AntiRagdoll", { Text = "Anti Ragdoll" })
        CharacterGroupBox:AddToggle("AntiFallDamage", { Text = "Anti Fall Damage" })
        CharacterGroupBox:AddToggle("AntiSkydive", { Text = "Anti Skydive" })
        CharacterGroupBox:AddToggle("NoPunchCooldown", { Text = "No Punch Cooldown" })
        CharacterGroupBox:AddToggle("SpoofKeycardDoors", { Text = "Spoof Keycard Doors", Tooltip = "Keycard Doors will open for you without a keycard with this on" })
        CharacterGroupBox:AddToggle("NoPromptWait", { Text = "No Prompt Duration", Tooltip = "Hold E Prompts will be instant when this is on" })
    end

    -- // Non UI Stuff // --

    -- // Character Stuff
    Toggles.NoPromptWait:OnChanged(function()
        local state = Toggles.NoPromptWait.Value
        if state then
            for _, v in pairs(CircleSpecs) do
                if not oldSpecs[v] then
                    oldSpecs[v] = v
                end
                v.Duration = 0
            end
        else
            for _, v in pairs(CircleSpecs) do
                v.Duration = oldSpecs[v].Duration or 0
            end
        end
    end)

    Toggles.SpoofKeycardDoors:OnChanged(function()
        local teamValue = game:GetService("Players").LocalPlayer:FindFirstChild("TeamValue")
        if teamValue and (teamValue == "Prisoner" or teamValue == "Criminal") then
            teamValue.Value = "Police"
        end
    end)

    Toggles.NoPunchCooldown:OnChanged(function()
        local script = localPlayer.PlayerScripts:FindFirstChild("LocalScript")

        if Toggles.NoPunchCooldown.Value then
            if not script then
                Library:Notify("Couldn't find the LocalScript")
            end
            getsenv(script).tick = function() return 0/0 end
        else
            getsenv(script).tick = tick
        end
    end)


    -- // Walkspeed + JumpPower
    humanoid.UseJumpPower = true

    Toggles.FlyToggle:OnChanged(function()
        if Toggles.FlyToggle.Value then
            flyingMaid:GiveTask(RunService.RenderStepped:Connect(flyingOnRenderStepped))
        else
            flyingMaid:DoCleaning()
        end
    end)

    Toggles.JumpPowerToggle:OnChanged(function()
        pcall(function()
            if Toggles.JumpPowerToggle.Value and humanoid then
                humanoid.JumpPower = Options.JumpPowerAmount.Value
            else
                if humanoid then
                    humanoid.JumpPower = 16
                end
            end
        end)
    end)

    Options.JumpPowerAmount:OnChanged(function()
        pcall(function()
            if Toggles.JumpPowerToggle.Value and humanoid then
                humanoid.JumpPower = Options.WalkSpeedAmount.Value
            end
        end)
    end)

    Toggles.WalkSpeedToggle:OnChanged(function()

        pcall(function()
            if Toggles.WalkSpeedToggle.Value and humanoid  then
                humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
            else
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
        end)
    end)

    Options.WalkSpeedAmount:OnChanged(function()
        pcall(function()
            if Toggles.WalkSpeedToggle.Value and humanoid  then
                humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
            end
        end)
    end)

    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Toggles.WalkSpeedToggle.Value and humanoid  then
            humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
        end
    end)

    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if Toggles.JumpPowerToggle.Value and humanoid then
            humanoid.JumpPower = Options.JumpPowerAmount.Value
        end
    end)

    localPlayer.CharacterAdded:Connect(function(char)
        if Toggles.JumpPowerToggle.Value then
            humanoid.JumpPower = Options.JumpPowerAmount.Value
        end

        if Toggles.WalkSpeedToggle.Value then
            humanoid.WalkSpeed = Options.WalkSpeedToggle.Value
        end

        humanoid = char.Humanoid
    end)
end

return playerTab