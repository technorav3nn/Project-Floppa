local Compatiblity = require("modules/exploit/Compatiblity")
local teleport = require("games/LifeSentence/TpBypass")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local FarmingManager = {}

FarmingManager.AutoScrapEnabled = false
FarmingManager.AutoRobEnabled = false

function FarmingManager:GetAllScrap()
    local lootSpawners = game:GetService("Workspace").SpawnsLoot
    for _, loot in ipairs(lootSpawners:GetChildren()) do
        if loot.Part.Attachment.ProximityPrompt.Enabled then
            local prompt = loot.Part.Attachment.ProximityPrompt
            prompt.RequiresLineOfSight = false
            teleport(loot.Part.CFrame)
            task.wait(0.4)
            Compatiblity:fireproximityprompt(prompt)
        end
    end
end

function FarmingManager:LoopGetAllScrap()
    if self.AutoScrapEnabled then
        RunService:BindToRenderStep(
            "ScrapLoop",
            Enum.RenderPriority.Character.Value,
            function()
                if self.AutoScrapEnabled then
                    self:GetAllScrap()
                else
                    RunService:UnbindFromRenderStep("ScrapLoop")
                end
            end
        )
    end
end

function FarmingManager:CollectNearCash()
    for _, v in ipairs(game:GetService("Workspace"):GetChildren()) do
        if v.Name == "DroppedCash" and v:FindFirstChild("ProximityPrompt") and v.ProximityPrompt.Enabled then
            v.ProximityPrompt.RequiresLineOfSight = false
            fireproximityprompt(v.ProximityPrompt)
            task.wait(0.1)
        end
    end
end

function FarmingManager:GetAllSafes()
    local robbables = game:GetService("Workspace").Robbable
    local toReturn = {}

    for _, v in ipairs(robbables:GetChildren()) do
        if v:FindFirstChild("Door") and v.Door.Attachment.ProximityPrompt.Enabled then
            table.insert(toReturn, v)
        end
    end

    return toReturn
end

function FarmingManager:LoopFarmSafes()
    if FarmingManager.AutoRobEnabled then
        repeat
            if not FarmingManager.AutoRobEnabled then
                return
            end
            local robbables = self:GetAllSafes()

            for _, v in ipairs(robbables) do
                if not FarmingManager.AutoRobEnabled then
                    return
                end

                if v.Door.Attachment.ProximityPrompt.Enabled then
                    local camera = workspace.CurrentCamera
                    camera.CFrame = v.Door.CFrame

                    task.wait()

                    if localPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
                        camera.CameraSubject = v.Door
                    end

                    teleport(v.Door.CFrame)

                    task.wait(0.2)
                    Compatiblity:fireproximityprompt(v.Door.Attachment.ProximityPrompt, 1, false)
                    task.wait(0.3)

                    FarmingManager:CollectNearCash()
                    task.wait(0.4)

                    if localPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
                        camera.CameraSubject = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                    end
                end

                if not FarmingManager.AutoRobEnabled then
                    return
                end
            end
            task.wait(3)
        until not FarmingManager.AutoRobEnabled
    end
end

return FarmingManager