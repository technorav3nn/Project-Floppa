local Character = require("modules/exploit/Character")
local Compatiblity = require("modules/exploit/Compatiblity")
local teleport = require("games/LifeSentence/TpBypass")

local GunConfigs = require(game:GetService("ReplicatedStorage").GunConfigs)

local CraftingManager = {}

CraftingManager.ValidCraftableWeapons = {}
CraftingManager.ResearchWeapons = {
    MetalVest = "1",
    Spaz = "2",
    AR = "3",
    Tec9 = "4",
    Garand = "5",
    LMG = "6",
    RPG = "7"
}

for k, _ in pairs(GunConfigs) do
    table.insert(CraftingManager.ValidCraftableWeapons, k)
end

function CraftingManager:CraftWeapon(weapon)
    local oldCf = Character:GetCFrame()
    teleport(CFrame.new(186, 7, -113))
    task.wait(0.3)

    Compatiblity:fireproximityprompt(game:GetService("Workspace").WorkBench.MainPart.Attachment.ProximityPrompt)

    task.wait(0.3)
    game:GetService("ReplicatedStorage").Events.LearnCraftEvent:FireServer(
        weapon .. "Frame"
    )
    task.wait(0.3)

    teleport(oldCf)
end

function CraftingManager:ResearchWeapon(name)
    local itemNumber = CraftingManager.ResearchWeapons[name]
    if itemNumber ~= nil then
        game:GetService("ReplicatedStorage").Events.LearnCraftEvent:FireServer(itemNumber, "Learn")
    else
        error('invalid item: '..name)
    end
end

return CraftingManager