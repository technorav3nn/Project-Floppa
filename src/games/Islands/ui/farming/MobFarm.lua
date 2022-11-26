local NetworkService = require("games/Islands/services/NetworkService")
local NotificationService = require("games/Islands/services/NotificationService")

local IslandsUtils = require("games/Islands/IslandsUtils")

local Constants = require("games/Islands/constants")

local mobFarmMaid = require("modules/util/Maid").new()

-- // to be replaced with the FarmingTab.Flags property, dw
local flags = {}

local function getMob(mobName)
    if not table.find(Constants.HostileMobKeys, mobName) then
        NotificationService:DisplayNotification({
            message = "Couldn't find the mob ".. mobName .. ", please contact Death_Blows"
        })
    end
end

return function (Library, Window, FarmingTab)
    local MobFarmSection = FarmingTab:AddSection("Mob Farm", { default = false })

    flags = FarmingTab.Flags

    MobFarmSection:AddToggle("Enabled", { flag = "MobFarmEnabled" })
    MobFarmSection:AddDropdown("Mob Selected", Constants.HostileMobKeys { default = "slime" })
end