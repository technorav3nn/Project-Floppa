local KeysManager = getgenv().JailbreakKeysManager
local TableUtil = require("modules/util/TableUtil")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = KeysManager.Network
local Keys = KeysManager.Keys

local ItemConfig = ReplicatedStorage.Game.ItemConfig

local allGuns = require(ReplicatedStorage.Game.GunShop.Data.Held)
local allItems = require(ReplicatedStorage.Game.GunShop.Data.Boost)
local allAmmo = require(ReplicatedStorage.Game.GunShop.Data.Projectile)

local guns = {}
local items = {}
local ammoTypes = {}
local oldGunStates = {}

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

for _, v in pairs(ItemConfig:GetChildren()) do
    local module = require(v)
    oldGunStates[v.Name] = TableUtil:deepCopy(module)
end

local function modGun(state, prop, newValue)
    for _, v in pairs(ItemConfig:GetChildren()) do
        local module = require(v)
        print(oldGunStates[v.Name][prop], "is old gun states; cur mod is ", module[prop])
        if state then
            module[prop] = newValue
        else
            module[prop] = oldGunStates[v.Name][prop]
        end
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

    local GunModGroupBox = CombatTab:AddLeftGroupbox("Gun Mods")
    do
        GunModGroupBox:AddToggle("InfAmmo", { Text = "Infinite Ammo" }):OnChanged(function()
            modGun(Toggles.InfAmmo.Value, "MagSize", math.huge)
        end)
        GunModGroupBox:AddToggle("NoRecoil", { Text = "No Recoil" }):OnChanged(function()
            modGun(Toggles.NoRecoil.Value, "CamShakeMagnitude", 0)
        end)
        
        GunModGroupBox:AddToggle("Automatic", { Text = "Automatic Firing" }):OnChanged(function()
            modGun(Toggles.Automatic.Value, "FireAuto", true)
        end)
        GunModGroupBox:AddToggle("NoReloadTime", { Text = "NoReloadTime" }):OnChanged(function()
            modGun(Toggles.NoReloadTime.Value, "ReloadTime", 0.01)
        end)
        GunModGroupBox:AddToggle("FireRate", { Text = "Custom Fire Rate" })
        AmmoGroupBox:AddSlider("FireRateAmount", {
            Rounding = 0,
            Text = "Fire Rate",
            Max = 150,
            Min = 1,
            Default = 3,
            Compact = true
        }):OnChanged(function()
            modGun(Toggles.FireRate.Value, "FireFreq", Options.FireRateAmount.Value)
        end)
    end
    local ThrowableModGroupBox = CombatTab:AddRightGroupbox("Throwable Mods")
    do
        
    end
end

return combatTab