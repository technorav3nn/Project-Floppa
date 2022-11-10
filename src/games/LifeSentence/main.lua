local Linoria = require("modules/exploit/ui/LinoriaLib")
local ChamsCreator = require("modules/exploit/visuals/Chams")
local LockerManager = require("games/LifeSentence/LockerManager")

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local Library, Window, settingsTab = Linoria:createLinoriaLib("life sentence")
local Chams = ChamsCreator.new({
    Enabled = false,
    UseTeamColor = false,
    Color = Color3.new(0.035294, 0.309803, 1)
})

local lockerItems = LockerManager:GetLockerItems()
local playerItems = LockerManager:GetPlayerItems()
local ItemSignal = LockerManager.ItemSignal

-- // UI
local Tabs = {
    Player = Window:AddTab("Player"),
    Items = Window:AddTab("Items"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Miscellaneous"),
    Settings = settingsTab
}

-- // Player Tab
do
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
                Multi = false,
                Text = 'Item',
                Tooltip = 'The Item to take from your Locker',
            })

            LockerTakeSubTab:AddButton("Take Item", function()
                LockerManager:GrabItem(Options.LockerTakeItemSelected.Value)
            end)
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
end

-- // Visuals Tab
do
    local ESPGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP")
    do
        ESPGroupBox:AddToggle('ESPEnabled', { Text = "Enabled" })
    end

    local ChamsGroupBox = Tabs.Visuals:AddRightGroupbox("Chams")
    do
        ChamsGroupBox:AddToggle('ChamsEnabled', { Text = "Enabled" })
        :OnChanged(function()
            Chams:Toggle(Toggles.ChamsEnabled.Value)
        end)
        ChamsGroupBox:AddSlider('ChamsFillTransparency', {
            Text = "Fill Transparency",
            Rounding = 1,
            Default = 1,
            Min = 0,
            Max = 1,
        })
        :OnChanged(function()
            Chams.FillTransparency = Options.ChamsFillTransparency.Value
        end)
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

-- // FYI: Options is a getgenv() variable, it does exist.