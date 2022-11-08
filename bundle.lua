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
if game.PlaceId == game.PlaceId then
    require("games/LifeSentence/main")
end
end)
__bundle_register("games/LifeSentence/main", function(require, _LOADED, __bundle_register, __bundle_modules)
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
end)
__bundle_register("modules/ui/LinoriaLib", function(require, _LOADED, __bundle_register, __bundle_modules)
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

end)
__bundle_register("modules/util/Util", function(require, _LOADED, __bundle_register, __bundle_modules)
local Util = {}

function Util:GetBuildId()
    -- // TODO: Add a .toml parser to get the Build Id from build-info.toml
    return "a48bf992ns92b"
end

return Util
end)
__bundle_register("modules/util/exploit/Teleporter", function(require, _LOADED, __bundle_register, __bundle_modules)
local Teleporter = {}

-- { [teleport name] = Cframe.new(cframe) }
function Teleporter.new(teleports)
    local self = setmetatable({
        teleports = teleports
    }, Teleporter)
    return self
end

function Teleporter:TeleportTo(teleportName)
    if self.teleports[teleportName] ~= nil then
        local success, error = pcall(function()
            game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = self.teleports[teleportName]
        end)

        if not success and error then
            return consoleerror(error)
        end
    else
        return consoleerror("Unknown teleport: " ..teleportName.. "!")
    end
end

return Teleporter
end)
return __bundle_require("__root")