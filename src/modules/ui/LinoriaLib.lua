local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Util = require("modules/util/Util")

-- // returns Library, Window, ThemeManager and SaveManager.
local function createLinoriaLib(gameName)
    Library:SetWatermarkVisibility(true)
    Library:SetWatermark('project floppa - ' .. gameName)

    local Window = Library:CreateWindow({
        -- // Position and Size are also valid options
        -- // but you do not need to define them unless you are changing them :)
        Title = 'project floppa - ' .. gameName .. "- build " .. Util:GetBuildId(),
        Center = true,
        AutoShow = true,
    })

    local Settings = Window:AddTab("Settings")

    return Library, Window, Settings
end

local function initManagers(Lib, tab)
    ThemeManager:SetLibrary(Lib)
    SaveManager:SetLibrary(Lib)

    SaveManager:IgnoreThemeSettings()

    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

    ThemeManager:SetFolder('project-floppa')
    SaveManager:SetFolder('project-floppa/game')

    SaveManager:BuildConfigSection(tab)

    ThemeManager:ApplyToTab(tab)
end

return {
    createLinoriaLib,
    initManagers
}
