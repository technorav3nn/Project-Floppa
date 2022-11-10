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
end)
__bundle_register("games/LifeSentence/LockerManager", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // Imports
local Signals = require("modules/util/Signals")
local Compatiblity = require("modules/exploit/Compatiblity")
local TableUtil = require("modules/util/TableUtil")
local Character = require("modules/exploit/Character")

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
    local items = LockerManager:GetLockerItems()
    LockerManager.ItemSignal:Fire("StoredLockerItemsUpdate", items)
end)

lockerFolder.ChildRemoved:Connect(function()
    task.wait(0.3)
    local items = LockerManager:GetLockerItems()
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
    local oldCFrame = Character:GetCFrame()
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
    local oldCFrame = Character:GetCFrame()
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
__bundle_register("modules/exploit/Character", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // Services
local Players = game:GetService("Players")

-- // Character
local Character = {}

function Character:GetCFrame()
    return Players.LocalPlayer.Character.HumanoidRootPart.CFrame
end

return Character
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
__bundle_register("modules/exploit/Compatiblity", function(require, _LOADED, __bundle_register, __bundle_modules)
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
__bundle_register("modules/exploit/visuals/Chams", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
    A class to use the Highlight feature as chams
    Some parts taken from wally's script showing the
    highlight feature.
--]]
-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- // Variables
local RenderStepped = RunService.RenderStepped

-- // Chams

local Chams = {}
Chams.__index = Chams

function Chams.new()
    local self = setmetatable({
        Enabled = false,
        UseTeamColor = false,
        Color = Color3.fromRGB(255, 0, 0),
        FillTransparency = 1,
        OutlineTransparency = 1,
        Objects = {}
    }, Chams)

    self:_init()

    return self
end

function Chams:_init()
    if CoreGui:FindFirstChildOfClass("Folder") then
        pcall(function()
            CoreGui:FindFirstChildOfClass("Folder"):Destroy()
        end)
    end

    local chamsFolder = Instance.new("Folder", CoreGui)
    chamsFolder.Name = "Chams"

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            self:_MakeCham(player.Character)
        end)

        player.CharacterRemoving:Connect(function(char)
            if self.Objects[player.Character.name] then
                self.Objects[char.Name]:Destroy()
                self.Objects[char.Name] = nil
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        if self.Objects[player.Character.Name] then
            self.Objects[player.Character.Name]:Destroy()
            self.Objects[player.Character.Name] = nil
        end
    end)

    for _, player in pairs(Players:GetPlayers()) do
        self:_MakeCham(player.Character)
    end

    self.RenderSteppedLoop = RenderStepped:Connect(function()
        local s, err = pcall(function()
            ---@type Highlight
            for _, highlight in pairs(self.Objects) do
                local player = Players:GetPlayerFromCharacter(highlight.Adornee)
                local colorToUse = (self.UseTeamColor and player.Team ~= nil) and player.TeamColor.Color or self.Color

                highlight.Enabled = self.Enabled
                highlight.OutlineColor = colorToUse
                highlight.FillColor = colorToUse
                highlight.FillTransparency = self.FillTransparency
            end
        end)

        if not s then
            for i = 1, 5 do
                error(err)
            end
            self.RenderSteppedLoop:Disconnect()
        end
    end)
end

function Chams:_MakeCham(char)
    local s, err = pcall(function()
        local player = Players:GetPlayerFromCharacter(char)
        local colorToUse = (self.UseTeamColor and player.Team ~= nil) and player.TeamColor.Color or self.Color

        local highlight = Instance.new("Highlight", CoreGui.Chams)

        highlight.Name = char.Name
        highlight.Adornee = char
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.OutlineColor = colorToUse
        highlight.FillColor = colorToUse

        self.Objects[char.Name] = highlight
    end)

    if not s then
        for i = 1, 5 do
            error(err)
        end
        self.RenderSteppedLoop:Disconnect()
    end
end

function Chams:Toggle(state)
    assert(type(state) == "boolean", "state of chams must be boolean!")
    self.Enabled = state
end

return Chams
end)
__bundle_register("modules/exploit/ui/LinoriaLib", function(require, _LOADED, __bundle_register, __bundle_modules)
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet('https://gist.githubusercontent.com/technorav3nn/461bc96a7cf4c1acf12794f5850f21cc/raw/68cd0a13c80d3b8d3423ea475d33185cd0d10978/linoria-work-swm.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Util = require("modules/util/Util")

local Linoria = {}

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
return __bundle_require("__root")