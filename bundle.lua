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
if not game.IsLoaded then
    game.Loaded:Wait()
end

if game.PlaceId == game.PlaceId then
    require("games/LifeSentence/main")
end
end)
__bundle_register("games/LifeSentence/main", function(require, _LOADED, __bundle_register, __bundle_modules)
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

end)
__bundle_register("games/LifeSentence/AimingManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Aiming = require("modules/exploit/aiming/Aiming")

repeat task.wait() until Aiming.Loaded

Aiming.Settings.Enabled = true
Aiming.Settings.TeamCheck = false

local AimingManager = {}

AimingManager.Aiming = Aiming

function AimingManager:Toggle(state)
    Aiming.Settings.Enabled = state
end

return AimingManager
end)
__bundle_register("modules/exploit/aiming/Aiming", function(require, _LOADED, __bundle_register, __bundle_modules)
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Load.lua"))()()

return Aiming
end)
__bundle_register("games/LifeSentence/AutobuyManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Character = require("modules/exploit/Character")
local teleport = require("games/LifeSentence/TpBypass")

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local buttons = game:GetService("Workspace").Buttons

local AutobuyManager = {}

AutobuyManager.Items = {}
AutobuyManager.ItemNames = {}
AutobuyManager.Buttons = {}

for _, button in ipairs(buttons:GetChildren()) do
    if button:FindFirstChild("Button") then
        AutobuyManager.Buttons[button.ToolName.Value] = button
    end
end

for itemName, _ in pairs(AutobuyManager.Buttons) do
    table.insert(AutobuyManager.Items, itemName)
end

function AutobuyManager:BuyItem(name)
    local button = AutobuyManager.Buttons[name]
    if button ~= nil then
        local prompt = button.Button:FindFirstChildWhichIsA("ProximityPrompt")
        local oldCFrame = Character:GetCFrame()

        -- // Makes it so that we can use it without our camera seeing it
        prompt.RequiresLineOfSight = false

        teleport(prompt.Parent.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.3)
        fireproximityprompt(prompt, math.huge)
        task.wait()
        teleport(oldCFrame)

        -- // Sometimes the character trips so i added this
        localPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    else
        error("couldn't find button with tool name: " .. name)
    end
end

return AutobuyManager
end)
__bundle_register("games/LifeSentence/TpBypass", function(require, _LOADED, __bundle_register, __bundle_modules)
local localPlayer = game:GetService("Players").LocalPlayer

local function teleport(cframe)
    localPlayer.Character.HumanoidRootPart:PivotTo(cframe)
end

return teleport
end)
__bundle_register("modules/exploit/Character", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // Services
local Players = game:GetService("Players")

-- // Character
local Character = {}

function Character:GetCFrame()
    return Players.LocalPlayer.Character.HumanoidRootPart.CFrame
end

function Character:GetPosition()
    return Players.LocalPlayer.Character.HumanoidRootPart.Position
end

return Character
end)
__bundle_register("games/LifeSentence/CraftingManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Character = require("modules/exploit/Character")
local Compatiblity = require("modules/exploit/Compatiblity")
local teleport = require("games/LifeSentence/TpBypass")

local GunConfigs = require(game:GetService("ReplicatedStorage").GunConfigs)

local CraftingManager = {}

CraftingManager.ValidCraftableWeapons = {}
CraftingManager.ResearchWeapons = {
    MetalVest = "1",
    Spaz = "2",
    AR = "3",
    Tec9 = "4",
    Garand = "5",
    LMG = "6",
    RPG = "7"
}

for k, _ in pairs(GunConfigs) do
    table.insert(CraftingManager.ValidCraftableWeapons, k)
end

function CraftingManager:CraftWeapon(weapon)
    local oldCf = Character:GetCFrame()
    teleport(CFrame.new(186, 7, -113))
    task.wait(0.3)

    Compatiblity:fireproximityprompt(game:GetService("Workspace").WorkBench.MainPart.Attachment.ProximityPrompt)

    task.wait(0.3)
    game:GetService("ReplicatedStorage").Events.LearnCraftEvent:FireServer(
        weapon .. "Frame"
    )
    task.wait(0.3)

    teleport(oldCf)
end

function CraftingManager:ResearchWeapon(name)
    local itemNumber = CraftingManager.ResearchWeapons[name]
    if itemNumber ~= nil then
        game:GetService("ReplicatedStorage").Events.LearnCraftEvent:FireServer(itemNumber, "Learn")
    else
        error('invalid item: '..name)
    end
end

return CraftingManager
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
__bundle_register("games/LifeSentence/FarmingManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Compatiblity = require("modules/exploit/Compatiblity")
local teleport = require("games/LifeSentence/TpBypass")

local RunService = game:GetService("RunService")

local FarmingManager = {}

FarmingManager.AutoScrapEnabled = false

function FarmingManager:GetAllScrap()
    local lootSpawners = game:GetService("Workspace").SpawnsLoot
    for _, loot in ipairs(lootSpawners:GetChildren()) do
        if loot.Part.Attachment.ProximityPrompt.Enabled then
            local prompt = loot.Part.Attachment.ProximityPrompt
            prompt.RequiresLineOfSight = false
            teleport(loot.Part.CFrame)
            task.wait(0.4)
            Compatiblity:fireproximityprompt(prompt)
        end
    end
end

function FarmingManager:LoopGetAllScrap()
    if self.AutoScrapEnabled then
        RunService:BindToRenderStep(
            "ScrapLoop",
            Enum.RenderPriority.Character.Value,
            function()
                if self.AutoScrapEnabled then
                    self:GetAllScrap()
                else
                    RunService:UnbindFromRenderStep("ScrapLoop")
                end
            end
        )
    end
end

function FarmingManager:FarmSafes()

end

return FarmingManager
end)
__bundle_register("games/LifeSentence/LockerManager", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // Imports
local Signals = require("modules/util/Signals")
local Compatiblity = require("modules/exploit/Compatiblity")
local TableUtil = require("modules/util/TableUtil")
local Character = require("modules/exploit/Character")

local teleport = require("games/LifeSentence/TpBypass")

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

    teleport(locker.HumanoidRootPart.CFrame + Vector3.new(0, 0, -3))

    --localPlayer.Character.HumanoidRootPart.CFrame =
    --    locker.HumanoidRootPart.CFrame + Vector3.new(0, 0, -3)

    task.wait(0.5)
    Compatiblity:fireproximityprompt(locker.HumanoidRootPart.Attachment.ProximityPrompt, 1, false)

    if not localPlayer.Character:FindFirstChild(item.Name) then
        localPlayer.Character.Humanoid:EquipTool(item)
    end

    task.wait(0.5)
    self:_LockerEvent("LockerStore", item)
    task.wait(0.3)
    firesignal(localPlayer.PlayerGui.HUD.LockerFrame.Inventory.ExitButton.MouseButton1Click)
    --localPlayer.Character.Humanoid:MoveTo(Character:GetPosition() + Vector3.new(0, 0, -5))
    --localPlayer.Character.Humanoid.MoveToFinished:Wait()
    task.wait(0.5)
    teleport(oldCFrame)
    task.wait(1)
    teleport(oldCFrame)
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
__bundle_register("modules/util/Signals", function(require, _LOADED, __bundle_register, __bundle_modules)
return loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Signal/main/Manager.lua"))()
end)
__bundle_register("modules/util/Maid", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
    Made by Quenty
    Source: https://github.com/Quenty/NevermoreEngine/blob/version2/Modules/Shared/Events/Maid.lua.
--]]

---	Manages the cleaning of events and other things.
-- Useful for encapsulating state and make deconstructors easy
-- @classmod Maid
-- @see Signal

local Maid = {}
Maid.ClassName = "Maid"

--- Returns a new Maid object
-- @constructor Maid.new()
-- @treturn Maid
function Maid.new()
	return setmetatable({
		_tasks = {}
	}, Maid)
end

function Maid.isMaid(value)
	return type(value) == "table" and value.ClassName == "Maid"
end

--- Returns Maid[key] if not part of Maid metatable
-- @return Maid[key] value
function Maid:__index(index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

--- Add a task to clean up. Tasks given to a maid will be cleaned when
--  maid[index] is set to a different value.
-- @usage
-- Maid[key] = (function)         Adds a task to perform
-- Maid[key] = (event connection) Manages an event connection
-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object,
--                                it is destroyed.
function Maid:__newindex(index, newTask)
	if Maid[index] ~= nil then
		error(("'%s' is reserved"):format(tostring(index)), 2)
	end

	local tasks = self._tasks
	local oldTask = tasks[index]

	if oldTask == newTask then
		return
	end

	tasks[index] = newTask

	if oldTask then
		if type(oldTask) == "function" then
			oldTask()
		elseif typeof(oldTask) == "RBXScriptConnection" then
			oldTask:Disconnect()
		elseif oldTask.Destroy then
			oldTask:Destroy()
		end
	end
end

--- Same as indexing, but uses an incremented number as a key.
-- @param task An item to clean
-- @treturn number taskId
function Maid:GiveTask(task)
	if not task then
		error("Task cannot be false or nil", 2)
	end

	local taskId = #self._tasks+1
	self[taskId] = task

	if type(task) == "table" and (not task.Destroy) then
		warn("[Maid.GiveTask] - Gave table task without .Destroy\n\n" .. debug.traceback())
	end

	return taskId
end

function Maid:GivePromise(promise)
	if not promise:IsPending() then
		return promise
	end

	local newPromise = promise.resolved(promise)
	local id = self:GiveTask(newPromise)

	-- Ensure GC
	newPromise:Finally(function()
		self[id] = nil
	end)

	return newPromise
end

--- Cleans up all tasks.
-- @alias Destroy
function Maid:DoCleaning()
	local tasks = self._tasks

	-- Disconnect all events first as we know this is safe
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end

	-- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
	local index, task = next(tasks)
	while task ~= nil do
		tasks[index] = nil
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif task.Destroy then
			task:Destroy()
		end
		index, task = next(tasks)
	end
end

--- Alias for DoCleaning()
-- @function Destroy
Maid.Destroy = Maid.DoCleaning

return Maid
end)
__bundle_register("modules/exploit/ui/LinoriaLib", function(require, _LOADED, __bundle_register, __bundle_modules)
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet('https://gist.githubusercontent.com/technorav3nn/461bc96a7cf4c1acf12794f5850f21cc/raw/68cd0a13c80d3b8d3423ea475d33185cd0d10978/linoria-work-swm.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Util = require("modules/util/Util")
local ChamsLibrary = require("modules/exploit/visuals/Chams")

local Chams = ChamsLibrary.new({
    Enabled = false,
    UseTeamColor = false,
    Color = Color3.new(0.035294, 0.309803, 1)
})
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

function Linoria:buildChamsGroupBox(ChamsGroupBox)
    ChamsGroupBox:AddToggle('ChamsEnabled', { Text = "Enabled" })
    :OnChanged(function()
        Chams:Toggle(Toggles.ChamsEnabled.Value)
    end)

    ChamsGroupBox:AddDivider()

    ChamsGroupBox:AddSlider('ChamsFillTransparency', {
        Text = "Fill Transparency",
        Rounding = 1,
        Default = 0.5,
        Min = 0,
        Max = 1,
    })
    :OnChanged(function()
        Chams.FillTransparency = Options.ChamsFillTransparency.Value
    end)

    ChamsGroupBox:AddSlider('ChamsOutlineTransparency', {
        Text = "Outline Transparency",
        Rounding = 1,
        Default = 0.5,
        Min = 0,
        Max = 1,
    })
    :OnChanged(function()
        Chams.OutlineTransparency = Options.ChamsOutlineTransparency.Value
    end)

    ChamsGroupBox:AddDivider()


    ChamsGroupBox:AddLabel('Fill Color'):AddColorPicker('ChamsFillColor', {
        Default = Chams.Color,
        Title = 'Fill Color',
    })

    Options.ChamsFillColor:OnChanged(function()
        Chams.Color = Options.ChamsFillColor.Value
    end)

    ChamsGroupBox:AddToggle("ChamsRainbowColor", { Text = "Rainbow Color" })

    task.spawn(function()
        local i = 1
        while task.wait() do
            if Toggles.ChamsRainbowColor and Toggles.ChamsRainbowColor.Value then
                i = i + 1
                local col = Color3.fromHSV(i/360, 1, 1)
                if i == 360 then
                    i = 1
                end
                print(col)
                Options.ChamsFillColor:SetValueRGB(col)
            end
        end
    end)
end

return Linoria
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
        FillTransparency = 0.5,
        OutlineTransparency = 0.5,
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
        self:_MakeCham(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        local cham = self.Objects[player.Name]
        if cham then
            cham:Destroy()
            self.Objects[player.Name] = nil
        end
    end)

    for _, player in pairs(Players:GetPlayers()) do
        self:_MakeCham(player)
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
                highlight.OutlineTransparency = self.OutlineTransparency
            end
        end)

        if not s then
            for _ = 1, 5 do
                error(err)
            end
            self.RenderSteppedLoop:Disconnect()
        end
    end)
end

function Chams:_MakeCham(player)
    local s, err = pcall(function()
        local colorToUse = (self.UseTeamColor and player.Team ~= nil) and player.TeamColor.Color or self.Color
        
        local highlight = Instance.new("Highlight", CoreGui.Chams)
        highlight.Name = player.Name
        highlight.Adornee = player.Character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.OutlineColor = colorToUse
        highlight.FillColor = colorToUse
        highlight.FillTransparency = self.FillTransparency
        highlight.OutlineTransparency = self.OutlineTransparency

        self.Objects[player.Name] = highlight

        player.CharacterAdded:Connect(function()
            highlight.Adornee = player.Character
        end)

        player.CharacterRemoving:Connect(function()
            highlight.Adornee = nil
        end)
    end)

    if not s then
        for _ = 1, 5 do
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
__bundle_register("modules/util/Util", function(require, _LOADED, __bundle_register, __bundle_modules)
local Util = {}

function Util:getBuildId()
    -- // TODO: Add a .toml parser to get the Build Id from build-info.toml
    return "a48bf992ns92b"
end

return Util
end)
return __bundle_require("__root")