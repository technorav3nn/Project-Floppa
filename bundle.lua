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
end)
__bundle_register("games/LifeSentence/LockerManager", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // Imports
local Signals = require("modules/util/Signals")
local Compatiblity = require("modules/util/exploit/Compatiblity")
local TableUtil = require("modules/util/TableUtil")

-- // LockerManager
local LockerManager = {}

-- // Used with dropdowns to refresh them
LockerManager.ItemSignal = Signals.new()

LockerManager.ItemSignal:Add("StoredLockerItemsUpdate")
LockerManager.ItemSignal:Add("CharacterItemsUpdate")

-- // Services
local Players = game:GetService("Players")

-- // Variables
local localPlayer = Players.LocalPlayer
local lockerFolder = game:GetService("ReplicatedStorage").PlayerStats[localPlayer.Name].LockerFolder

-- // Events
lockerFolder.ChildAdded:Connect(function()
    task.wait(0.3)
    local items = TableUtil:map(lockerFolder:GetChildren(), function(instance)
        print(instance.ClassName)

        return instance.ToolName.Value
    end)
    LockerManager.ItemSignal:Fire("StoredLockerItemsUpdate", items)
end)

lockerFolder.ChildRemoved:Connect(function()
    task.wait(0.3)
    local items = TableUtil:map(lockerFolder:GetChildren(), function(instance)
        print(instance.ClassName)

        return instance.ToolName.Value
    end)
    LockerManager.ItemSignal:Fire("StoredLockerItemsUpdate", items)
end)

localPlayer.Character.ChildAdded:Connect(function()
    local items = LockerManager:GetPlayerItems()
    LockerManager.ItemSignal:Fire("CharacterItemsUpdate", items)
end)

localPlayer.Character.ChildRemoved:Connect(function()
    local items = LockerManager:GetPlayerItems()
    LockerManager.ItemSignal:Fire("CharacterItemsUpdate", items)
end)

localPlayer.Backpack.ChildAdded:Connect(function()
    local items = LockerManager:GetPlayerItems()
    LockerManager.ItemSignal:Fire("CharacterItemsUpdate", items)
end)

localPlayer.Backpack.ChildRemoved:Connect(function()
    local items = LockerManager:GetPlayerItems()
    LockerManager.ItemSignal:Fire("CharacterItemsUpdate", items)
end)

-- // LockerManager

function LockerManager:_LockerEvent(action, instance)
    game:GetService("ReplicatedStorage").Events.LockerEvent:FireServer(action, instance)
end

function LockerManager:GetPlayerItems()
    local items = {}

    for _, tool in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if not tool:FindFirstChild("CantStore") then
                table.insert(items, tool.Name)
            end
        end
    end

    for _, v in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") then
            if not v:FindFirstChild("CantStore") then
                table.insert(items, v.Name)
            end
        end
    end

    return items
end

function LockerManager:GetLockerItems()
    task.wait(0.3)
    local items = TableUtil:map(lockerFolder:GetChildren(), function(instance)
        print(instance.ClassName)
        return instance.ToolName.Value
    end)
    return items
end

function LockerManager:GrabItem(item)
    local oldCFrame = localPlayer.Character.HumanoidRootPart.CFrame
    local locker = game:GetService("Workspace"):FindFirstChild("Locker")

    localPlayer.Character.HumanoidRootPart.CFrame =
        locker.HumanoidRootPart.CFrame + Vector3.new(0, 0, -3)
    task.wait(0.2)
    Compatiblity:fireproximityprompt(locker.HumanoidRootPart.Attachment.ProximityPrompt, 1, false)

    local itemAsInstance = nil

    for _, v in ipairs(game:GetService("ReplicatedStorage").PlayerStats.yt4r5.LockerFolder:GetChildren()) do
        if v.ToolName.Value == item then
            itemAsInstance = v
        end
    end

    if itemAsInstance == nil then
        return
    end

    self:_LockerEvent("LockerTake", itemAsInstance)
    task.wait(0.2)

    localPlayer.Character.HumanoidRootPart.CFrame = oldCFrame
end

function LockerManager:StoreItem(item)
    local oldCFrame = localPlayer.Character.HumanoidRootPart.CFrame
    local locker = game:GetService("Workspace"):FindFirstChild("Locker")

    localPlayer.Character.HumanoidRootPart.CFrame =
        locker.HumanoidRootPart.CFrame + Vector3.new(0, 0, -3)

    task.wait(0.5)
    Compatiblity:fireproximityprompt(locker.HumanoidRootPart.Attachment.ProximityPrompt, 1, false)

    if not localPlayer.Character:FindFirstChild(item.Name) then
        localPlayer.Character.Humanoid:EquipTool(item)
    end
    task.wait(0.5)
    self:_LockerEvent("LockerStore", item)
    task.wait(0.7)

    localPlayer.Character.HumanoidRootPart.CFrame = oldCFrame
    task.wait(1)
    localPlayer.Character.HumanoidRootPart.CFrame = oldCFrame
end

return LockerManager
end)
__bundle_register("modules/util/TableUtil", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = {}

function TableUtil:map(tbl, fn, ...)
    local t = {}
    for _, element in ipairs(tbl) do
        local _, result = pcall(fn, element, ...)
        table.insert(t, result)
    end
    return t
end

return TableUtil
end)
__bundle_register("modules/util/exploit/Compatiblity", function(require, _LOADED, __bundle_register, __bundle_modules)
local Compatiblity = {}

function Compatiblity:fireproximityprompt(ProximityPrompt, amount, skip)
    -- // Synapses fireproximityprompt is gay asf so we use this lol
    -- // Made by Sowd on v3rm
    if ProximityPrompt.ClassName == "ProximityPrompt" then
        amount = amount or 1
        local PromptTime = ProximityPrompt.HoldDuration
        if skip then
            ProximityPrompt.HoldDuration = 0
        end
        for i = 1, amount do
            ProximityPrompt:InputHoldBegin()
            if not skip then
                task.wait(ProximityPrompt.HoldDuration)
            end
            ProximityPrompt:InputHoldEnd()
        end
        ProximityPrompt.HoldDuration = PromptTime
    else
        error("userdata<ProximityPrompt> expected")
    end
end

return Compatiblity
end)
__bundle_register("modules/util/Signals", function(require, _LOADED, __bundle_register, __bundle_modules)
return loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Signal/main/Manager.lua"))()
end)
__bundle_register("modules/ui/LinoriaLib", function(require, _LOADED, __bundle_register, __bundle_modules)
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Util = require("modules/util/Util")

local Linoria = {}

-- // returns Library, Window, ThemeManager and SaveManager.
function Linoria:createLinoriaLib(gameName)
    Library:SetWatermarkVisibility(true)
    Library:SetWatermark('project floppa - ' .. gameName)

    local Window = Library:CreateWindow({
        -- // Position and Size are also valid options
        -- // but you do not need to define them unless you are changing them :)
        Title = "project floppa - build " .. Util:getBuildId(),
        Center = true,
        AutoShow = true,
    })


    return Library, Window
end

function Linoria:initManagers(Lib, Window)
    ThemeManager.BuiltInThemes.Default[2].AccentColor = Color3.fromRGB(255, 65, 65):ToHex()

    local Settings = Window:AddTab("Settings")

    ThemeManager:SetLibrary(Lib)
    SaveManager:SetLibrary(Lib)

    SaveManager:IgnoreThemeSettings()

    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

    ThemeManager:SetFolder('project-floppa')
    SaveManager:SetFolder('project-floppa/game')

    SaveManager:BuildConfigSection(Settings)

    ThemeManager:ApplyToTab(Settings)

end

return Linoria
end)
__bundle_register("modules/util/Util", function(require, _LOADED, __bundle_register, __bundle_modules)
local Util = {}

function Util:getBuildId()
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