local Modules = require("games/Jailbreak/managers/ModuleManager")
local Specs = Modules.UI.CircleAction.Specs

local CircleSpecManager = {}

function CircleSpecManager:FireCirclePrompt(name, once)
    for _, v in pairs(Specs) do
        if v.Name == name then
            v:Callback(true)
            if once then
                break
            end
        end
    end
end

return CircleSpecManager
