local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Maid = require("modules/util/Maid")

local PlayerUtil = require("modules/exploit/Player")
local CharacterUtil = require("modules/exploit/Character")

local Player = PlayerUtil:GetLocalPlayer()

local maids = {
    infJump = Maid.new()
}
local flags = {}

local function infiniteJump()
    UserInputService.JumpRequest:Connect(function()
        game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end)
end

local function noclipPlayer()
    for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

return function (Library, Window)
    local PlayerTab = Window:AddTab("Player", { default = true })

    flags = PlayerTab.Flags

    local MovementSection = PlayerTab:AddSection("Movement", { position = "left" })
    do
        MovementSection:AddSlider("WalkSpeed", 16, 500, 120, {
            toggleable = true, 
            default = false, 
            flag = "WalkSpeedToggle", 
            fireontoggle = true, 
            fireondrag = true, 
            rounded = true
        }, function(value, state)
            if state then
                PlayerUtil:GetChar():FindFirstChildOfClass("Humanoid").WalkSpeed = value
            else
                PlayerUtil:GetChar():FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
        end)

        MovementSection:AddSlider("JumpPower", 50, 400, 100, {
            toggleable = true, 
            default = false, 
            flag = "JumpPowerToggle", 
            fireontoggle = true, 
            fireondrag = true, 
            rounded = true
        }, function(value, state)
            if state then
                PlayerUtil:GetChar():FindFirstChildOfClass("Humanoid").JumpPower = value
            else
                PlayerUtil:GetChar():FindFirstChildOfClass("Humanoid").JumpPower = 50
            end
        end)

        MovementSection:AddToggle("Noclip", { flag = "Noclip" }, function(state)
            if state then
                maids.infJump:GiveTask(RunService.Stepped:Connect(noclipPlayer))
            else
                noclipMaid:DoCleaning()
            end
        end)

        MovementSection:AddToggle("Infinite Jump", { flag = "InfiniteJump" }, function(state)
            if state then
                maids.infJump:GiveTask(infiniteJump)
            else
                infJumpMaid:DoCleaning()
            end            
        end)
    end
end