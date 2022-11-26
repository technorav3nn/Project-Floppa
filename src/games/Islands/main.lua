local LibModule = require("modules/exploit/ui/Vynixius")

local Library, Window = LibModule.createVynixiusLib("Project Floppa", "Islands")

require("games/Islands/ui/farming/main")(Library, Window)

LibModule.initalizeSettingsTab(Window)