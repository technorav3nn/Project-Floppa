local Linoria = require("modules/exploit/ui/LinoriaLib")
local Maid = require("modules/util/Maid")

local LockerManager = require("games/LifeSentence/LockerManager")
local FarmingManager = require("games/LifeSentence/FarmingManager")
local CraftingManager = require("games/LifeSentence/CraftingManager")
local AutobuyManager = require("games/LifeSentence/AutobuyManager")
local AimingManager = require("games/LifeSentence/AimingManager")

local Aiming = AimingManager.Aiming
local AimingSettings = Aiming.Settings

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
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Miscellaneous"),
    Settings = settingsTab
}

-- // Player Tab
do
    local CombatGroupBox = Tabs.Player:AddLeftGroupbox("Combat")
    do
        CombatGroupBox:AddToggle("SilentAim", {Text = "Silent Aim"}):OnChanged(function()
            AimingManager:Toggle(Toggles.SilentAim.Value)
        end)
    end

    local MovementGroupBox = Tabs.Player:AddRightGroupbox("Movement")
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

-- // Visuals Tab
do
    local ESPGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP")
    do
        ESPGroupBox:AddToggle('ESPEnabled', { Text = "Enabled" })
    end

    local ChamsGroupBox = Tabs.Visuals:AddRightGroupbox("Chams")
    Linoria:buildChamsGroupBox(ChamsGroupBox)
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
