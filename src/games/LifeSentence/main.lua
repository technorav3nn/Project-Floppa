local Util = require("modules/util/Util")
local Teleporter = require("modules/util/exploit/Teleporter")
local Linoria = require("modules/ui/LinoriaLib")

local Library, Window, settingsTab = Linoria.createLinoriaLib("life sentence")

local Tabs = {
    Items = Window:AddTab("Items"),
    Settings = settingsTab
}

local GroupBox = Tabs.Test:AddLeftGroupbox('Locker')
do
    GroupBox:AddButton("Print 'hi'")
end

Linoria.initManagers(Library, Tabs.Settings)

-- // print(initThemeAndSaveManagers)
-- // initThemeAndSaveManagers(Library, Tabs.Settings)