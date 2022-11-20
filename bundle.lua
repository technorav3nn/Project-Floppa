-- Bundled by luabundle {"version":"1.6.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '\"' .. name .. '\"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("__root", function(require, _LOADED, __bundle_register, __bundle_modules)
local DEBUG = true

if not game.IsLoaded then
    game.Loaded:Wait()
end

if game.PlaceId == 7860844204 then
    require("games/LifeSentence/main")
elseif game.PlaceId == 606849621 then
    require("games/Jailbreak/main")
end
end)
__bundle_register("games/Jailbreak/main", function(require, _LOADED, __bundle_register, __bundle_modules)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HumanoidUnloadConsts = require(ReplicatedStorage.HumanoidUnload.HumanoidUnloadConsts);
local WorldUnloadConsts = require(ReplicatedStorage.WorldUnload.WorldUnloadConsts)

HumanoidUnloadConsts.MAX_DIST_TO_LOAD = math.huge
WorldUnloadConsts.MAX_DIST_TO_LOAD = math.huge

local Linoria = require("modules/exploit/ui/LinoriaLib")
local JailbreakUtil = require("games/Jailbreak/JailbreakUtil")

JailbreakUtil:Notify("Loading...", 1)

-- // Simple AC Bypasses
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, index)
    if self == humanoid and tostring(index) == "WalkSpeed" and not checkcaller() then
        return 16
    elseif self == humanoid and tostring(index) == "JumpPower" and not checkcaller() then
        return 50
    end

    return oldIndex(self, index)
end)

-- // End Simple AC Bypasses

-- // Cache these managers in getgenv() to reduce load time
local CacheManager = getgenv().JailbreakCacheManager ~= nil and getgenv().JailbreakCacheManager or require("games/Jailbreak/managers/CacheManager")
local KeysManager =  getgenv().JailbreakKeysManager ~= nil and getgenv().JailbreakKeysManager or require("games/Jailbreak/managers/KeysManager")

if not getgenv().JailbreakCacheManager then
    getgenv().JailbreakCacheManager = require("games/Jailbreak/managers/CacheManager")
end

if not getgenv().JailbreakKeysManager then
    getgenv().JailbreakKeysManager = require("games/Jailbreak/managers/KeysManager")
end

getgenv().usingLargerUI = true

local Library, Window = Linoria:createLinoriaLib("jailbreak",  UDim2.fromOffset(600, 650))

local Tabs = {
    Player = Window:AddTab("Player"),
    Combat = Window:AddTab("Combat"),
    Visuals = Window:AddTab("Visuals"),
    Vehicle = Window:AddTab("Vehicle"),
    Farming = Window:AddTab("Farming"),
    Teleports = Window:AddTab("Teleports"),
    Misc = Window:AddTab("Misc"),
}

require("games/Jailbreak/ui/PlayerTab")(Tabs.Player, Library, Window)
require("games/Jailbreak/ui/VisualsTab")(Tabs.Visuals, Library, Window)
require("games/Jailbreak/ui/FarmingTab")(Tabs.Farming, Library, Window)
require("games/Jailbreak/ui/CombatTab")(Tabs.Combat, Library, Window)
require("games/Jailbreak/ui/TeleportsTab")(Tabs.Teleports, Library, Window)

local SettingsTab = Linoria:initManagers(Library, Window)

local CreditsGroupbox = SettingsTab:AddLeftGroupbox("Credits")
do
    CreditsGroupbox:AddLabel("Introvert1337 - Teleporting & Hashes")
    CreditsGroupbox:AddButton("Copy Teleport Module Link", function()
        setclipboard("https://github.com/Introvert1337/RobloxReleases/blob/main/Scripts/Jailbreak/Teleporation.lua")
    end)
end

local gui = game:GetService("CoreGui"):FindFirstChild("ScreenGui")

JailbreakUtil:Notify("Project Floppa has loaded!", 3)

getgenv().usingLargerUI = false
end)
__bundle_register("games/Jailbreak/ui/TeleportsTab", function(require, _LOADED, __bundle_register, __bundle_modules)
local Teleporter = require("modules/exploit/Teleporter")
local teleport = require("games/Jailbreak/TeleportBypass")

local RobberyTeleporter = Teleporter.new({
    Teleports = {
        ["Jewelry In"] = CFrame.new(133, 17, 1316),
        ["Jewelry Out"] = CFrame.new(156, 18, 1353),
        ["Bank In"] = CFrame.new(24, 19, 853),
        ["Bank Out"] = CFrame.new(11, 17, 788),
        ["Museum In"] = CFrame.new(1071, 102, 1191),
        ["Museum Out"] = CFrame.new(1103, 138, 1246),
        ["Power Plant"] = CFrame.new(691, 37, 2362),
        ["Cargo Plane Spawn"] = CFrame.new(-1227, 64, 2787),
        ["Gas Station"] = CFrame.new(-1596, 18, 710),
        ["Donut Store"] = CFrame.new(270.763885, 18.4229183, -1762.90149),
        ["Casino"] = CFrame.new(-227.88002014160156, 22.14699363708496, -4659.5556640625)
    },
    TeleportFn = teleport
})

local LocationTeleporter = Teleporter.new({
    Teleports = {
        ["Airport"] = CFrame.new(0, 0, 0),
        Prison = CFrame.new(0, 0, 0),
        ["Police HQ"] = CFrame.new(0, 0, 0),
        ["City Police Station"] = CFrame.new(0, 0, 0),
        ["Prison Police Station"] = CFrame.new(0, 0, 0),
        ["Military Base"] = CFrame.new(846.1241455078125, 19.318744659423828, -3621.896240234375),
        ["Cargo Port"] = CFrame.new(0, 0, 0),
        ["Crater City" ]= CFrame.new(-530.5619506835938, 19.598960876464844, -5669.6943359375),
        ["Fire Station"] = CFrame.new(0, 0, 0),
        ["Trade Port"] = CFrame.new(2386.97314453125, 24.2812442779541, -3881.135009765625),
        ["Jetpack Spawn"] = CFrame.new(-643.7464599609375, 220.8810577392578, -6010.41357421875),
        ["Crater City Airport"] = CFrame.new(-738.9046020507812, 22.281513214111328, -4917.40185546875),
        ["Crater City Gunshop"] = CFrame.new(-530.5619506835938, 19.598960876464844, -5669.6943359375)
    },
    TeleportFn = teleport
})

local vehicleTps = {}

local VehicleTeleporter = Teleporter.new({
    Teleports = vehicleTps,
    TeleportFn = teleport
})

local RobberyTeleportKeys = RobberyTeleporter:GetTeleportKeys()
local LocationTeleportKeys = LocationTeleporter:GetTeleportKeys()
local VehicleTeleportKeys = VehicleTeleporter:GetTeleportKeys()

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.4)
    RobberyTeleporter.TeleportFn = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))()
    LocationTeleporter.TeleportFn = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))()
    VehicleTeleporter.TeleportFn = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))()
end)

local function farmingTab(PlayerTab)
    local LocationTeleportsGroupBox = PlayerTab:AddLeftGroupbox("Location Teleports")
    do
        LocationTeleportsGroupBox:AddDropdown("LocationTeleportSelected", {
            Values = LocationTeleportKeys,
            Text = "Location Teleport",
            Default = LocationTeleportKeys[1],
            Compact = true
        })
        LocationTeleportsGroupBox:AddButton("Teleport to Location", function()
            LocationTeleporter:TeleportTo(Options.LocationTeleportSelected.Value)
        end)
    end

    local RobberyTeleportsGroupBox = PlayerTab:AddRightGroupbox("Robbery Teleports")
    do
        RobberyTeleportsGroupBox:AddDropdown("RobberyTeleportSelected", {
            Values = RobberyTeleportKeys,
            Text = "Robbery Teleport",
            Default = RobberyTeleportKeys[1],
            Compact = true
        })
        RobberyTeleportsGroupBox:AddButton("Teleport to Robbery", function()
            RobberyTeleporter:TeleportTo(Options.RobberyTeleportSelected.Value)
        end)
    end
    
    local VehicleTeleportsGroupBox = PlayerTab:AddLeftGroupbox("Vehicle Teleports")
    do
        VehicleTeleportsGroupBox:AddDropdown("VehicleTeleportSelected", {
            Values = VehicleTeleportKeys,
            Text = "Vehicle Teleport",
            Default = VehicleTeleportKeys[1],
            Compact = true
        })
        VehicleTeleportsGroupBox:AddButton("Teleport to Vehicle", function()
            VehicleTeleporter:TeleportTo(Options.VehicleTeleportSelected.Value)
        end)
    end
end

return farmingTab
end)
__bundle_register("games/Jailbreak/TeleportBypass", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // huge credits to Introvert1337

return loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))()
end)
__bundle_register("modules/exploit/Teleporter", function(require, _LOADED, __bundle_register, __bundle_modules)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local Teleporter = {}
Teleporter.__index = Teleporter

-- // teleport example:
--[[
    local Teleports = {
        Bank = CFrame.new(244, 543, 231)
        Jewel = CFrame.new(0, 0, 0)
    }

    local Teleporter = TeleportModule.new({
        Teleports = Teleports,
        TeleportFn = myCustomTeleportFunction
    })

    Teleporter:TeleportTo("Bank")
]]

function Teleporter.new(teleporterOptions)
    assert(teleporterOptions.Teleports ~= nil, "must have Teleports in teleporterOptions!")

    local self = setmetatable({}, Teleporter)

    self.Teleports = teleporterOptions.Teleports
    self.TeleportFn = teleporterOptions.TeleportFn or function (teleportName)
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        character:FindFirstChild("HumanoidRootPart").CFrame = self.teleports[teleportName]

        if not success and error then
            return error(error)
        end
    end

    return self
end

function Teleporter:GetTeleportKeys()
    local keys = {}

    for k, _ in pairs(self.Teleports) do
        table.insert(keys, k)
    end

    return keys
end

function Teleporter:TeleportTo(teleportName)
    assert(self.Teleports[teleportName] ~= nil, "teleportName doesnt exist in Teleports!")
    assert(typeof(self.Teleports[teleportName]) == "CFrame", "self.Teleports[teleportName] (" .. teleportName .. ") must be a CFrame value!")

    local teleportFunction = self.TeleportFn
    local success, err = pcall(teleportFunction, self.Teleports[teleportName])

    if not success then
        warn(err)
    end

    return success
end

return Teleporter
end)
__bundle_register("games/Jailbreak/ui/CombatTab", function(require, _LOADED, __bundle_register, __bundle_modules)
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
end)
__bundle_register("modules/util/TableUtil", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = {}

function TableUtil:map(tbl, fn, ...)
    local t = {}
    for _, element in ipairs(tbl) do
        local _, result = pcall(fn, element, ...)
        table.insert(t, result)
    end
    return t
end

-- // http://lua-users.org/wiki/CopyTable
function TableUtil:deepCopy(orig)
    local origType = type(orig)
    local copy
    if origType == 'table' then
        copy = {}
        for origKey, origValue in next, orig, nil do
            copy[self:deepCopy(origKey)] = self:deepCopy(origValue)
        end
        setmetatable(copy, self:deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

return TableUtil
end)
__bundle_register("games/Jailbreak/ui/FarmingTab", function(require, _LOADED, __bundle_register, __bundle_modules)
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
end)
__bundle_register("games/Jailbreak/managers/ContractManager/ContractManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = require("games/Jailbreak/managers/ModuleManager")
local ContractSystem = Modules.ContractSystem

-- // ContractManager
local ContractManager = {}

ContractManager.__index = ContractManager

function ContractManager.new()
    local self = setmetatable({}, ContractManager)
    return self
end

function ContractManager:GetActiveContracts()
    return ContractSystem.getContracts()
end

return ContractManager
end)
__bundle_register("games/Jailbreak/managers/ModuleManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = ReplicatedStorage.Game
local Contract = Game.Contract

return {
    UI = require(ReplicatedStorage.Module.UI),
    Contract = require(Contract.Contract),
    ContractSystem = require(Contract.ContractSystem),
    GunShopUI = require(Game.GunShop.GunShopUI),
    PlayerUtils = require(Game.PlayerUtils)
}
end)
__bundle_register("modules/exploit/Player", function(require, _LOADED, __bundle_register, __bundle_modules)
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local Player = {}

function Player:GetLocalPlayer()
    return localPlayer
end

function Player:GetChar()
    return localPlayer.Character
end

return Player
end)
__bundle_register("games/Jailbreak/ui/VisualsTab", function(require, _LOADED, __bundle_register, __bundle_modules)
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
            IsEnabled = "AirdropESP"
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
end)
__bundle_register("modules/util/Util", function(require, _LOADED, __bundle_register, __bundle_modules)
local Util = {}

function Util:getBuildId()
    -- // TODO: Add a .toml parser to get the Build Id from build-info.toml
    return "a48bf992ns92b"
end

-- // I use this to fix the ESP lib on Script-Ware M
function Util:isScriptWareM()
    local identifyexec = type(identifyexecutor) == "function" and identifyexecutor or nil
    if identifyexec then
        local sw, swVersion = identifyexec()
        return swVersion == "Mac"
    else
        return false
    end
end

return Util
end)
__bundle_register("modules/exploit/ui/LinoriaLib", function(require, _LOADED, __bundle_register, __bundle_modules)
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet('https://gist.githubusercontent.com/technorav3nn/461bc96a7cf4c1acf12794f5850f21cc/raw/7f0858a86daf5ec357932a609641bb0ea93829f7/linoria-work-swm.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Util = require("modules/util/Util")
local ChamsLibrary = require("modules/exploit/visuals/Chams")

local Chams = ChamsLibrary.new({
    Enabled = false,
    UseTeamColor = false,
    Color = Color3.new(0.035294, 0.309803, 1)
})

local Linoria = {}

function Linoria:createLinoriaLib(gameName, size)
    Library:SetWatermarkVisibility(true)
    Library:SetWatermark('project floppa - ' .. gameName)

    local Window = Library:CreateWindow({
        Size = size,
        Title = "project floppa - build " .. Util:getBuildId(),
        Center = true,
        AutoShow = true,
    })

    return Library, Window
end

function Linoria:initManagers(Lib, Window)
    ThemeManager.BuiltInThemes.Default[2].AccentColor = Color3.fromRGB(255, 65, 65):ToHex()

    local Settings = Window:AddTab("Settings")

    ThemeManager:SetLibrary(Lib)

    SaveManager:SetLibrary(Lib)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

    ThemeManager:SetFolder('project-floppa')

    SaveManager:SetFolder('project-floppa/game')
    SaveManager:BuildConfigSection(Settings)

    ThemeManager:ApplyToTab(Settings)

    return Settings
end

function Linoria:buildChamsGroupBox(ChamsGroupBox)
    ChamsGroupBox:AddToggle('ChamsEnabled', { Text = "Enabled" })
    :OnChanged(function()
        Chams:Toggle(Toggles.ChamsEnabled.Value)
    end)

    ChamsGroupBox:AddDivider()

    ChamsGroupBox:AddSlider('ChamsFillTransparency', {
        Text = "Fill Transparency",
        Rounding = 1,
        Default = 0.5,
        Min = 0,
        Max = 1,
    })
    :OnChanged(function()
        Chams.FillTransparency = Options.ChamsFillTransparency.Value
    end)

    ChamsGroupBox:AddSlider('ChamsOutlineTransparency', {
        Text = "Outline Transparency",
        Rounding = 1,
        Default = 0.5,
        Min = 0,
        Max = 1,
    })
    :OnChanged(function()
        Chams.OutlineTransparency = Options.ChamsOutlineTransparency.Value
    end)

    ChamsGroupBox:AddDivider()


    ChamsGroupBox:AddLabel('Fill Color'):AddColorPicker('ChamsFillColor', {
        Default = Chams.Color,
        Title = 'Fill Color',
    })

    Options.ChamsFillColor:OnChanged(function()
        Chams.Color = Options.ChamsFillColor.Value
    end)

    ChamsGroupBox:AddToggle("ChamsRainbowColor", { Text = "Rainbow Color" })

    task.spawn(function()
        local i = 1
        while task.wait() do
            if Toggles.ChamsRainbowColor and Toggles.ChamsRainbowColor.Value then
                i = i + 1
                local col = Color3.fromHSV(i/360, 1, 1)
                if i == 360 then
                    i = 1
                end
                print(col)
                Options.ChamsFillColor:SetValueRGB(col)
            end
        end
    end)
end

function Linoria:buildESPBoxes(ESPTabBox)
    local ESP = require("modules/exploit/visuals/ESP")

    local ESPTab = ESPTabBox:AddLeftGroupbox("ESP")
    local ESPOptionsTab = ESPTabBox:AddRightGroupbox("ESP Options")

    ESPTab:AddToggle("ESPEnabled", { Text = "Enabled "}):OnChanged(function() ESP:Toggle(Toggles.ESPEnabled.Value) end)
    ESPTab:AddToggle("PlayerESPEnabled", { Text = "Show Players" }):OnChanged(function() ESP.Players = Toggles.PlayerESPEnabled.Value end)
    
    ESPOptionsTab:AddToggle("UseTeamColor", { Text = "Use Team Color", Default = true }):OnChanged(function() ESP.TeamColor = Toggles.UseTeamColor.Value end)
    ESPOptionsTab:AddToggle("ShowNames", { Text = "Show Names", Default = true }):OnChanged(function() ESP.Names = Toggles.ShowNames.Value end)
    ESPOptionsTab:AddToggle("ShowBoxes", { Text = "Show Boxes", Default = true }):OnChanged(function() ESP.Boxes = Toggles.ShowBoxes.Value end)
    ESPOptionsTab:AddToggle("ShowTracers", { Text = "Show Tracers" }):OnChanged(function() ESP.Tracers = Toggles.ShowTracers.Value end)
    ESPOptionsTab:AddToggle("ShowEquippedItem", { Text = "Show Equipped Item" }):OnChanged(function() ESP.Equipped = Toggles.ShowEquippedItem.Value end)
    ESPOptionsTab:AddToggle("ShowHealth", { Text = "Show Health Bars", Default = false }):OnChanged(function() ESP.HealthBar = Toggles.ShowHealth.Value end)
    ESPOptionsTab:AddToggle("ShowDistance", { Text = "Show Distance", Default = true }):OnChanged(function() ESP.Distance = Toggles.ShowDistance.Value end)

    ESPOptionsTab:AddSlider("MaxShownDistance", {
        Min = 200,
        Max = 10000,
        Default = 2000,
        Text = "Max Shown Distance",
        Compact = true,
        Rounding = 0
    }):OnChanged(function() ESP.MaxShownDistance = Options.MaxShownDistance.Value end)

    return ESPTab, ESPOptionsTab, ESP
end

return Linoria
end)
__bundle_register("modules/exploit/visuals/ESP", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // edited by me
local isSWM = require("modules/util/Util"):isScriptWareM()

--Settings--
local ESP = {
    Enabled = false,
    Boxes = true,
    BoxShift = CFrame.new(0,-1.5,0),
	BoxSize = Vector3.new(4,6,0),
    Color = Color3.fromRGB(255, 170, 0),
    FaceCamera = false,
    Names = true,
    TeamColor = true,
    Thickness = 2,
    AttachShift = 1,
    TeamMates = true,
    Players = true,
    
    Objects = setmetatable({}, {__mode="kv"}),
    Overrides = {}
}

--Declarations--
local cam = workspace.CurrentCamera
local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()

local V3new = Vector3.new
local WorldToViewportPoint = cam.WorldToViewportPoint

--Functions--
local function Draw(obj, props)
	local new = Drawing.new(obj)
	
	props = props or {}
	for i,v in pairs(props) do
		new[i] = v
	end
	return new
end

function ESP:GetTeam(p)
	local ov = self.Overrides.GetTeam
	if ov then
		return ov(p)
	end
	
	return p and p.Team
end

function ESP:IsTeamMate(p)
    local ov = self.Overrides.IsTeamMate
	if ov then
		return ov(p)
    end
    
    return self:GetTeam(p) == self:GetTeam(plr)
end

function ESP:GetColor(obj)
	local ov = self.Overrides.GetColor
	if ov then
		return ov(obj)
    end
    local p = self:GetPlrFromChar(obj)
	return p and self.TeamColor and p.Team and p.Team.TeamColor.Color or self.Color
end

function ESP:GetPlrFromChar(char)
	local ov = self.Overrides.GetPlrFromChar
	if ov then
		return ov(char)
	end
	
	return plrs:GetPlayerFromCharacter(char)
end

function ESP:Toggle(bool)
    self.Enabled = bool
    if not bool then
        for i,v in pairs(self.Objects) do
            if v.Type == "Box" then --fov circle etc
                if v.Temporary then
                    v:Remove()
                else
                    for i,v in pairs(v.Components) do
                        v.Visible = false
                    end
                end
            end
        end
    end
end

function ESP:GetBox(obj)
    return self.Objects[obj]
end

function ESP:AddObjectListener(parent, options)
    local function NewListener(c)
        if type(options.Type) == "string" and c:IsA(options.Type) or options.Type == nil then
            if type(options.Name) == "string" and c.Name == options.Name or options.Name == nil then
                if not options.Validator or options.Validator(c) then
                    local box = ESP:Add(c, {
                        PrimaryPart = type(options.PrimaryPart) == "string" and c:WaitForChild(options.PrimaryPart) or type(options.PrimaryPart) == "function" and options.PrimaryPart(c),
                        Color = type(options.Color) == "function" and options.Color(c) or options.Color,
                        ColorDynamic = options.ColorDynamic,
                        Name = type(options.CustomName) == "function" and options.CustomName(c) or options.CustomName,
                        IsEnabled = options.IsEnabled,
                        RenderInNil = options.RenderInNil
                    })
                    --TODO: add a better way of passing options
                    if options.OnAdded then
                        coroutine.wrap(options.OnAdded)(box)
                    end
                end
            end
        end
    end

    if options.Recursive then
        parent.DescendantAdded:Connect(NewListener)
        for i,v in pairs(parent:GetDescendants()) do
            coroutine.wrap(NewListener)(v)
        end
    else
        parent.ChildAdded:Connect(NewListener)
        for i,v in pairs(parent:GetChildren()) do
            coroutine.wrap(NewListener)(v)
        end
    end
end

local boxBase = {}
boxBase.__index = boxBase

function boxBase:Remove()
    ESP.Objects[self.Object] = nil
    for i,v in pairs(self.Components) do
        v.Visible = false
        v:Remove()
        self.Components[i] = nil
    end
end

function boxBase:Update()
    if not self.PrimaryPart then
        --warn("not supposed to print", self.Object)
        return self:Remove()
    end

    local color
    if ESP.Highlighted == self.Object then
       color = ESP.HighlightColor
    else
        color = self.Color or self.ColorDynamic and self:ColorDynamic() or ESP:GetColor(self.Object) or ESP.Color
    end

    local allow = true
    if ESP.Overrides.UpdateAllow and not ESP.Overrides.UpdateAllow(self) then
        allow = false
    end
    if self.Player and not ESP.TeamMates and ESP:IsTeamMate(self.Player) then
        allow = false
    end
    if self.Player and not ESP.Players then
        allow = false
    end
    if self.IsEnabled and (type(self.IsEnabled) == "string" and not ESP[self.IsEnabled] or type(self.IsEnabled) == "function" and not self:IsEnabled()) then
        allow = false
    end
    if not workspace:IsAncestorOf(self.PrimaryPart) and not self.RenderInNil then
        allow = false
    end

    if not allow then
        for i,v in pairs(self.Components) do
            v.Visible = false
        end
        return
    end

    if ESP.Highlighted == self.Object then
        color = ESP.HighlightColor
    end

    --calculations--
    local cf = self.PrimaryPart.CFrame
    if ESP.FaceCamera then
        cf = CFrame.new(cf.p, cam.CFrame.p)
    end
    local size = self.Size
    local locs = {
        TopLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,size.Y/2,0),
        TopRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,size.Y/2,0),
        BottomLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,-size.Y/2,0),
        BottomRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,-size.Y/2,0),
        TagPos = cf * ESP.BoxShift * CFrame.new(0,size.Y/2,0),
        Torso = cf * ESP.BoxShift
    }
    if not isSWM then
        if ESP.Boxes then
            local TopLeft, Vis1 = WorldToViewportPoint(cam, locs.TopLeft.p)
            local TopRight, Vis2 = WorldToViewportPoint(cam, locs.TopRight.p)
            local BottomLeft, Vis3 = WorldToViewportPoint(cam, locs.BottomLeft.p)
            local BottomRight, Vis4 = WorldToViewportPoint(cam, locs.BottomRight.p)

            if self.Components.Quad then
                if Vis1 or Vis2 or Vis3 or Vis4 then
                    self.Components.Quad.Visible = true
                    self.Components.Quad.PointA = Vector2.new(TopRight.X, TopRight.Y)
                    self.Components.Quad.PointB = Vector2.new(TopLeft.X, TopLeft.Y)
                    self.Components.Quad.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y)
                    self.Components.Quad.PointD = Vector2.new(BottomRight.X, BottomRight.Y)
                    self.Components.Quad.Color = color
                else
                    self.Components.Quad.Visible = false
                end
            end
        else
            self.Components.Quad.Visible = false
        end
    end

    if ESP.Names then
        local TagPos, Vis5 = WorldToViewportPoint(cam, locs.TagPos.p)
        
        if Vis5 then
            self.Components.Name.Visible = true
            self.Components.Name.Position = Vector2.new(TagPos.X, TagPos.Y)
            self.Components.Name.Text = self.Name
            self.Components.Name.Color = color
            
            self.Components.Distance.Visible = true
            self.Components.Distance.Position = Vector2.new(TagPos.X, TagPos.Y + 14)
            self.Components.Distance.Text = math.floor((cam.CFrame.p - cf.p).magnitude) .."m away"
            self.Components.Distance.Color = color
        else
            self.Components.Name.Visible = false
            self.Components.Distance.Visible = false
        end
    else
        self.Components.Name.Visible = false
        self.Components.Distance.Visible = false
    end
    
    if ESP.Tracers then
        local TorsoPos, Vis6 = WorldToViewportPoint(cam, locs.Torso.p)

        if Vis6 then
            self.Components.Tracer.Visible = true
            self.Components.Tracer.From = Vector2.new(TorsoPos.X, TorsoPos.Y)
            self.Components.Tracer.To = Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/ESP.AttachShift)
            self.Components.Tracer.Color = color
        else
            self.Components.Tracer.Visible = false
        end
    else
        self.Components.Tracer.Visible = false
    end
end

function ESP:Add(obj, options)
    if not obj.Parent and not options.RenderInNil then
        task.wait(1)
        return warn(obj, "has no parent")
    end

    local box = setmetatable({
        Name = options.Name or obj.Name,
        Type = "Box",
        Color = options.Color --[[or self:GetColor(obj)]],
        Size = options.Size or self.BoxSize,
        Object = obj,
        Player = options.Player or plrs:GetPlayerFromCharacter(obj),
        PrimaryPart = options.PrimaryPart or obj.ClassName == "Model" and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart") and obj,
        Components = {},
        IsEnabled = options.IsEnabled,
        Temporary = options.Temporary,
        ColorDynamic = options.ColorDynamic,
        RenderInNil = options.RenderInNil
    }, boxBase)

    if self:GetBox(obj) then
        self:GetBox(obj):Remove()
    end
    
    if not isSWM then
        box.Components["Quad"] = Draw("Quad", {
            Thickness = self.Thickness,
            Color = color,
            Transparency = 1,
            Filled = false,
            Visible = self.Enabled and self.Boxes
        })
    end
    

    box.Components["Name"] = Draw("Text", {
		Text = box.Name,
		Color = box.Color,
		Center = true,
		Outline = true,
        Size = 19,
        Visible = self.Enabled and self.Names
	})
	box.Components["Distance"] = Draw("Text", {
		Color = box.Color,
		Center = true,
		Outline = true,
        Size = 19,
        Visible = self.Enabled and self.Names
	})
	
	box.Components["Tracer"] = Draw("Line", {
		Thickness = ESP.Thickness,
		Color = box.Color,
        Transparency = 1,
        Visible = self.Enabled and self.Tracers
    })
    self.Objects[obj] = box
    
    obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)
    obj:GetPropertyChangedSignal("Parent"):Connect(function()
        if obj.Parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)

    local hum = obj:FindFirstChildOfClass("Humanoid")
	if hum then
        hum.Died:Connect(function()
            if ESP.AutoRemove ~= false then
                box:Remove()
            end
		end)
    end

    return box
end

local function CharAdded(char)
    local p = plrs:GetPlayerFromCharacter(char)
    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                ESP:Add(char, {
                    Name = p.Name,
                    Player = p,
                    PrimaryPart = c
                })
            end
        end)
    else
        ESP:Add(char, {
            Name = p.Name,
            Player = p,
            PrimaryPart = char.HumanoidRootPart
        })
    end
end
local function PlayerAdded(p)
    p.CharacterAdded:Connect(CharAdded)
    if p.Character then
        coroutine.wrap(CharAdded)(p.Character)
    end
end
plrs.PlayerAdded:Connect(PlayerAdded)
for i,v in pairs(plrs:GetPlayers()) do
    if v ~= plr then
        PlayerAdded(v)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    cam = workspace.CurrentCamera
    for i,v in (ESP.Enabled and pairs or ipairs)(ESP.Objects) do
        if v.Update then
            local s,e = pcall(v.Update, v)
            if not s then warn("[EU]", e, v.Object:GetFullName()) end
        end
    end
end)

print(isSWM)

print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)


return ESP
end)
__bundle_register("modules/exploit/visuals/Chams", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
    A class to use the Highlight feature as chams
    Some parts taken from wally's script showing the
    highlight feature.
--]]
-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- // Variables
local RenderStepped = RunService.RenderStepped

-- // Chams

local Chams = {}
Chams.__index = Chams

function Chams.new()
    local self = setmetatable({
        Enabled = false,
        UseTeamColor = false,
        Color = Color3.fromRGB(255, 0, 0),
        FillTransparency = 0.5,
        OutlineTransparency = 0.5,
        Objects = {}
    }, Chams)

    self:_init()

    return self
end

function Chams:_init()
    if CoreGui:FindFirstChildOfClass("Folder") then
        pcall(function()
            CoreGui:FindFirstChildOfClass("Folder"):Destroy()
        end)
    end

    local chamsFolder = Instance.new("Folder", CoreGui)
    chamsFolder.Name = "Chams"

    Players.PlayerAdded:Connect(function(player)
        self:_MakeCham(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        local cham = self.Objects[player.Name]
        if cham then
            cham:Destroy()
            self.Objects[player.Name] = nil
        end
    end)

    for _, player in pairs(Players:GetPlayers()) do
        self:_MakeCham(player)
    end

    self.RenderSteppedLoop = RenderStepped:Connect(function()
        local s, err = pcall(function()
            ---@type Highlight
            for _, highlight in pairs(self.Objects) do
                local player = Players:GetPlayerFromCharacter(highlight.Adornee)
                local colorToUse = (self.UseTeamColor and player.Team ~= nil) and player.TeamColor.Color or self.Color

                highlight.Enabled = self.Enabled
                highlight.OutlineColor = colorToUse
                highlight.FillColor = colorToUse
                highlight.FillTransparency = self.FillTransparency
                highlight.OutlineTransparency = self.OutlineTransparency
            end
        end)

        if not s then
            for _ = 1, 5 do
                error(err)
            end
            self.RenderSteppedLoop:Disconnect()
        end
    end)
end

function Chams:_MakeCham(player)
    local s, err = pcall(function()
        local colorToUse = (self.UseTeamColor and player.Team ~= nil) and player.TeamColor.Color or self.Color
        
        local highlight = Instance.new("Highlight", CoreGui.Chams)
        highlight.Name = player.Name
        highlight.Adornee = player.Character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.OutlineColor = colorToUse
        highlight.FillColor = colorToUse
        highlight.FillTransparency = self.FillTransparency
        highlight.OutlineTransparency = self.OutlineTransparency

        self.Objects[player.Name] = highlight

        player.CharacterAdded:Connect(function()
            highlight.Adornee = player.Character
        end)

        player.CharacterRemoving:Connect(function()
            highlight.Adornee = nil
        end)
    end)

    if not s then
        for _ = 1, 5 do
            error(err)
        end
        self.RenderSteppedLoop:Disconnect()
    end
end

function Chams:Toggle(state)
    assert(type(state) == "boolean", "state of chams must be boolean!")
    self.Enabled = state
end

return Chams
end)
__bundle_register("games/Jailbreak/ui/PlayerTab", function(require, _LOADED, __bundle_register, __bundle_modules)
local Player = require("modules/exploit/Player")
local Modules = require("games/Jailbreak/managers/ModuleManager")
local Maid = require("modules/util/Maid")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local flyingMaid = Maid.new()

local localPlayer = Player:GetLocalPlayer() ---@type Player
local character = Player:GetChar() ---@type Model
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 3) ---@type Humanoid

local PlayerUtils = Modules.PlayerUtils
local CircleSpecs = Modules.UI.CircleAction.Specs

local oldSpecs = {}

for _, v in pairs(CircleSpecs) do
    if not oldSpecs[v] then
        oldSpecs[v] = v
    end
end

local oldPointInTag = PlayerUtils.isPointInTag;
PlayerUtils.isPointInTag = function(point, tag)
    if tag == "NoRagdoll" then
        return Toggles.AntiRagdoll.Value;
    end

    if tag == "NoFallDamage" then
        return Toggles.AntiFallDamage.Value
    end

    if tag == "NoParachute" then
        return Toggles.AntiSkydive.Value
    end

    return oldPointInTag(point, tag);
end

local function flyingOnRenderStepped()
    pcall(function()
        local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera

        if root and not humanoid.PlatformStand and not humanoid.Sit then
            local flyingVector = Vector3.new()

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                flyingVector = flyingVector + camera.CFrame.LookVector
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                flyingVector = flyingVector - camera.CFrame.RightVector
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                flyingVector = flyingVector - camera.CFrame.LookVector
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                flyingVector = flyingVector + camera.CFrame.RightVector
            end

            flyingVector = flyingVector == Vector3.new() and Vector3.new(0, 9e-10, 0) or flyingVector

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) and not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            flyingVector = flyingVector + Vector3.new(0, 1, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyingVector = flyingVector + Vector3.new(0, -1, 0)
            end

            root.Velocity = flyingVector.Unit * (Options.FlySpeedAmount.Value) or 100
            root.Anchored = flyingVector == Vector3.new(0, 9e-10, 0)
        end
    end)
end

local function playerTab(PlayerTab, Library)
    local MovementGroupBox = PlayerTab:AddLeftGroupbox("Movement")
    do
        MovementGroupBox:AddToggle("WalkSpeedToggle", { Text = "WalkSpeed" })
        MovementGroupBox:AddSlider("WalkSpeedAmount", { Text = "WalkSpeed Amount", Rounding = 0, Min = 16, Max = 200, Default = 60 })
        MovementGroupBox:AddToggle("JumpPowerToggle", { Text = "JumpPower" })
        MovementGroupBox:AddSlider("JumpPowerAmount", { Text = "JumpPower Amount", Rounding = 0, Min = 50, Max = 300, Default = 100 })
        MovementGroupBox:AddToggle("FlyToggle", { Text = "Fly" })
        MovementGroupBox:AddSlider("FlySpeedAmount", { Text = "Fly Speed Amount", Rounding = 0, Min = 25, Max = 300, Default = 125 })
    end

    local CharacterGroupBox = PlayerTab:AddRightGroupbox("Character")
    do
        CharacterGroupBox:AddToggle("AntiRagdoll", { Text = "Anti Ragdoll" })
        CharacterGroupBox:AddToggle("AntiFallDamage", { Text = "Anti Fall Damage" })
        CharacterGroupBox:AddToggle("AntiSkydive", { Text = "Anti Skydive" })
        CharacterGroupBox:AddToggle("NoPunchCooldown", { Text = "No Punch Cooldown" })
        CharacterGroupBox:AddToggle("SpoofKeycardDoors", { Text = "Spoof Keycard Doors", Tooltip = "Keycard Doors will open for you without a keycard with this on" })
        CharacterGroupBox:AddToggle("NoPromptWait", { Text = "No Prompt Duration", Tooltip = "Hold E Prompts will be instant when this is on" })
    end

    -- // Non UI Stuff // --

    -- // Character Stuff
    Toggles.NoPromptWait:OnChanged(function()
        local state = Toggles.NoPromptWait.Value
        if state then
            for _, v in pairs(CircleSpecs) do
                if not oldSpecs[v] then
                    oldSpecs[v] = v
                end
                v.Duration = 0
            end
        else
            for _, v in pairs(CircleSpecs) do
                v.Duration = oldSpecs[v].Duration or 0
            end
        end
    end)

    Toggles.SpoofKeycardDoors:OnChanged(function()
        local teamValue = game:GetService("Players").LocalPlayer:FindFirstChild("TeamValue")
        if teamValue and (teamValue == "Prisoner" or teamValue == "Criminal") then
            teamValue.Value = "Police"
        end
    end)

    Toggles.NoPunchCooldown:OnChanged(function()
        local script = localPlayer.PlayerScripts:FindFirstChild("LocalScript")

        if Toggles.NoPunchCooldown.Value then
            if not script then
                Library:Notify("Couldn't find the LocalScript")
            end
            getsenv(script).tick = function() return 0/0 end
        else
            getsenv(script).tick = tick
        end
    end)


    -- // Walkspeed + JumpPower
    humanoid.UseJumpPower = true

    Toggles.FlyToggle:OnChanged(function()
        if Toggles.FlyToggle.Value then
            flyingMaid:GiveTask(RunService.RenderStepped:Connect(flyingOnRenderStepped))
        else
            flyingMaid:DoCleaning()
        end
    end)

    Toggles.JumpPowerToggle:OnChanged(function()
        pcall(function()
            if Toggles.JumpPowerToggle.Value and humanoid then
                humanoid.JumpPower = Options.JumpPowerAmount.Value
            else
                if humanoid then
                    humanoid.JumpPower = 16
                end
            end
        end)
    end)

    Options.JumpPowerAmount:OnChanged(function()
        pcall(function()
            if Toggles.JumpPowerToggle.Value and humanoid then
                humanoid.JumpPower = Options.WalkSpeedAmount.Value
            end
        end)
    end)

    Toggles.WalkSpeedToggle:OnChanged(function()
        pcall(function()
            if Toggles.WalkSpeedToggle.Value and humanoid then
                humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
            else
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
        end)
    end)

    Options.WalkSpeedAmount:OnChanged(function()
        pcall(function()
            if Toggles.WalkSpeedToggle.Value and humanoid  then
                humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
            end
        end)
    end)

    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Toggles.WalkSpeedToggle.Value and humanoid  then
            humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
        end
    end)

    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if Toggles.JumpPowerToggle.Value and humanoid then
            humanoid.JumpPower = Options.JumpPowerAmount.Value
        end
    end)

    localPlayer.CharacterAdded:Connect(function(char)
        if Toggles.JumpPowerToggle.Value then
            humanoid.JumpPower = Options.JumpPowerAmount.Value
        end

        if Toggles.WalkSpeedToggle.Value then
            humanoid.WalkSpeed = Options.WalkSpeedToggle.Value
        end

        humanoid = char.Humanoid
    end)
end

return playerTab
end)
__bundle_register("modules/util/Maid", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
    Made by Quenty
    Source: https://github.com/Quenty/NevermoreEngine/blob/version2/Modules/Shared/Events/Maid.lua.
--]]

---	Manages the cleaning of events and other things.
-- Useful for encapsulating state and make deconstructors easy
-- @classmod Maid
-- @see Signal

local Maid = {}
Maid.ClassName = "Maid"

--- Returns a new Maid object
-- @constructor Maid.new()
-- @treturn Maid
function Maid.new()
	return setmetatable({
		_tasks = {}
	}, Maid)
end

function Maid.isMaid(value)
	return type(value) == "table" and value.ClassName == "Maid"
end

--- Returns Maid[key] if not part of Maid metatable
-- @return Maid[key] value
function Maid:__index(index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

--- Add a task to clean up. Tasks given to a maid will be cleaned when
--  maid[index] is set to a different value.
-- @usage
-- Maid[key] = (function)         Adds a task to perform
-- Maid[key] = (event connection) Manages an event connection
-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object,
--                                it is destroyed.
function Maid:__newindex(index, newTask)
	if Maid[index] ~= nil then
		error(("'%s' is reserved"):format(tostring(index)), 2)
	end

	local tasks = self._tasks
	local oldTask = tasks[index]

	if oldTask == newTask then
		return
	end

	tasks[index] = newTask

	if oldTask then
		if type(oldTask) == "function" then
			oldTask()
		elseif typeof(oldTask) == "RBXScriptConnection" then
			oldTask:Disconnect()
		elseif oldTask.Destroy then
			oldTask:Destroy()
		end
	end
end

--- Same as indexing, but uses an incremented number as a key.
-- @param task An item to clean
-- @treturn number taskId
function Maid:GiveTask(task)
	if not task then
		error("Task cannot be false or nil", 2)
	end

	local taskId = #self._tasks+1
	self[taskId] = task

	if type(task) == "table" and (not task.Destroy) then
		warn("[Maid.GiveTask] - Gave table task without .Destroy\n\n" .. debug.traceback())
	end

	return taskId
end

function Maid:GivePromise(promise)
	if not promise:IsPending() then
		return promise
	end

	local newPromise = promise.resolved(promise)
	local id = self:GiveTask(newPromise)

	-- Ensure GC
	newPromise:Finally(function()
		self[id] = nil
	end)

	return newPromise
end

--- Cleans up all tasks.
-- @alias Destroy
function Maid:DoCleaning()
	local tasks = self._tasks

	-- Disconnect all events first as we know this is safe
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end

	-- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
	local index, task = next(tasks)
	while task ~= nil do
		tasks[index] = nil
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif task.Destroy then
			task:Destroy()
		end
		index, task = next(tasks)
	end
end

--- Alias for DoCleaning()
-- @function Destroy
Maid.Destroy = Maid.DoCleaning

return Maid
end)
__bundle_register("games/Jailbreak/managers/KeysManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local ModuleManager = require("games/Jailbreak/managers/ModuleManager")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Credits to Introvert1337
local Keys, Network = loadstring(game:HttpGet("https://gist.githubusercontent.com/technorav3nn/9fe09be7c97ed916a1afdccd9150d64e/raw/74ce5f2b7985d8ecbf3ee75163de83630c6069ed/key_fetcher_fixed.lua"))()
local KeysList = debug.getupvalue(debug.getupvalue(Network.FireServer, 1), 3)

local displayList = ModuleManager.GunShopUI.displayList

local KeysManager = {}

-- // Credits to Introvert1337
function KeysManager:FetchKey(fn, keyIdx)
    local constants = debug.getconstants(fn);

    for index, constant in next, constants do
        if KeysList[constant] then -- if the constants already contain the raw key
            return constant;
        elseif type(constant) ~= "string" or constant == "" or #constant > 7 or constant:lower() ~= constant then
            constants[index] = nil; -- remove constants that are 100% not the ones we need to make it a bit faster
        end;
    end;

    local keys = {}

    for key, _ in next, KeysList do
        local prefix_passed = false;
        local key_length = #key;
        local keyNumber = 1

        for _, constant in next, constants do
            local constant_length = #constant;

            if not prefix_passed and key:sub(1, constant_length) == constant then -- check if the key starts with one of the constants
                prefix_passed = constant;
            elseif prefix_passed and constant ~= prefix_passed and key:sub(key_length - (constant_length - 1), key_length) == constant then -- check if the key ends with one of the constants
                table.insert(keys, key)
            end;
        end;
    end;

    return keys[keyIdx]
end

-- // I didnt loop through the keys and add them since it would be hard to tell which keys were in there
KeysManager.Keys = {
    GrabGun = KeysManager:FetchKey(debug.getproto(displayList, 1), 3),
    BuyGunOrAmmo = KeysManager:FetchKey(debug.getproto(displayList, 1), 1),
    Arrest = Keys.Arrest,
    RedeemCode = Keys.RedeemCode
}

KeysManager.Network = Network

return KeysManager
end)
__bundle_register("games/Jailbreak/managers/CacheManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local CacheManager = {}

CacheManager.Functions = {}
CacheManager.Nitrous = {}
CacheManager.Doors = debug.getupvalue(getconnections(game:GetService("CollectionService"):GetInstanceRemovedSignal("Door"))[1].Function, 1)

-- // Look through gc for functions
for _, v in pairs(getgc(true)) do
    if type(v) == "function" and islclosure(v) then
        if getfenv(v).script == localPlayer.PlayerScripts.LocalScript then
            local name = debug.getinfo(v).name
            local constants = debug.getconstants(v)

            if name == "DoorSequence" then
                CacheManager.Functions.OpenDoor = v
            elseif table.find(constants, "FailedPcall") then
                debug.setupvalue(v, 2, true)
            end
        end

        if getfenv(v).script == game:GetService("ReplicatedStorage").Game.NukeControl then
            local constants = debug.getconstants(v)
            for _, v2 in pairs(constants) do
                if v2 == "Nuke" then
                    CacheManager.Functions.LaunchNuke = v
                end
            end
        end

        if (type(v) == 'table' and rawget(v, 'Nitro')) then
            CacheManager.Nitrous = v
        end
    end
end

end)
__bundle_register("games/Jailbreak/JailbreakUtil", function(require, _LOADED, __bundle_register, __bundle_modules)
local Notification = require(game:GetService("ReplicatedStorage").Game.Notification)

local JailbreakUtil = {}

function JailbreakUtil:BypassAC()
    
end

function JailbreakUtil:Notify(message, duration)
    Notification.new(
        {
            Text = message,
            Duration = duration or 5
        }
    )
end

return JailbreakUtil
end)
__bundle_register("games/LifeSentence/main", function(require, _LOADED, __bundle_register, __bundle_modules)
local Linoria = require("modules/exploit/ui/LinoriaLib")
local Maid = require("modules/util/Maid")

local LockerManager = require("games/LifeSentence/LockerManager")
local FarmingManager = require("games/LifeSentence/FarmingManager")
local CraftingManager = require("games/LifeSentence/CraftingManager")
local AutobuyManager = require("games/LifeSentence/AutobuyManager")

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local LocalMain = getsenv(localPlayer:WaitForChild("Backpack").Local.LocalMain)

local Library, Window, settingsTab = Linoria:createLinoriaLib("life sentence")

local lockerItems = LockerManager:GetLockerItems()
local playerItems = LockerManager:GetPlayerItems()
local ItemSignal = LockerManager.ItemSignal

local maids = {
    WalkSpeedMaid = Maid.new()
}

-- // UI
local Tabs = {
    Player = Window:AddTab("Player"),
    Items = Window:AddTab("Items"),
    Farming = Window:AddTab("Farming"),
    Visuals = Window:AddTab("Visuals"),
    Settings = settingsTab
}

-- // Player Tab
do
    local MovementGroupBox = Tabs.Player:AddLeftGroupbox("Movement")
    do
        MovementGroupBox:AddToggle("InfStamina", { Text = "Infinite Stamina "}):OnChanged(function()
            if Toggles.InfStamina.Value then
                debug.setupvalue(LocalMain.AddStamina, 1, math.huge)
            else
                debug.setupvalue(LocalMain.AddStamina, 1, 100)
            end
        end)
        MovementGroupBox:AddToggle("NoJumpCool", { Text = "No Jump Cooldown" }):OnChanged(function()
            if Toggles.NoJumpCool.Value then
                for _, v in pairs(getconnections(game:GetService("UserInputService").JumpRequest)) do
                    v:Disable()
                 end
            else
                for _, v in pairs(getconnections(game:GetService("UserInputService").JumpRequest)) do
                    v:Enable()
                end
            end
        end)

        MovementGroupBox:AddDivider()
        MovementGroupBox:AddToggle("WalkSpeedToggle", { Text = "Walkspeed"}):OnChanged(function()
            if Toggles.WalkSpeedToggle.Value then
                localPlayer.Character.Humanoid.WalkSpeed = Options.WalkSpeed.Value
                maids.WalkSpeedMaid:GiveTask(localPlayer.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    localPlayer.Character.Humanoid.WalkSpeed = Options.WalkSpeed.Value
                end))
            else
                localPlayer.Character.Humanoid.WalkSpeed = 16
                maids.WalkSpeedMaid:DoCleaning()
            end
        end)
        MovementGroupBox:AddSlider("WalkSpeed", { Text = "Walkspeed Amount", Min = 16, Max = 500, Default = 16, Rounding = 0, Compact = true })

        MovementGroupBox:AddToggle("JumpPowerToggle", { Text = "JumpPower"})
        MovementGroupBox:AddSlider("JumpPower", { Text = "JumpPower Amount", Min = 50, Max = 500, Default = 50, Rounding = 0, Compact = true })
    end
end

-- // Items Tab
do
    local LockerTabBox = Tabs.Items:AddLeftTabbox()
    do
        local LockerTakeSubTab = LockerTabBox:AddTab("Locker Take")
        do
            LockerTakeSubTab:AddDropdown('LockerTakeItemSelected', {
                Values = lockerItems,
                Default = lockerItems[1],
                Text = 'Item',
                Tooltip = 'The Item to take from your Locker',
            })

            LockerTakeSubTab:AddButton("Take Item", function() LockerManager:GrabItem(Options.LockerTakeItemSelected.Value) end)
        end

        local LockerStoreTab = LockerTabBox:AddTab("Locker Store")
        do
            LockerStoreTab:AddDropdown('LockerStoreItemSelected', {
                Values = playerItems,
                Default = playerItems[1],
                Multi = false,
                Text = 'Item',
                Tooltip = 'The Item to store to your Locker',
            })
            LockerStoreTab:AddButton("Store Item", function()
                local selected = Options.LockerStoreItemSelected.Value
                local item = localPlayer.Character:FindFirstChild(selected) or localPlayer.Backpack:FindFirstChild(selected)

                LockerManager:StoreItem(item)
            end)
        end
    end

    local ScrapGroupBox = Tabs.Items:AddRightGroupbox("Scrap")
    do
        ScrapGroupBox:AddButton("Grab All Scrap", function() FarmingManager:GetAllScrap() end)
        ScrapGroupBox:AddToggle("AutoScrap", { Text = "Auto Grab All Scrap" })
        :OnChanged(function()
            FarmingManager.AutoScrapEnabled = Toggles.AutoScrap.Value
            FarmingManager:LoopGetAllScrap()
        end)
    end

    local CraftingGroupBox = Tabs.Items:AddLeftGroupbox("Crafting")
    do
        CraftingGroupBox:AddDropdown("CraftingGunToCraft", {Text = "Gun To Craft", Values = CraftingManager.ValidCraftableWeapons, Default = "Glock"})
        CraftingGroupBox:AddButton("Craft Weapon", function() CraftingManager:CraftWeapon(Options.CraftingGunToCraft.Value) end)
    end

    local ResearchGroupBox = Tabs.Items:AddRightGroupbox("Researching")
    do
        ResearchGroupBox:AddDropdown("ResearchGunToResarch", {Text = "Item To Research", Values = CraftingManager.ValidCraftableWeapons, Default = "Glock"})
        ResearchGroupBox:AddButton("Research Item", function() CraftingManager:ResearchWeapon(Options.ResearchGunToResarch.Value) end)
    end

    local AutobuyGroupBox = Tabs.Items:AddLeftGroupbox("Autobuys")
    do
        AutobuyGroupBox:AddDropdown("ItemToBuy", { Text = "Item To Buy", Values = AutobuyManager.Items, Default = "Cola" })
        AutobuyGroupBox:AddButton("Buy Item", function()
            AutobuyManager:BuyItem(Options.ItemToBuy.Value)
        end)
    end
end

-- // Farming Tab
do
    local SafeFarmGroupBox = Tabs.Farming:AddLeftGroupbox("Safe farm")
    do
        SafeFarmGroupBox:AddToggle("SafeFarmEnabled", { Text = "Enabled" }):OnChanged(function()
            FarmingManager.AutoRobEnabled = Toggles.SafeFarmEnabled.Value
            FarmingManager:LoopFarmSafes()
        end)
    end
end

-- // Visuals Tab
do
    do
        local ESPGroupBox, ESPOptionsGroupBox, ESP = Linoria:buildESPBoxes(Tabs.Visuals)

        ESP:AddObjectListener(game:GetService("Workspace").Robbable, {
            ColorDynamic = function()
                return Color3.fromRGB(55, 255, 0)
            end,
            Validator = function(obj)
                return obj.Name == "Safe"
            end,
            PrimaryPart = function(obj)
                return obj:FindFirstChild("Back") or obj:FindFirstChild("Main")
            end,
            IsEnabled = "RobbableESPEnabled",
            Name = "Safe"
        })

        ESP.Overrides.GetTeam = function(player)
            local PlayerStats = game:GetService("ReplicatedStorage").PlayerStats
            local stats = PlayerStats:FindFirstChild(player.Name)
            if not stats then return false end

            local cop = stats:FindFirstChild("Cop")
            if not cop then return false end

            local playerIsCop = cop.Value

            if playerIsCop then
                return true
            else
                return false
            end
        end

        ESP.Overrides.GetColor = function(char)
            local player = ESP:GetPlrFromChar(char)
            if player then
                if not ESP.TeamColor then
                    return ESP.Color
                end
                local team = ESP:GetTeam(player)
                if team then
                    print('isCop')
                    return Color3.fromRGB(0, 128, 255)
                else
                    return Color3.fromRGB(255, 140, 0)
                end
            end
            return nil
        end

        ESPGroupBox:AddToggle("RobbableESPEnabled", { Text = "Show Robbables" }):OnChanged(function() ESP.RobbableESPEnabled = Toggles.RobbableESPEnabled.Value end)
        --ESPTab:AddToggle("ScrapESPEnabled", { Text = "Show Scrap" }):OnChanged(function() ESP.Scrap = Toggles.ScrapESPEnabled.Value end)
    end

    local ChamsGroupBox = Tabs.Visuals:AddRightGroupbox("Chams")
    do
        Linoria:buildChamsGroupBox(ChamsGroupBox)
    end
end


ItemSignal:Connect("StoredLockerItemsUpdate", function(items)
    Options.LockerTakeItemSelected.Values = items
    Options.LockerTakeItemSelected:SetValues()
    Options.LockerTakeItemSelected:SetValue()

    table.foreach(items, print)
end)

ItemSignal:Connect("CharacterItemsUpdate", function(items)
    Options.LockerStoreItemSelected.Values = items
    Options.LockerStoreItemSelected:SetValues()
    Options.LockerStoreItemSelected:SetValue()
end)

Linoria:initManagers(Library, Window)

-- // Used to remove the anti-cheat script
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            localPlayer.Backpack.Local.Dead:Destroy()
        end)
    end
end)

end)
__bundle_register("games/LifeSentence/AutobuyManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Character = require("modules/exploit/Character")
local teleport = require("games/LifeSentence/TpBypass")

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local buttons = game:GetService("Workspace").Buttons

local AutobuyManager = {}

AutobuyManager.Items = {}
AutobuyManager.ItemNames = {}
AutobuyManager.Buttons = {}

for _, button in ipairs(buttons:GetChildren()) do
    if button:FindFirstChild("Button") then
        AutobuyManager.Buttons[button.ToolName.Value] = button
    end
end

for itemName, _ in pairs(AutobuyManager.Buttons) do
    table.insert(AutobuyManager.Items, itemName)
end

function AutobuyManager:BuyItem(name)
    local button = AutobuyManager.Buttons[name]
    if button ~= nil then
        local prompt = button.Button:FindFirstChildWhichIsA("ProximityPrompt")
        local oldCFrame = Character:GetCFrame()

        -- // Makes it so that we can use it without our camera seeing it
        prompt.RequiresLineOfSight = false

        teleport(prompt.Parent.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.3)
        fireproximityprompt(prompt, math.huge)
        task.wait()
        teleport(oldCFrame)

        -- // Sometimes the character trips so i added this
        localPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    else
        error("couldn't find button with tool name: " .. name)
    end
end

return AutobuyManager
end)
__bundle_register("games/LifeSentence/TpBypass", function(require, _LOADED, __bundle_register, __bundle_modules)
local localPlayer = game:GetService("Players").LocalPlayer

local function teleport(cframe)
    localPlayer.Character.HumanoidRootPart:PivotTo(cframe)
end

return teleport
end)
__bundle_register("modules/exploit/Character", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // Services
local Players = game:GetService("Players")

-- // Character
local Character = {}

function Character:GetCFrame()
    return Players.LocalPlayer.Character.HumanoidRootPart.CFrame
end

function Character:GetPosition()
    return Players.LocalPlayer.Character.HumanoidRootPart.Position
end

return Character
end)
__bundle_register("games/LifeSentence/CraftingManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Character = require("modules/exploit/Character")
local Compatiblity = require("modules/exploit/Compatiblity")
local teleport = require("games/LifeSentence/TpBypass")

local GunConfigs = require(game:GetService("ReplicatedStorage").GunConfigs)

local CraftingManager = {}

CraftingManager.ValidCraftableWeapons = {}
CraftingManager.ResearchWeapons = {
    MetalVest = "1",
    Spaz = "2",
    AR = "3",
    Tec9 = "4",
    Garand = "5",
    LMG = "6",
    RPG = "7"
}

for k, _ in pairs(GunConfigs) do
    table.insert(CraftingManager.ValidCraftableWeapons, k)
end

function CraftingManager:CraftWeapon(weapon)
    local oldCf = Character:GetCFrame()
    teleport(CFrame.new(186, 7, -113))
    task.wait(0.3)

    Compatiblity:fireproximityprompt(game:GetService("Workspace").WorkBench.MainPart.Attachment.ProximityPrompt)

    task.wait(0.3)
    game:GetService("ReplicatedStorage").Events.LearnCraftEvent:FireServer(
        weapon .. "Frame"
    )
    task.wait(0.3)

    teleport(oldCf)
end

function CraftingManager:ResearchWeapon(name)
    local itemNumber = CraftingManager.ResearchWeapons[name]
    if itemNumber ~= nil then
        game:GetService("ReplicatedStorage").Events.LearnCraftEvent:FireServer(itemNumber, "Learn")
    else
        error('invalid item: '..name)
    end
end

return CraftingManager
end)
__bundle_register("modules/exploit/Compatiblity", function(require, _LOADED, __bundle_register, __bundle_modules)
local Compatiblity = {}

function Compatiblity:fireproximityprompt(ProximityPrompt, amount, skip)
    -- // Synapses fireproximityprompt is gay asf so we use this lol
    -- // Made by Sowd on v3rm
    if ProximityPrompt.ClassName == "ProximityPrompt" then
        amount = amount or 1
        local PromptTime = ProximityPrompt.HoldDuration
        if skip then
            ProximityPrompt.HoldDuration = 0
        end
        for i = 1, amount do
            ProximityPrompt:InputHoldBegin()
            if not skip then
                task.wait(ProximityPrompt.HoldDuration)
            end
            ProximityPrompt:InputHoldEnd()
        end
        ProximityPrompt.HoldDuration = PromptTime
    else
        error("userdata<ProximityPrompt> expected")
    end
end

return Compatiblity
end)
__bundle_register("games/LifeSentence/FarmingManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Compatiblity = require("modules/exploit/Compatiblity")
local teleport = require("games/LifeSentence/TpBypass")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local FarmingManager = {}

FarmingManager.AutoScrapEnabled = false
FarmingManager.AutoRobEnabled = false

function FarmingManager:GetAllScrap()
    local lootSpawners = game:GetService("Workspace").SpawnsLoot
    for _, loot in ipairs(lootSpawners:GetChildren()) do
        if loot.Part.Attachment.ProximityPrompt.Enabled then
            local prompt = loot.Part.Attachment.ProximityPrompt
            prompt.RequiresLineOfSight = false
            teleport(loot.Part.CFrame)
            task.wait(0.4)
            Compatiblity:fireproximityprompt(prompt)
        end
    end
end

function FarmingManager:LoopGetAllScrap()
    if self.AutoScrapEnabled then
        RunService:BindToRenderStep(
            "ScrapLoop",
            Enum.RenderPriority.Character.Value,
            function()
                if self.AutoScrapEnabled then
                    self:GetAllScrap()
                else
                    RunService:UnbindFromRenderStep("ScrapLoop")
                end
            end
        )
    end
end

function FarmingManager:CollectNearCash()
    for _, v in ipairs(game:GetService("Workspace"):GetChildren()) do
        if v.Name == "DroppedCash" and v:FindFirstChild("ProximityPrompt") and v.ProximityPrompt.Enabled then
            v.ProximityPrompt.RequiresLineOfSight = false
            fireproximityprompt(v.ProximityPrompt)
            task.wait(0.1)
        end
    end
end

function FarmingManager:GetAllSafes()
    local robbables = game:GetService("Workspace").Robbable
    local toReturn = {}

    for _, v in ipairs(robbables:GetChildren()) do
        if v:FindFirstChild("Door") and v.Door.Attachment.ProximityPrompt.Enabled then
            table.insert(toReturn, v)
        end
    end

    return toReturn
end

function FarmingManager:LoopFarmSafes()
    if FarmingManager.AutoRobEnabled then
        repeat
            if not FarmingManager.AutoRobEnabled then
                return
            end
            local robbables = self:GetAllSafes()

            for _, v in ipairs(robbables) do
                if not FarmingManager.AutoRobEnabled then
                    return
                end

                if v.Door.Attachment.ProximityPrompt.Enabled then
                    local camera = workspace.CurrentCamera
                    camera.CFrame = v.Door.CFrame

                    task.wait()

                    if localPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
                        camera.CameraSubject = v.Door
                    end

                    teleport(v.Door.CFrame)

                    task.wait(0.2)
                    Compatiblity:fireproximityprompt(v.Door.Attachment.ProximityPrompt, 1, false)
                    task.wait(0.3)

                    FarmingManager:CollectNearCash()
                    task.wait(0.4)

                    if localPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
                        camera.CameraSubject = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                    end
                end

                if not FarmingManager.AutoRobEnabled then
                    return
                end
            end
            task.wait(3)
        until not FarmingManager.AutoRobEnabled
    end
end

return FarmingManager
end)
__bundle_register("games/LifeSentence/LockerManager", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // Imports
local Signals = require("modules/util/Signals")
local Compatiblity = require("modules/exploit/Compatiblity")
local TableUtil = require("modules/util/TableUtil")
local Character = require("modules/exploit/Character")

local teleport = require("games/LifeSentence/TpBypass")

-- // LockerManager
local LockerManager = {}

-- // Used with dropdowns to refresh them
LockerManager.ItemSignal = Signals.new()

LockerManager.ItemSignal:Add("StoredLockerItemsUpdate")
LockerManager.ItemSignal:Add("CharacterItemsUpdate")

-- // Services
local Players = game:GetService("Players")

-- // Variables
local localPlayer = Players.LocalPlayer
local lockerFolder = game:GetService("ReplicatedStorage").PlayerStats[localPlayer.Name].LockerFolder

-- // Events
lockerFolder.ChildAdded:Connect(function()
    task.wait(0.3)
    local items = LockerManager:GetLockerItems()
    LockerManager.ItemSignal:Fire("StoredLockerItemsUpdate", items)
end)

lockerFolder.ChildRemoved:Connect(function()
    task.wait(0.3)
    local items = LockerManager:GetLockerItems()
    LockerManager.ItemSignal:Fire("StoredLockerItemsUpdate", items)
end)

localPlayer.Character.ChildAdded:Connect(function()
    local items = LockerManager:GetPlayerItems()
    LockerManager.ItemSignal:Fire("CharacterItemsUpdate", items)
end)

localPlayer.Character.ChildRemoved:Connect(function()
    local items = LockerManager:GetPlayerItems()
    LockerManager.ItemSignal:Fire("CharacterItemsUpdate", items)
end)

localPlayer.Backpack.ChildAdded:Connect(function()
    local items = LockerManager:GetPlayerItems()
    LockerManager.ItemSignal:Fire("CharacterItemsUpdate", items)
end)

localPlayer.Backpack.ChildRemoved:Connect(function()
    local items = LockerManager:GetPlayerItems()
    LockerManager.ItemSignal:Fire("CharacterItemsUpdate", items)
end)

-- // LockerManager

function LockerManager:_LockerEvent(action, instance)
    game:GetService("ReplicatedStorage").Events.LockerEvent:FireServer(action, instance)
end

function LockerManager:GetPlayerItems()
    local items = {}

    for _, tool in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if not tool:FindFirstChild("CantStore") then
                table.insert(items, tool.Name)
            end
        end
    end

    for _, v in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") then
            if not v:FindFirstChild("CantStore") then
                table.insert(items, v.Name)
            end
        end
    end

    return items
end

function LockerManager:GetLockerItems()
    task.wait(0.3)
    local items = TableUtil:map(lockerFolder:GetChildren(), function(instance)
        print(instance.ClassName)
        return instance.ToolName.Value
    end)
    return items
end

function LockerManager:GrabItem(item)
    local oldCFrame = Character:GetCFrame()
    local locker = game:GetService("Workspace"):FindFirstChild("Locker")

    localPlayer.Character.HumanoidRootPart.CFrame =
        locker.HumanoidRootPart.CFrame + Vector3.new(0, 0, -3)
    task.wait(0.2)
    Compatiblity:fireproximityprompt(locker.HumanoidRootPart.Attachment.ProximityPrompt, 1, false)

    local itemAsInstance = nil

    for _, v in ipairs(game:GetService("ReplicatedStorage").PlayerStats.yt4r5.LockerFolder:GetChildren()) do
        if v.ToolName.Value == item then
            itemAsInstance = v
        end
    end

    if itemAsInstance == nil then
        return
    end

    self:_LockerEvent("LockerTake", itemAsInstance)
    task.wait(0.2)

    localPlayer.Character.HumanoidRootPart.CFrame = oldCFrame
end

function LockerManager:StoreItem(item)
    local oldCFrame = Character:GetCFrame()
    local locker = game:GetService("Workspace"):FindFirstChild("Locker")

    teleport(locker.HumanoidRootPart.CFrame + Vector3.new(0, 0, -3))

    --localPlayer.Character.HumanoidRootPart.CFrame =
    --    locker.HumanoidRootPart.CFrame + Vector3.new(0, 0, -3)

    task.wait(0.5)
    Compatiblity:fireproximityprompt(locker.HumanoidRootPart.Attachment.ProximityPrompt, 1, false)

    if not localPlayer.Character:FindFirstChild(item.Name) then
        localPlayer.Character.Humanoid:EquipTool(item)
    end

    task.wait(0.5)
    self:_LockerEvent("LockerStore", item)
    task.wait(0.3)
    firesignal(localPlayer.PlayerGui.HUD.LockerFrame.Inventory.ExitButton.MouseButton1Click)
    --localPlayer.Character.Humanoid:MoveTo(Character:GetPosition() + Vector3.new(0, 0, -5))
    --localPlayer.Character.Humanoid.MoveToFinished:Wait()
    task.wait(0.5)
    teleport(oldCFrame)
    task.wait(1)
    teleport(oldCFrame)
end

return LockerManager
end)
__bundle_register("modules/util/Signals", function(require, _LOADED, __bundle_register, __bundle_modules)
return loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Signal/main/Manager.lua"))()
end)
return __bundle_require("__root")