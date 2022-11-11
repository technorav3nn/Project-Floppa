local Compatiblity = require("modules/exploit/Compatiblity")
local teleport = require("games/LifeSentence/TpBypass")

local RunService = game:GetService("RunService")

local FarmingManager = {}

FarmingManager.AutoScrapEnabled = false

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

function FarmingManager:FarmSafes()

end

return FarmingManager