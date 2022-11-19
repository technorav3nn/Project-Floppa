local Linoria = require("modules/exploit/ui/LinoriaLib")
local Util = require("modules/util/Util")

local Modules = require("games/Jailbreak/managers/ModuleManager")
local Specs = Modules.UI.CircleAction.Specs

local function visualsTab(VisualsTab)
    local ESPGroupBox, ESPOptionsGroupBox, ESP = Linoria:buildESPBoxes(VisualsTab)
    do
        ESP:AddObjectListener(game.Workspace, {
            Name = "Drop",
            CustomName = "Airdrop",
            Color = Color3.fromRGB(123, 255, 0),
            PrimaryPart = function(obj)
                return obj:FindFirstChildWhichIsA("BasePart")
            end,
            Validator = function(obj)
                return obj:FindFirstChildWhichIsA("BasePart")
            end,
            Enabled = "AirdropESP"
        })
        ESPGroupBox:AddToggle("AirdropESP", { Text = "Show Airdrops" }):OnChanged(function() ESP.AirdropESP = Toggles.AirdropESP.Value end)
    end

    local ChamsGroupBox = VisualsTab:AddRightGroupbox("Chams")
    do
        Linoria:buildChamsGroupBox(ChamsGroupBox)
    end


    local OtherGroupBox = VisualsTab:AddLeftGroupbox("Other")
    do
        OtherGroupBox:AddButton("Open Security Cameras", function()
            for _, v in pairs(Specs) do
                if v.Name == "Open Security Cameras" then
                    v:Callback(true)
                    break
                end
            end
        end)
    end
end

return visualsTab