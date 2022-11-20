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