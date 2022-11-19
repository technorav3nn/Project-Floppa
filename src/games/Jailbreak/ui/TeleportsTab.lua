local Player = require("modules/exploit/Player")

local ContractManager = require("games/Jailbreak/managers/ContractManager/ContractManager").new()

local function farmingTab(PlayerTab)
    local MovementGroupBox = PlayerTab:AddLeftGroupbox("Movement")
    do
        MovementGroupBox:AddButton("Test", function()
            for i, v in pairs(ContractManager:GetActiveContracts()) do
                table.foreach(v, print)
            end
            print("------------")
        end)
    end
end

return farmingTab