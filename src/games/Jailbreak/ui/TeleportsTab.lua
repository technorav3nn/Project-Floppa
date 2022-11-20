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