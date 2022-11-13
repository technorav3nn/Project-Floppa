local Linoria = require("modules/exploit/ui/LinoriaLib")

local Modules = require("games/Jailbreak/managers/ModuleManager")
local Specs = Modules.UI.CircleAction.Specs


local function visualsTab(VisualsTab)
    local ESPGroupBox, ESPOptionsGroupBox, ESP = Linoria:buildESPBoxes(VisualsTab)
    do
        ESPGroupBox:AddToggle("AirdropESP", { Text = "Show Airdrops" })
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