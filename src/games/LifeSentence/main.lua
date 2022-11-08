-- // Imports
local Util = require("modules/util/Util")
local Teleporter = require("modules/util/exploit/Teleporter")
local Linoria = require("modules/ui/LinoriaLib")

-- // Services
local Players = game:GetService("Players")

-- // Manager Imports
local LockerManager = require("games/LifeSentence/LockerManager")

-- // Variables
local Library, Window, settingsTab = Linoria:createLinoriaLib("life sentence")

local lockerItems = LockerManager:GetLockerItems()
local playerItems = LockerManager:GetPlayerItems()

local ItemSignal = LockerManager.ItemSignal

local localPlayer = Players.LocalPlayer

-- // UI
local Tabs = {
    Items = Window:AddTab("Items"),
    Settings = settingsTab
}

local Components = {
    LockerTakeDropdown = nil
}

local LockerTabBox = Tabs.Items:AddLeftTabbox()
do
    local LockerTakeTab = LockerTabBox:AddTab("Locker Take")
    do
        Components.LockerTakeDropdown = LockerTakeTab:AddDropdown('LockerTakeItemSelected', {
            Values = lockerItems,
            Default = lockerItems[1],
            Multi = false,
            Text = 'Item',
            Tooltip = 'The Item to take from your Locker',
        })

        LockerTakeTab:AddButton("Take Item", function()
            LockerManager:GrabItem(Options.LockerTakeItemSelected.Value)
        end)
    end

    local LockerStoreTab = LockerTabBox:AddTab("Locker Store")
    do
        Components.LockerStoreDropdown = LockerStoreTab:AddDropdown('LockerStoreItemSelected', {
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

ItemSignal:Connect("StoredLockerItemsUpdate", function(items)
    Components.LockerTakeDropdown.Values = items
    Components.LockerTakeDropdown:SetValues()
    Components.LockerTakeDropdown:SetValue()

    table.foreach(items, print)
end)

ItemSignal:Connect("CharacterItemsUpdate", function(items)
    Components.LockerStoreDropdown.Values = items
    Components.LockerStoreDropdown:SetValues()
    Components.LockerStoreDropdown:SetValue()
end)

Linoria:initManagers(Library, Window)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            game:GetService("Players").LocalPlayer.Backpack.Local.Dead:Destroy()
        end)
    end
end)

-- // FYI: Options is a getgenv() variable, it does exist.