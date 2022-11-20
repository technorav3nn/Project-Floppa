local Gun = require(ReplicatedStorage.Game.Item.Gun)

-- // create a sniper to pop tires and disable helis
local trollSniper = {
    __ClassName = "Sniper",
    LastImpactSound = 1,
    Maid = require(ReplicatedStorage.Module.Maid),
    LastImpact = 1,
    Local = true,
    Config = {},
    IgnoreList = {},
}

-- // "make" it into a gun
Gun.SetupBulletEmitter(trollSniper)

trollSniper.OnHitSurface:Connect(function()
    print("sniper hit surface unknown if car or heli")
end)

local function miscTab()

end

return miscTab