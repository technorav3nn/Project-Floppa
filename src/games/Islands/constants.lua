local TableUtil = require("modules/util/TableUtil")

local Constants
Constants = {
    Rocks = {
        "rockIron",
        "rockCoal",
        "rockPrismarine",
        "rockStone",
        "rockCopper",
        "rockDiamond",
        "rockGold",
        "rockElectrite",
        "rockClay",
        "rockSlate",
        "rockSandstone",
    },
    HostileMobs = {
        slime = { boss = false },
        wizardLizard = { boss = false },
        slimeKing = { boss = true },
    },
    HostileMobKeys = TableUtil:getKeys(Constants.HostileMobs)
}

return Constants