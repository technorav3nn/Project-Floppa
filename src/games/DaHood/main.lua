require("games/DaHood/AntiCheatBypass")

local LibModule = require("modules/exploit/ui/VynixiusV2")

local Library, Window = LibModule.createVynixiusLib("Project Floppa", "Da Hood")

require("games/DaHood/ui/Player")(Library, Window)

LibModule.initalizeSettingsTab(Window)
