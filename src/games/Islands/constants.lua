local TableUtil = require("modules/util/TableUtil")

local HostileMobs = {
    slime = { boss = false },
    wizardLizard = { boss = false },
    slimeKing = { boss = true },
}

return {
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
    HostileMobs = HostileMobs,
    HostileMobKeys = TableUtil:getKeys(HostileMobs)
}