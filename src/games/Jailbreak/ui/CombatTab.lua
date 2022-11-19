local KeysManager = require("games/Jailbreak/managers/KeysManager")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gun = require(ReplicatedStorage.Game.Item.Gun)

local Network = KeysManager.Network
local Keys = KeysManager.Keys

local allGuns = require(ReplicatedStorage.Game.GunShop.Data.Held)
local allItems = require(ReplicatedStorage.Game.GunShop.Data.Boost)
local allAmmo = require(ReplicatedStorage.Game.GunShop.Data.Projectile)

local trollSniper = {
    __ClassName = "Sniper",
    LastImpactSound = 1,
    Maid = require(ReplicatedStorage.Module.Maid),
    LastImpact = 1,
    Local = true,
    Config = {},
    IgnoreList = {},
}

Gun.SetupBulletEmitter(trollSniper)

trollSniper.OnHitSurface:Connect(function()
    print("sniper hit surface unknown if car or heli")
end)

local guns = {}
local items = {}
local ammoTypes = {}

for _, gunTable in pairs(allGuns) do
    table.insert(guns, gunTable.Name)
end

for _, itemTable in pairs(allItems) do
    table.insert(items, itemTable.Name)
end

for _, ammoTable in pairs(allAmmo) do
    if string.find(ammoTable.Name, "Cartridge") or string.find(ammoTable.Name, "Ammo") then
        table.insert(ammoTypes, ammoTable.Name)
    end
end

local function combatTab(CombatTab)
    local GrabWeaponGroupBox = CombatTab:AddLeftGroupbox("Guns")
    do
        GrabWeaponGroupBox:AddDropdown("WeaponSelected", {
            Default = "Shotgun",
            Text = "Selected Gun",
            Values = guns,
            Compact = true
        })
        GrabWeaponGroupBox:AddButton("Grab Selected Gun", function()
            Network:FireServer(Keys.GrabGun, Options.WeaponSelected.Value)
        end)
        GrabWeaponGroupBox:AddButton("Buy Selected  Gun", function()
            Network:FireServer(Keys.BuyGunOrAmmo, Options.WeaponSelected.Value)
        end)
    end

    local AmmoGroupBox = CombatTab:AddRightGroupbox("Ammo")
    do
        AmmoGroupBox:AddDropdown("AmmoSelected", {
            Default = "C4Ammo",
            Values = ammoTypes,
            Text = "Selected Ammo Type",
            Compact = true
        })
        AmmoGroupBox:AddSlider("AmmoAmount", {
            Rounding = 0,
            Text = "Ammo Amount",
            Max = 10,
            Min = 1,
            Default = 2,
            Compact = true
        })
        AmmoGroupBox:AddButton("Buy Selected Ammo", function()
            for _ = 1, Options.AmmoAmount.Value do
                Network:FireServer(Keys.BuyGunOrAmmo, Options.AmmoSelected.Value)
            end
        end)
    end

    local GrabItemGroupBox = CombatTab:AddLeftGroupbox("Items")
    do
        GrabItemGroupBox:AddDropdown("ItemSelected", {
            Default = "Binoculars",
            Text = "Selected Item",
            Values = items,
            Compact = true
        })
        GrabItemGroupBox:AddButton("Grab Selected Item", function()
            Network:FireServer(Keys.GrabGun, Options.ItemSelected.Value)
        end)
        GrabItemGroupBox:AddButton("Buy Selected Item", function()
            Network:FireServer(Keys.BuyGunOrAmmo, Options.ItemSelected.Value)
        end)
    end
end

return combatTab