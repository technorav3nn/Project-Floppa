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
local DEBUG = true

if not game.IsLoaded then
    game.Loaded:Wait()
end

if game.PlaceId == 7860844204 then
    require("games/LifeSentence/main")
elseif game.PlaceId == 606849621 then
    require("games/Jailbreak/main")
elseif game.PlaceId == 4872321990 then
    require("games/Islands/main")
end
end)
__bundle_register("games/Islands/main", function(require, _LOADED, __bundle_register, __bundle_modules)
local LibModule = require("modules/exploit/ui/Vynixius")

local Library, Window = LibModule.createVynixiusLib("Project Floppa", "Islands")

require("games/Islands/ui/farming/main")(Library, Window)

LibModule.initalizeSettingsTab(Window)
end)
__bundle_register("games/Islands/ui/farming/main", function(require, _LOADED, __bundle_register, __bundle_modules)
return function (Library, Window)
    local FarmingTab = Window:AddTab("Farming")

    require("games/Islands/ui/farming/OreFarm")(Library, Window, FarmingTab)
    require("games/Islands/ui/farming/MobFarm")(Library, Window, FarmingTab)
end
end)
__bundle_register("games/Islands/ui/farming/MobFarm", function(require, _LOADED, __bundle_register, __bundle_modules)
local NetworkService = require("games/Islands/services/NetworkService")
local NotificationService = require("games/Islands/services/NotificationService")

local IslandsUtils = require("games/Islands/IslandsUtils")

local Constants = require("games/Islands/constants")

local mobFarmMaid = require("modules/util/Maid").new()

-- // to be replaced with the FarmingTab.Flags property, dw
local flags = {}

local function getMob(mobName)
    if not table.find(Constants.HostileMobKeys, mobName) then
        NotificationService:DisplayNotification({
            message = "Couldn't find the mob ".. mobName .. ", please contact Death_Blows"
        })
    end
end

return function (Library, Window, FarmingTab)
    local MobFarmSection = FarmingTab:AddSection("Mob Farm", { default = false })

    flags = FarmingTab.Flags

    MobFarmSection:AddToggle("Enabled", { flag = "MobFarmEnabled" })
    MobFarmSection:AddDropdown("Mob Selected", Constants.HostileMobKeys { default = "slime" })
end
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
__bundle_register("games/Islands/constants", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("modules/util/TableUtil")

local Constants
Constants = {
    Rocks = {
        "rockIron",
        "rockCoal",
        "rockPrismarine",
        "rockStone",
        "rockCopper",
        "rockDiamond",
        "rockGold",
        "rockElectrite",
        "rockClay",
        "rockSlate",
        "rockSandstone",
    },
    HostileMobs = {
        slime = { boss = false },
        wizardLizard = { boss = false },
        slimeKing = { boss = true },
    },
    HostileMobKeys = TableUtil:getKeys(Constants.HostileMobs)
}

return Constants
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

-- // http://lua-users.org/wiki/CopyTable
function TableUtil:deepCopy(orig)
    local origType = type(orig)
    local copy
    if origType == 'table' then
        copy = {}
        for origKey, origValue in next, orig, nil do
            copy[self:deepCopy(origKey)] = self:deepCopy(origValue)
        end
        setmetatable(copy, self:deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function TableUtil:getKeys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do 
        table.insert(keys, k) 
    end
    return keys
end

return TableUtil
end)
__bundle_register("games/Islands/IslandsUtils", function(require, _LOADED, __bundle_register, __bundle_modules)
local Promise = require("modules/util/Promise")

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- // skidded from IY XD
local flying = false

local function startFlying(vfly)
    local iyflyspeed = 0.2
    local vehicleflyspeed = 1

    repeat task.wait() until Players.LocalPlayer and Players.LocalPlayer.Character and Players.LocalPlayer.Character.HumanoidRootPart and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	repeat task.wait() until Players.LocalPlayer:GetMouse()

	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

	local T = Players.LocalPlayer.Character.HumanoidRootPart
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		flying = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = T.CFrame
		BV.velocity = Vector3.new(0, 0, 0)
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				if not vfly and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
					Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
				else
					BV.velocity = Vector3.new(0, 0, 0)
				end
				BG.cframe = workspace.CurrentCamera.CoordinateFrame
			until not flying
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
				Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end
	flyKeyDown = Players.LocalPlayer:GetMouse().KeyDown:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 's' then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'a' then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'd' then
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif true and KEY:lower() == 'e' then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif true and KEY:lower() == 'q' then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
	end)
	flyKeyUp = Players.LocalPlayer:GetMouse().KeyUp:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = 0
		elseif KEY:lower() == 's' then
			CONTROL.B = 0
		elseif KEY:lower() == 'a' then
			CONTROL.L = 0
		elseif KEY:lower() == 'd' then
			CONTROL.R = 0
		elseif KEY:lower() == 'e' then
			CONTROL.Q = 0
		elseif KEY:lower() == 'q' then
			CONTROL.E = 0
		end
	end)
	FLY()
end

local function stopFlying(vfly)
	flying = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local IslandsUtils = {}

function IslandsUtils:GetLocalPlayerIsland()
    for _, island in pairs(game:GetService("Workspace").Islands:GetChildren()) do
        if island:IsA("Model") then
            local islandOwners = island:FindFirstChild("Owners")
            if islandOwners then
                local localPlayerId = game.Players.LocalPlayer.UserId
                for _, id in pairs(islandOwners:GetChildren()) do
                    if id:IsA("NumberValue") and id.Value == localPlayerId then
                        return island, island.Name
                    end
                end
            end
        end
    end
end

function IslandsUtils:Teleport(cframe)
    return function()
        return Promise.new(function(resolve, reject, onCancel)
            local connection
            local time =
            (cframe.p + Vector3.new(0, 0, 3) -
            game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude / 20

            local tween = game:GetService("TweenService"):Create(
                game.Players.LocalPlayer.Character.HumanoidRootPart,
                TweenInfo.new(time, Enum.EasingStyle.Linear),
                { CFrame = cframe }
            )

            if onCancel(function() tween:Cancel() end) then
                return
            end

            startFlying()
            task.wait(0.1)

            connection = game:GetService("RunService").Stepped:Connect(function ()
                for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            tween.Completed:Connect(function(...)
                connection:Disconnect()
                stopFlying()

                resolve(...)
            end)

            tween:Play()
            tween.Completed:Wait()
        end)
    end
end

return IslandsUtils
end)
__bundle_register("modules/util/Promise", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
	An implementation of Promises similar to Promise/A+.
]]

local ERROR_NON_PROMISE_IN_LIST = "Non-promise value passed into %s at index %s"
local ERROR_NON_LIST = "Please pass a list of promises to %s"
local ERROR_NON_FUNCTION = "Please pass a handler function to %s!"
local MODE_KEY_METATABLE = { __mode = "k" }

local function isCallable(value)
	if type(value) == "function" then
		return true
	end

	if type(value) == "table" then
		local metatable = getmetatable(value)
		if metatable and type(rawget(metatable, "__call")) == "function" then
			return true
		end
	end

	return false
end

--[[
	Creates an enum dictionary with some metamethods to prevent common mistakes.
]]
local function makeEnum(enumName, members)
	local enum = {}

	for _, memberName in ipairs(members) do
		enum[memberName] = memberName
	end

	return setmetatable(enum, {
		__index = function(_, k)
			error(string.format("%s is not in %s!", k, enumName), 2)
		end,
		__newindex = function()
			error(string.format("Creating new members in %s is not allowed!", enumName), 2)
		end,
	})
end

--[=[
	An object to represent runtime errors that occur during execution.
	Promises that experience an error like this will be rejected with
	an instance of this object.

	@class Error
]=]
local Error
do
	Error = {
		Kind = makeEnum("Promise.Error.Kind", {
			"ExecutionError",
			"AlreadyCancelled",
			"NotResolvedInTime",
			"TimedOut",
		}),
	}
	Error.__index = Error

	function Error.new(options, parent)
		options = options or {}
		return setmetatable({
			error = tostring(options.error) or "[This error has no error text.]",
			trace = options.trace,
			context = options.context,
			kind = options.kind,
			parent = parent,
			createdTick = os.clock(),
			createdTrace = debug.traceback(),
		}, Error)
	end

	function Error.is(anything)
		if type(anything) == "table" then
			local metatable = getmetatable(anything)

			if type(metatable) == "table" then
				return rawget(anything, "error") ~= nil and type(rawget(metatable, "extend")) == "function"
			end
		end

		return false
	end

	function Error.isKind(anything, kind)
		assert(kind ~= nil, "Argument #2 to Promise.Error.isKind must not be nil")

		return Error.is(anything) and anything.kind == kind
	end

	function Error:extend(options)
		options = options or {}

		options.kind = options.kind or self.kind

		return Error.new(options, self)
	end

	function Error:getErrorChain()
		local runtimeErrors = { self }

		while runtimeErrors[#runtimeErrors].parent do
			table.insert(runtimeErrors, runtimeErrors[#runtimeErrors].parent)
		end

		return runtimeErrors
	end

	function Error:__tostring()
		local errorStrings = {
			string.format("-- Promise.Error(%s) --", self.kind or "?"),
		}

		for _, runtimeError in ipairs(self:getErrorChain()) do
			table.insert(
				errorStrings,
				table.concat({
					runtimeError.trace or runtimeError.error,
					runtimeError.context,
				}, "\n")
			)
		end

		return table.concat(errorStrings, "\n")
	end
end

--[[
	Packs a number of arguments into a table and returns its length.

	Used to cajole varargs without dropping sparse values.
]]
local function pack(...)
	return select("#", ...), { ... }
end

--[[
	Returns first value (success), and packs all following values.
]]
local function packResult(success, ...)
	return success, select("#", ...), { ... }
end

local function makeErrorHandler(traceback)
	assert(traceback ~= nil, "traceback is nil")

	return function(err)
		-- If the error object is already a table, forward it directly.
		-- Should we extend the error here and add our own trace?

		if type(err) == "table" then
			return err
		end

		return Error.new({
			error = err,
			kind = Error.Kind.ExecutionError,
			trace = debug.traceback(tostring(err), 2),
			context = "Promise created at:\n\n" .. traceback,
		})
	end
end

--[[
	Calls a Promise executor with error handling.
]]
local function runExecutor(traceback, callback, ...)
	return packResult(xpcall(callback, makeErrorHandler(traceback), ...))
end

--[[
	Creates a function that invokes a callback with correct error handling and
	resolution mechanisms.
]]
local function createAdvancer(traceback, callback, resolve, reject)
	return function(...)
		local ok, resultLength, result = runExecutor(traceback, callback, ...)

		if ok then
			resolve(unpack(result, 1, resultLength))
		else
			reject(result[1])
		end
	end
end

local function isEmpty(t)
	return next(t) == nil
end

--[=[
	An enum value used to represent the Promise's status.
	@interface Status
	@tag enum
	@within Promise
	.Started "Started" -- The Promise is executing, and not settled yet.
	.Resolved "Resolved" -- The Promise finished successfully.
	.Rejected "Rejected" -- The Promise was rejected.
	.Cancelled "Cancelled" -- The Promise was cancelled before it finished.
]=]
--[=[
	@prop Status Status
	@within Promise
	@readonly
	@tag enums
	A table containing all members of the `Status` enum, e.g., `Promise.Status.Resolved`.
]=]
--[=[
	A Promise is an object that represents a value that will exist in the future, but doesn't right now.
	Promises allow you to then attach callbacks that can run once the value becomes available (known as *resolving*),
	or if an error has occurred (known as *rejecting*).

	@class Promise
	@__index prototype
]=]
local Promise = {
	Error = Error,
	Status = makeEnum("Promise.Status", { "Started", "Resolved", "Rejected", "Cancelled" }),
	_getTime = os.clock,
	_timeEvent = game:GetService("RunService").Heartbeat,
	_unhandledRejectionCallbacks = {},
}
Promise.prototype = {}
Promise.__index = Promise.prototype

function Promise._new(traceback, callback, parent)
	if parent ~= nil and not Promise.is(parent) then
		error("Argument #2 to Promise.new must be a promise or nil", 2)
	end

	local self = {
		-- The executor thread.
		_thread = nil,

		-- Used to locate where a promise was created
		_source = traceback,

		_status = Promise.Status.Started,

		-- A table containing a list of all results, whether success or failure.
		-- Only valid if _status is set to something besides Started
		_values = nil,

		-- Lua doesn't like sparse arrays very much, so we explicitly store the
		-- length of _values to handle middle nils.
		_valuesLength = -1,

		-- Tracks if this Promise has no error observers..
		_unhandledRejection = true,

		-- Queues representing functions we should invoke when we update!
		_queuedResolve = {},
		_queuedReject = {},
		_queuedFinally = {},

		-- The function to run when/if this promise is cancelled.
		_cancellationHook = nil,

		-- The "parent" of this promise in a promise chain. Required for
		-- cancellation propagation upstream.
		_parent = parent,

		-- Consumers are Promises that have chained onto this one.
		-- We track them for cancellation propagation downstream.
		_consumers = setmetatable({}, MODE_KEY_METATABLE),
	}

	if parent and parent._status == Promise.Status.Started then
		parent._consumers[self] = true
	end

	setmetatable(self, Promise)

	local function resolve(...)
		self:_resolve(...)
	end

	local function reject(...)
		self:_reject(...)
	end

	local function onCancel(cancellationHook)
		if cancellationHook then
			if self._status == Promise.Status.Cancelled then
				cancellationHook()
			else
				self._cancellationHook = cancellationHook
			end
		end

		return self._status == Promise.Status.Cancelled
	end

	self._thread = coroutine.create(function()
		local ok, _, result = runExecutor(self._source, callback, resolve, reject, onCancel)

		if not ok then
			reject(result[1])
		end
	end)

	task.spawn(self._thread)

	return self
end

--[=[
	Construct a new Promise that will be resolved or rejected with the given callbacks.

	If you `resolve` with a Promise, it will be chained onto.

	You can safely yield within the executor function and it will not block the creating thread.

	```lua
	local myFunction()
		return Promise.new(function(resolve, reject, onCancel)
			wait(1)
			resolve("Hello world!")
		end)
	end

	myFunction():andThen(print)
	```

	You do not need to use `pcall` within a Promise. Errors that occur during execution will be caught and turned into a rejection automatically. If `error()` is called with a table, that table will be the rejection value. Otherwise, string errors will be converted into `Promise.Error(Promise.Error.Kind.ExecutionError)` objects for tracking debug information.

	You may register an optional cancellation hook by using the `onCancel` argument:

	* This should be used to abort any ongoing operations leading up to the promise being settled.
	* Call the `onCancel` function with a function callback as its only argument to set a hook which will in turn be called when/if the promise is cancelled.
	* `onCancel` returns `true` if the Promise was already cancelled when you called `onCancel`.
	* Calling `onCancel` with no argument will not override a previously set cancellation hook, but it will still return `true` if the Promise is currently cancelled.
	* You can set the cancellation hook at any time before resolving.
	* When a promise is cancelled, calls to `resolve` or `reject` will be ignored, regardless of if you set a cancellation hook or not.

	:::caution
	If the Promise is cancelled, the `executor` thread is closed with `coroutine.close` after the cancellation hook is called.

	You must perform any cleanup code in the cancellation hook: any time your executor yields, it **may never resume**.
	:::

	@param executor (resolve: (...: any) -> (), reject: (...: any) -> (), onCancel: (abortHandler?: () -> ()) -> boolean) -> ()
	@return Promise
]=]
function Promise.new(executor)
	return Promise._new(debug.traceback(nil, 2), executor)
end

function Promise:__tostring()
	return string.format("Promise(%s)", self._status)
end

--[=[
	The same as [Promise.new](/api/Promise#new), except execution begins after the next `Heartbeat` event.

	This is a spiritual replacement for `spawn`, but it does not suffer from the same [issues](https://eryn.io/gist/3db84579866c099cdd5bb2ff37947cec) as `spawn`.

	```lua
	local function waitForChild(instance, childName, timeout)
	  return Promise.defer(function(resolve, reject)
		local child = instance:WaitForChild(childName, timeout)

		;(child and resolve or reject)(child)
	  end)
	end
	```

	@param executor (resolve: (...: any) -> (), reject: (...: any) -> (), onCancel: (abortHandler?: () -> ()) -> boolean) -> ()
	@return Promise
]=]
function Promise.defer(executor)
	local traceback = debug.traceback(nil, 2)
	local promise
	promise = Promise._new(traceback, function(resolve, reject, onCancel)
		local connection
		connection = Promise._timeEvent:Connect(function()
			connection:Disconnect()
			local ok, _, result = runExecutor(traceback, executor, resolve, reject, onCancel)

			if not ok then
				reject(result[1])
			end
		end)
	end)

	return promise
end

-- Backwards compatibility
Promise.async = Promise.defer

--[=[
	Creates an immediately resolved Promise with the given value.

	```lua
	-- Example using Promise.resolve to deliver cached values:
	function getSomething(name)
		if cache[name] then
			return Promise.resolve(cache[name])
		else
			return Promise.new(function(resolve, reject)
				local thing = getTheThing()
				cache[name] = thing

				resolve(thing)
			end)
		end
	end
	```

	@param ... any
	@return Promise<...any>
]=]
function Promise.resolve(...)
	local length, values = pack(...)
	return Promise._new(debug.traceback(nil, 2), function(resolve)
		resolve(unpack(values, 1, length))
	end)
end

--[=[
	Creates an immediately rejected Promise with the given value.

	:::caution
	Something needs to consume this rejection (i.e. `:catch()` it), otherwise it will emit an unhandled Promise rejection warning on the next frame. Thus, you should not create and store rejected Promises for later use. Only create them on-demand as needed.
	:::

	@param ... any
	@return Promise<...any>
]=]
function Promise.reject(...)
	local length, values = pack(...)
	return Promise._new(debug.traceback(nil, 2), function(_, reject)
		reject(unpack(values, 1, length))
	end)
end

--[[
	Runs a non-promise-returning function as a Promise with the
  given arguments.
]]
function Promise._try(traceback, callback, ...)
	local valuesLength, values = pack(...)

	return Promise._new(traceback, function(resolve)
		resolve(callback(unpack(values, 1, valuesLength)))
	end)
end

--[=[
	Begins a Promise chain, calling a function and returning a Promise resolving with its return value. If the function errors, the returned Promise will be rejected with the error. You can safely yield within the Promise.try callback.

	:::info
	`Promise.try` is similar to [Promise.promisify](#promisify), except the callback is invoked immediately instead of returning a new function.
	:::

	```lua
	Promise.try(function()
		return math.random(1, 2) == 1 and "ok" or error("Oh an error!")
	end)
		:andThen(function(text)
			print(text)
		end)
		:catch(function(err)
			warn("Something went wrong")
		end)
	```

	@param callback (...: T...) -> ...any
	@param ... T... -- Additional arguments passed to `callback`
	@return Promise
]=]
function Promise.try(callback, ...)
	return Promise._try(debug.traceback(nil, 2), callback, ...)
end

--[[
	Returns a new promise that:
		* is resolved when all input promises resolve
		* is rejected if ANY input promises reject
]]
function Promise._all(traceback, promises, amount)
	if type(promises) ~= "table" then
		error(string.format(ERROR_NON_LIST, "Promise.all"), 3)
	end

	-- We need to check that each value is a promise here so that we can produce
	-- a proper error rather than a rejected promise with our error.
	for i, promise in pairs(promises) do
		if not Promise.is(promise) then
			error(string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.all", tostring(i)), 3)
		end
	end

	-- If there are no values then return an already resolved promise.
	if #promises == 0 or amount == 0 then
		return Promise.resolve({})
	end

	return Promise._new(traceback, function(resolve, reject, onCancel)
		-- An array to contain our resolved values from the given promises.
		local resolvedValues = {}
		local newPromises = {}

		-- Keep a count of resolved promises because just checking the resolved
		-- values length wouldn't account for promises that resolve with nil.
		local resolvedCount = 0
		local rejectedCount = 0
		local done = false

		local function cancel()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end

		-- Called when a single value is resolved and resolves if all are done.
		local function resolveOne(i, ...)
			if done then
				return
			end

			resolvedCount = resolvedCount + 1

			if amount == nil then
				resolvedValues[i] = ...
			else
				resolvedValues[resolvedCount] = ...
			end

			if resolvedCount >= (amount or #promises) then
				done = true
				resolve(resolvedValues)
				cancel()
			end
		end

		onCancel(cancel)

		-- We can assume the values inside `promises` are all promises since we
		-- checked above.
		for i, promise in ipairs(promises) do
			newPromises[i] = promise:andThen(function(...)
				resolveOne(i, ...)
			end, function(...)
				rejectedCount = rejectedCount + 1

				if amount == nil or #promises - rejectedCount < amount then
					cancel()
					done = true

					reject(...)
				end
			end)
		end

		if done then
			cancel()
		end
	end)
end

--[=[
	Accepts an array of Promises and returns a new promise that:
	* is resolved after all input promises resolve.
	* is rejected if *any* input promises reject.

	:::info
	Only the first return value from each promise will be present in the resulting array.
	:::

	After any input Promise rejects, all other input Promises that are still pending will be cancelled if they have no other consumers.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.all(promises)
	```

	@param promises {Promise<T>}
	@return Promise<{T}>
]=]
function Promise.all(promises)
	return Promise._all(debug.traceback(nil, 2), promises)
end

--[=[
	Folds an array of values or promises into a single value. The array is traversed sequentially.

	The reducer function can return a promise or value directly. Each iteration receives the resolved value from the previous, and the first receives your defined initial value.

	The folding will stop at the first rejection encountered.
	```lua
	local basket = {"blueberry", "melon", "pear", "melon"}
	Promise.fold(basket, function(cost, fruit)
		if fruit == "blueberry" then
			return cost -- blueberries are free!
		else
			-- call a function that returns a promise with the fruit price
			return fetchPrice(fruit):andThen(function(fruitCost)
				return cost + fruitCost
			end)
		end
	end, 0)
	```

	@since v3.1.0
	@param list {T | Promise<T>}
	@param reducer (accumulator: U, value: T, index: number) -> U | Promise<U>
	@param initialValue U
]=]
function Promise.fold(list, reducer, initialValue)
	assert(type(list) == "table", "Bad argument #1 to Promise.fold: must be a table")
	assert(isCallable(reducer), "Bad argument #2 to Promise.fold: must be a function")

	local accumulator = Promise.resolve(initialValue)
	return Promise.each(list, function(resolvedElement, i)
		accumulator = accumulator:andThen(function(previousValueResolved)
			return reducer(previousValueResolved, resolvedElement, i)
		end)
	end):andThen(function()
		return accumulator
	end)
end

--[=[
	Accepts an array of Promises and returns a Promise that is resolved as soon as `count` Promises are resolved from the input array. The resolved array values are in the order that the Promises resolved in. When this Promise resolves, all other pending Promises are cancelled if they have no other consumers.

	`count` 0 results in an empty array. The resultant array will never have more than `count` elements.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.some(promises, 2) -- Only resolves with first 2 promises to resolve
	```

	@param promises {Promise<T>}
	@param count number
	@return Promise<{T}>
]=]
function Promise.some(promises, count)
	assert(type(count) == "number", "Bad argument #2 to Promise.some: must be a number")

	return Promise._all(debug.traceback(nil, 2), promises, count)
end

--[=[
	Accepts an array of Promises and returns a Promise that is resolved as soon as *any* of the input Promises resolves. It will reject only if *all* input Promises reject. As soon as one Promises resolves, all other pending Promises are cancelled if they have no other consumers.

	Resolves directly with the value of the first resolved Promise. This is essentially [[Promise.some]] with `1` count, except the Promise resolves with the value directly instead of an array with one element.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.any(promises) -- Resolves with first value to resolve (only rejects if all 3 rejected)
	```

	@param promises {Promise<T>}
	@return Promise<T>
]=]
function Promise.any(promises)
	return Promise._all(debug.traceback(nil, 2), promises, 1):andThen(function(values)
		return values[1]
	end)
end

--[=[
	Accepts an array of Promises and returns a new Promise that resolves with an array of in-place Statuses when all input Promises have settled. This is equivalent to mapping `promise:finally` over the array of Promises.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.allSettled(promises)
	```

	@param promises {Promise<T>}
	@return Promise<{Status}>
]=]
function Promise.allSettled(promises)
	if type(promises) ~= "table" then
		error(string.format(ERROR_NON_LIST, "Promise.allSettled"), 2)
	end

	-- We need to check that each value is a promise here so that we can produce
	-- a proper error rather than a rejected promise with our error.
	for i, promise in pairs(promises) do
		if not Promise.is(promise) then
			error(string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.allSettled", tostring(i)), 2)
		end
	end

	-- If there are no values then return an already resolved promise.
	if #promises == 0 then
		return Promise.resolve({})
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
		-- An array to contain our resolved values from the given promises.
		local fates = {}
		local newPromises = {}

		-- Keep a count of resolved promises because just checking the resolved
		-- values length wouldn't account for promises that resolve with nil.
		local finishedCount = 0

		-- Called when a single value is resolved and resolves if all are done.
		local function resolveOne(i, ...)
			finishedCount = finishedCount + 1

			fates[i] = ...

			if finishedCount >= #promises then
				resolve(fates)
			end
		end

		onCancel(function()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end)

		-- We can assume the values inside `promises` are all promises since we
		-- checked above.
		for i, promise in ipairs(promises) do
			newPromises[i] = promise:finally(function(...)
				resolveOne(i, ...)
			end)
		end
	end)
end

--[=[
	Accepts an array of Promises and returns a new promise that is resolved or rejected as soon as any Promise in the array resolves or rejects.

	:::warning
	If the first Promise to settle from the array settles with a rejection, the resulting Promise from `race` will reject.

	If you instead want to tolerate rejections, and only care about at least one Promise resolving, you should use [Promise.any](#any) or [Promise.some](#some) instead.
	:::

	All other Promises that don't win the race will be cancelled if they have no other consumers.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.race(promises) -- Only returns 1st value to resolve or reject
	```

	@param promises {Promise<T>}
	@return Promise<T>
]=]
function Promise.race(promises)
	assert(type(promises) == "table", string.format(ERROR_NON_LIST, "Promise.race"))

	for i, promise in pairs(promises) do
		assert(Promise.is(promise), string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.race", tostring(i)))
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
		local newPromises = {}
		local finished = false

		local function cancel()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end

		local function finalize(callback)
			return function(...)
				cancel()
				finished = true
				return callback(...)
			end
		end

		if onCancel(finalize(reject)) then
			return
		end

		for i, promise in ipairs(promises) do
			newPromises[i] = promise:andThen(finalize(resolve), finalize(reject))
		end

		if finished then
			cancel()
		end
	end)
end

--[=[
	Iterates serially over the given an array of values, calling the predicate callback on each value before continuing.

	If the predicate returns a Promise, we wait for that Promise to resolve before moving on to the next item
	in the array.

	:::info
	`Promise.each` is similar to `Promise.all`, except the Promises are ran in order instead of all at once.

	But because Promises are eager, by the time they are created, they're already running. Thus, we need a way to defer creation of each Promise until a later time.

	The predicate function exists as a way for us to operate on our data instead of creating a new closure for each Promise. If you would prefer, you can pass in an array of functions, and in the predicate, call the function and return its return value.
	:::

	```lua
	Promise.each({
		"foo",
		"bar",
		"baz",
		"qux"
	}, function(value, index)
		return Promise.delay(1):andThen(function()
		print(("%d) Got %s!"):format(index, value))
		end)
	end)

	--[[
		(1 second passes)
		> 1) Got foo!
		(1 second passes)
		> 2) Got bar!
		(1 second passes)
		> 3) Got baz!
		(1 second passes)
		> 4) Got qux!
	]]
	```

	If the Promise a predicate returns rejects, the Promise from `Promise.each` is also rejected with the same value.

	If the array of values contains a Promise, when we get to that point in the list, we wait for the Promise to resolve before calling the predicate with the value.

	If a Promise in the array of values is already Rejected when `Promise.each` is called, `Promise.each` rejects with that value immediately (the predicate callback will never be called even once). If a Promise in the list is already Cancelled when `Promise.each` is called, `Promise.each` rejects with `Promise.Error(Promise.Error.Kind.AlreadyCancelled`). If a Promise in the array of values is Started at first, but later rejects, `Promise.each` will reject with that value and iteration will not continue once iteration encounters that value.

	Returns a Promise containing an array of the returned/resolved values from the predicate for each item in the array of values.

	If this Promise returned from `Promise.each` rejects or is cancelled for any reason, the following are true:
	- Iteration will not continue.
	- Any Promises within the array of values will now be cancelled if they have no other consumers.
	- The Promise returned from the currently active predicate will be cancelled if it hasn't resolved yet.

	@since 3.0.0
	@param list {T | Promise<T>}
	@param predicate (value: T, index: number) -> U | Promise<U>
	@return Promise<{U}>
]=]
function Promise.each(list, predicate)
	assert(type(list) == "table", string.format(ERROR_NON_LIST, "Promise.each"))
	assert(isCallable(predicate), string.format(ERROR_NON_FUNCTION, "Promise.each"))

	return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
		local results = {}
		local promisesToCancel = {}

		local cancelled = false

		local function cancel()
			for _, promiseToCancel in ipairs(promisesToCancel) do
				promiseToCancel:cancel()
			end
		end

		onCancel(function()
			cancelled = true

			cancel()
		end)

		-- We need to preprocess the list of values and look for Promises.
		-- If we find some, we must register our andThen calls now, so that those Promises have a consumer
		-- from us registered. If we don't do this, those Promises might get cancelled by something else
		-- before we get to them in the series because it's not possible to tell that we plan to use it
		-- unless we indicate it here.

		local preprocessedList = {}

		for index, value in ipairs(list) do
			if Promise.is(value) then
				if value:getStatus() == Promise.Status.Cancelled then
					cancel()
					return reject(Error.new({
						error = "Promise is cancelled",
						kind = Error.Kind.AlreadyCancelled,
						context = string.format(
							"The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\n\nThat Promise was created at:\n\n%s",
							index,
							value._source
						),
					}))
				elseif value:getStatus() == Promise.Status.Rejected then
					cancel()
					return reject(select(2, value:await()))
				end

				-- Chain a new Promise from this one so we only cancel ours
				local ourPromise = value:andThen(function(...)
					return ...
				end)

				table.insert(promisesToCancel, ourPromise)
				preprocessedList[index] = ourPromise
			else
				preprocessedList[index] = value
			end
		end

		for index, value in ipairs(preprocessedList) do
			if Promise.is(value) then
				local success
				success, value = value:await()

				if not success then
					cancel()
					return reject(value)
				end
			end

			if cancelled then
				return
			end

			local predicatePromise = Promise.resolve(predicate(value, index))

			table.insert(promisesToCancel, predicatePromise)

			local success, result = predicatePromise:await()

			if not success then
				cancel()
				return reject(result)
			end

			results[index] = result
		end

		resolve(results)
	end)
end

--[=[
	Checks whether the given object is a Promise via duck typing. This only checks if the object is a table and has an `andThen` method.

	@param object any
	@return boolean -- `true` if the given `object` is a Promise.
]=]
function Promise.is(object)
	if type(object) ~= "table" then
		return false
	end

	local objectMetatable = getmetatable(object)

	if objectMetatable == Promise then
		-- The Promise came from this library.
		return true
	elseif objectMetatable == nil then
		-- No metatable, but we should still chain onto tables with andThen methods
		return isCallable(object.andThen)
	elseif
		type(objectMetatable) == "table"
		and type(rawget(objectMetatable, "__index")) == "table"
		and isCallable(rawget(rawget(objectMetatable, "__index"), "andThen"))
	then
		-- Maybe this came from a different or older Promise library.
		return true
	end

	return false
end

--[=[
	Wraps a function that yields into one that returns a Promise.

	Any errors that occur while executing the function will be turned into rejections.

	:::info
	`Promise.promisify` is similar to [Promise.try](#try), except the callback is returned as a callable function instead of being invoked immediately.
	:::

	```lua
	local sleep = Promise.promisify(wait)

	sleep(1):andThen(print)
	```

	```lua
	local isPlayerInGroup = Promise.promisify(function(player, groupId)
		return player:IsInGroup(groupId)
	end)
	```

	@param callback (...: any) -> ...any
	@return (...: any) -> Promise
]=]
function Promise.promisify(callback)
	return function(...)
		return Promise._try(debug.traceback(nil, 2), callback, ...)
	end
end

--[=[
	Returns a Promise that resolves after `seconds` seconds have passed. The Promise resolves with the actual amount of time that was waited.

	This function is **not** a wrapper around `wait`. `Promise.delay` uses a custom scheduler which provides more accurate timing. As an optimization, cancelling this Promise instantly removes the task from the scheduler.

	:::warning
	Passing `NaN`, infinity, or a number less than 1/60 is equivalent to passing 1/60.
	:::

	```lua
		Promise.delay(5):andThenCall(print, "This prints after 5 seconds")
	```

	@function delay
	@within Promise
	@param seconds number
	@return Promise<number>
]=]
do
	-- uses a sorted doubly linked list (queue) to achieve O(1) remove operations and O(n) for insert

	-- the initial node in the linked list
	local first
	local connection

	function Promise.delay(seconds)
		assert(type(seconds) == "number", "Bad argument #1 to Promise.delay, must be a number.")
		-- If seconds is -INF, INF, NaN, or less than 1 / 60, assume seconds is 1 / 60.
		-- This mirrors the behavior of wait()
		if not (seconds >= 1 / 60) or seconds == math.huge then
			seconds = 1 / 60
		end

		return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
			local startTime = Promise._getTime()
			local endTime = startTime + seconds

			local node = {
				resolve = resolve,
				startTime = startTime,
				endTime = endTime,
			}

			if connection == nil then -- first is nil when connection is nil
				first = node
				connection = Promise._timeEvent:Connect(function()
					local threadStart = Promise._getTime()

					while first ~= nil and first.endTime < threadStart do
						local current = first
						first = current.next

						if first == nil then
							connection:Disconnect()
							connection = nil
						else
							first.previous = nil
						end

						current.resolve(Promise._getTime() - current.startTime)
					end
				end)
			else -- first is non-nil
				if first.endTime < endTime then -- if `node` should be placed after `first`
					-- we will insert `node` between `current` and `next`
					-- (i.e. after `current` if `next` is nil)
					local current = first
					local next = current.next

					while next ~= nil and next.endTime < endTime do
						current = next
						next = current.next
					end

					-- `current` must be non-nil, but `next` could be `nil` (i.e. last item in list)
					current.next = node
					node.previous = current

					if next ~= nil then
						node.next = next
						next.previous = node
					end
				else
					-- set `node` to `first`
					node.next = first
					first.previous = node
					first = node
				end
			end

			onCancel(function()
				-- remove node from queue
				local next = node.next

				if first == node then
					if next == nil then -- if `node` is the first and last
						connection:Disconnect()
						connection = nil
					else -- if `node` is `first` and not the last
						next.previous = nil
					end
					first = next
				else
					local previous = node.previous
					-- since `node` is not `first`, then we know `previous` is non-nil
					previous.next = next

					if next ~= nil then
						next.previous = previous
					end
				end
			end)
		end)
	end
end

--[=[
	Returns a new Promise that resolves if the chained Promise resolves within `seconds` seconds, or rejects if execution time exceeds `seconds`. The chained Promise will be cancelled if the timeout is reached.

	Rejects with `rejectionValue` if it is non-nil. If a `rejectionValue` is not given, it will reject with a `Promise.Error(Promise.Error.Kind.TimedOut)`. This can be checked with [[Error.isKind]].

	```lua
	getSomething():timeout(5):andThen(function(something)
		-- got something and it only took at max 5 seconds
	end):catch(function(e)
		-- Either getting something failed or the time was exceeded.

		if Promise.Error.isKind(e, Promise.Error.Kind.TimedOut) then
			warn("Operation timed out!")
		else
			warn("Operation encountered an error!")
		end
	end)
	```

	Sugar for:

	```lua
	Promise.race({
		Promise.delay(seconds):andThen(function()
			return Promise.reject(
				rejectionValue == nil
				and Promise.Error.new({ kind = Promise.Error.Kind.TimedOut })
				or rejectionValue
			)
		end),
		promise
	})
	```

	@param seconds number
	@param rejectionValue? any -- The value to reject with if the timeout is reached
	@return Promise
]=]
function Promise.prototype:timeout(seconds, rejectionValue)
	local traceback = debug.traceback(nil, 2)

	return Promise.race({
		Promise.delay(seconds):andThen(function()
			return Promise.reject(rejectionValue == nil and Error.new({
				kind = Error.Kind.TimedOut,
				error = "Timed out",
				context = string.format(
					"Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s",
					seconds,
					traceback
				),
			}) or rejectionValue)
		end),
		self,
	})
end

--[=[
	Returns the current Promise status.

	@return Status
]=]
function Promise.prototype:getStatus()
	return self._status
end

--[[
	Creates a new promise that receives the result of this promise.

	The given callbacks are invoked depending on that result.
]]
function Promise.prototype:_andThen(traceback, successHandler, failureHandler)
	self._unhandledRejection = false

	-- If we are already cancelled, we return a cancelled Promise
	if self._status == Promise.Status.Cancelled then
		local promise = Promise.new(function() end)
		promise:cancel()

		return promise
	end

	-- Create a new promise to follow this part of the chain
	return Promise._new(traceback, function(resolve, reject, onCancel)
		-- Our default callbacks just pass values onto the next promise.
		-- This lets success and failure cascade correctly!

		local successCallback = resolve
		if successHandler then
			successCallback = createAdvancer(traceback, successHandler, resolve, reject)
		end

		local failureCallback = reject
		if failureHandler then
			failureCallback = createAdvancer(traceback, failureHandler, resolve, reject)
		end

		if self._status == Promise.Status.Started then
			-- If we haven't resolved yet, put ourselves into the queue
			table.insert(self._queuedResolve, successCallback)
			table.insert(self._queuedReject, failureCallback)

			onCancel(function()
				-- These are guaranteed to exist because the cancellation handler is guaranteed to only
				-- be called at most once
				if self._status == Promise.Status.Started then
					table.remove(self._queuedResolve, table.find(self._queuedResolve, successCallback))
					table.remove(self._queuedReject, table.find(self._queuedReject, failureCallback))
				end
			end)
		elseif self._status == Promise.Status.Resolved then
			-- This promise has already resolved! Trigger success immediately.
			successCallback(unpack(self._values, 1, self._valuesLength))
		elseif self._status == Promise.Status.Rejected then
			-- This promise died a terrible death! Trigger failure immediately.
			failureCallback(unpack(self._values, 1, self._valuesLength))
		end
	end, self)
end

--[=[
	Chains onto an existing Promise and returns a new Promise.

	:::warning
	Within the failure handler, you should never assume that the rejection value is a string. Some rejections within the Promise library are represented by [[Error]] objects. If you want to treat it as a string for debugging, you should call `tostring` on it first.
	:::

	You can return a Promise from the success or failure handler and it will be chained onto.

	Calling `andThen` on a cancelled Promise returns a cancelled Promise.

	:::tip
	If the Promise returned by `andThen` is cancelled, `successHandler` and `failureHandler` will not run.

	To run code no matter what, use [Promise:finally].
	:::

	@param successHandler (...: any) -> ...any
	@param failureHandler? (...: any) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:andThen(successHandler, failureHandler)
	assert(successHandler == nil or isCallable(successHandler), string.format(ERROR_NON_FUNCTION, "Promise:andThen"))
	assert(failureHandler == nil or isCallable(failureHandler), string.format(ERROR_NON_FUNCTION, "Promise:andThen"))

	return self:_andThen(debug.traceback(nil, 2), successHandler, failureHandler)
end

--[=[
	Shorthand for `Promise:andThen(nil, failureHandler)`.

	Returns a Promise that resolves if the `failureHandler` worked without encountering an additional error.

	:::warning
	Within the failure handler, you should never assume that the rejection value is a string. Some rejections within the Promise library are represented by [[Error]] objects. If you want to treat it as a string for debugging, you should call `tostring` on it first.
	:::

	Calling `catch` on a cancelled Promise returns a cancelled Promise.

	:::tip
	If the Promise returned by `catch` is cancelled,  `failureHandler` will not run.

	To run code no matter what, use [Promise:finally].
	:::

	@param failureHandler (...: any) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:catch(failureHandler)
	assert(failureHandler == nil or isCallable(failureHandler), string.format(ERROR_NON_FUNCTION, "Promise:catch"))
	return self:_andThen(debug.traceback(nil, 2), nil, failureHandler)
end

--[=[
	Similar to [Promise.andThen](#andThen), except the return value is the same as the value passed to the handler. In other words, you can insert a `:tap` into a Promise chain without affecting the value that downstream Promises receive.

	```lua
		getTheValue()
		:tap(print)
		:andThen(function(theValue)
			print("Got", theValue, "even though print returns nil!")
		end)
	```

	If you return a Promise from the tap handler callback, its value will be discarded but `tap` will still wait until it resolves before passing the original value through.

	@param tapHandler (...: any) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:tap(tapHandler)
	assert(isCallable(tapHandler), string.format(ERROR_NON_FUNCTION, "Promise:tap"))
	return self:_andThen(debug.traceback(nil, 2), function(...)
		local callbackReturn = tapHandler(...)

		if Promise.is(callbackReturn) then
			local length, values = pack(...)
			return callbackReturn:andThen(function()
				return unpack(values, 1, length)
			end)
		end

		return ...
	end)
end

--[=[
	Attaches an `andThen` handler to this Promise that calls the given callback with the predefined arguments. The resolved value is discarded.

	```lua
		promise:andThenCall(someFunction, "some", "arguments")
	```

	This is sugar for

	```lua
		promise:andThen(function()
		return someFunction("some", "arguments")
		end)
	```

	@param callback (...: any) -> any
	@param ...? any -- Additional arguments which will be passed to `callback`
	@return Promise
]=]
function Promise.prototype:andThenCall(callback, ...)
	assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, "Promise:andThenCall"))
	local length, values = pack(...)
	return self:_andThen(debug.traceback(nil, 2), function()
		return callback(unpack(values, 1, length))
	end)
end

--[=[
	Attaches an `andThen` handler to this Promise that discards the resolved value and returns the given value from it.

	```lua
		promise:andThenReturn("some", "values")
	```

	This is sugar for

	```lua
		promise:andThen(function()
			return "some", "values"
		end)
	```

	:::caution
	Promises are eager, so if you pass a Promise to `andThenReturn`, it will begin executing before `andThenReturn` is reached in the chain. Likewise, if you pass a Promise created from [[Promise.reject]] into `andThenReturn`, it's possible that this will trigger the unhandled rejection warning. If you need to return a Promise, it's usually best practice to use [[Promise.andThen]].
	:::

	@param ... any -- Values to return from the function
	@return Promise
]=]
function Promise.prototype:andThenReturn(...)
	local length, values = pack(...)
	return self:_andThen(debug.traceback(nil, 2), function()
		return unpack(values, 1, length)
	end)
end

--[=[
	Cancels this promise, preventing the promise from resolving or rejecting. Does not do anything if the promise is already settled.

	Cancellations will propagate upwards and downwards through chained promises.

	Promises will only be cancelled if all of their consumers are also cancelled. This is to say that if you call `andThen` twice on the same promise, and you cancel only one of the child promises, it will not cancel the parent promise until the other child promise is also cancelled.

	```lua
		promise:cancel()
	```
]=]
function Promise.prototype:cancel()
	if self._status ~= Promise.Status.Started then
		return
	end

	self._status = Promise.Status.Cancelled

	if self._cancellationHook then
		self._cancellationHook()
	end

	coroutine.close(self._thread)

	if self._parent then
		self._parent:_consumerCancelled(self)
	end

	for child in pairs(self._consumers) do
		child:cancel()
	end

	self:_finalize()
end

--[[
	Used to decrease the number of consumers by 1, and if there are no more,
	cancel this promise.
]]
function Promise.prototype:_consumerCancelled(consumer)
	if self._status ~= Promise.Status.Started then
		return
	end

	self._consumers[consumer] = nil

	if next(self._consumers) == nil then
		self:cancel()
	end
end

--[[
	Used to set a handler for when the promise resolves, rejects, or is
	cancelled.
]]
function Promise.prototype:_finally(traceback, finallyHandler)
	self._unhandledRejection = false

	local promise = Promise._new(traceback, function(resolve, reject, onCancel)
		local handlerPromise

		onCancel(function()
			-- The finally Promise is not a proper consumer of self. We don't care about the resolved value.
			-- All we care about is running at the end. Therefore, if self has no other consumers, it's safe to
			-- cancel. We don't need to hold out cancelling just because there's a finally handler.
			self:_consumerCancelled(self)

			if handlerPromise then
				handlerPromise:cancel()
			end
		end)

		local finallyCallback = resolve
		if finallyHandler then
			finallyCallback = function(...)
				local callbackReturn = finallyHandler(...)

				if Promise.is(callbackReturn) then
					handlerPromise = callbackReturn

					callbackReturn
						:finally(function(status)
							if status ~= Promise.Status.Rejected then
								resolve(self)
							end
						end)
						:catch(function(...)
							reject(...)
						end)
				else
					resolve(self)
				end
			end
		end

		if self._status == Promise.Status.Started then
			-- The promise is not settled, so queue this.
			table.insert(self._queuedFinally, finallyCallback)
		else
			-- The promise already settled or was cancelled, run the callback now.
			finallyCallback(self._status)
		end
	end)

	return promise
end

--[=[
	Set a handler that will be called regardless of the promise's fate. The handler is called when the promise is
	resolved, rejected, *or* cancelled.

	Returns a new Promise that:
	- resolves with the same values that this Promise resolves with.
	- rejects with the same values that this Promise rejects with.
	- is cancelled if this Promise is cancelled.

	If the value you return from the handler is a Promise:
	- We wait for the Promise to resolve, but we ultimately discard the resolved value.
	- If the returned Promise rejects, the Promise returned from `finally` will reject with the rejected value from the
	*returned* promise.
	- If the `finally` Promise is cancelled, and you returned a Promise from the handler, we cancel that Promise too.

	Otherwise, the return value from the `finally` handler is entirely discarded.

	:::note Cancellation
	As of Promise v4, `Promise:finally` does not count as a consumer of the parent Promise for cancellation purposes.
	This means that if all of a Promise's consumers are cancelled and the only remaining callbacks are finally handlers,
	the Promise is cancelled and the finally callbacks run then and there.

	Cancellation still propagates through the `finally` Promise though: if you cancel the `finally` Promise, it can cancel
	its parent Promise if it had no other consumers. Likewise, if the parent Promise is cancelled, the `finally` Promise
	will also be cancelled.
	:::

	```lua
	local thing = createSomething()

	doSomethingWith(thing)
		:andThen(function()
			print("It worked!")
			-- do something..
		end)
		:catch(function()
			warn("Oh no it failed!")
		end)
		:finally(function()
			-- either way, destroy thing

			thing:Destroy()
		end)

	```

	@param finallyHandler (status: Status) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:finally(finallyHandler)
	assert(finallyHandler == nil or isCallable(finallyHandler), string.format(ERROR_NON_FUNCTION, "Promise:finally"))
	return self:_finally(debug.traceback(nil, 2), finallyHandler)
end

--[=[
	Same as `andThenCall`, except for `finally`.

	Attaches a `finally` handler to this Promise that calls the given callback with the predefined arguments.

	@param callback (...: any) -> any
	@param ...? any -- Additional arguments which will be passed to `callback`
	@return Promise
]=]
function Promise.prototype:finallyCall(callback, ...)
	assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, "Promise:finallyCall"))
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return callback(unpack(values, 1, length))
	end)
end

--[=[
	Attaches a `finally` handler to this Promise that discards the resolved value and returns the given value from it.

	```lua
		promise:finallyReturn("some", "values")
	```

	This is sugar for

	```lua
		promise:finally(function()
			return "some", "values"
		end)
	```

	@param ... any -- Values to return from the function
	@return Promise
]=]
function Promise.prototype:finallyReturn(...)
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return unpack(values, 1, length)
	end)
end

--[=[
	Yields the current thread until the given Promise completes. Returns the Promise's status, followed by the values that the promise resolved or rejected with.

	@yields
	@return Status -- The Status representing the fate of the Promise
	@return ...any -- The values the Promise resolved or rejected with.
]=]
function Promise.prototype:awaitStatus()
	self._unhandledRejection = false

	if self._status == Promise.Status.Started then
		local thread = coroutine.running()

		self
			:finally(function()
				task.spawn(thread)
			end)
			-- The finally promise can propagate rejections, so we attach a catch handler to prevent the unhandled
			-- rejection warning from appearing
			:catch(
				function() end
			)

		coroutine.yield()
	end

	if self._status == Promise.Status.Resolved then
		return self._status, unpack(self._values, 1, self._valuesLength)
	elseif self._status == Promise.Status.Rejected then
		return self._status, unpack(self._values, 1, self._valuesLength)
	end

	return self._status
end

local function awaitHelper(status, ...)
	return status == Promise.Status.Resolved, ...
end

--[=[
	Yields the current thread until the given Promise completes. Returns true if the Promise resolved, followed by the values that the promise resolved or rejected with.

	:::caution
	If the Promise gets cancelled, this function will return `false`, which is indistinguishable from a rejection. If you need to differentiate, you should use [[Promise.awaitStatus]] instead.
	:::

	```lua
		local worked, value = getTheValue():await()

	if worked then
		print("got", value)
	else
		warn("it failed")
	end
	```

	@yields
	@return boolean -- `true` if the Promise successfully resolved
	@return ...any -- The values the Promise resolved or rejected with.
]=]
function Promise.prototype:await()
	return awaitHelper(self:awaitStatus())
end

local function expectHelper(status, ...)
	if status ~= Promise.Status.Resolved then
		error((...) == nil and "Expected Promise rejected with no value." or (...), 3)
	end

	return ...
end

--[=[
	Yields the current thread until the given Promise completes. Returns the values that the promise resolved with.

	```lua
	local worked = pcall(function()
		print("got", getTheValue():expect())
	end)

	if not worked then
		warn("it failed")
	end
	```

	This is essentially sugar for:

	```lua
	select(2, assert(promise:await()))
	```

	**Errors** if the Promise rejects or gets cancelled.

	@error any -- Errors with the rejection value if this Promise rejects or gets cancelled.
	@yields
	@return ...any -- The values the Promise resolved with.
]=]
function Promise.prototype:expect()
	return expectHelper(self:awaitStatus())
end

-- Backwards compatibility
Promise.prototype.awaitValue = Promise.prototype.expect

--[[
	Intended for use in tests.

	Similar to await(), but instead of yielding if the promise is unresolved,
	_unwrap will throw. This indicates an assumption that a promise has
	resolved.
]]
function Promise.prototype:_unwrap()
	if self._status == Promise.Status.Started then
		error("Promise has not resolved or rejected.", 2)
	end

	local success = self._status == Promise.Status.Resolved

	return success, unpack(self._values, 1, self._valuesLength)
end

function Promise.prototype:_resolve(...)
	if self._status ~= Promise.Status.Started then
		if Promise.is((...)) then
			(...):_consumerCancelled(self)
		end
		return
	end

	-- If the resolved value was a Promise, we chain onto it!
	if Promise.is((...)) then
		-- Without this warning, arguments sometimes mysteriously disappear
		if select("#", ...) > 1 then
			local message = string.format(
				"When returning a Promise from andThen, extra arguments are " .. "discarded! See:\n\n%s",
				self._source
			)
			warn(message)
		end

		local chainedPromise = ...

		local promise = chainedPromise:andThen(function(...)
			self:_resolve(...)
		end, function(...)
			local maybeRuntimeError = chainedPromise._values[1]

			-- Backwards compatibility < v2
			if chainedPromise._error then
				maybeRuntimeError = Error.new({
					error = chainedPromise._error,
					kind = Error.Kind.ExecutionError,
					context = "[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]",
				})
			end

			if Error.isKind(maybeRuntimeError, Error.Kind.ExecutionError) then
				return self:_reject(maybeRuntimeError:extend({
					error = "This Promise was chained to a Promise that errored.",
					trace = "",
					context = string.format(
						"The Promise at:\n\n%s\n...Rejected because it was chained to the following Promise, which encountered an error:\n",
						self._source
					),
				}))
			end

			self:_reject(...)
		end)

		if promise._status == Promise.Status.Cancelled then
			self:cancel()
		elseif promise._status == Promise.Status.Started then
			-- Adopt ourselves into promise for cancellation propagation.
			self._parent = promise
			promise._consumers[self] = true
		end

		return
	end

	self._status = Promise.Status.Resolved
	self._valuesLength, self._values = pack(...)

	-- We assume that these callbacks will not throw errors.
	for _, callback in ipairs(self._queuedResolve) do
		coroutine.wrap(callback)(...)
	end

	self:_finalize()
end

function Promise.prototype:_reject(...)
	if self._status ~= Promise.Status.Started then
		return
	end

	self._status = Promise.Status.Rejected
	self._valuesLength, self._values = pack(...)

	-- If there are any rejection handlers, call those!
	if not isEmpty(self._queuedReject) then
		-- We assume that these callbacks will not throw errors.
		for _, callback in ipairs(self._queuedReject) do
			coroutine.wrap(callback)(...)
		end
	else
		-- At this point, no one was able to observe the error.
		-- An error handler might still be attached if the error occurred
		-- synchronously. We'll wait one tick, and if there are still no
		-- observers, then we should put a message in the console.

		local err = tostring((...))

		coroutine.wrap(function()
			Promise._timeEvent:Wait()

			-- Someone observed the error, hooray!
			if not self._unhandledRejection then
				return
			end

			-- Build a reasonable message
			local message = string.format("Unhandled Promise rejection:\n\n%s\n\n%s", err, self._source)

			for _, callback in ipairs(Promise._unhandledRejectionCallbacks) do
				task.spawn(callback, self, unpack(self._values, 1, self._valuesLength))
			end

			if Promise.TEST then
				-- Don't spam output when we're running tests.
				return
			end

			warn(message)
		end)()
	end

	self:_finalize()
end

--[[
	Calls any :finally handlers. We need this to be a separate method and
	queue because we must call all of the finally callbacks upon a success,
	failure, *and* cancellation.
]]
function Promise.prototype:_finalize()
	for _, callback in ipairs(self._queuedFinally) do
		-- Purposefully not passing values to callbacks here, as it could be the
		-- resolved values, or rejected errors. If the developer needs the values,
		-- they should use :andThen or :catch explicitly.
		coroutine.wrap(callback)(self._status)
	end

	self._queuedFinally = nil
	self._queuedReject = nil
	self._queuedResolve = nil

	-- Clear references to other Promises to allow gc
	if not Promise.TEST then
		self._parent = nil
		self._consumers = nil
	end

	task.defer(coroutine.close, self._thread)
end

--[=[
	Chains a Promise from this one that is resolved if this Promise is already resolved, and rejected if it is not resolved at the time of calling `:now()`. This can be used to ensure your `andThen` handler occurs on the same frame as the root Promise execution.

	```lua
	doSomething()
		:now()
		:andThen(function(value)
			print("Got", value, "synchronously.")
		end)
	```

	If this Promise is still running, Rejected, or Cancelled, the Promise returned from `:now()` will reject with the `rejectionValue` if passed, otherwise with a `Promise.Error(Promise.Error.Kind.NotResolvedInTime)`. This can be checked with [[Error.isKind]].

	@param rejectionValue? any -- The value to reject with if the Promise isn't resolved
	@return Promise
]=]
function Promise.prototype:now(rejectionValue)
	local traceback = debug.traceback(nil, 2)
	if self._status == Promise.Status.Resolved then
		return self:_andThen(traceback, function(...)
			return ...
		end)
	else
		return Promise.reject(rejectionValue == nil and Error.new({
			kind = Error.Kind.NotResolvedInTime,
			error = "This Promise was not resolved in time for :now()",
			context = ":now() was called at:\n\n" .. traceback,
		}) or rejectionValue)
	end
end

--[=[
	Repeatedly calls a Promise-returning function up to `times` number of times, until the returned Promise resolves.

	If the amount of retries is exceeded, the function will return the latest rejected Promise.

	```lua
	local function canFail(a, b, c)
		return Promise.new(function(resolve, reject)
			-- do something that can fail

			local failed, thing = doSomethingThatCanFail(a, b, c)

			if failed then
				reject("it failed")
			else
				resolve(thing)
			end
		end)
	end

	local MAX_RETRIES = 10
	local value = Promise.retry(canFail, MAX_RETRIES, "foo", "bar", "baz") -- args to send to canFail
	```

	@since 3.0.0
	@param callback (...: P) -> Promise<T>
	@param times number
	@param ...? P
	@return Promise<T>
]=]
function Promise.retry(callback, times, ...)
	assert(isCallable(callback), "Parameter #1 to Promise.retry must be a function")
	assert(type(times) == "number", "Parameter #2 to Promise.retry must be a number")

	local args, length = { ... }, select("#", ...)

	return Promise.resolve(callback(...)):catch(function(...)
		if times > 0 then
			return Promise.retry(callback, times - 1, unpack(args, 1, length))
		else
			return Promise.reject(...)
		end
	end)
end

--[=[
	Repeatedly calls a Promise-returning function up to `times` number of times, waiting `seconds` seconds between each
	retry, until the returned Promise resolves.

	If the amount of retries is exceeded, the function will return the latest rejected Promise.

	@since v3.2.0
	@param callback (...: P) -> Promise<T>
	@param times number
	@param seconds number
	@param ...? P
	@return Promise<T>
]=]
function Promise.retryWithDelay(callback, times, seconds, ...)
	assert(isCallable(callback), "Parameter #1 to Promise.retry must be a function")
	assert(type(times) == "number", "Parameter #2 (times) to Promise.retry must be a number")
	assert(type(seconds) == "number", "Parameter #3 (seconds) to Promise.retry must be a number")

	local args, length = { ... }, select("#", ...)

	return Promise.resolve(callback(...)):catch(function(...)
		if times > 0 then
			Promise.delay(seconds):await()

			return Promise.retryWithDelay(callback, times - 1, seconds, unpack(args, 1, length))
		else
			return Promise.reject(...)
		end
	end)
end

--[=[
	Converts an event into a Promise which resolves the next time the event fires.

	The optional `predicate` callback, if passed, will receive the event arguments and should return `true` or `false`, based on if this fired event should resolve the Promise or not. If `true`, the Promise resolves. If `false`, nothing happens and the predicate will be rerun the next time the event fires.

	The Promise will resolve with the event arguments.

	:::tip
	This function will work given any object with a `Connect` method. This includes all Roblox events.
	:::

	```lua
	-- Creates a Promise which only resolves when `somePart` is touched
	-- by a part named `"Something specific"`.
	return Promise.fromEvent(somePart.Touched, function(part)
		return part.Name == "Something specific"
	end)
	```

	@since 3.0.0
	@param event Event -- Any object with a `Connect` method. This includes all Roblox events.
	@param predicate? (...: P) -> boolean -- A function which determines if the Promise should resolve with the given value, or wait for the next event to check again.
	@return Promise<P>
]=]
function Promise.fromEvent(event, predicate)
	predicate = predicate or function()
		return true
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
		local connection
		local shouldDisconnect = false

		local function disconnect()
			connection:Disconnect()
			connection = nil
		end

		-- We use shouldDisconnect because if the callback given to Connect is called before
		-- Connect returns, connection will still be nil. This happens with events that queue up
		-- events when there's nothing connected, such as RemoteEvents

		connection = event:Connect(function(...)
			local callbackValue = predicate(...)

			if callbackValue == true then
				resolve(...)

				if connection then
					disconnect()
				else
					shouldDisconnect = true
				end
			elseif type(callbackValue) ~= "boolean" then
				error("Promise.fromEvent predicate should always return a boolean")
			end
		end)

		if shouldDisconnect and connection then
			return disconnect()
		end

		onCancel(disconnect)
	end)
end

--[=[
	Registers a callback that runs when an unhandled rejection happens. An unhandled rejection happens when a Promise
	is rejected, and the rejection is not observed with `:catch`.

	The callback is called with the actual promise that rejected, followed by the rejection values.

	@since v3.2.0
	@param callback (promise: Promise, ...: any) -- A callback that runs when an unhandled rejection happens.
	@return () -> () -- Function that unregisters the `callback` when called
]=]
function Promise.onUnhandledRejection(callback)
	table.insert(Promise._unhandledRejectionCallbacks, callback)

	return function()
		local index = table.find(Promise._unhandledRejectionCallbacks, callback)

		if index then
			table.remove(Promise._unhandledRejectionCallbacks, index)
		end
	end
end

return Promise
end)
__bundle_register("games/Islands/services/NotificationService", function(require, _LOADED, __bundle_register, __bundle_modules)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Flamework = require(ReplicatedStorage.rbxts_include.node_modules['@flamework'].core.out).Flamework
local IslandsNotificationController = Flamework.resolveDependency(
    "client/flame/controllers/notifications/islands-notification-controller@IslandsNotificationController"
)

local NotificationService = {}

NotificationService.Icons = require(ReplicatedStorage.TS.image.image).Image

function NotificationService:DisplayNotification(options)
    local resolvedOptions = {
        largeIcon = options.largeIcon or "rbxthumb://type=AvatarHeadShot&id=" .. Players.LocalPlayer.UserId .. "&w=150&h=150",
        gameId = options.gameId or "bedwars",
        title = title or string.upper("Project Floppa"),
        message = message or "Unknown Message"
    }
    
    IslandsNotificationController:displayNotification(resolvedOptions);
end

return NotificationService
end)
__bundle_register("games/Islands/services/NetworkService", function(require, _LOADED, __bundle_register, __bundle_modules)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotesPath = ReplicatedStorage.rbxts_include.node_modules.net.out._NetManaged

local NetworkService = {}

function NetworkService:FireBlockBreak(args)
    --[[
        arguments example:
        {
            ["player_tracking_category"] = "join_from_web",
            ["part"] = workspace.WildernessBlocks.rockAndesite["1"],
            ["block"] = workspace.WildernessBlocks.rockAndesite,
            ["norm"] = 235.67018127441406, 26.330665588378906, -521.550048828125,
            ["pos"] = 0.7484670281410217, 0.3499663770198822, -0.5633125305175781
        }
    ]]
    return remotesPath.CLIENT_BLOCK_HIT_REQUEST:InvokeServer(args)
end

return NetworkService
end)
__bundle_register("games/Islands/ui/farming/OreFarm", function(require, _LOADED, __bundle_register, __bundle_modules)
local NetworkService = require("games/Islands/services/NetworkService")
local NotificationService = require("games/Islands/services/NotificationService")

local IslandsUtils = require("games/Islands/IslandsUtils")
local rocks = require("games/Islands/constants").Rocks

local oreFarmMaid = require("modules/util/Maid").new()

local localPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

local selectedOre = "rockIron"
local range = 250
local currentlyMining = false
local faster = false

local elapsed = tick()

local function getClosestRock(rockName, useHub)
    local rockPath = useHub and game.Workspace.WildernessBlocks or IslandsUtils:GetLocalPlayerIsland().Blocks
    local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not root then return end

    local distance = tonumber(range)
    local closest = false

    for _, v in next, rockPath:GetChildren() do
        if v.Name == rockName then
            local newDistance = localPlayer:DistanceFromCharacter(v.Position)
            if newDistance < distance then
                closest = v
                distance = newDistance
            end
        end
    end

    return closest
end

local function farmRock(rockName, useHub)
    local rockPath = useHub and game.Workspace.WildernessBlocks or IslandsUtils:GetLocalPlayerIsland().Blocks
    if not rockPath then return end

    local rock = getClosestRock(rockName, useHub)
    if not rock then 
        NotificationService:DisplayNotification({
            message = "No ".. rockName .. " was found near you, waiting until one is found."
        }) 
    end

    currentlyMining = true

    local teleportPromise = IslandsUtils:Teleport(rock.CFrame)()
        :andThen(function()
            if not faster then
                repeat
                    if tick() - elapsed >= 3 then
                        --teleportPromise:cancel()
                        currentlyMining = false
                        elapsed = tick()
                        return
                    end

                    task.wait()
                    NetworkService:FireBlockBreak({
                        ["player_tracking_category"] = "join_from_web",
                        ["part"] = rock:FindFirstChild("1"),
                        ["block"] = rock,
                        ["norm"] = Vector3.new(-3498.322265625, 37.062782287598, -3482.3693847656),
                        ["pos"] = rock.Position
                    })

                    --if not rock then
                    --   teleportPromise:cancel()
                    --end

                until not rock

                currentlyMining = false
                return
            end
        end)
        :catch(function(err)
            warn("Error when teleporting to ore: ", err)
        end)

    if faster then
        -- // used to combat the anti cheat tp-ing us back
        repeat
            if tick() - elapsed >= 3 then
                teleportPromise:cancel()
                currentlyMining = false
                elapsed = tick()
                return
            end
    
            task.wait()
            NetworkService:FireBlockBreak({
                ["player_tracking_category"] = "join_from_web",
                ["part"] = rock:FindFirstChild("1"),
                ["block"] = rock,
                ["norm"] = Vector3.new(-3498.322265625, 37.062782287598, -3482.3693847656),
                ["pos"] = rock.Position
            })

            if not rock then
               teleportPromise:cancel()
            end

        until not rock

        currentlyMining = false
    end
end

return function (Library, Window, FarmingTab)
    local OreFarmSection = FarmingTab:AddSection("Ore Farm", { default = false })

    OreFarmSection:AddToggle("Enabled", { flag = "OreFarmEnabled"}, function(state)
        if state then
            oreFarmMaid:GiveTask(RunService.Heartbeat:Connect(function()
				if currentlyMining then return end
                farmRock(selectedOre, true)
            end))
		else
			oreFarmMaid:DoCleaning()
        end
    end)
    OreFarmSection:AddToggle("Faster Farming (Can Lag)", { flag = "OreFarmFasterFarming" }, function(state)
        faster = state
    end)
    OreFarmSection:AddDropdown("Ore Selected", rocks, {default = "rockIron", flag = "OreFarmOreSelected"}, function(selected)
        selectedOre = selected
    end)
    OreFarmSection:AddSlider("Ore Range", 100, 3000, 250, { flag = "OreFarmRange", rounded = true }, function(value)
        range = value
    end)
end

end)
__bundle_register("modules/exploit/ui/Vynixius", function(require, _LOADED, __bundle_register, __bundle_modules)
--[[
    Made by RegularVynixu
    Edited by me, Death_Blows
]]

--[[
	Midnight = {
        SchemeColor = Color3.fromRGB(26, 189, 158),
        Background = Color3.fromRGB(44, 62, 82),
        Header = Color3.fromRGB(57, 81, 105),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(52, 74, 95)
    },
]]

--[[
	old:
	Accent = Color3.fromRGB(0, 255, 0),
		TopbarColor = Color3.fromRGB(23, 23, 23),
		SidebarColor = Color3.fromRGB(20, 20, 20),
		BackgroundColor = Color3.fromRGB(15, 15, 15),
		SectionColor = Color3.fromRGB(23, 23, 23),
		TextColor = Color3.fromRGB(255, 255, 255),
]]


local midnightTheme = {
	Accent = Color3.fromRGB(26, 189, 158),
	TopbarColor = Color3.fromRGB(70, 93, 117),
	SidebarColor = Color3.fromRGB(57, 81, 105),
	BackgroundColor = Color3.fromRGB(44, 62, 82),
	SectionColor = Color3.fromRGB(52, 74, 95),
	TextColor = Color3.fromRGB(255, 255, 255),
}

local oceanTheme = {
	Accent = Color3.fromRGB(86, 76, 251),
	TopbarColor = Color3.fromRGB(38, 45, 71),
	SidebarColor = Color3.fromRGB(38, 45, 71),
	BackgroundColor = Color3.fromRGB(26, 32, 58),
	SectionColor = Color3.fromRGB(38, 45, 71),
	TextColor = Color3.fromRGB(200, 200, 200),
}

local Library = {
	Theme = midnightTheme,
	Notif = {
		Active = {},
		Queue = {},
		IsBusy = false,
	},
	Settings = {
		ConfigPath = "ass",
		MaxNotifLines = 5,
		MaxNotifStacking = 5,
	},
}

-- Services

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local TXS = game:GetService("TextService")
local HS = game:GetService("HttpService")
local CG = game.CoreGui
-- Variables

local get = game.HttpService.GetAsync

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local SelfModules = {
	UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/UI.lua"))(),
	Directory = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Directory.lua"))(),
}
local Storage = { Connections = {}, Tween = { Cosmetic = {} } }

local ListenForInput = false

-- Directory
local Directory = SelfModules.Directory.Create({
	["Vynixius UI Library"] = {
		"Configs",
	},
})

-- Misc Functions

local function tween(...)
	local args = {...}

	if typeof(args[2]) ~= "string" then
		table.insert(args, 2, "")
	end

	local tween = TS:Create(args[1], TweenInfo.new(args[3], Enum.EasingStyle.Quint), args[4])

	if args[2] == "Cosmetic" then
		Storage.Tween.Cosmetic[args[1]] = tween

		task.spawn(function()
			task.wait(args[3])

			if Storage.Tween.Cosmetic[tween] then
				Storage.Tween.Cosmetic[tween] = nil
			end
		end)
	end

	tween:Play()
end

-- Functions

local ScreenGui = SelfModules.UI.Create("ScreenGui", {
	Name = "Vynixius UI Library",
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

function Library:Destroy()
	if ScreenGui.Parent then
		ScreenGui:Destroy()
	end
end

function Library:Notify(options, callback)
	if Library.Notif.IsBusy == true then
		Library.Notif.Queue[#Library.Notif.Queue + 1] = { options, callback }
		return
	end	

	Library.Notif.IsBusy = true

	local Notification = {
		Type = "Notification",
		Selection = nil,
		Callback = callback,
	}

	Notification.Frame = SelfModules.UI.Create("Frame", {
		Name = "Notification",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, 10, 1, -66),
		Size = UDim2.new(0, 320, 0, 42 + Library.Settings.MaxNotifLines * 14),

		SelfModules.UI.Create("Frame", {
			Name = "Topbar",
			BackgroundColor3 = Library.Theme.TopbarColor,
			Size = UDim2.new(1, 0, 0, 28),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.TopbarColor,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0.5, 0),
			}),

			SelfModules.UI.Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 7, 0.5, -8),
				Size = UDim2.new(1, -54, 0, 16),
				Font = Enum.Font.SourceSans,
				Text = options.title or "Notification",
				TextColor3 = Library.Theme.TextColor,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			SelfModules.UI.Create("ImageButton", {
				Name = "Yes",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -24, 0.5, -10),
				Size = UDim2.new(0, 20, 0, 20),
				Image = "http://www.roblox.com/asset/?id=7919581359",
				ImageColor3 = Library.Theme.TextColor,
			}),

			SelfModules.UI.Create("ImageButton", {
				Name = "No",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -2, 0.5, -10),
				Size = UDim2.new(0, 20, 0, 20),
				Image = "http://www.roblox.com/asset/?id=7919583990",
				ImageColor3 = Library.Theme.TextColor,
			}),
		}, UDim.new(0,5)),

		SelfModules.UI.Create("Frame", {
			Name = "Background",
			BackgroundColor3 = Library.Theme.BackgroundColor,
			Position = UDim2.new(0, 0, 0, 28),
			Size = UDim2.new(1, 0, 1, -28),

			SelfModules.UI.Create("TextLabel", {
				Name = "Description",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 7, 0, 7),
				Size = UDim2.new(1, -14, 1, -14),
				Font = Enum.Font.SourceSans,
				Text = options.text,
				TextColor3 = Library.Theme.TextColor,
				TextSize = 14,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.BackgroundColor,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 5),
			}),
		}, UDim.new(0, 5)),
	})

	if options.color ~= nil then
		local indicator = SelfModules.UI.Create("Frame", {
			Name = "Indicator",
			BackgroundColor3 = options.color,
			Size = UDim2.new(0, 4, 1, 0),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = options.color,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
			}),
		}, UDim.new(0, 3))

		Notification.Frame.Topbar.Title.Position = UDim2.new(0, 11, 0.5, -8)
		Notification.Frame.Topbar.Title.Size = UDim2.new(1, -60, 0, 16)
		Notification.Frame.Background.Description.Position = UDim2.new(0, 11, 0, 7)
		Notification.Frame.Background.Description.Size = UDim2.new(1, -18, 1, -14)
		indicator.Parent = Notification.Frame
	end

	-- Functions

	function Notification:GetHeight()
		local desc = self.Frame.Background.Description

		return 42 + math.round(TXS:GetTextSize(desc.Text, 14, Enum.Font.SourceSans, Vector2.new(desc.AbsoluteSize.X, Library.Settings.MaxNotifStacking * 14)).Y + 0.5)
	end

	function Notification:Select(bool)
		tween(self.Frame.Topbar[bool and "Yes" or "No"], 0.1, { ImageColor3 = bool and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75) })
		tween(self.Frame, 0.5, { Position = UDim2.new(0, -320, 0, self.Frame.AbsolutePosition.Y) })

		local notifIdx = table.find(Library.Notif.Active, self)

		if notifIdx then
			table.remove(Library.Notif.Active, notifIdx)
			task.delay(0.5, self.Frame.Destroy, self.Frame)
		end

		pcall(task.spawn, self.Callback, bool)
	end

	-- Scripts

	Library.Notif.Active[#Library.Notif.Active + 1] = Notification
	Storage.Connections[Notification] = {}
	Notification.Frame.Size = UDim2.new(0, 320, 0, Notification:GetHeight())
	Notification.Frame.Position = UDim2.new(0, -320, 1, -Notification:GetHeight() - 10)
	Notification.Frame.Parent = ScreenGui

	if #Library.Notif.Active > Library.Settings.MaxNotifStacking then
		Library.Notif.Active[1]:Select(false)
	end

	for i, v in next, Library.Notif.Active do
		if v ~= Notification then
			tween(v.Frame, 0.5, { Position = v.Frame.Position - UDim2.new(0, 0, 0, Notification:GetHeight() + 10) })
		end
	end

	tween(Notification.Frame, 0.5, { Position = UDim2.new(0, 10, 1, -Notification:GetHeight() - 10) })

	task.spawn(function()
		task.wait(0.5)

		Storage.Connections[Notification].Yes = Notification.Frame.Topbar.Yes.Activated:Connect(function()
			Notification:Select(true)
		end)

		Storage.Connections[Notification].No = Notification.Frame.Topbar.No.Activated:Connect(function()
			Notification:Select(false)
		end)

		Library.Notif.IsBusy = false

		if #Library.Notif.Queue > 0 then
			local notif = Library.Notif.Queue[1]
			table.remove(Library.Notif.Queue, 1)

			Library:Notify(notif[1], notif[2])
		end
	end)

	task.spawn(function()
		task.wait(options.duration or 10)

		if Notification.Frame.Parent ~= nil then
			Notification:Select(false)
		end
	end)

	return Notification
end

function Library:AddWindow(options)
	assert(options, "No options data assigned to Window")

	local Window = {
		Name = options.title[1].. " ".. options.title[2],
		Type = "Window",
		Tabs = {},
		Sidebar = { List = {}, Toggled = false },
		Key = options.key or Enum.KeyCode.RightControl,
		Toggled = options.default ~= false,
	}

	-- Custom theme setup

	if options.theme ~= nil then
		for i, v in next, options.theme do
			for i2, _ in next, Library.Theme do
				if string.lower(i) == string.lower(i2) and typeof(v) == "Color3" then
					Library.Theme[i2] = v
				end
			end
		end
	end

	-- Window construction

	Window.Frame = SelfModules.UI.Create("Frame", {
		Name = "Window",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 400, 0, 497),
		Position = UDim2.new(1, -490, 1, -527),
		Visible = options.default ~= false,

		SelfModules.UI.Create("Frame", {
			Name = "Topbar",
			BackgroundColor3 = Library.Theme.TopbarColor,
			Size = UDim2.new(1, 100, 0, 40),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.TopbarColor,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0.5, 0),
			}),

			SelfModules.UI.Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 19),
				Size = UDim2.new(1, -46, 0, 16),
				Font = Enum.Font.GothamBold,
				Text = string.format("%s - <font color='%s'>%s</font>", options.title[1], SelfModules.UI.Color.ToFormat(SelfModules.UI.Color.Add(Library.Theme.Accent, Color3.fromRGB(40, 40, 40))), options.title[2]),
				RichText = true,
				TextColor3 = Library.Theme.TextColor,
				TextSize = 15,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				
			}),
		}, UDim.new(0, 5)),

		SelfModules.UI.Create("Frame", {
			Name = "Background",
			BackgroundColor3 = Library.Theme.BackgroundColor,
			Position = UDim2.new(0, 30, 0, 40),
			Size = UDim2.new(1, -30, 1, -40),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.BackgroundColor,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 5),
			}),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.BackgroundColor,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 5, 1, 0),
			}),

			SelfModules.UI.Create("Frame", {
				Name = "Tabs",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.BackgroundColor, Color3.fromRGB(15, 15, 15)),
				Position = UDim2.new(0, 3, 0, 3),
				Size = UDim2.new(1, -6, 1, -6),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.BackgroundColor, Color3.fromRGB(5, 5, 5)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5)),

		SelfModules.UI.Create("Frame", {
			Name = "Sidebar",
			BackgroundColor3 = Library.Theme.SidebarColor,
			Position = UDim2.new(0, 0, 0, 40),
			Size = UDim2.new(0, 30, 1, -40),
			ZIndex = 2,

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.SidebarColor,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 5),
			}),

			SelfModules.UI.Create("Frame", {
				Name = "Filling",
				BackgroundColor3 = Library.Theme.SidebarColor,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -5, 0, 0),
				Size = UDim2.new(0, 5, 1, 0),
			}),

			SelfModules.UI.Create("Frame", {
				Name = "Border",
				BackgroundColor3 = Library.Theme.BackgroundColor,
				BorderSizePixel = 0,
				Position = UDim2.new(1, 0, 0, 0),
				Selectable = true,
				Size = UDim2.new(0, 5, 1, 0),
				ZIndex = 2,
			}),

			SelfModules.UI.Create("Frame", {
				Name = "Line",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(10, 10, 10)),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 5, 0, 29),
				Size = UDim2.new(1, -10, 0, 2),
			}),

			SelfModules.UI.Create("ScrollingFrame", {
				Name = "List",
				Active = true,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Position = UDim2.new(0.01, 5, 0, 35),
				Size = UDim2.new(1, -10, 1, -40),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarThickness = 5,

				SelfModules.UI.Create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 5),
				}),
			}),

			--[[SelfModules.UI.Create("TextLabel", {
				Name = "Indicator",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -30, 0, 0),
				Size = UDim2.new(0, 30, 0, 30),
				Font = Enum.Font.SourceSansBold,
				Text = "+",
				TextColor3 = Library.Theme.TextColor,
				TextSize = 20,
				Rotation = 45
			}),--]]
		}, UDim.new(0, 5))
	})

	-- Functions

	local function saveConfig(filePath)
		local config = { Flags = {}, Binds = {}, Sliders = {}, Pickers = {} }
		
		for _, tab in next, Window.Tabs do
			for flag, value in next, tab.Flags do
				config.Flags[flag] = value
			end

			for _, section in next, tab.Sections do
				for _, item in next, section.List do
					local flag = item.Flag or item.Name

					if item.Type == "Bind" then
						config.Binds[flag] = item.Bind.Name

					elseif item.Type == "Slider" then
						config.Sliders[flag] = item.Value

					elseif item.Type == "Picker" then
						config.Pickers[flag] = { Color = item.Color, Rainbow = item.Rainbow }

					elseif item.Type == "SubSection" then
						for _, item2 in next, item.List do
							local flag2 = item2.Flag or item2.Name

							if item2.Type == "Bind" then
								config.Binds[flag2] = item2.Bind.Name

							elseif item2.Type == "Slider" then
								config.Sliders[flag2] = item2.Value

							elseif item2.Type == "Picker" then
								config.Pickers[flag2] = { Color = item2.Color, Rainbow = item2.Rainbow }
							end
						end
					end
				end
			end
		end
	end

	local function loadConfig(filePath)
		local s, config = pcall(function()
			return HS:JSONDecode(readfile(filePath))
		end)
	
		if s then
			for _, tab in next, Window.Tabs do
				for _, section in next, tab.Sections do
					for _, item in next, section.List do
						local flag = item.Flag or item.Name
	
						if config.Flags[flag] ~= nil then
							item[item.Type == "Toggle" and "Set" or "Toggle"](item, config.Flags[flag])
						end
	
						if item.Type == "Bind" then
							item:Set(Enum.KeyCode[config.Binds[flag]])
	
						elseif item.Type == "Slider" then
							item:Set(config.Sliders[flag])
	
						elseif item.Type == "Picker" then
							local picker = config.Pickers[flag]
	
							item:Set(picker.Color.R, picker.Color.G, picker.Color.B)
							item:ToggleRainbow(picker.Rainbow)
	
						elseif item.Type == "SubSection" then
							for _, item2 in next, item.List do
								local flag2 = item2.Flag or item2.Name
	
								if config.Flags[flag2] ~= nil then
									item2[item2.Type == "Toggle" and "Set" or "Toggle"](item2, config.Flags[flag2])
								end
	
								if item2.Type == "Bind" then
									item2:Set(Enum.KeyCode[config.Binds[flag2]])
	
								elseif item2.Type == "Slider" then
									item2:Set(config.Sliders[flag2])
	
								elseif item2.Type == "Picker" then
									local picker = config.Pickers[flag2]
	
									item2:Set(picker.Color.R, picker.Color.G, picker.Color.B)
									item2:ToggleRainbow(picker.Rainbow)
								end
							end
						end
					end
				end
			end
		end
	end

	function Window:Toggle(bool)
		self.Toggled = bool
		self.Frame.Visible = bool
	end

	function Window:SetKey(keycode)
		self.Key = keycode
	end

	local function setAccent(accent)
		Library.Theme.Accent = accent
		Window.Frame.Topbar.Title.Text = string.format("%s - <font color='%s'>%s</font>", options.title[1], SelfModules.UI.Color.ToFormat(accent), options.title[2])

		for _, tab in next, Window.Tabs do
			for _, section in next, tab.Sections do
				for _, item in next, section.List do
					local flag = item.Flag or item.Name

					if tab.Flags[flag] == true or item.Rainbow == true then
						local overlay = nil

						for _, v in next, item.Frame:GetDescendants() do
							if v.Name == "Overlay" then
								overlay = v; break
							end
						end

						if overlay then
							local tween = Storage.Tween.Cosmetic[overlay]

							if tween then
								tween:Cancel(); tween = nil
							end

							overlay.BackgroundColor3 = SelfModules.UI.Color.Add(accent, Color3.fromRGB(50, 50, 50))
						end
					end

					if item.Type == "Slider" then
						item.Frame.Holder.Slider.Bar.Fill.BackgroundColor3 = SelfModules.UI.Color.Sub(accent, Color3.fromRGB(50, 50, 50))
						item.Frame.Holder.Slider.Point.BackgroundColor3 = accent

					elseif item.Type == "SubSection" then
						for _, item2 in next, item.List do
							local flag2 = item2.Flag or item2.Name

							if tab.Flags[flag2] == true or item2.Rainbow == true then
								local overlay = nil

								for _, v in next, item2.Frame:GetDescendants() do
									if v.Name == "Overlay" then
										overlay = v; break
									end
								end

								if overlay then
									local tween = Storage.Tween.Cosmetic[overlay]

									if tween then
										tween:Cancel(); tween = nil
									end

									overlay.BackgroundColor3 = SelfModules.UI.Color.Add(accent, Color3.fromRGB(50, 50, 50))
								end
							end

							if item2.Type == "Slider" then
								item2.Frame.Holder.Slider.Bar.Fill.BackgroundColor3 = SelfModules.UI.Color.Sub(accent, Color3.fromRGB(50, 50, 50))
								item2.Frame.Holder.Slider.Point.BackgroundColor3 = accent
							end
						end
					end
				end
			end
		end
	end

	function Window:SetAccent(accent)
		if Storage.Connections.WindowRainbow ~= nil then
			Storage.Connections.WindowRainbow:Disconnect()
		end

		if typeof(accent) == "string" and string.lower(accent) == "rainbow" then
			Storage.Connections.WindowRainbow = RS.Heartbeat:Connect(function()
				setAccent(Color3.fromHSV(tick() % 5 / 5, 1, 1))
			end)

		elseif typeof(accent) == "Color3" then
			setAccent(accent)
		end
	end

	local function toggleSidebar(bool)
		Window.Sidebar.Toggled = bool
		-- {0, -100},{0, 40}
		task.spawn(function()
			task.wait(bool and 0 or 0.5)
			Window.Sidebar.Frame.Border.Visible = bool
		end)

		tween(Window.Sidebar.Frame, 0.5, { Size = UDim2.new(0, bool and 130 or 30, 1, -40) })
		tween(Window.Sidebar.Frame.Indicator, 0.5, { Rotation = bool and 45 or 0 })

		for i, v in next, Window.Sidebar.List do
			tween(v.Frame.Button, 0.5, { BackgroundTransparency = bool and 0 or 1 })
			tween(v.Frame, 0.5, { BackgroundTransparency = bool and 0 or 1 })
		end
	end

	-- Scripts

	Window.Key = options.key or Window.Key
	Storage.Connections[Window] = {}
	SelfModules.UI.MakeDraggable(Window.Frame, Window.Frame.Topbar, 0.1)
	Window.Sidebar.Frame = Window.Frame.Sidebar
	Window.Sidebar.Frame.Position = UDim2.new(0, -100,0, 40)
	Window.Sidebar.Frame.Size = UDim2.new(0, 130, 1, -40)
	Window.Sidebar.Frame.Border.Visible = false
	--for i, v in ipairs(Window.Sidebar.List) do
	--	v.Frame.Button.BackgroundTransparency = 0
	--	v.Frame.BackgroundTransparency = 0
	--end
	Window.Frame.Topbar.Position = UDim2.new(0, -100, 0, 0)
	Window.Frame.Parent = ScreenGui
	
	
	--toggleSidebar(true)

	UIS.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Window.Key and not ListenForInput then
			Window:Toggle(not Window.Toggled)
		end
	end)

	Window.Sidebar.Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and Mouse.Y - Window.Sidebar.Frame.AbsolutePosition.Y <= 25 then
			--toggleSidebar(not Window.Sidebar.Toggled)
		end
	end)

	-- Tab

	function Window:AddTab(name, options)
		options = options or {}

		local Tab = {
			Name = name,
			Type = "Tab",
			Sections = {},
			Flags = {},
			Button = {
				Name = name,
				Selected = false,
			},
		}
		
		

		Tab.Frame = SelfModules.UI.Create("ScrollingFrame", {
			Name = "Tab",
			Active = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 5, 0, 5),
			Size = UDim2.new(1, -10, 1, -10),
			ScrollBarImageColor3 = SelfModules.UI.Color.Add(Library.Theme.BackgroundColor, Color3.fromRGB(15, 15, 15)),
			ScrollBarThickness = 5,
			Visible = false,

			SelfModules.UI.Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
			}),
		})

		Tab.Button.Frame = SelfModules.UI.Create("Frame", {
			Name = name,
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(15, 15, 15)),
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 120, 0, 32),

			SelfModules.UI.Create("TextButton", {
				Name = "Button",
				AutoButtonColor = false,
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(5, 5, 5)),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),
				Font = Enum.Font.SourceSans,
				Text = name,
				TextColor3 = Library.Theme.TextColor,
				TextSize = 14,
				TextWrapped = true,
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5))
		

		-- Functions


		function Tab:Show()
			for i, v in next, Window.Tabs do
				local bool = v == self

				v.Frame.Visible = bool
				v.Button.Selected = bool
				
				--tween(v.Button.Frame.Button, 0.1, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(35, 35, 35)) or SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(5, 5, 5)) })
				--tween(v.Button.Frame, 0.1, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(45, 45, 45)) or SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(15, 15, 15)) })
				--v.Button.Frame.BackgroundTransparency = bool and 0 or 1
				--for i, v in next, Window.Sidebar.List do
				--	tween(v.Frame.Button, 0, { BackgroundTransparency = bool and 0 or 1 })
				--	tween(v.Frame, 0, { BackgroundTransparency = bool and 1 or 0 })
				--end
				--tween(v.Button.Frame, 0.5, { BackgroundTransparency = bool and 0 or 1 })
				--tween(v.Button, 0.5, { BackgroundTransparency = bool and 0 or 1 
				
				tween(v.Button.Frame.Button, 0.1, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(35, 35, 35)) or SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(5, 5, 5)) })
				tween(v.Button.Frame, 0.1, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(45, 45, 45)) or SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(15, 15, 15)) })
			end

			--toggleSidebar(false)
		end

		function Tab:Hide()
			self.Frame.Visible = false
		end

		function Tab:GetHeight()
			local height = 0

			for i, v in next, self.Sections do
				height = height + v:GetHeight() + (i < #self.Sections and 5 or 0)
			end

			return height
		end

		function Tab:UpdateHeight()
			Tab.Frame.CanvasSize = UDim2.new(0, 0, 0, Tab:GetHeight())
		end

		-- Scripts

		Window.Tabs[#Window.Tabs + 1] = Tab
		Window.Sidebar.List[#Window.Sidebar.List + 1] = Tab.Button
		Tab.Frame.Parent = Window.Frame.Background.Tabs.Holder
		Tab.Frame.CanvasSize = UDim2.new(0, 0, 0, Tab.Frame.AbsoluteSize.Y + 1)
		Tab.Button.Frame.Parent = Window.Frame.Sidebar.List

		Tab.Frame.ChildAdded:Connect(function(c)
			if c.ClassName == "Frame" then
				Tab:UpdateHeight()
			end
		end)

		Tab.Frame.ChildRemoved:Connect(function(c)
			if c.ClassName == "Frame" then
				Tab:UpdateHeight()
			end
		end)

		Tab.Button.Frame.Button.MouseEnter:Connect(function()
			if Tab.Button.Selected == false then
				tween(Tab.Button.Frame.Button, 0.1, { BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(15, 15, 15)), })
				tween(Tab.Button.Frame, 0.1, { BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(25, 25, 25)), })
			end
		end)

		Tab.Button.Frame.Button.MouseLeave:Connect(function()
			if Tab.Button.Selected == false then
				tween(Tab.Button.Frame.Button, 0.1, { BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(5, 5, 5)), })
				tween(Tab.Button.Frame, 0.1, { BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(15, 15, 15)),  })
			end
		end)

		Tab.Button.Frame.Button.Activated:Connect(function()
			if Tab.Button.Selected == false then
				Tab:Show()
				local sec = Tab.Sections[1]
				print(sec)
				if sec and sec.Options.default then
					sec:Toggle(true)
					sec:UpdateHeight()
					sec:Toggle(false)
					sec:UpdateHeight()
					sec:Toggle(true)
					sec:UpdateHeight()
				end
			end
		end)

		if options.default == true then
			Tab:Show()
		end
		
		--tween(Tab.Button.Frame.Button, 0.1, { BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(15, 15, 15)), BackgroundTransparency = 0.1})
		--tween(Tab.Button.Frame, 0.1, { BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SidebarColor, Color3.fromRGB(25, 25, 25)), BackgroundTransparency = 0.1 })

		-- Section
-- Section

function Tab:AddSection(name, options)
	options = options or {}
	
	local Section = {
		Name = name,
		Type = "Section",
		Toggled = options.default == true,
		List = {},
		Options = options
	}

	Section.Frame = SelfModules.UI.Create("Frame", {
		Name = "Section",
		BackgroundColor3 = Library.Theme.SectionColor,
		ClipsDescendants = true,
		Size = UDim2.new(1, -10, 0, 40),

		SelfModules.UI.Create("Frame", {
			Name = "Line",
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 5, 0, 30),
			Size = UDim2.new(1, -10, 0, 2),
		}),

		SelfModules.UI.Create("TextLabel", {
			Name = "Header",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 5, 0, 8),
			Size = UDim2.new(1, -40, 0, 14),
			Font = Enum.Font.SourceSans,
			Text = name,
			TextColor3 = Library.Theme.TextColor,
			TextSize = 14,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		SelfModules.UI.Create("Frame", {
			Name = "List",
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Position = UDim2.new(0, 5, 0, 40),
			Size = UDim2.new(1, -10, 1, -40),

			SelfModules.UI.Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 5),
			}),

			SelfModules.UI.Create("UIPadding", {
				PaddingBottom = UDim.new(0, 1),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
				PaddingTop = UDim.new(0, 1),
			}),
		}),

		SelfModules.UI.Create("TextLabel", {
			Name = "Indicator",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -30, 0, 0),
			Size = UDim2.new(0, 30, 0, 30),
			Font = Enum.Font.SourceSansBold,
			Text = "+",
			TextColor3 = Library.Theme.TextColor,
			TextSize = 20,
			ZIndex = 1,
		})
	}, UDim.new(0, 5))

	-- Functions

	local function toggleSection(bool)
		Section.Toggled = bool

		tween(Section.Frame, 0.5, { Size = UDim2.new(1, -10, 0, Section:GetHeight()) })
		tween(Section.Frame.Indicator, 0.5, { Rotation = bool and 45 or 0 })

		tween(Tab.Frame, 0.5, { CanvasSize = UDim2.new(0, 0, 0, Tab:GetHeight()) })
	end

	function Section:Toggle(bool)
		print(bool)
		toggleSection(bool)
	end

	function Section:GetHeight()
		local height = 40

		if Section.Toggled == true then
			for i, v in next, self.List do
				height = height + (v.GetHeight ~= nil and v:GetHeight() or v.Frame.AbsoluteSize.Y) + 5
			end
		end

		return height
	end

	function Section:UpdateHeight()
		if Section.Toggled == true then
			Section.Frame.Size = UDim2.new(1, -10, 0, Section:GetHeight())
			Section.Frame.Indicator.Rotation = 45

			Tab:UpdateHeight()
		end
	end

	-- Scripts

	Tab.Sections[#Tab.Sections + 1] = Section
	Section.Frame.Parent = Tab.Frame

	Section.Frame.List.ChildAdded:Connect(function(c)
		if c.ClassName == "Frame" then
			Section:UpdateHeight()
		end
	end)

	Section.Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and #Section.List > 0 and Mouse.Y - Section.Frame.AbsolutePosition.Y <= 30 then
			toggleSection(not Section.Toggled)
		end
	end)

	-- Button

	function Section:AddButton(name, callback)
		local Button = {
			Name = name,
			Type = "Button",
			Callback = callback,
		}

		Button.Frame = SelfModules.UI.Create("Frame", {
			Name = name,
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			Size = UDim2.new(1, 2, 0, 32),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				Size = UDim2.new(1, -2, 1, -2),
				Position = UDim2.new(0, 1, 0, 1),

				SelfModules.UI.Create("TextButton", {
					Name = "Button",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
					Position = UDim2.new(0, 2, 0, 2),
					Size = UDim2.new(1, -4, 1, -4),
					AutoButtonColor = false,
					Font = Enum.Font.SourceSans,
					Text = name,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5))

		-- Functions

		local function buttonVisual()
			task.spawn(function()
				local Visual = SelfModules.UI.Create("Frame", {
					Name = "Visual",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.9,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 0, 1, 0),
				}, UDim.new(0, 5))

				Visual.Parent = Button.Frame.Holder.Button
				tween(Visual, 0.5, { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
				task.wait(0.5)
				Visual:Destroy()
			end)
		end

		-- Scripts

		Section.List[#Section.List + 1] = Button
		Button.Frame.Parent = Section.Frame.List

		Button.Frame.Holder.Button.MouseButton1Down:Connect(function()
			Button.Frame.Holder.Button.TextSize = 12
		end)

		Button.Frame.Holder.Button.MouseButton1Up:Connect(function()
			Button.Frame.Holder.Button.TextSize = 14
			buttonVisual()

			pcall(task.spawn, Button.Callback)
		end)

		Button.Frame.Holder.Button.MouseLeave:Connect(function()
			Button.Frame.Holder.Button.TextSize = 14
		end)

		return Button
	end

	-- Toggle

	function Section:AddToggle(name, options, callback)
		local Toggle = {
			Name = name,
			Type = "Toggle",
			Flag = options.flag or name,
			Callback = callback,
		}

		Toggle.Frame = SelfModules.UI.Create("Frame", {
			Name = name,
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			Size = UDim2.new(1, 2, 0, 32),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),

				SelfModules.UI.Create("TextLabel", {
					Name = "Label",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 5, 0.5, -7),
					Size = UDim2.new(1, -50, 0, 14),
					Font = Enum.Font.SourceSans,
					Text = name,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),

				SelfModules.UI.Create("Frame", {
					Name = "Indicator",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
					Position = UDim2.new(1, -42, 0, 2),
					Size = UDim2.new(0, 40, 0, 26),

					SelfModules.UI.Create("ImageLabel", {
						Name = "Overlay",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)),
						Position = UDim2.new(0, 2, 0, 2),
						Size = UDim2.new(0, 22, 0, 22),
						Image = "http://www.roblox.com/asset/?id=7827504335",
						ImageTransparency = 1,
					}, UDim.new(0, 5)),
				}, UDim.new(0, 5))
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5))


		function Toggle:Set(bool, instant)
			Tab.Flags[Toggle.Flag] = bool

			tween(Toggle.Frame.Holder.Indicator.Overlay, instant and 0 or 0.25, { ImageTransparency = bool and 0 or 1, Position = bool and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2) })
			tween(Toggle.Frame.Holder.Indicator.Overlay, "Cosmetic", instant and 0 or 0.25, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.Accent, Color3.fromRGB(15, 15, 15)) or SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)) })
		
			pcall(task.spawn, Toggle.Callback, bool)
		end

		-- Scripts

		Section.List[#Section.List + 1] = Toggle
		Tab.Flags[Toggle.Flag] = options.default == true
		Toggle.Frame.Parent = Section.Frame.List

		Toggle.Frame.Holder.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				Toggle:Set(not Tab.Flags[Toggle.Flag], false)
			end
		end)

		Toggle:Set(options.default == true, true)

		return Toggle
	end

	-- Label

	function Section:AddLabel(name)
		local Label = {
			Name = name,
			Type = "Label",
		}

		Label.Frame = SelfModules.UI.Create("Frame", {
			Name = name,
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			Size = UDim2.new(1, 2, 0, 22),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),

				SelfModules.UI.Create("TextLabel", {
					Name = "Label",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 2, 0.5, 0),
					Size = UDim2.new(1, -4, 0, 14),
					Font = Enum.Font.SourceSans,
					Text = name,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
				}),
			}, UDim.new(0, 5))
		}, UDim.new(0, 5))

		-- Scripts

		Section.List[#Section.List + 1] = Label
		Label.Label = Label.Frame.Holder.Label
		Label.Frame.Parent = Section.Frame.List

		return Label
	end

	-- DualLabel

	function Section:AddDualLabel(options)
		options = options or {}
		
		local DualLabel = {
			Name = options[1].. " ".. options[2],
			Type = "DualLabel",
		}

		DualLabel.Frame = SelfModules.UI.Create("Frame", {
			Name = options[1].. " ".. options[2],
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			Size = UDim2.new(1, 2, 0, 22),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),

				SelfModules.UI.Create("TextLabel", {
					Name = "Label1",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 5, 0.5, 0),
					Size = UDim2.new(0.5, -5, 0, 14),
					Font = Enum.Font.SourceSans,
					Text = options[1],
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),

				SelfModules.UI.Create("TextLabel", {
					Name = "Label2",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0.5, -5, 0, 14),
					Font = Enum.Font.SourceSans,
					Text = options[2],
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Right,
				}),
			}, UDim.new(0, 5))
		}, UDim.new(0, 5))

		-- Scripts

		Section.List[#Section.List + 1] = DualLabel
		DualLabel.Label1 = DualLabel.Frame.Holder.Label1
		DualLabel.Label2 = DualLabel.Frame.Holder.Label2
		DualLabel.Frame.Parent = Section.Frame.List

		return DualLabel
	end

	-- ClipboardLabel

	function Section:AddClipboardLabel(name, callback)
		local ClipboardLabel = {
			Name = name,
			Type = "ClipboardLabel",
			Callback = callback,
		}

		ClipboardLabel.Frame = SelfModules.UI.Create("Frame", {
			Name = name,
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			Size = UDim2.new(1, 2, 0, 22),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),

				SelfModules.UI.Create("TextLabel", {
					Name = "Label",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 2, 0.5, 0),
					Size = UDim2.new(1, -22, 0, 14),
					Font = Enum.Font.SourceSans,
					Text = name,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
				}),

				SelfModules.UI.Create("ImageLabel", {
					Name = "Icon",
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -18, 0, 2),
					Size = UDim2.new(0, 16, 0, 16),
					Image = "rbxassetid://9243581053",
				}),
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5))

		-- Scripts

		Section.List[#Section.List + 1] = ClipboardLabel
		ClipboardLabel.Label = ClipboardLabel.Frame.Holder.Label
		ClipboardLabel.Frame.Parent = Section.Frame.List

		ClipboardLabel.Frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local s, result = pcall(ClipboardLabel.Callback)

				if s then
					setclipboard(result)
				end
			end
		end)

		return ClipboardLabel
	end

	-- Box

	function Section:AddBox(name, options, callback)
		local Box = {
			Name = name,
			Type = "Box",
			Callback = callback,
		}

		Box.Frame = SelfModules.UI.Create("Frame", {
			Name = name,
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			Size = UDim2.new(1, 2, 0, 32),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),

				SelfModules.UI.Create("TextLabel", {
					Name = "Label",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 5, 0.5, -7),
					Size = UDim2.new(1, -135, 0, 14),
					Font = Enum.Font.SourceSans,
					Text = name,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),

				SelfModules.UI.Create("Frame", {
					Name = "TextBox",
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = SelfModules.UI.Color.Sub(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
					Position = UDim2.new(1, -2, 0, 2),
					Size = UDim2.new(0, 140, 1, -4),
					ZIndex = 2,

					SelfModules.UI.Create("Frame", {
						Name = "Holder",
						BackgroundColor3 = Library.Theme.SectionColor,
						Position = UDim2.new(0, 1, 0, 1),
						Size = UDim2.new(1, -2, 1, -2),
						ZIndex = 2,

						SelfModules.UI.Create("TextBox", {
							Name = "Box",
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							ClearTextOnFocus = options.clearonfocus ~= true,
							Position = UDim2.new(0, 28, 0.5, 0),
							Size = UDim2.new(1, -30, 1, 0),
							Font = Enum.Font.SourceSans,
							PlaceholderText = "Text",
							Text = "",
							TextColor3 = Library.Theme.TextColor,
							TextSize = 14,
							TextWrapped = true,
						}),

						SelfModules.UI.Create("TextLabel", {
							Name = "Icon",
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 6, 0.5, 0),
							Size = UDim2.new(0, 14, 0, 14),
							Font = Enum.Font.SourceSansBold,
							Text = "T",
							TextColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(40, 40, 40)),
							TextSize = 18,
							TextWrapped = true,
						}),
					}, UDim.new(0, 5)),
				}, UDim.new(0, 5))
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5))

		-- Functions

		local function extendBox(bool)
			tween(Box.Frame.Holder.TextBox, 0.25, { Size = UDim2.new(0, bool and 200 or 140, 1, -4) })
		end

		-- Scripts

		Section.List[#Section.List + 1] = Box
		Box.Box = Box.Frame.Holder.TextBox.Holder.Box
		Box.Frame.Parent = Section.Frame.List

		Box.Frame.Holder.TextBox.Holder.MouseEnter:Connect(function()
			extendBox(true)
		end)

		Box.Frame.Holder.TextBox.Holder.MouseLeave:Connect(function()
			if Box.Frame.Holder.TextBox.Holder.Box:IsFocused() == false then
				extendBox(false)
			end
		end)

		Box.Frame.Holder.TextBox.Holder.Box.FocusLost:Connect(function()
			if Box.Frame.Holder.TextBox.Holder.Box.Text == "" and options.fireonempty ~= true then
				return
			end

			extendBox(false)
			pcall(task.spawn, Box.Callback, Box.Frame.Holder.TextBox.Holder.Box.Text)
		end)

		return Box
	end

	-- Bind

	function Section:AddBind(name, bind, options, callback)
		local Bind = {
			Name = name,
			Type = "Bind",
			Bind = bind,
			Flag = options.flag or name,
			Callback = callback,
		}

		Bind.Frame = SelfModules.UI.Create("Frame", {
			Name = name,
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			Size = UDim2.new(1, 2, 0, 32),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),

				SelfModules.UI.Create("TextLabel", {
					Name = "Label",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 5, 0.5, -7),
					Size = UDim2.new(1, -135, 0, 14),
					Font = Enum.Font.SourceSans,
					Text = name,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),

				SelfModules.UI.Create("Frame", {
					Name = "Bind",
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
					Position = UDim2.new(1, options.toggleable == true and -44 or -2, 0, 2),
					Size = UDim2.new(0, 78, 0, 26),
					ZIndex = 2,

					SelfModules.UI.Create("TextLabel", {
						Name = "Label",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
						Position = UDim2.new(0, 1, 0, 1),
						Size = UDim2.new(1, -2, 1, -2),
						Font = Enum.Font.SourceSans,
						Text = "",
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
					}, UDim.new(0, 5)),
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5))

		-- Variables

		local indicatorEntered = false
		local connections = {}

		-- Functions

		local function listenForInput()
			if connections.listen then
				connections.listen:Disconnect()
			end

			Bind.Frame.Holder.Bind.Label.Text = "..."
			ListenForInput = true

			connections.listen = UIS.InputBegan:Connect(function(input, gameProcessed)
				if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
					Bind:Set(input.KeyCode)
				end
			end)
		end

		local function cancelListen()
			if connections.listen then
				connections.listen:Disconnect(); connections.listen = nil
			end

			Bind.Frame.Holder.Bind.Label.Text = Bind.Bind.Name
			task.spawn(function() RS.RenderStepped:Wait(); ListenForInput = false end)
		end

		function Bind:Set(bind)
			Bind.Bind = bind
			Bind.Frame.Holder.Bind.Label.Text = bind.Name
			Bind.Frame.Holder.Bind.Size = UDim2.new(0, math.max(12 + math.round(TXS:GetTextSize(bind.Name, 14, Enum.Font.SourceSans, Vector2.new(9e9)).X + 0.5), 42), 0, 26)
			
			if connections.listen then
				cancelListen()
			end
		end

		if options.toggleable == true then
			function Bind:Toggle(bool, instant)
				Tab.Flags[Bind.Flag] = bool

				tween(Bind.Frame.Holder.Indicator.Overlay, instant and 0 or 0.25, { ImageTransparency = bool and 0 or 1, Position = bool and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2) })
				tween(Bind.Frame.Holder.Indicator.Overlay, "Cosmetic", instant and 0 or 0.25, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.Accent, Color3.fromRGB(50, 50, 50)) or SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)) })

				if options.fireontoggle ~= false then
					pcall(task.spawn, Bind.Callback, Bind.Bind)
				end
			end
		end

		-- Scripts

		Section.List[#Section.List + 1] = Bind
		Bind.Frame.Parent = Section.Frame.List

		Bind.Frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if indicatorEntered == true then
					Bind:Toggle(not Tab.Flags[Bind.Flag], false)
				else
					listenForInput()
				end
			end
		end)

		UIS.InputBegan:Connect(function(input)
			if input.KeyCode == Bind.Bind then
				if (options.toggleable == true and Tab.Flags[Bind.Flag] == false) or ListenForInput then
					return
				end

				pcall(task.spawn, Bind.Callback, Bind.Bind)
			end
		end)

		if options.toggleable == true then
			local indicator = SelfModules.UI.Create("Frame", {
				Name = "Indicator",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
				Position = UDim2.new(1, -2, 0, 2),
				Size = UDim2.new(0, 40, 0, 26),

				SelfModules.UI.Create("ImageLabel", {
					Name = "Overlay",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)),
					Position = UDim2.new(0, 2, 0, 2),
					Size = UDim2.new(0, 22, 0, 22),
					Image = "http://www.roblox.com/asset/?id=7827504335",
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Scripts

			Tab.Flags[Bind.Flag] = options.default == true
			indicator.Parent = Bind.Frame.Holder

			Bind.Frame.Holder.Indicator.MouseEnter:Connect(function()
				indicatorEntered = true
			end)

			Bind.Frame.Holder.Indicator.MouseLeave:Connect(function()
				indicatorEntered = false
			end)

			Bind:Toggle(options.default == true, true)
		end

		Bind:Set(Bind.Bind)

		return Bind
	end

	-- Slider

	function Section:AddSlider(name, min, max, default, options, callback)
		local Slider = {
			Name = name,
			Type = "Slider",
			Value = default,
			Flag = options.flag or name,
			Callback = callback,
		}

		Slider.Frame = SelfModules.UI.Create("Frame", {
			Name = name,
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			Size = UDim2.new(1, 2, 0, 41),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),

				SelfModules.UI.Create("TextLabel", {
					Name = "Label",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 5, 0, 5),
					Size = UDim2.new(1, -75, 0, 14),
					Font = Enum.Font.SourceSans,
					Text = name,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),

				SelfModules.UI.Create("Frame", {
					Name = "Slider",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 5, 1, -15),
					Size = UDim2.new(1, -10, 0, 10),

					SelfModules.UI.Create("Frame", {
						Name = "Bar",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
						ClipsDescendants = true,
						Size = UDim2.new(1, 0, 1, 0),

						SelfModules.UI.Create("Frame", {
							Name = "Fill",
							BackgroundColor3 = SelfModules.UI.Color.Sub(Library.Theme.Accent, Color3.fromRGB(50, 50, 50)),
							Size = UDim2.new(0.5, 0, 1, 0),
						}, UDim.new(0, 5)),
					}, UDim.new(0, 5)),

					SelfModules.UI.Create("Frame", {
						Name = "Point",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Library.Theme.Accent,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0, 12, 0, 12),
					}, UDim.new(0, 5)),
				}),

				SelfModules.UI.Create("TextBox", {
					Name = "Input",
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					PlaceholderText = "...",
					Position = UDim2.new(1, -5, 0, 5),
					Size = UDim2.new(0, 60, 0, 14),
					Font = Enum.Font.SourceSans,
					Text = "",
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Right,
				}),
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5))

		-- Variables

		local connections = {}

		-- Functions

		local function getSliderValue(val)
			val = math.clamp(val, min, max)

			if options.rounded == true then
				val = math.floor(val)
			end

			return val
		end

		local function sliderVisual(val)
			val = getSliderValue(val)

			Slider.Frame.Holder.Input.Text = val

			local valuePercent = 1 - ((max - val) / (max - min))
			local pointPadding = 1 / Slider.Frame.Holder.Slider.AbsoluteSize.X * 5
			tween(Slider.Frame.Holder.Slider.Bar.Fill, 0.25, { Size = UDim2.new(valuePercent, 0, 1, 0) })
			tween(Slider.Frame.Holder.Slider.Point, 0.25, { Position = UDim2.fromScale(math.clamp(valuePercent, pointPadding, 1 - pointPadding), 0.5) })
		end

		function Slider:Set(val)
			val = getSliderValue(val)
			Slider.Value = val
			sliderVisual(val)

			if options.toggleable == true and Tab.Flags[Slider.Flag] == false then
				return
			end

			pcall(task.spawn, Slider.Callback, val, Tab.Flags[Slider.Flag] or nil)
		end

		if options.toggleable == true then
			function Slider:Toggle(bool, instant)
				Tab.Flags[Slider.Flag] = bool

				tween(Slider.Frame.Holder.Indicator.Overlay, instant and 0 or 0.25, { ImageTransparency = bool and 0 or 1, Position = bool and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2) })
				tween(Slider.Frame.Holder.Indicator.Overlay, "Cosmetic", instant and 0 or 0.25, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.Accent, Color3.fromRGB(50, 50, 50)) or SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)) })

				if options.fireontoggle ~= false then
					pcall(task.spawn, Slider.Callback, Slider.Value, bool)
				end
			end
		end

		-- Scripts

		Section.List[#Section.List + 1] = Slider
		Slider.Frame.Parent = Section.Frame.List

		Slider.Frame.Holder.Slider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then

				connections.move = Mouse.Move:Connect(function()
					local sliderPercent = math.clamp((Mouse.X - Slider.Frame.Holder.Slider.AbsolutePosition.X) / Slider.Frame.Holder.Slider.AbsoluteSize.X, 0, 1)
					local sliderValue = math.floor((min + sliderPercent * (max - min)) * 10) / 10

					if options.fireondrag ~= false then
						Slider:Set(sliderValue)
					else
						sliderVisual(sliderValue)
					end
				end)

			end
		end)

		Slider.Frame.Holder.Slider.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				connections.move:Disconnect()
				connections.move = nil

				if options.fireondrag ~= true then
					local sliderPercent = math.clamp((Mouse.X - Slider.Frame.Holder.Slider.AbsolutePosition.X) / Slider.Frame.Holder.Slider.AbsoluteSize.X, 0, 1)
					local sliderValue = math.floor((min + sliderPercent * (max - min)) * 10) / 10

					Slider:Set(sliderValue)
				end
			end
		end)

		Slider.Frame.Holder.Input.FocusLost:Connect(function()
			Slider.Frame.Holder.Input.Text = string.sub(Slider.Frame.Holder.Input.Text, 1, 10)

			if tonumber(Slider.Frame.Holder.Input.Text) then
				Slider:Set(Slider.Frame.Holder.Input.Text)
			end
		end)

		if options.toggleable == true then
			local indicator = SelfModules.UI.Create("Frame", {
				Name = "Indicator",
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
				Position = UDim2.new(1, -2, 1, -2),
				Size = UDim2.new(0, 40, 0, 26),

				SelfModules.UI.Create("ImageLabel", {
					Name = "Overlay",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)),
					Position = UDim2.new(0, 2, 0, 2),
					Size = UDim2.new(0, 22, 0, 22),
					Image = "http://www.roblox.com/asset/?id=7827504335",
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Scripts

			Tab.Flags[Slider.Flag] = options.default == true
			Slider.Frame.Size = UDim2.new(1, 2, 0, 54)
			Slider.Frame.Holder.Slider.Size = UDim2.new(1, -50, 0, 10)
			indicator.Parent = Slider.Frame.Holder

			Slider.Frame.Holder.Indicator.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Slider:Toggle(not Tab.Flags[Slider.Flag], false)
				end
			end)

			Slider:Toggle(options.default == true, true)
		end

		Slider:Set(Slider.Value)

		return Slider
	end

	-- Dropdown

	function Section:AddDropdown(name, list, options, callback)
		local Dropdown = {
			Name = name,
			Type = "Dropdown",
			Toggled = false,
			Selected = "",
			List = {},
			Callback = callback,
		}

		local ListObjects = {}

		Dropdown.Frame = SelfModules.UI.Create("Frame", {
			Name = "Dropdown",
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			Size = UDim2.new(1, 2, 0, 42),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 40),

					SelfModules.UI.Create("Frame", {
						Name = "Displays",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 0, 8),
						Size = UDim2.new(1, -35, 0, 14),

						SelfModules.UI.Create("TextLabel", {
							Name = "Label",
							BackgroundTransparency = 1,
							Size = UDim2.new(0.5, 0, 1, 0),
							Font = Enum.Font.SourceSans,
							Text = name,
							TextColor3 = Library.Theme.TextColor,
							TextSize = 14,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
						}),

						SelfModules.UI.Create("TextLabel", {
							Name = "Selected",
							BackgroundTransparency = 1,
							Position = UDim2.new(0.5, 0, 0, 0),
							Size = UDim2.new(0.5, 0, 1, 0),
							Font = Enum.Font.SourceSans,
							Text = "",
							TextColor3 = Library.Theme.TextColor,
							TextSize = 14,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Right,
						}),
					}),

					SelfModules.UI.Create("ImageLabel", {
						Name = "Indicator",
						AnchorPoint = Vector2.new(1, 0),
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -5, 0, 5),
						Size = UDim2.new(0, 20, 0, 20),
						Image = "rbxassetid://9243354333",
					}),

					SelfModules.UI.Create("Frame", {
						Name = "Line",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 5, 0, 30),
						Size = UDim2.new(1, -10, 0, 2),
					}),
				}, UDim.new(0, 5)),

				SelfModules.UI.Create("ScrollingFrame", {
					Name = "List",
					Active = true,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 5, 0, 40),
					Size = UDim2.new(1, -10, 1, -40),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarImageColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
					ScrollBarThickness = 5,

					SelfModules.UI.Create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 5),
					}),
				}),
			}, UDim.new(0,5)),
		}, UDim.new(0, 5))

		-- Functions

		function Dropdown:GetHeight()
			return 42 + (Dropdown.Toggled == true and math.min(#Dropdown.List, 5) * 27 or 0)
		end

		function Dropdown:UpdateHeight()
			Dropdown.Frame.Holder.List.CanvasSize = UDim2.new(0, 0, 0, #Dropdown.List * 27 - 5)

			if Dropdown.Toggled == true then
				Dropdown.Frame.Size = UDim2.new(1, 2, 0, Dropdown:GetHeight())
				Section:UpdateHeight()
			end
		end

		function Dropdown:Add(name, options, callback)
			local Item = {
				Name = name,
				Callback = callback,
			}

			Item.Frame = SelfModules.UI.Create("Frame", {
				Name = name,
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				Size = UDim2.new(1, -10, 0, 22),

				SelfModules.UI.Create("TextButton", {
					Name = "Button",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					Font = Enum.Font.SourceSans,
					Text = name,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Scripts

			Dropdown.List[#Dropdown.List + 1] = name
			ListObjects[#ListObjects + 1] = Item
			Item.Frame.Parent = Dropdown.Frame.Holder.List

			if Dropdown.Toggled == true then
				Dropdown:UpdateHeight()
			end

			Item.Frame.Button.Activated:Connect(function()
				if typeof(Item.Callback) == "function" then
					pcall(task.spawn, Item.Callback)
				else
					Dropdown:Select(Item.Name)
				end
			end)

			return Item
		end

		function Dropdown:Remove(name, ignoreToggle)
			for i, v in next, Dropdown.List do
				if v == name then
					local item = ListObjects[i]

					if item then
						item.Frame:Destroy()
						table.remove(Dropdown.List, i)
						table.remove(ListObjects, i)

						if Dropdown.Toggled then
							Dropdown:UpdateHeight()
						end
						
						if #Dropdown.List == 0 and not ignoreToggle then
							Dropdown:Toggle(false)
						end
					end

					break
				end
			end
		end

		function Dropdown:ClearList()
			for _ = 1, #Dropdown.List, 1 do
				Dropdown:Remove(Dropdown.List[1], true)
			end
		end

		function Dropdown:SetList(list)
			Dropdown:ClearList()

			for _, v in next, list do
				Dropdown:Add(v)
			end
		end

		function Dropdown:Select(itemName)
			Dropdown.Selected = itemName
			Dropdown.Frame.Holder.Holder.Displays.Selected.Text = itemName
			Dropdown:Toggle(false)

			pcall(task.spawn, Dropdown.Callback, itemName)
		end

		function Dropdown:Toggle(bool)
			Dropdown.Toggled = bool

			tween(Dropdown.Frame, 0.5, { Size = UDim2.new(1, 2, 0, Dropdown:GetHeight()) })
			tween(Dropdown.Frame.Holder.Holder.Indicator, 0.5, { Rotation = bool and 90 or 0 })
			tween(Section.Frame, 0.5, { Size = UDim2.new(1, -10, 0, Section:GetHeight()) })
			tween(Tab.Frame, 0.5, { CanvasSize = UDim2.new(0, 0, 0, Tab:GetHeight()) })
		end

		-- Scripts

		Section.List[#Section.List + 1] = Dropdown
		Dropdown.Frame.Parent = Section.Frame.List
		
		Dropdown.Frame.Holder.List.ChildAdded:Connect(function(c)
			if c.ClassName == "Frame" then
				Dropdown:UpdateHeight()
			end
		end)
		
		Dropdown.Frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and #Dropdown.List > 0 and Mouse.Y - Dropdown.Frame.AbsolutePosition.Y <= 30 then
				Dropdown:Toggle(not Dropdown.Toggled)
			end
		end)

		for i, v in next, list do
			Dropdown:Add(v)
		end

		if typeof(options.default) == "string" then
			Dropdown:Select(options.default)
		end

		return Dropdown
	end

	-- Picker

	function Section:AddPicker(name, options, callback)
		local Picker = {
			Name = name,
			Type = "Picker",
			Toggled = false,
			Rainbow = false,
			Callback = callback,
		}

		local h, s, v = (options.color or Library.Theme.Accent):ToHSV()
		Picker.Color = { R = h, G = s, B = v }

		Picker.Frame = SelfModules.UI.Create("Frame", {
			Name = "ColorPicker",
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			ClipsDescendants = true,
			Size = UDim2.new(1, 2, 0, 42),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				ClipsDescendants = true,
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),

				SelfModules.UI.Create("Frame", {
					Name = "Top",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 40),

					SelfModules.UI.Create("TextLabel", {
						Name = "Label",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 0, 8),
						Size = UDim2.new(0.5, -15, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = name,
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					SelfModules.UI.Create("Frame", {
						Name = "Selected",
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
						Position = UDim2.new(1, -29, 0, 2),
						Size = UDim2.new(0, 100, 0, 26),

						SelfModules.UI.Create("Frame", {
							Name = "Preview",
							BackgroundColor3 = Color3.fromHSV(Picker.Color.R, Picker.Color.G, Picker.Color.B),
							Position = UDim2.new(0, 1, 0, 1),
							Size = UDim2.new(1, -2, 1, -2),
						}, UDim.new(0, 5)),

						SelfModules.UI.Create("TextLabel", {
							Name = "Display",
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 0, 0.5, 0),
							Size = UDim2.new(1, 0, 0, 16),
							Font = Enum.Font.SourceSans,
							Text = "",
							TextColor3 = Library.Theme.TextColor,
							TextSize = 16,
							TextStrokeColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
							TextStrokeTransparency = 0.5,
						}),
					}, UDim.new(0, 5)),

					SelfModules.UI.Create("ImageLabel", {
						Name = "Indicator",
						AnchorPoint = Vector2.new(1, 0),
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -5, 0, 5),
						Size = UDim2.new(0, 20, 0, 20),
						Image = "rbxassetid://9243354333",
					}),

					SelfModules.UI.Create("Frame", {
						Name = "Line",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 5, 0, 30),
						Size = UDim2.new(1, -10, 0, 2),
					}),
				}),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					Active = true,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, 40),
					Size = UDim2.new(1, 0, 1, -40),

					SelfModules.UI.Create("Frame", {
						Name = "Palette",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 5, 0, 5),
						Size = UDim2.new(1, -196, 0, 110),

						SelfModules.UI.Create("Frame", {
							Name = "Point",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = SelfModules.UI.Color.Sub(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
							Position = UDim2.new(1, 0, 0, 0),
							Size = UDim2.new(0, 7, 0, 7),
							ZIndex = 2,

							SelfModules.UI.Create("Frame", {
								Name = "Inner",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								Position = UDim2.new(0, 1, 0, 1),
								Size = UDim2.new(1, -2, 1, -2),
								ZIndex = 2,
							}, UDim.new(1, 0)),
						}, UDim.new(1, 0)),

						SelfModules.UI.Create("Frame", {
							Name = "Hue",
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 1, 0),

							SelfModules.UI.Create("UIGradient", {
								Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromHSV(Picker.Color.R, Picker.Color.G, Picker.Color.B))},
							}),
						}, UDim.new(0, 5)),

						SelfModules.UI.Create("Frame", {
							Name = "SatVal",
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 2,

							SelfModules.UI.Create("UIGradient", {
								Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))},
								Rotation = 90,
								Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(1.00, 0.00)},
							}),
						}, UDim.new(0, 5)),
					}),

					SelfModules.UI.Create("Frame", {
						Name = "HueSlider",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 5, 0, 125),
						Size = UDim2.new(1, -10, 0, 20),

						SelfModules.UI.Create("UIGradient", {
							Color = ColorSequence.new{
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
								ColorSequenceKeypoint.new(0.16666, Color3.fromRGB(255, 255, 0)),
								ColorSequenceKeypoint.new(0.33333, Color3.fromRGB(0, 255, 0)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
								ColorSequenceKeypoint.new(0.66667, Color3.fromRGB(0, 0, 255)),
								ColorSequenceKeypoint.new(0.83333, Color3.fromRGB(255, 0, 255)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
							},
						}),

						SelfModules.UI.Create("Frame", {
							Name = "Bar",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = SelfModules.UI.Color.Sub(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
							Position = UDim2.new(0.5, 0, 0, 0),
							Size = UDim2.new(0, 6, 1, 6),

							SelfModules.UI.Create("Frame", {
								Name = "Inner",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								Position = UDim2.new(0, 1, 0, 1),
								Size = UDim2.new(1, -2, 1, -2),
							}, UDim.new(0, 5)),
						}, UDim.new(0, 5)),
					}, UDim.new(0, 5)),

					SelfModules.UI.Create("Frame", {
						Name = "RGB",
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -180, 0, 5),
						Size = UDim2.new(0, 75, 0, 110),

						SelfModules.UI.Create("Frame", {
							Name = "Red",
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 30),

							SelfModules.UI.Create("TextBox", {
								Name = "Box",
								BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
								Size = UDim2.new(1, 0, 1, 0),
								Font = Enum.Font.SourceSans,
								PlaceholderText = "R",
								Text = 255,
								TextColor3 = Library.Theme.TextColor,
								TextSize = 16,
								TextWrapped = true,
							}, UDim.new(0, 5)),
						}, UDim.new(0, 5)),

						SelfModules.UI.Create("Frame", {
							Name = "Green",
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 0, 0, 40),
							Size = UDim2.new(1, 0, 0, 30),

							SelfModules.UI.Create("TextBox", {
								Name = "Box",
								BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
								Size = UDim2.new(1, 0, 1, 0),
								Font = Enum.Font.SourceSans,
								PlaceholderText = "G",
								Text = 0,
								TextColor3 = Library.Theme.TextColor,
								TextSize = 16,
								TextWrapped = true,
							}, UDim.new(0, 5)),
						}, UDim.new(0, 5)),

						SelfModules.UI.Create("Frame", {
							Name = "Blue",
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 0, 0, 80),
							Size = UDim2.new(1, 0, 0, 30),

							SelfModules.UI.Create("TextBox", {
								Name = "Box",
								BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
								Size = UDim2.new(1, 0, 1, 0),
								Font = Enum.Font.SourceSans,
								PlaceholderText = "B",
								Text = 0,
								TextColor3 = Library.Theme.TextColor,
								TextSize = 16,
								TextWrapped = true,
							}, UDim.new(0, 5)),
						}, UDim.new(0, 5)),
					}),

					SelfModules.UI.Create("Frame", {
						Name = "Rainbow",
						AnchorPoint = Vector2.new(1, 0),
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -5, 0, 87),
						Size = UDim2.new(0, 90, 0, 26),

						SelfModules.UI.Create("TextLabel", {
							Name = "Label",
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 47, 0.5, 0),
							Size = UDim2.new(1, -47, 0, 14),
							Font = Enum.Font.SourceSans,
							Text = "Rainbow",
							TextColor3 = Library.Theme.TextColor,
							TextSize = 14,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
						}),

						SelfModules.UI.Create("Frame", {
							Name = "Indicator",
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
							Size = UDim2.new(0, 40, 0, 26),

							SelfModules.UI.Create("ImageLabel", {
								Name = "Overlay",
								BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)),
								Position = UDim2.new(0, 2, 0, 2),
								Size = UDim2.new(0, 22, 0, 22),
								Image = "http://www.roblox.com/asset/?id=7827504335",
								ImageTransparency = 1,
							}, UDim.new(0, 5)),
						}, UDim.new(0, 5)),
					})
				}),
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5))

		-- Variables

		local hueDragging, satDragging = false, false

		-- Functions

		function Picker:GetHeight()
			return Picker.Toggled == true and 192 or 42
		end

		function Picker:Toggle(bool)
			Picker.Toggled = bool

			tween(Picker.Frame, 0.5, { Size = UDim2.new(1, 2, 0, Picker:GetHeight()) })
			tween(Picker.Frame.Holder.Top.Indicator, 0.5, { Rotation = bool and 90 or 0 })
			tween(Section.Frame, 0.5, { Size = UDim2.new(1, -10, 0, Section:GetHeight()) })
			tween(Tab.Frame, 0.5, { CanvasSize = UDim2.new(0, 0, 0, Tab:GetHeight()) })
		end

		function Picker:ToggleRainbow(bool)
			Picker.Rainbow = bool

			tween(Picker.Frame.Holder.Holder.Rainbow.Indicator.Overlay, 0.25, {ImageTransparency = bool and 0 or 1, Position = bool and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2) })
			tween(Picker.Frame.Holder.Holder.Rainbow.Indicator.Overlay, "Cosmetic", 0.25, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.Accent, Color3.fromRGB(50, 50, 50)) or SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)) })

			if bool then
				if not Storage.Connections[Picker] then
					Storage.Connections[Picker] = {}
				end

				Storage.Connections[Picker].Rainbow = RS.Heartbeat:Connect(function()
					Picker:Set(tick() % 5 / 5, Picker.Color.G, Picker.Color.B)
				end)

			elseif Storage.Connections[Picker] then
				Storage.Connections[Picker].Rainbow:Disconnect()
				Storage.Connections[Picker].Rainbow = nil
			end
		end

		function Picker:Set(h, s, v)
			Picker.Color.R, Picker.Color.G, Picker.Color.B = h, s, v

			local color = Color3.fromHSV(h, s, v)
			Picker.Frame.Holder.Holder.Palette.Hue.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
			Picker.Frame.Holder.Top.Selected.Preview.BackgroundColor3 = color
			Picker.Frame.Holder.Top.Selected.Display.Text = string.format("%d, %d, %d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
			Picker.Frame.Holder.Top.Selected.Size = UDim2.new(0, math.round(TXS:GetTextSize(Picker.Frame.Holder.Top.Selected.Display.Text, 16, Enum.Font.SourceSans, Vector2.new(9e9)).X + 0.5) + 20, 0, 26)

			Picker.Frame.Holder.Holder.RGB.Red.Box.Text = math.floor(color.R * 255 + 0.5)
			Picker.Frame.Holder.Holder.RGB.Green.Box.Text = math.floor(color.G * 255 + 0.5)
			Picker.Frame.Holder.Holder.RGB.Blue.Box.Text = math.floor(color.B * 255 + 0.5)

			tween(Picker.Frame.Holder.Holder.HueSlider.Bar, 0.1, { Position = UDim2.new(h, 0, 0.5, 0) })
			tween(Picker.Frame.Holder.Holder.Palette.Point, 0.1, { Position = UDim2.new(s, 0, 1 - v, 0) })

			pcall(task.spawn, Picker.Callback, color)
		end

		-- Scripts

		Section.List[#Section.List + 1] = Picker
		Picker.Frame.Parent = Section.Frame.List

		Picker.Frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and Mouse.Y - Picker.Frame.AbsolutePosition.Y <= 30 then
				Picker:Toggle(not Picker.Toggled)
			end
		end)

		Picker.Frame.Holder.Holder.HueSlider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				hueDragging = true
			end
		end)

		Picker.Frame.Holder.Holder.HueSlider.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				hueDragging = false
			end
		end)

		Picker.Frame.Holder.Holder.Palette.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				satDragging = true
			end
		end)

		Picker.Frame.Holder.Holder.Palette.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				satDragging = false
			end
		end)

		Mouse.Move:Connect(function()
			if hueDragging and not Picker.Rainbow then
				Picker:Set(math.clamp((Mouse.X - Picker.Frame.Holder.Holder.HueSlider.AbsolutePosition.X) / Picker.Frame.Holder.Holder.HueSlider.AbsoluteSize.X, 0, 1), Picker.Color.G, Picker.Color.B)

			elseif satDragging then
				Picker:Set(Picker.Color.R, math.clamp((Mouse.X - Picker.Frame.Holder.Holder.Palette.AbsolutePosition.X) / Picker.Frame.Holder.Holder.Palette.AbsoluteSize.X, 0, 1), 1 - math.clamp((Mouse.Y - Picker.Frame.Holder.Holder.Palette.AbsolutePosition.Y) / Picker.Frame.Holder.Holder.Palette.AbsoluteSize.Y, 0, 1))
			end
		end)

		Picker.Frame.Holder.Holder.RGB.Red.Box.FocusLost:Connect(function()
			local num = tonumber(Picker.Frame.Holder.Holder.RGB.Red.Box.Text)
			local color = Color3.fromHSV(Picker.Color.R, Picker.Color.G, Picker.Color.B)

			if num then
				Picker:Set(Color3.new(math.clamp(math.floor(num), 0, 255) / 255, color.G, color.B):ToHSV())
			else
				Picker.Frame.Holder.Holder.RGB.Red.Box.Text = math.floor(color.R * 255 + 0.5)
			end
		end)

		Picker.Frame.Holder.Holder.RGB.Green.Box.FocusLost:Connect(function()
			local num = tonumber(Picker.Frame.Holder.Holder.RGB.Green.Box.Text)
			local color = Color3.fromHSV(Picker.Color.R, Picker.Color.G, Picker.Color.B)

			if num then
				Picker:Set(Color3.new(color.R, math.clamp(math.floor(num), 0, 255) / 255, color.B):ToHSV() )
			else
				Picker.Frame.Holder.Holder.RGB.Green.Box.Text = math.floor(color.B * 255 + 0.5)
			end
		end)

		Picker.Frame.Holder.Holder.RGB.Blue.Box.FocusLost:Connect(function()
			local num = tonumber(Picker.Frame.Holder.Holder.RGB.Blue.Box.Text)
			local color = Color3.fromHSV(Picker.Color.R, Picker.Color.G, Picker.Color.B)

			if num then
				Picker:Set(Color3.new(color.R, color.G, math.clamp(math.floor(num), 0, 255) / 255):ToHSV())
			else
				Picker.Frame.Holder.Holder.RGB.Blue.Box.Text = math.floor(color.B * 255 + 0.5)
			end
		end)

		Picker.Frame.Holder.Holder.Rainbow.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				Picker:ToggleRainbow(not Picker.Rainbow)
			end
		end)

		Picker:Set(Picker.Color.R, Picker.Color.G, Picker.Color.B)

		return Picker
	end

	-- SubSection

	function Section:AddSubSection(name, options)
		options = options or {}
		
		local SubSection = {
			Name = name,
			Type = "SubSection",
			Toggled = options.default or false,
			List = {},
		}

		SubSection.Frame = SelfModules.UI.Create("Frame", {
			Name = "SubSection",
			BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
			Size = UDim2.new(1, 2, 0, 42),

			SelfModules.UI.Create("Frame", {
				Name = "Holder",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),

				SelfModules.UI.Create("TextLabel", {
					Name = "Header",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 5, 0, 8),
					Size = UDim2.new(1, -40, 0, 14),
					Font = Enum.Font.SourceSans,
					Text = name,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),

				SelfModules.UI.Create("TextLabel", {
					Name = "Indicator",
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -5, 0, 5),
					Size = UDim2.new(0, 20, 0, 20),
					Font = Enum.Font.SourceSansBold,
					Text = "+",
					TextColor3 = Library.Theme.TextColor,
					TextSize = 20,
				}),

				SelfModules.UI.Create("Frame", {
					Name = "Line",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
					BorderSizePixel = 0,
					Position = UDim2.new(0, 5, 0, 30),
					Size = UDim2.new(1, -10, 0, 2),
				}),

				SelfModules.UI.Create("Frame", {
					Name = "List",
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Position = UDim2.new(0, 5, 0, 40),
					Size = UDim2.new(1, -10, 1, -40),

					SelfModules.UI.Create("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 5),
					}),

					SelfModules.UI.Create("UIPadding", {
						PaddingBottom = UDim.new(0, 1),
						PaddingLeft = UDim.new(0, 1),
						PaddingRight = UDim.new(0, 1),
						PaddingTop = UDim.new(0, 1),
					}),
				}),
			}, UDim.new(0, 5)),
		}, UDim.new(0, 5))

		-- Functions

		local function toggleSubSection(bool)
			SubSection.Toggled = bool

			tween(SubSection.Frame, 0.5, { Size = UDim2.new(1, 2, 0, SubSection:GetHeight()) })
			tween(SubSection.Frame.Holder.Indicator, 0.5, { Rotation = bool and 45 or 0 })

			tween(Section.Frame, 0.5, { Size = UDim2.new(1, -10, 0, Section:GetHeight()) })
			tween(Tab.Frame, 0.5, { CanvasSize = UDim2.new(0, 0, 0, Tab:GetHeight()) })
		end

		function SubSection:GetHeight()
			local height = 42

			if SubSection.Toggled == true then
				for i, v in next, self.List do
					height = height + (v.GetHeight ~= nil and v:GetHeight() or v.Frame.AbsoluteSize.Y) + 5
				end
			end

			return height
		end

		function SubSection:UpdateHeight()
			if SubSection.Toggled == true then
				SubSection.Frame.Size = UDim2.new(1, 2, 0, SubSection:GetHeight())
				SubSection.Frame.Holder.Indicator.Rotation = 45

				Section:UpdateHeight()
			end
		end

		-- Button

		function SubSection:AddButton(name, callback)
			local Button = {
				Name = name,
				Type = "Button",
				Callback = callback,
			}

			Button.Frame = SelfModules.UI.Create("Frame", {
				Name = name,
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				Size = UDim2.new(1, 2, 0, 32),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.new(0, 1, 0, 1),

					SelfModules.UI.Create("TextButton", {
						Name = "Button",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
						Position = UDim2.new(0, 2, 0, 2),
						Size = UDim2.new(1, -4, 1, -4),
						AutoButtonColor = false,
						Font = Enum.Font.SourceSans,
						Text = name,
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
					}, UDim.new(0, 5)),
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Functions

			local function buttonVisual()
				task.spawn(function()
					local Visual = SelfModules.UI.Create("Frame", {
						Name = "Visual",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.9,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0, 0, 1, 0),
					}, UDim.new(0, 5))

					Visual.Parent = Button.Frame.Holder.Button
					tween(Visual, 0.5, { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
					task.wait(0.5)
					Visual:Destroy()
				end)
			end

			-- Scripts

			SubSection.List[#SubSection.List + 1] = Button
			Button.Frame.Parent = SubSection.Frame.Holder.List

			Button.Frame.Holder.Button.MouseButton1Down:Connect(function()
				Button.Frame.Holder.Button.TextSize = 12
			end)

			Button.Frame.Holder.Button.MouseButton1Up:Connect(function()
				Button.Frame.Holder.Button.TextSize = 14
				buttonVisual()

				pcall(task.spawn, Button.Callback)
			end)

			Button.Frame.Holder.Button.MouseLeave:Connect(function()
				Button.Frame.Holder.Button.TextSize = 14
			end)

			return Button
		end

		-- Toggle

		function SubSection:AddToggle(name, options, callback)
			local Toggle = {
				Name = name,
				Type = "Toggle",
				Flag = options and options.flag or name,
				Callback = callback,
			}

			Toggle.Frame = SelfModules.UI.Create("Frame", {
				Name = name,
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				Size = UDim2.new(1, 2, 0, 32),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),

					SelfModules.UI.Create("TextLabel", {
						Name = "Label",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 0.5, -7),
						Size = UDim2.new(1, -50, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = name,
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					SelfModules.UI.Create("Frame", {
						Name = "Indicator",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
						Position = UDim2.new(1, -42, 0, 2),
						Size = UDim2.new(0, 40, 0, 26),

						SelfModules.UI.Create("ImageLabel", {
							Name = "Overlay",
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)),
							Position = UDim2.new(0, 2, 0, 2),
							Size = UDim2.new(0, 22, 0, 22),
							Image = "http://www.roblox.com/asset/?id=7827504335",
							ImageTransparency = 1,
						}, UDim.new(0, 5)),
					}, UDim.new(0, 5))
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Functions

			function Toggle:Set(bool, instant)
				Tab.Flags[Toggle.Flag] = bool

				tween(Toggle.Frame.Holder.Indicator.Overlay, instant and 0 or 0.25, { ImageTransparency = bool and 0 or 1, Position = bool and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2) })
				tween(Toggle.Frame.Holder.Indicator.Overlay, "Cosmetic", instant and 0 or 0.25, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.Accent, Color3.fromRGB(50, 50, 50)) or SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)) })
			
				pcall(task.spawn, Toggle.Callback, bool)
			end

			-- Scripts

			SubSection.List[#SubSection.List + 1] = Toggle
			Tab.Flags[Toggle.Flag] = options.default == true
			Toggle.Frame.Parent = SubSection.Frame.Holder.List

			Toggle.Frame.Holder.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Toggle:Set(not Tab.Flags[Toggle.Flag], false)
				end
			end)

			Toggle:Set(options.default == true, true)

			return Toggle
		end

		-- Label

		function SubSection:AddLabel(name)
			local Label = {
				Name = name,
				Type = "Label",
			}

			Label.Frame = SelfModules.UI.Create("Frame", {
				Name = name,
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				Size = UDim2.new(1, 2, 0, 22),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),

					SelfModules.UI.Create("TextLabel", {
						Name = "Label",
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 2, 0.5, 0),
						Size = UDim2.new(1, -4, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = name,
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
					}),
				}, UDim.new(0, 5))
			}, UDim.new(0, 5))

			-- Scripts

			SubSection.List[#SubSection.List + 1] = Label
			Label.Label = Label.Frame.Holder.Label
			Label.Frame.Parent = SubSection.Frame.Holder.List

			return Label
		end

		-- DualLabel

		function SubSection:AddDualLabel(options)
			options = options or {}
			
			local DualLabel = {
				Name = options[1].. " ".. options[2],
				Type = "DualLabel",
			}

			DualLabel.Frame = SelfModules.UI.Create("Frame", {
				Name = options[1].. " ".. options[2],
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				Size = UDim2.new(1, 2, 0, 22),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),

					SelfModules.UI.Create("TextLabel", {
						Name = "Label1",
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 0.5, 0),
						Size = UDim2.new(0.5, -5, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = options[1],
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					SelfModules.UI.Create("TextLabel", {
						Name = "Label2",
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(0.5, -5, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = options[2],
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Right,
					}),
				}, UDim.new(0, 5))
			}, UDim.new(0, 5))

			-- Scripts

			SubSection.List[#SubSection.List + 1] = DualLabel
			DualLabel.Label1 = DualLabel.Frame.Holder.Label1
			DualLabel.Label2 = DualLabel.Frame.Holder.Label2
			DualLabel.Frame.Parent = SubSection.Frame.Holder.List

			return DualLabel
		end

		-- ClipboardLabel

		function SubSection:AddClipboardLabel(name, callback)
			local ClipboardLabel = {
				Name = name,
				Type = "ClipboardLabel",
				Callback = callback,
			}

			ClipboardLabel.Frame = SelfModules.UI.Create("Frame", {
				Name = name,
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				Size = UDim2.new(1, 2, 0, 22),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),

					SelfModules.UI.Create("TextLabel", {
						Name = "Label",
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 2, 0.5, 0),
						Size = UDim2.new(1, -22, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = name,
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
					}),

					SelfModules.UI.Create("ImageLabel", {
						Name = "Icon",
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -18, 0, 2),
						Size = UDim2.new(0, 16, 0, 16),
						Image = "rbxassetid://9243581053",
					}),
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Scripts

			SubSection.List[#SubSection.List + 1] = ClipboardLabel
			ClipboardLabel.Label = ClipboardLabel.Frame.Holder.Label
			ClipboardLabel.Frame.Parent = SubSection.Frame.Holder.List

			ClipboardLabel.Frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local s, result = pcall(ClipboardLabel.Callback)

					if s then
						setclipboard(result)
					end
				end
			end)

			return ClipboardLabel
		end

		-- Box

		function SubSection:AddBox(name, options, callback)
			local Box = {
				Name = name,
				Type = "Box",
				Callback = callback,
			}

			Box.Frame = SelfModules.UI.Create("Frame", {
				Name = name,
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				Size = UDim2.new(1, 2, 0, 32),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),

					SelfModules.UI.Create("TextLabel", {
						Name = "Label",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 0.5, -7),
						Size = UDim2.new(1, -135, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = name,
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					SelfModules.UI.Create("Frame", {
						Name = "TextBox",
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Library.Theme.SectionColor,
						Position = UDim2.new(1, -2, 0, 2),
						Size = UDim2.new(0, 140, 1, -4),
						ZIndex = 2,

						SelfModules.UI.Create("Frame", {
							Name = "Holder",
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(5, 5, 5)),
							Position = UDim2.new(0, 1, 0, 1),
							Size = UDim2.new(1, -2, 1, -2),
							ZIndex = 2,

							SelfModules.UI.Create("TextBox", {
								Name = "Box",
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = 1,
								ClearTextOnFocus = options.clearonfocus ~= true,
								Position = UDim2.new(0, 28, 0.5, 0),
								Size = UDim2.new(1, -30, 1, 0),
								Font = Enum.Font.SourceSans,
								PlaceholderText = "Text",
								Text = "",
								TextColor3 = Library.Theme.TextColor,
								TextSize = 14,
								TextWrapped = true,
							}),

							SelfModules.UI.Create("TextLabel", {
								Name = "Icon",
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = 1,
								Position = UDim2.new(0, 6, 0.5, 0),
								Size = UDim2.new(0, 14, 0, 14),
								Font = Enum.Font.SourceSansBold,
								Text = "T",
								TextColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(40, 40, 40)),
								TextSize = 18,
								TextWrapped = true,
							}),
						}, UDim.new(0, 5)),
					}, UDim.new(0, 5))
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Functions

			local function extendBox(bool)
				tween(Box.Frame.Holder.TextBox, 0.25, { Size = UDim2.new(0, bool and 200 or 140, 1, -4) })
			end

			-- Scripts

			SubSection.List[#SubSection.List + 1] = Box
			Box.Box = Box.Frame.Holder.TextBox.Holder.Box
			Box.Frame.Parent = SubSection.Frame.Holder.List

			Box.Frame.Holder.TextBox.Holder.MouseEnter:Connect(function()
				extendBox(true)
			end)

			Box.Frame.Holder.TextBox.Holder.MouseLeave:Connect(function()
				if Box.Frame.Holder.TextBox.Holder.Box:IsFocused() == false then
					extendBox(false)
				end
			end)

			Box.Frame.Holder.TextBox.Holder.Box.FocusLost:Connect(function()
				if Box.Frame.Holder.TextBox.Holder.Box.Text == "" and options.fireonempty ~= true then
					return
				end

				extendBox(false)
				pcall(task.spawn, Box.Callback, Box.Frame.Holder.TextBox.Holder.Box.Text)
			end)

			return Box
		end

		-- Bind

		function SubSection:AddBind(name, bind, options, callback)
			local Bind = {
				Name = name,
				Type = "Bind",
				Bind = bind,
				Flag = options.flag or name,
				Callback = callback,
			}

			Bind.Frame = SelfModules.UI.Create("Frame", {
				Name = name,
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				Size = UDim2.new(1, 2, 0, 32),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),

					SelfModules.UI.Create("TextLabel", {
						Name = "Label",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 0.5, -7),
						Size = UDim2.new(1, -135, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = name,
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					SelfModules.UI.Create("Frame", {
						Name = "Bind",
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
						Position = UDim2.new(1, options.toggleable == true and -44 or -2, 0, 2),
						Size = UDim2.new(0, 78, 0, 26),
						ZIndex = 2,

						SelfModules.UI.Create("TextLabel", {
							Name = "Label",
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
							Position = UDim2.new(0, 1, 0, 1),
							Size = UDim2.new(1, -2, 1, -2),
							Font = Enum.Font.SourceSans,
							Text = "",
							TextColor3 = Library.Theme.TextColor,
							TextSize = 14,
						}, UDim.new(0, 5)),
					}, UDim.new(0, 5)),
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Variables

			local indicatorEntered = false
			local connections = {}

			-- Functions

			local function listenForInput()
				if connections.listen then
					connections.listen:Disconnect()
				end

				Bind.Frame.Holder.Bind.Label.Text = "..."
				ListenForInput = true

				connections.listen = UIS.InputBegan:Connect(function(input, gameProcessed)
					if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
						Bind:Set(input.KeyCode)
					end
				end)
			end

			local function cancelListen()
				if connections.listen then
					connections.listen:Disconnect(); connections.listen = nil
				end

				Bind.Frame.Holder.Bind.Label.Text = Bind.Bind.Name
				task.spawn(function() RS.RenderStepped:Wait(); ListenForInput = false end)
			end

			function Bind:Set(bind)
				Bind.Bind = bind
				Bind.Frame.Holder.Bind.Label.Text = bind.Name
				Bind.Frame.Holder.Bind.Size = UDim2.new(0, math.max(12 + math.round(TXS:GetTextSize(bind.Name, 14, Enum.Font.SourceSans, Vector2.new(9e9)).X + 0.5), 42), 0, 26)
				
				if connections.listen then
					cancelListen()
				end
			end

			if options.toggleable == true then
				function Bind:Toggle(bool, instant)
					Tab.Flags[Bind.Flag] = bool

					tween(Bind.Frame.Holder.Indicator.Overlay, instant and 0 or 0.25, { ImageTransparency = bool and 0 or 1, Position = bool and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2) })
					tween(Bind.Frame.Holder.Indicator.Overlay, "Cosmetic", instant and 0 or 0.25, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.Accent, Color3.fromRGB(50, 50, 50)) or SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)) })

					if options.fireontoggle ~= false then
						pcall(task.spawn, Bind.Callback, Bind.Bind)
					end
				end
			end

			-- Scripts

			SubSection.List[#SubSection.List + 1] = Bind
			Bind.Frame.Parent = SubSection.Frame.Holder.List

			Bind.Frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if indicatorEntered == true then
						Bind:Toggle(not Tab.Flags[Bind.Flag], false)
					else
						listenForInput()
					end
				end
			end)

			UIS.InputBegan:Connect(function(input)
				if input.KeyCode == Bind.Bind then
					if options.toggleable == true and Tab.Flags[Bind.Flag] == false then
						return
					end

					pcall(task.spawn, Bind.Callback, Bind.Bind)
				end
			end)

			if options.toggleable == true then
				local indicator = SelfModules.UI.Create("Frame", {
					Name = "Indicator",
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
					Position = UDim2.new(1, -2, 0, 2),
					Size = UDim2.new(0, 40, 0, 26),

					SelfModules.UI.Create("ImageLabel", {
						Name = "Overlay",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)),
						Position = UDim2.new(0, 2, 0, 2),
						Size = UDim2.new(0, 22, 0, 22),
						Image = "http://www.roblox.com/asset/?id=7827504335",
					}, UDim.new(0, 5)),
				}, UDim.new(0, 5))

				-- Scripts

				Tab.Flags[Bind.Flag] = options.default == true
				indicator.Parent = Bind.Frame.Holder

				Bind.Frame.Holder.Indicator.MouseEnter:Connect(function()
					indicatorEntered = true
				end)

				Bind.Frame.Holder.Indicator.MouseLeave:Connect(function()
					indicatorEntered = false
				end)

				Bind:Toggle(options.default == true, true)
			end

			Bind:Set(Bind.Bind)

			return Bind
		end

		-- Slider

		function SubSection:AddSlider(name, min, max, default, options, callback)
			local Slider = {
				Name = name,
				Type = "Slider",
				Value = default,
				Flag = options.flag or name,
				Callback = callback,
			}

			Slider.Frame = SelfModules.UI.Create("Frame", {
				Name = name,
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				Size = UDim2.new(1, 2, 0, 41),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),

					SelfModules.UI.Create("TextLabel", {
						Name = "Label",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 0, 5),
						Size = UDim2.new(1, -75, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = name,
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					SelfModules.UI.Create("Frame", {
						Name = "Slider",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 1, -15),
						Size = UDim2.new(1, -10, 0, 10),

						SelfModules.UI.Create("Frame", {
							Name = "Bar",
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
							ClipsDescendants = true,
							Size = UDim2.new(1, 0, 1, 0),

							SelfModules.UI.Create("Frame", {
								Name = "Fill",
								BackgroundColor3 = SelfModules.UI.Color.Sub(Library.Theme.Accent, Color3.fromRGB(50, 50, 50)),
								Size = UDim2.new(0.5, 0, 1, 0),
							}, UDim.new(0, 5)),
						}, UDim.new(0, 5)),

						SelfModules.UI.Create("Frame", {
							Name = "Point",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Library.Theme.Accent,
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(0, 12, 0, 12),
						}, UDim.new(0, 5)),
					}),

					SelfModules.UI.Create("TextBox", {
						Name = "Input",
						AnchorPoint = Vector2.new(1, 0),
						BackgroundTransparency = 1,
						PlaceholderText = "...",
						Position = UDim2.new(1, -5, 0, 5),
						Size = UDim2.new(0, 60, 0, 14),
						Font = Enum.Font.SourceSans,
						Text = "",
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Right,
					}),
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Variables

			local connections = {}

			-- Functions

			local function getSliderValue(val)
				val = math.clamp(val, min, max)

				if options.rounded == true then
					val = math.floor(val)
				end

				return val
			end

			local function sliderVisual(val)
				val = getSliderValue(val)

				Slider.Frame.Holder.Input.Text = val

				local valuePercent = 1 - ((max - val) / (max - min))
				local pointPadding = 1 / Slider.Frame.Holder.Slider.AbsoluteSize.X * 5
				tween(Slider.Frame.Holder.Slider.Bar.Fill, 0.25, { Size = UDim2.new(valuePercent, 0, 1, 0) })
				tween(Slider.Frame.Holder.Slider.Point, 0.25, { Position = UDim2.fromScale(math.clamp(valuePercent, pointPadding, 1 - pointPadding), 0.5) })
			end

			function Slider:Set(val)
				val = getSliderValue(val)
				Slider.Value = val
				sliderVisual(val)

				if options.toggleable == true and Tab.Flags[Slider.Flag] == false then
					return
				end

				pcall(task.spawn, Slider.Callback, val, Tab.Flags[Slider.Flag] or nil)
			end

			if options.toggleable == true then
				function Slider:Toggle(bool, instant)
					Tab.Flags[Slider.Flag] = bool

					tween(Slider.Frame.Holder.Indicator.Overlay, instant and 0 or 0.25, { ImageTransparency = bool and 0 or 1, Position = bool and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2) })
					tween(Slider.Frame.Holder.Indicator.Overlay, "Cosmetic", instant and 0 or 0.25, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.Accent, Color3.fromRGB(50, 50, 50)) or SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)) })
				
					if options.fireontoggle ~= false then
						pcall(task.spawn, Slider.Callback, Slider.Value, bool)
					end
				end
			end

			-- Scripts

			SubSection.List[#SubSection.List + 1] = Slider
			Slider.Frame.Parent = SubSection.Frame.Holder.List

			Slider.Frame.Holder.Slider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then

					connections.move = Mouse.Move:Connect(function()
						local sliderPercent = math.clamp((Mouse.X - Slider.Frame.Holder.Slider.AbsolutePosition.X) / Slider.Frame.Holder.Slider.AbsoluteSize.X, 0, 1)
						local sliderValue = math.floor((min + sliderPercent * (max - min)) * 10) / 10

						if options.fireondrag ~= false then
							Slider:Set(sliderValue)
						else
							sliderVisual(sliderValue)
						end
					end)

				end
			end)

			Slider.Frame.Holder.Slider.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					connections.move:Disconnect()
					connections.move = nil

					if options.fireondrag ~= true then
						local sliderPercent = math.clamp((Mouse.X - Slider.Frame.Holder.Slider.AbsolutePosition.X) / Slider.Frame.Holder.Slider.AbsoluteSize.X, 0, 1)
						local sliderValue = math.floor((min + sliderPercent * (max - min)) * 10) / 10

						Slider:Set(sliderValue)
					end
				end
			end)

			Slider.Frame.Holder.Input.FocusLost:Connect(function()
				Slider.Frame.Holder.Input.Text = string.sub(Slider.Frame.Holder.Input.Text, 1, 10)

				if tonumber(Slider.Frame.Holder.Input.Text) then
					Slider:Set(Slider.Frame.Holder.Input.Text)
				end
			end)

			if options.toggleable == true then
				local indicator = SelfModules.UI.Create("Frame", {
					Name = "Indicator",
					AnchorPoint = Vector2.new(1, 1),
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
					Position = UDim2.new(1, -2, 1, -2),
					Size = UDim2.new(0, 40, 0, 26),

					SelfModules.UI.Create("ImageLabel", {
						Name = "Overlay",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)),
						Position = UDim2.new(0, 2, 0, 2),
						Size = UDim2.new(0, 22, 0, 22),
						Image = "http://www.roblox.com/asset/?id=7827504335",
					}, UDim.new(0, 5)),
				}, UDim.new(0, 5))

				-- Scripts

				Tab.Flags[Slider.Flag] = options.default == true
				Slider.Frame.Size = UDim2.new(1, 2, 0, 54)
				Slider.Frame.Holder.Slider.Size = UDim2.new(1, -50, 0, 10)
				indicator.Parent = Slider.Frame.Holder

				Slider.Frame.Holder.Indicator.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Slider:Toggle(not Tab.Flags[Slider.Flag], false)
					end
				end)

				Slider:Toggle(options.default == true, true)
			end

			Slider:Set(Slider.Value)

			return Slider
		end

		-- Dropdown

		function SubSection:AddDropdown(name, list, options, callback)
			local Dropdown = {
				Name = name,
				Type = "Dropdown",
				Toggled = false,
				Selected = "",
				List = {},
				Callback = callback,
			}

			local ListObjects = {}

			Dropdown.Frame = SelfModules.UI.Create("Frame", {
				Name = "Dropdown",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				Size = UDim2.new(1, 2, 0, 42),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),

					SelfModules.UI.Create("Frame", {
						Name = "Holder",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 40),

						SelfModules.UI.Create("Frame", {
							Name = "Displays",
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 5, 0, 8),
							Size = UDim2.new(1, -35, 0, 14),

							SelfModules.UI.Create("TextLabel", {
								Name = "Label",
								BackgroundTransparency = 1,
								Size = UDim2.new(0.5, 0, 1, 0),
								Font = Enum.Font.SourceSans,
								Text = name,
								TextColor3 = Library.Theme.TextColor,
								TextSize = 14,
								TextWrapped = true,
								TextXAlignment = Enum.TextXAlignment.Left,
							}),

							SelfModules.UI.Create("TextLabel", {
								Name = "Selected",
								BackgroundTransparency = 1,
								Position = UDim2.new(0.5, 0, 0, 0),
								Size = UDim2.new(0.5, 0, 1, 0),
								Font = Enum.Font.SourceSans,
								Text = "",
								TextColor3 = Library.Theme.TextColor,
								TextSize = 14,
								TextWrapped = true,
								TextXAlignment = Enum.TextXAlignment.Right,
							}),
						}),

						SelfModules.UI.Create("ImageLabel", {
							Name = "Indicator",
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -5, 0, 5),
							Size = UDim2.new(0, 20, 0, 20),
							Image = "rbxassetid://9243354333",
						}),

						SelfModules.UI.Create("Frame", {
							Name = "Line",
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
							BorderSizePixel = 0,
							Position = UDim2.new(0, 5, 0, 30),
							Size = UDim2.new(1, -10, 0, 2),
						}),
					}, UDim.new(0, 5)),

					SelfModules.UI.Create("ScrollingFrame", {
						Name = "List",
						Active = true,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 5, 0, 40),
						Size = UDim2.new(1, -10, 1, -40),
						CanvasSize = UDim2.new(0, 0, 0, 0),
						ScrollBarImageColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
						ScrollBarThickness = 5,

						SelfModules.UI.Create("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 5),
						}),
					}),
				}, UDim.new(0,5)),
			}, UDim.new(0, 5))

			-- Functions

			function Dropdown:GetHeight()
				return 42 + (Dropdown.Toggled == true and math.min(#Dropdown.List, 5) * 27 or 0)
			end

			function Dropdown:UpdateHeight()
				Dropdown.Frame.Holder.List.CanvasSize = UDim2.new(0, 0, 0, #Dropdown.List * 27 - 5)
				
				if Dropdown.Toggled == true then
					Dropdown.Frame.Size = UDim2.new(1, 2, 0, Dropdown:GetHeight())
					SubSection:UpdateHeight()
				end
			end

			function Dropdown:Add(name, options, callback)
				local Item = {
					Name = name,
					Callback = callback,
				}

				Item.Frame = SelfModules.UI.Create("Frame", {
					Name = name,
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
					Size = UDim2.new(1, -10, 0, 22),

					SelfModules.UI.Create("TextButton", {
						Name = "Button",
						BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
						Position = UDim2.new(0, 1, 0, 1),
						Size = UDim2.new(1, -2, 1, -2),
						Font = Enum.Font.SourceSans,
						Text = name,
						TextColor3 = Library.Theme.TextColor,
						TextSize = 14,
						TextWrapped = true,
					}, UDim.new(0, 5)),
				}, UDim.new(0, 5))

				-- Scripts

				Dropdown.List[#Dropdown.List + 1] = name
				ListObjects[#ListObjects + 1] = Item
				Item.Frame.Parent = Dropdown.Frame.Holder.List

				if Dropdown.Toggled == true then
					Dropdown:UpdateHeight()
				end

				Item.Frame.Button.Activated:Connect(function()
					if typeof(Item.Callback) == "function" then
						pcall(task.spawn, Item.Callback)
					else
						Dropdown:Select(Item.Name)
					end
				end)

				return Item
			end

			function Dropdown:Remove(name, ignoreToggle)
				for i, v in next, Dropdown.List do
					if v == name then
						local item = ListObjects[i]

						if item then
							item.Frame:Destroy()
							table.remove(Dropdown.List, i)
							table.remove(ListObjects, i)

							if Dropdown.Toggled then
								Dropdown:UpdateHeight()
							end
							
							if #Dropdown.List == 0 and not ignoreToggle then
								Dropdown:Toggle(false)
							end
						end

						break
					end
				end
			end

			function Dropdown:ClearList()
				for _ = 1, #Dropdown.List, 1 do
					Dropdown:Remove(Dropdown.List[1], true)
				end
			end

			function Dropdown:SetList(list)
				Dropdown:ClearList()

				for _, v in next, list do
					Dropdown:Add(v)
				end
			end

			function Dropdown:Select(itemName)
				Dropdown.Selected = itemName
				Dropdown.Frame.Holder.Holder.Displays.Selected.Text = itemName
				Dropdown:Toggle(false)

				pcall(task.spawn, Dropdown.Callback, itemName)
			end

			function Dropdown:Toggle(bool)
				Dropdown.Toggled = bool

				tween(Dropdown.Frame, 0.5, { Size = UDim2.new(1, 2, 0, Dropdown:GetHeight()) })
				tween(Dropdown.Frame.Holder.Holder.Indicator, 0.5, { Rotation = bool and 90 or 0 })
				tween(SubSection.Frame, 0.5, { Size = UDim2.new(1, 2, 0, SubSection:GetHeight()) })
				tween(Section.Frame, 0.5, { Size = UDim2.new(1, -10, 0, Section:GetHeight()) })
				tween(Tab.Frame, 0.5, { CanvasSize = UDim2.new(0, 0, 0, Tab:GetHeight()) })
			end

			-- Scripts

			SubSection.List[#SubSection.List + 1] = Dropdown
			Dropdown.Frame.Parent = SubSection.Frame.Holder.List
			
			Dropdown.Frame.Holder.List.ChildAdded:Connect(function(c)
				if c.ClassName == "Frame" then
					Dropdown:UpdateHeight()
				end
			end)
			
			Dropdown.Frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and #Dropdown.List > 0 and Mouse.Y - Dropdown.Frame.AbsolutePosition.Y <= 30 then
					Dropdown:Toggle(not Dropdown.Toggled)
				end
			end)

			for i, v in next, list do
				Dropdown:Add(v)
			end

			if typeof(options.default) == "string" then
				Dropdown:Select(options.default)
			end

			return Dropdown
		end

		-- Picker

		function SubSection:AddPicker(name, options, callback)
			local Picker = {
				Name = name,
				Type = "Picker",
				Toggled = false,
				Rainbow = false,
				Callback = callback,
			}

			local h, s, v = (options.color or Library.Theme.Accent):ToHSV()
			Picker.Color = { R = h, G = s, B = v }

			Picker.Frame = SelfModules.UI.Create("Frame", {
				Name = "ColorPicker",
				BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
				ClipsDescendants = true,
				Size = UDim2.new(1, 2, 0, 42),

				SelfModules.UI.Create("Frame", {
					Name = "Holder",
					BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
					ClipsDescendants = true,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),

					SelfModules.UI.Create("Frame", {
						Name = "Top",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 40),

						SelfModules.UI.Create("TextLabel", {
							Name = "Label",
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 5, 0, 8),
							Size = UDim2.new(0.5, -15, 0, 14),
							Font = Enum.Font.SourceSans,
							Text = name,
							TextColor3 = Library.Theme.TextColor,
							TextSize = 14,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
						}),

						SelfModules.UI.Create("Frame", {
							Name = "Selected",
							AnchorPoint = Vector2.new(1, 0),
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
							Position = UDim2.new(1, -29, 0, 2),
							Size = UDim2.new(0, 100, 0, 26),

							SelfModules.UI.Create("Frame", {
								Name = "Preview",
								BackgroundColor3 = Color3.fromHSV(Picker.Color.R, Picker.Color.G, Picker.Color.B),
								Position = UDim2.new(0, 1, 0, 1),
								Size = UDim2.new(1, -2, 1, -2),
							}, UDim.new(0, 5)),

							SelfModules.UI.Create("TextLabel", {
								Name = "Display",
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = 1,
								Position = UDim2.new(0, 0, 0.5, 0),
								Size = UDim2.new(1, 0, 0, 16),
								Font = Enum.Font.SourceSans,
								Text = "",
								TextColor3 = Library.Theme.TextColor,
								TextSize = 16,
								TextStrokeColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
								TextStrokeTransparency = 0.5,
							}),
						}, UDim.new(0, 5)),

						SelfModules.UI.Create("ImageLabel", {
							Name = "Indicator",
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -5, 0, 5),
							Size = UDim2.new(0, 20, 0, 20),
							Image = "rbxassetid://9243354333",
						}),

						SelfModules.UI.Create("Frame", {
							Name = "Line",
							BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
							BorderSizePixel = 0,
							Position = UDim2.new(0, 5, 0, 30),
							Size = UDim2.new(1, -10, 0, 2),
						}),
					}),

					SelfModules.UI.Create("Frame", {
						Name = "Holder",
						Active = true,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 0, 40),
						Size = UDim2.new(1, 0, 1, -40),

						SelfModules.UI.Create("Frame", {
							Name = "Palette",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.new(0, 5, 0, 5),
							Size = UDim2.new(1, -196, 0, 110),

							SelfModules.UI.Create("Frame", {
								Name = "Point",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = SelfModules.UI.Color.Sub(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
								Position = UDim2.new(1, 0, 0, 0),
								Size = UDim2.new(0, 7, 0, 7),
								ZIndex = 2,

								SelfModules.UI.Create("Frame", {
									Name = "Inner",
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									Position = UDim2.new(0, 1, 0, 1),
									Size = UDim2.new(1, -2, 1, -2),
									ZIndex = 2,
								}, UDim.new(1, 0)),
							}, UDim.new(1, 0)),

							SelfModules.UI.Create("Frame", {
								Name = "Hue",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 1, 0),

								SelfModules.UI.Create("UIGradient", {
									Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromHSV(Picker.Color.R, Picker.Color.G, Picker.Color.B))},
								}),
							}, UDim.new(0, 5)),

							SelfModules.UI.Create("Frame", {
								Name = "SatVal",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 2,

								SelfModules.UI.Create("UIGradient", {
									Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))},
									Rotation = 90,
									Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(1.00, 0.00)},
								}),
							}, UDim.new(0, 5)),
						}),

						SelfModules.UI.Create("Frame", {
							Name = "HueSlider",
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							Position = UDim2.new(0, 5, 0, 125),
							Size = UDim2.new(1, -10, 0, 20),

							SelfModules.UI.Create("UIGradient", {
								Color = ColorSequence.new{
									ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
									ColorSequenceKeypoint.new(0.16666, Color3.fromRGB(255, 255, 0)),
									ColorSequenceKeypoint.new(0.33333, Color3.fromRGB(0, 255, 0)),
									ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
									ColorSequenceKeypoint.new(0.66667, Color3.fromRGB(0, 0, 255)),
									ColorSequenceKeypoint.new(0.83333, Color3.fromRGB(255, 0, 255)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
								},
							}),

							SelfModules.UI.Create("Frame", {
								Name = "Bar",
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = SelfModules.UI.Color.Sub(Library.Theme.SectionColor, Color3.fromRGB(10, 10, 10)),
								Position = UDim2.new(0.5, 0, 0, 0),
								Size = UDim2.new(0, 6, 1, 6),

								SelfModules.UI.Create("Frame", {
									Name = "Inner",
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									Position = UDim2.new(0, 1, 0, 1),
									Size = UDim2.new(1, -2, 1, -2),
								}, UDim.new(0, 5)),
							}, UDim.new(0, 5)),
						}, UDim.new(0, 5)),

						SelfModules.UI.Create("Frame", {
							Name = "RGB",
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -180, 0, 5),
							Size = UDim2.new(0, 75, 0, 110),

							SelfModules.UI.Create("Frame", {
								Name = "Red",
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 0, 30),

								SelfModules.UI.Create("TextBox", {
									Name = "Box",
									BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
									Size = UDim2.new(1, 0, 1, 0),
									Font = Enum.Font.SourceSans,
									PlaceholderText = "R",
									Text = 255,
									TextColor3 = Library.Theme.TextColor,
									TextSize = 16,
									TextWrapped = true,
								}, UDim.new(0, 5)),
							}, UDim.new(0, 5)),

							SelfModules.UI.Create("Frame", {
								Name = "Green",
								BackgroundTransparency = 1,
								Position = UDim2.new(0, 0, 0, 40),
								Size = UDim2.new(1, 0, 0, 30),

								SelfModules.UI.Create("TextBox", {
									Name = "Box",
									BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
									Size = UDim2.new(1, 0, 1, 0),
									Font = Enum.Font.SourceSans,
									PlaceholderText = "G",
									Text = 0,
									TextColor3 = Library.Theme.TextColor,
									TextSize = 16,
									TextWrapped = true,
								}, UDim.new(0, 5)),
							}, UDim.new(0, 5)),

							SelfModules.UI.Create("Frame", {
								Name = "Blue",
								BackgroundTransparency = 1,
								Position = UDim2.new(0, 0, 0, 80),
								Size = UDim2.new(1, 0, 0, 30),

								SelfModules.UI.Create("TextBox", {
									Name = "Box",
									BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(15, 15, 15)),
									Size = UDim2.new(1, 0, 1, 0),
									Font = Enum.Font.SourceSans,
									PlaceholderText = "B",
									Text = 0,
									TextColor3 = Library.Theme.TextColor,
									TextSize = 16,
									TextWrapped = true,
								}, UDim.new(0, 5)),
							}, UDim.new(0, 5)),
						}),

						SelfModules.UI.Create("Frame", {
							Name = "Rainbow",
							AnchorPoint = Vector2.new(1, 0),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -5, 0, 87),
							Size = UDim2.new(0, 90, 0, 26),

							SelfModules.UI.Create("TextLabel", {
								Name = "Label",
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = 1,
								Position = UDim2.new(0, 47, 0.5, 0),
								Size = UDim2.new(1, -47, 0, 14),
								Font = Enum.Font.SourceSans,
								Text = "Rainbow",
								TextColor3 = Library.Theme.TextColor,
								TextSize = 14,
								TextWrapped = true,
								TextXAlignment = Enum.TextXAlignment.Left,
							}),

							SelfModules.UI.Create("Frame", {
								Name = "Indicator",
								BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(20, 20, 20)),
								Size = UDim2.new(0, 40, 0, 26),

								SelfModules.UI.Create("ImageLabel", {
									Name = "Overlay",
									BackgroundColor3 = SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)),
									Position = UDim2.new(0, 2, 0, 2),
									Size = UDim2.new(0, 22, 0, 22),
									Image = "http://www.roblox.com/asset/?id=7827504335",
									ImageTransparency = 1,
								}, UDim.new(0, 5)),
							}, UDim.new(0, 5)),
						})
					}),
				}, UDim.new(0, 5)),
			}, UDim.new(0, 5))

			-- Variables

			local hueDragging, satDragging = false, false

			-- Functions

			function Picker:GetHeight()
				return Picker.Toggled == true and 192 or 42
			end

			function Picker:Toggle(bool)
				Picker.Toggled = bool

				tween(Picker.Frame, 0.5, { Size = UDim2.new(1, 2, 0, Picker:GetHeight()) })
				tween(Picker.Frame.Holder.Top.Indicator, 0.5, { Rotation = bool and 90 or 0 })

				tween(SubSection.Frame, 0.5, { Size = UDim2.new(1, 2, 0, SubSection:GetHeight()) })
				tween(Section.Frame, 0.5, { Size = UDim2.new(1, -10, 0, Section:GetHeight()) })
				tween(Tab.Frame, 0.5, { CanvasSize = UDim2.new(0, 0, 0, Tab:GetHeight()) })
			end

			function Picker:ToggleRainbow(bool)
				Picker.Rainbow = bool

				tween(Picker.Frame.Holder.Holder.Rainbow.Indicator.Overlay, 0.25, {ImageTransparency = bool and 0 or 1, Position = bool and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2) })
				tween(Picker.Frame.Holder.Holder.Rainbow.Indicator.Overlay, "Cosmetic", 0.25, { BackgroundColor3 = bool and SelfModules.UI.Color.Add(Library.Theme.Accent, Color3.fromRGB(50, 50, 50)) or SelfModules.UI.Color.Add(Library.Theme.SectionColor, Color3.fromRGB(25, 25, 25)) })

				if bool then
					if not Storage.Connections[Picker] then
						Storage.Connections[Picker] = {}
					end

					Storage.Connections[Picker].Rainbow = RS.Heartbeat:Connect(function()
						Picker:Set(tick() % 5 / 5, Picker.Color.G, Picker.Color.B)
					end)

				elseif Storage.Connections[Picker] then
					Storage.Connections[Picker].Rainbow:Disconnect()
					Storage.Connections[Picker].Rainbow = nil
				end
			end

			function Picker:Set(h, s, v)
				Picker.Color.R, Picker.Color.G, Picker.Color.B = h, s, v

				local color = Color3.fromHSV(h, s, v)
				Picker.Frame.Holder.Holder.Palette.Hue.UIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
				Picker.Frame.Holder.Top.Selected.Preview.BackgroundColor3 = color
				Picker.Frame.Holder.Top.Selected.Display.Text = string.format("%d, %d, %d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
				Picker.Frame.Holder.Top.Selected.Size = UDim2.new(0, math.round(TXS:GetTextSize(Picker.Frame.Holder.Top.Selected.Display.Text, 16, Enum.Font.SourceSans, Vector2.new(9e9)).X + 0.5) + 20, 0, 26)

				Picker.Frame.Holder.Holder.RGB.Red.Box.Text = math.floor(color.R * 255 + 0.5)
				Picker.Frame.Holder.Holder.RGB.Green.Box.Text = math.floor(color.G * 255 + 0.5)
				Picker.Frame.Holder.Holder.RGB.Blue.Box.Text = math.floor(color.B * 255 + 0.5)

				tween(Picker.Frame.Holder.Holder.HueSlider.Bar, 0.1, { Position = UDim2.new(h, 0, 0.5, 0) })
				tween(Picker.Frame.Holder.Holder.Palette.Point, 0.1, { Position = UDim2.new(s, 0, 1 - v, 0) })

				pcall(task.spawn, Picker.Callback, color)
			end

			-- Scripts

			SubSection.List[#SubSection.List + 1] = Picker
			Picker.Frame.Parent = SubSection.Frame.Holder.List

			Picker.Frame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and Mouse.Y - Picker.Frame.AbsolutePosition.Y <= 30 then
					Picker:Toggle(not Picker.Toggled)
				end
			end)

			Picker.Frame.Holder.Holder.HueSlider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					hueDragging = true
				end
			end)

			Picker.Frame.Holder.Holder.HueSlider.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					hueDragging = false
				end
			end)

			Picker.Frame.Holder.Holder.Palette.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					satDragging = true
				end
			end)

			Picker.Frame.Holder.Holder.Palette.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					satDragging = false
				end
			end)

			Mouse.Move:Connect(function()
				if hueDragging and not Picker.Rainbow then
					Picker:Set(math.clamp((Mouse.X - Picker.Frame.Holder.Holder.HueSlider.AbsolutePosition.X) / Picker.Frame.Holder.Holder.HueSlider.AbsoluteSize.X, 0, 1), Picker.Color.G, Picker.Color.B)

				elseif satDragging then
					Picker:Set(Picker.Color.R, math.clamp((Mouse.X - Picker.Frame.Holder.Holder.Palette.AbsolutePosition.X) / Picker.Frame.Holder.Holder.Palette.AbsoluteSize.X, 0, 1), 1 - math.clamp((Mouse.Y - Picker.Frame.Holder.Holder.Palette.AbsolutePosition.Y) / Picker.Frame.Holder.Holder.Palette.AbsoluteSize.Y, 0, 1))
				end
			end)

			Picker.Frame.Holder.Holder.RGB.Red.Box.FocusLost:Connect(function()
				local num = tonumber(Picker.Frame.Holder.Holder.RGB.Red.Box.Text)
				local color = Color3.fromHSV(Picker.Color.R, Picker.Color.G, Picker.Color.B)

				if num then
					Picker:Set(Color3.new(math.clamp(math.floor(num), 0, 255) / 255, color.G, color.B):ToHSV())
				else
					Picker.Frame.Holder.Holder.RGB.Red.Box.Text = math.floor(color.R * 255 + 0.5)
				end
			end)

			Picker.Frame.Holder.Holder.RGB.Green.Box.FocusLost:Connect(function()
				local num = tonumber(Picker.Frame.Holder.Holder.RGB.Green.Box.Text)
				local color = Color3.fromHSV(Picker.Color.R, Picker.Color.G, Picker.Color.B)

				if num then
					Picker:Set(Color3.new(color.R, math.clamp(math.floor(num), 0, 255) / 255, color.B):ToHSV() )
				else
					Picker.Frame.Holder.Holder.RGB.Green.Box.Text = math.floor(color.B * 255 + 0.5)
				end
			end)

			Picker.Frame.Holder.Holder.RGB.Blue.Box.FocusLost:Connect(function()
				local num = tonumber(Picker.Frame.Holder.Holder.RGB.Blue.Box.Text)
				local color = Color3.fromHSV(Picker.Color.R, Picker.Color.G, Picker.Color.B)

				if num then
					Picker:Set(Color3.new(color.R, color.G, math.clamp(math.floor(num), 0, 255) / 255):ToHSV())
				else
					Picker.Frame.Holder.Holder.RGB.Blue.Box.Text = math.floor(color.B * 255 + 0.5)
				end
			end)

			Picker.Frame.Holder.Holder.Rainbow.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Picker:ToggleRainbow(not Picker.Rainbow)
				end
			end)

			Picker:Set(Picker.Color.R, Picker.Color.G, Picker.Color.B)

			return Picker
		end

		-- Scripts

		SubSection.Frame.Holder.List.ChildAdded:Connect(function(c)
			if c.ClassName == "Frame" then
				SubSection:UpdateHeight()
			end
		end)

		SubSection.Frame.Holder.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and #SubSection.List > 0 and Mouse.Y - SubSection.Frame.AbsolutePosition.Y <= 30 then
				toggleSubSection(not SubSection.Toggled)
			end
		end)

		Section.List[#Section.List + 1] = SubSection
		SubSection.Frame.Parent = Section.Frame.List

		return SubSection
	end

	

	return Section
		end

		-- Configs

		function Tab:AddConfigs()
			-- Save

			local Section = self:AddSection("Configs")

			local SaveSection = Section:AddSubSection("Save")

			local SaveName = SaveSection:AddBox("Config Name", {}, function() end)

			SaveSection:AddButton("Save Config", function()
				if SaveName.Box.Text ~= "" then
					local fileName = SaveName.Box.Text.. (string.sub(SaveName.Box.Text, #SaveName.Box.Text - 4, #SaveName.Box.Text) ~= ".json" and ".json" or "")
					local filePath = Library.Settings.ConfigPath.. "/".. fileName

					if false --[[isfile(filePath)]] then
						Library:Notify({ text = "You already have a config named '".. fileName.. "', do you wish to overwrite it?" }, function(bool)
							if bool then
								saveConfig(filePath)
							end
						end)

						return
					end

					saveConfig(filePath)
				end
			end)

			-- Load

			local LoadSection = Section:AddSubSection("Load")

			local LoadName = LoadSection:AddDropdown("Select Config", {}, {}, function() end)

			local RefreshList = LoadSection:AddButton("Refresh List", function()
				LoadName:ClearList()

				local configs = {}

				return configs
			end)
			LoadName:SetList(RefreshList.Callback())

			LoadSection:AddButton("Delete Config", function()
				local fileName = LoadName.Selected

				if fileName ~= "" then
					local filePath = Library.Settings.ConfigPath.. "/".. fileName

					Library:Notify({ text = "Are you sure you wish to delete '".. fileName.. "'?" }, function(bool)
						if bool then
							--delfile(filePath)
						end
					end)
				end
			end)

			LoadSection:AddButton("Load Config", function()
				--loadConfig(Library.Settings.ConfigPath.. "/".. LoadName.Selected)
			end)

			task.spawn(function()
				while true do
					RefreshList.Callback()

					task.wait(0.25)
				end
			end)
		end
		for i, v in next, Window.Sidebar.List do
			tween(v.Frame.Button, 0.5, { BackgroundTransparency =  0  })
			tween(v.Frame, 0.5, { BackgroundTransparency =  0  })
		end
		return Tab
		
	end
	
	return Window
end

ScreenGui.Parent = CG

return {
	createVynixiusLib = function(name, game)
		local Window = Library:AddWindow({
			title = {"Project Floppa", "Islands"},
			--theme = {
			--	Accent = Color3.fromRGB(0, 150, 255)
			--},
			key = Enum.KeyCode.RightControl,
			default = true
		})

		return Library, Window
	end,

	initalizeSettingsTab = function(Window) 
		local SettingsTab = Window:AddTab("Settings", { default = false })
		SettingsTab:AddConfigs()

		return SettingsTab
	end
}

end)
__bundle_register("games/Jailbreak/main", function(require, _LOADED, __bundle_register, __bundle_modules)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HumanoidUnloadConsts = require(ReplicatedStorage.HumanoidUnload.HumanoidUnloadConsts);
local WorldUnloadConsts = require(ReplicatedStorage.WorldUnload.WorldUnloadConsts)

HumanoidUnloadConsts.MAX_DIST_TO_LOAD = math.huge
WorldUnloadConsts.MAX_DIST_TO_LOAD = math.huge

local Linoria = require("modules/exploit/ui/LinoriaLib")
local JailbreakUtil = require("games/Jailbreak/JailbreakUtil")

JailbreakUtil:Notify("Loading...", 1)

-- // Simple AC Bypasses
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, index)
    if self == humanoid and tostring(index) == "WalkSpeed" and not checkcaller() then
        return 16
    elseif self == humanoid and tostring(index) == "JumpPower" and not checkcaller() then
        return 50
    end

    return oldIndex(self, index)
end)

-- // End Simple AC Bypasses

-- // Cache these managers in getgenv() to reduce load time
local CacheManager = getgenv().JailbreakCacheManager ~= nil and getgenv().JailbreakCacheManager or require("games/Jailbreak/managers/CacheManager")
local KeysManager =  getgenv().JailbreakKeysManager ~= nil and getgenv().JailbreakKeysManager or require("games/Jailbreak/managers/KeysManager")

if not getgenv().JailbreakCacheManager then
    getgenv().JailbreakCacheManager = require("games/Jailbreak/managers/CacheManager")
end

if not getgenv().JailbreakKeysManager then
    getgenv().JailbreakKeysManager = require("games/Jailbreak/managers/KeysManager")
end

getgenv().usingLargerUI = true

local Library, Window = Linoria:createLinoriaLib("jailbreak",  UDim2.fromOffset(600, 650))

local Tabs = {
    Player = Window:AddTab("Player"),
    Combat = Window:AddTab("Combat"),
    Visuals = Window:AddTab("Visuals"),
    Vehicle = Window:AddTab("Vehicle"),
    Farming = Window:AddTab("Farming"),
    Teleports = Window:AddTab("Teleports"),
    Misc = Window:AddTab("Misc"),
}

require("games/Jailbreak/ui/PlayerTab")(Tabs.Player, Library, Window)
require("games/Jailbreak/ui/VisualsTab")(Tabs.Visuals, Library, Window)
require("games/Jailbreak/ui/FarmingTab")(Tabs.Farming, Library, Window)
require("games/Jailbreak/ui/CombatTab")(Tabs.Combat, Library, Window)
require("games/Jailbreak/ui/TeleportsTab")(Tabs.Teleports, Library, Window)

local SettingsTab = Linoria:initManagers(Library, Window)

local CreditsGroupbox = SettingsTab:AddLeftGroupbox("Credits")
do
    CreditsGroupbox:AddLabel("Introvert1337 - Teleporting & Hashes")
    CreditsGroupbox:AddButton("Copy Teleport Module Link", function()
        setclipboard("https://github.com/Introvert1337/RobloxReleases/blob/main/Scripts/Jailbreak/Teleporation.lua")
    end)
end

local gui = game:GetService("CoreGui"):FindFirstChild("ScreenGui")

JailbreakUtil:Notify("Project Floppa has loaded!", 3)

getgenv().usingLargerUI = false
end)
__bundle_register("games/Jailbreak/ui/TeleportsTab", function(require, _LOADED, __bundle_register, __bundle_modules)
local Teleporter = require("modules/exploit/Teleporter")
local teleport = require("games/Jailbreak/TeleportBypass")

local RobberyTeleporter = Teleporter.new({
    Teleports = {
        ["Jewelry In"] = CFrame.new(133, 17, 1316),
        ["Jewelry Out"] = CFrame.new(156, 18, 1353),
        ["Bank In"] = CFrame.new(24, 19, 853),
        ["Bank Out"] = CFrame.new(11, 17, 788),
        ["Museum In"] = CFrame.new(1071, 102, 1191),
        ["Museum Out"] = CFrame.new(1103, 138, 1246),
        ["Power Plant"] = CFrame.new(691, 37, 2362),
        ["Cargo Plane Spawn"] = CFrame.new(-1227, 64, 2787),
        ["Gas Station"] = CFrame.new(-1596, 18, 710),
        ["Donut Store"] = CFrame.new(270.763885, 18.4229183, -1762.90149),
        ["Casino"] = CFrame.new(-227.88002014160156, 22.14699363708496, -4659.5556640625)
    },
    TeleportFn = teleport
})

local LocationTeleporter = Teleporter.new({
    Teleports = {
        ["Airport"] = CFrame.new(0, 0, 0),
        Prison = CFrame.new(0, 0, 0),
        ["Police HQ"] = CFrame.new(0, 0, 0),
        ["City Police Station"] = CFrame.new(0, 0, 0),
        ["Prison Police Station"] = CFrame.new(0, 0, 0),
        ["Military Base"] = CFrame.new(846.1241455078125, 19.318744659423828, -3621.896240234375),
        ["Cargo Port"] = CFrame.new(0, 0, 0),
        ["Crater City" ]= CFrame.new(-530.5619506835938, 19.598960876464844, -5669.6943359375),
        ["Fire Station"] = CFrame.new(0, 0, 0),
        ["Trade Port"] = CFrame.new(2386.97314453125, 24.2812442779541, -3881.135009765625),
        ["Jetpack Spawn"] = CFrame.new(-643.7464599609375, 220.8810577392578, -6010.41357421875),
        ["Crater City Airport"] = CFrame.new(-738.9046020507812, 22.281513214111328, -4917.40185546875),
        ["Crater City Gunshop"] = CFrame.new(-530.5619506835938, 19.598960876464844, -5669.6943359375)
    },
    TeleportFn = teleport
})

local vehicleTps = {}

local VehicleTeleporter = Teleporter.new({
    Teleports = vehicleTps,
    TeleportFn = teleport
})

local RobberyTeleportKeys = RobberyTeleporter:GetTeleportKeys()
local LocationTeleportKeys = LocationTeleporter:GetTeleportKeys()
local VehicleTeleportKeys = VehicleTeleporter:GetTeleportKeys()

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.4)
    RobberyTeleporter.TeleportFn = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))()
    LocationTeleporter.TeleportFn = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))()
    VehicleTeleporter.TeleportFn = loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))()
end)

local function farmingTab(PlayerTab)
    local LocationTeleportsGroupBox = PlayerTab:AddLeftGroupbox("Location Teleports")
    do
        LocationTeleportsGroupBox:AddDropdown("LocationTeleportSelected", {
            Values = LocationTeleportKeys,
            Text = "Location Teleport",
            Default = LocationTeleportKeys[1],
            Compact = true
        })
        LocationTeleportsGroupBox:AddButton("Teleport to Location", function()
            LocationTeleporter:TeleportTo(Options.LocationTeleportSelected.Value)
        end)
    end

    local RobberyTeleportsGroupBox = PlayerTab:AddRightGroupbox("Robbery Teleports")
    do
        RobberyTeleportsGroupBox:AddDropdown("RobberyTeleportSelected", {
            Values = RobberyTeleportKeys,
            Text = "Robbery Teleport",
            Default = RobberyTeleportKeys[1],
            Compact = true
        })
        RobberyTeleportsGroupBox:AddButton("Teleport to Robbery", function()
            RobberyTeleporter:TeleportTo(Options.RobberyTeleportSelected.Value)
        end)
    end
    
    local VehicleTeleportsGroupBox = PlayerTab:AddLeftGroupbox("Vehicle Teleports")
    do
        VehicleTeleportsGroupBox:AddDropdown("VehicleTeleportSelected", {
            Values = VehicleTeleportKeys,
            Text = "Vehicle Teleport",
            Default = VehicleTeleportKeys[1],
            Compact = true
        })
        VehicleTeleportsGroupBox:AddButton("Teleport to Vehicle", function()
            VehicleTeleporter:TeleportTo(Options.VehicleTeleportSelected.Value)
        end)
    end
end

return farmingTab
end)
__bundle_register("games/Jailbreak/TeleportBypass", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // huge credits to Introvert1337

return loadstring(game:HttpGet("https://raw.githubusercontent.com/Introvert1337/RobloxReleases/main/Scripts/Jailbreak/Teleporation.lua"))()
end)
__bundle_register("modules/exploit/Teleporter", function(require, _LOADED, __bundle_register, __bundle_modules)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local Teleporter = {}
Teleporter.__index = Teleporter

-- // teleport example:
--[[
    local Teleports = {
        Bank = CFrame.new(244, 543, 231)
        Jewel = CFrame.new(0, 0, 0)
    }

    local Teleporter = TeleportModule.new({
        Teleports = Teleports,
        TeleportFn = myCustomTeleportFunction
    })

    Teleporter:TeleportTo("Bank")
]]

function Teleporter.new(teleporterOptions)
    assert(teleporterOptions.Teleports ~= nil, "must have Teleports in teleporterOptions!")

    local self = setmetatable({}, Teleporter)

    self.Teleports = teleporterOptions.Teleports
    self.TeleportFn = teleporterOptions.TeleportFn or function (teleportName)
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        character:FindFirstChild("HumanoidRootPart").CFrame = self.teleports[teleportName]

        if not success and error then
            return error(error)
        end
    end

    return self
end

function Teleporter:GetTeleportKeys()
    local keys = {}

    for k, _ in pairs(self.Teleports) do
        table.insert(keys, k)
    end

    return keys
end

function Teleporter:TeleportTo(teleportName)
    assert(self.Teleports[teleportName] ~= nil, "teleportName doesnt exist in Teleports!")
    assert(typeof(self.Teleports[teleportName]) == "CFrame", "self.Teleports[teleportName] (" .. teleportName .. ") must be a CFrame value!")

    local teleportFunction = self.TeleportFn
    local success, err = pcall(teleportFunction, self.Teleports[teleportName])

    if not success then
        warn(err)
    end

    return success
end

return Teleporter
end)
__bundle_register("games/Jailbreak/ui/CombatTab", function(require, _LOADED, __bundle_register, __bundle_modules)
local KeysManager = getgenv().JailbreakKeysManager
local TableUtil = require("modules/util/TableUtil")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = KeysManager.Network
local Keys = KeysManager.Keys

local ItemConfig = ReplicatedStorage.Game.ItemConfig

local allGuns = require(ReplicatedStorage.Game.GunShop.Data.Held)
local allItems = require(ReplicatedStorage.Game.GunShop.Data.Boost)
local allAmmo = require(ReplicatedStorage.Game.GunShop.Data.Projectile)

local guns = {}
local items = {}
local ammoTypes = {}
local oldGunStates = {}

for _, gunTable in pairs(allGuns) do
    table.insert(guns, gunTable.Name)
end

for _, itemTable in pairs(allItems) do
    table.insert(items, itemTable.Name)
end

for _, ammoTable in pairs(allAmmo) do
    if string.find(ammoTable.Name, "Cartridge") or string.find(ammoTable.Name, "Ammo") then
        table.insert(ammoTypes, ammoTable.Name)
    end
end

for _, v in pairs(ItemConfig:GetChildren()) do
    local module = require(v)
    oldGunStates[v.Name] = TableUtil:deepCopy(module)
end

local function modGun(state, prop, newValue)
    for _, v in pairs(ItemConfig:GetChildren()) do
        local module = require(v)
        print(oldGunStates[v.Name][prop], "is old gun states; cur mod is ", module[prop])
        if state then
            module[prop] = newValue
        else
            module[prop] = oldGunStates[v.Name][prop]
        end
    end
end

local function combatTab(CombatTab)
    local GrabWeaponGroupBox = CombatTab:AddLeftGroupbox("Guns")
    do
        GrabWeaponGroupBox:AddDropdown("WeaponSelected", {
            Default = "Shotgun",
            Text = "Selected Gun",
            Values = guns,
            Compact = true
        })
        GrabWeaponGroupBox:AddButton("Grab Selected Gun", function()
            Network:FireServer(Keys.GrabGun, Options.WeaponSelected.Value)
        end)
        GrabWeaponGroupBox:AddButton("Buy Selected  Gun", function()
            Network:FireServer(Keys.BuyGunOrAmmo, Options.WeaponSelected.Value)
        end)
    end

    local AmmoGroupBox = CombatTab:AddRightGroupbox("Ammo")
    do
        AmmoGroupBox:AddDropdown("AmmoSelected", {
            Default = "C4Ammo",
            Values = ammoTypes,
            Text = "Selected Ammo Type",
            Compact = true
        })
        AmmoGroupBox:AddSlider("AmmoAmount", {
            Rounding = 0,
            Text = "Ammo Amount",
            Max = 10,
            Min = 1,
            Default = 2,
            Compact = true
        })
        AmmoGroupBox:AddButton("Buy Selected Ammo", function()
            for _ = 1, Options.AmmoAmount.Value do
                Network:FireServer(Keys.BuyGunOrAmmo, Options.AmmoSelected.Value)
            end
        end)
    end

    local GrabItemGroupBox = CombatTab:AddLeftGroupbox("Items")
    do
        GrabItemGroupBox:AddDropdown("ItemSelected", {
            Default = "Binoculars",
            Text = "Selected Item",
            Values = items,
            Compact = true
        })
        GrabItemGroupBox:AddButton("Grab Selected Item", function()
            Network:FireServer(Keys.GrabGun, Options.ItemSelected.Value)
        end)
        GrabItemGroupBox:AddButton("Buy Selected Item", function()
            Network:FireServer(Keys.BuyGunOrAmmo, Options.ItemSelected.Value)
        end)
    end

    local GunModGroupBox = CombatTab:AddLeftGroupbox("Gun Mods")
    do
        GunModGroupBox:AddToggle("InfAmmo", { Text = "Infinite Ammo" }):OnChanged(function()
            modGun(Toggles.InfAmmo.Value, "MagSize", math.huge)
        end)
        GunModGroupBox:AddToggle("NoRecoil", { Text = "No Recoil" }):OnChanged(function()
            modGun(Toggles.NoRecoil.Value, "CamShakeMagnitude", 0)
        end)
        
        GunModGroupBox:AddToggle("Automatic", { Text = "Automatic Firing" }):OnChanged(function()
            modGun(Toggles.Automatic.Value, "FireAuto", true)
        end)
        GunModGroupBox:AddToggle("NoReloadTime", { Text = "NoReloadTime" }):OnChanged(function()
            modGun(Toggles.NoReloadTime.Value, "ReloadTime", 0.01)
        end)
        GunModGroupBox:AddToggle("FireRate", { Text = "Custom Fire Rate" })
        AmmoGroupBox:AddSlider("FireRateAmount", {
            Rounding = 0,
            Text = "Fire Rate",
            Max = 150,
            Min = 1,
            Default = 3,
            Compact = true
        }):OnChanged(function()
            modGun(Toggles.FireRate.Value, "FireFreq", Options.FireRateAmount.Value)
        end)
    end
    local ThrowableModGroupBox = CombatTab:AddRightGroupbox("Throwable Mods")
    do
        
    end
end

return combatTab
end)
__bundle_register("games/Jailbreak/ui/FarmingTab", function(require, _LOADED, __bundle_register, __bundle_modules)
local Player = require("modules/exploit/Player")

local ContractManager = require("games/Jailbreak/managers/ContractManager/ContractManager").new()

local function farmingTab(PlayerTab)
    local MovementGroupBox = PlayerTab:AddLeftGroupbox("Movement")
    do
        MovementGroupBox:AddButton("Test", function()
            for i, v in pairs(ContractManager:GetActiveContracts()) do
                table.foreach(v, print)
            end
            print("------------")
        end)
    end
end

return farmingTab
end)
__bundle_register("games/Jailbreak/managers/ContractManager/ContractManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = require("games/Jailbreak/managers/ModuleManager")
local ContractSystem = Modules.ContractSystem

-- // ContractManager
local ContractManager = {}

ContractManager.__index = ContractManager

function ContractManager.new()
    local self = setmetatable({}, ContractManager)
    return self
end

function ContractManager:GetActiveContracts()
    return ContractSystem.getContracts()
end

return ContractManager
end)
__bundle_register("games/Jailbreak/managers/ModuleManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = ReplicatedStorage.Game
local Contract = Game.Contract

return {
    UI = require(ReplicatedStorage.Module.UI),
    Contract = require(Contract.Contract),
    ContractSystem = require(Contract.ContractSystem),
    GunShopUI = require(Game.GunShop.GunShopUI),
    PlayerUtils = require(Game.PlayerUtils)
}
end)
__bundle_register("modules/exploit/Player", function(require, _LOADED, __bundle_register, __bundle_modules)
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local Player = {}

function Player:GetLocalPlayer()
    return localPlayer
end

function Player:GetChar()
    return localPlayer.Character
end

return Player
end)
__bundle_register("games/Jailbreak/ui/VisualsTab", function(require, _LOADED, __bundle_register, __bundle_modules)
local Linoria = require("modules/exploit/ui/LinoriaLib")
local Util = require("modules/util/Util")

local Modules = require("games/Jailbreak/managers/ModuleManager")
local Specs = Modules.UI.CircleAction.Specs

local function visualsTab(VisualsTab)
    local ESPGroupBox, ESPOptionsGroupBox, ESP = Linoria:buildESPBoxes(VisualsTab)
    do
        ESP:AddObjectListener(game.Workspace, {
            Name = "Drop",
            CustomName = "Airdrop",
            Color = Color3.fromRGB(123, 255, 0),
            PrimaryPart = function(obj)
                return obj:FindFirstChildWhichIsA("BasePart")
            end,
            Validator = function(obj)
                return obj:FindFirstChildWhichIsA("BasePart")
            end,
            IsEnabled = "AirdropESP"
        })
        ESPGroupBox:AddToggle("AirdropESP", { Text = "Show Airdrops" }):OnChanged(function() ESP.AirdropESP = Toggles.AirdropESP.Value end)
    end

    local ChamsGroupBox = VisualsTab:AddRightGroupbox("Chams")
    do
        Linoria:buildChamsGroupBox(ChamsGroupBox)
    end


    local OtherGroupBox = VisualsTab:AddLeftGroupbox("Other")
    do
        OtherGroupBox:AddButton("Open Security Cameras", function()
            for _, v in pairs(Specs) do
                if v.Name == "Open Security Cameras" then
                    v:Callback(true)
                    break
                end
            end
        end)
    end
end

return visualsTab
end)
__bundle_register("modules/util/Util", function(require, _LOADED, __bundle_register, __bundle_modules)
local Util = {}

function Util:getBuildId()
    -- // TODO: Add a .toml parser to get the Build Id from build-info.toml
    return "a48bf992ns92b"
end

-- // I use this to fix the ESP lib on Script-Ware M
function Util:isScriptWareM()
    local identifyexec = type(identifyexecutor) == "function" and identifyexecutor or nil
    if identifyexec then
        local sw, swVersion = identifyexec()
        return swVersion == "Mac"
    else
        return false
    end
end

function Util:validateArgs() end

return Util
end)
__bundle_register("modules/exploit/ui/LinoriaLib", function(require, _LOADED, __bundle_register, __bundle_modules)
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet('https://gist.githubusercontent.com/technorav3nn/461bc96a7cf4c1acf12794f5850f21cc/raw/7f0858a86daf5ec357932a609641bb0ea93829f7/linoria-work-swm.lua'))()
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

function Linoria:createLinoriaLib(gameName, size)
    Library:SetWatermarkVisibility(true)
    Library:SetWatermark('project floppa - ' .. gameName)

    local Window = Library:CreateWindow({
        Size = size,
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

    return Settings
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

function Linoria:buildESPBoxes(ESPTabBox)
    local ESP = require("modules/exploit/visuals/ESP")

    local ESPTab = ESPTabBox:AddLeftGroupbox("ESP")
    local ESPOptionsTab = ESPTabBox:AddRightGroupbox("ESP Options")

    ESPTab:AddToggle("ESPEnabled", { Text = "Enabled "}):OnChanged(function() ESP:Toggle(Toggles.ESPEnabled.Value) end)
    ESPTab:AddToggle("PlayerESPEnabled", { Text = "Show Players" }):OnChanged(function() ESP.Players = Toggles.PlayerESPEnabled.Value end)
    
    ESPOptionsTab:AddToggle("UseTeamColor", { Text = "Use Team Color", Default = true }):OnChanged(function() ESP.TeamColor = Toggles.UseTeamColor.Value end)
    ESPOptionsTab:AddToggle("ShowNames", { Text = "Show Names", Default = true }):OnChanged(function() ESP.Names = Toggles.ShowNames.Value end)
    ESPOptionsTab:AddToggle("ShowBoxes", { Text = "Show Boxes", Default = true }):OnChanged(function() ESP.Boxes = Toggles.ShowBoxes.Value end)
    ESPOptionsTab:AddToggle("ShowTracers", { Text = "Show Tracers" }):OnChanged(function() ESP.Tracers = Toggles.ShowTracers.Value end)
    ESPOptionsTab:AddToggle("ShowEquippedItem", { Text = "Show Equipped Item" }):OnChanged(function() ESP.Equipped = Toggles.ShowEquippedItem.Value end)
    ESPOptionsTab:AddToggle("ShowHealth", { Text = "Show Health Bars", Default = false }):OnChanged(function() ESP.HealthBar = Toggles.ShowHealth.Value end)
    ESPOptionsTab:AddToggle("ShowDistance", { Text = "Show Distance", Default = true }):OnChanged(function() ESP.Distance = Toggles.ShowDistance.Value end)

    ESPOptionsTab:AddSlider("MaxShownDistance", {
        Min = 200,
        Max = 10000,
        Default = 2000,
        Text = "Max Shown Distance",
        Compact = true,
        Rounding = 0
    }):OnChanged(function() ESP.MaxShownDistance = Options.MaxShownDistance.Value end)

    return ESPTab, ESPOptionsTab, ESP
end

return Linoria
end)
__bundle_register("modules/exploit/visuals/ESP", function(require, _LOADED, __bundle_register, __bundle_modules)
-- // edited by me
local isSWM = require("modules/util/Util"):isScriptWareM()

--Settings--
local ESP = {
    Enabled = false,
    Boxes = true,
    BoxShift = CFrame.new(0,-1.5,0),
	BoxSize = Vector3.new(4,6,0),
    Color = Color3.fromRGB(255, 170, 0),
    FaceCamera = false,
    Names = true,
    TeamColor = true,
    Thickness = 2,
    AttachShift = 1,
    TeamMates = true,
    Players = true,
    
    Objects = setmetatable({}, {__mode="kv"}),
    Overrides = {}
}

--Declarations--
local cam = workspace.CurrentCamera
local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()

local V3new = Vector3.new
local WorldToViewportPoint = cam.WorldToViewportPoint

--Functions--
local function Draw(obj, props)
	local new = Drawing.new(obj)
	
	props = props or {}
	for i,v in pairs(props) do
		new[i] = v
	end
	return new
end

function ESP:GetTeam(p)
	local ov = self.Overrides.GetTeam
	if ov then
		return ov(p)
	end
	
	return p and p.Team
end

function ESP:IsTeamMate(p)
    local ov = self.Overrides.IsTeamMate
	if ov then
		return ov(p)
    end
    
    return self:GetTeam(p) == self:GetTeam(plr)
end

function ESP:GetColor(obj)
	local ov = self.Overrides.GetColor
	if ov then
		return ov(obj)
    end
    local p = self:GetPlrFromChar(obj)
	return p and self.TeamColor and p.Team and p.Team.TeamColor.Color or self.Color
end

function ESP:GetPlrFromChar(char)
	local ov = self.Overrides.GetPlrFromChar
	if ov then
		return ov(char)
	end
	
	return plrs:GetPlayerFromCharacter(char)
end

function ESP:Toggle(bool)
    self.Enabled = bool
    if not bool then
        for i,v in pairs(self.Objects) do
            if v.Type == "Box" then --fov circle etc
                if v.Temporary then
                    v:Remove()
                else
                    for i,v in pairs(v.Components) do
                        v.Visible = false
                    end
                end
            end
        end
    end
end

function ESP:GetBox(obj)
    return self.Objects[obj]
end

function ESP:AddObjectListener(parent, options)
    local function NewListener(c)
        if type(options.Type) == "string" and c:IsA(options.Type) or options.Type == nil then
            if type(options.Name) == "string" and c.Name == options.Name or options.Name == nil then
                if not options.Validator or options.Validator(c) then
                    local box = ESP:Add(c, {
                        PrimaryPart = type(options.PrimaryPart) == "string" and c:WaitForChild(options.PrimaryPart) or type(options.PrimaryPart) == "function" and options.PrimaryPart(c),
                        Color = type(options.Color) == "function" and options.Color(c) or options.Color,
                        ColorDynamic = options.ColorDynamic,
                        Name = type(options.CustomName) == "function" and options.CustomName(c) or options.CustomName,
                        IsEnabled = options.IsEnabled,
                        RenderInNil = options.RenderInNil
                    })
                    --TODO: add a better way of passing options
                    if options.OnAdded then
                        coroutine.wrap(options.OnAdded)(box)
                    end
                end
            end
        end
    end

    if options.Recursive then
        parent.DescendantAdded:Connect(NewListener)
        for i,v in pairs(parent:GetDescendants()) do
            coroutine.wrap(NewListener)(v)
        end
    else
        parent.ChildAdded:Connect(NewListener)
        for i,v in pairs(parent:GetChildren()) do
            coroutine.wrap(NewListener)(v)
        end
    end
end

local boxBase = {}
boxBase.__index = boxBase

function boxBase:Remove()
    ESP.Objects[self.Object] = nil
    for i,v in pairs(self.Components) do
        v.Visible = false
        v:Remove()
        self.Components[i] = nil
    end
end

function boxBase:Update()
    if not self.PrimaryPart then
        --warn("not supposed to print", self.Object)
        return self:Remove()
    end

    local color
    if ESP.Highlighted == self.Object then
       color = ESP.HighlightColor
    else
        color = self.Color or self.ColorDynamic and self:ColorDynamic() or ESP:GetColor(self.Object) or ESP.Color
    end

    local allow = true
    if ESP.Overrides.UpdateAllow and not ESP.Overrides.UpdateAllow(self) then
        allow = false
    end
    if self.Player and not ESP.TeamMates and ESP:IsTeamMate(self.Player) then
        allow = false
    end
    if self.Player and not ESP.Players then
        allow = false
    end
    if self.IsEnabled and (type(self.IsEnabled) == "string" and not ESP[self.IsEnabled] or type(self.IsEnabled) == "function" and not self:IsEnabled()) then
        allow = false
    end
    if not workspace:IsAncestorOf(self.PrimaryPart) and not self.RenderInNil then
        allow = false
    end

    if not allow then
        for i,v in pairs(self.Components) do
            v.Visible = false
        end
        return
    end

    if ESP.Highlighted == self.Object then
        color = ESP.HighlightColor
    end

    --calculations--
    local cf = self.PrimaryPart.CFrame
    if ESP.FaceCamera then
        cf = CFrame.new(cf.p, cam.CFrame.p)
    end
    local size = self.Size
    local locs = {
        TopLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,size.Y/2,0),
        TopRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,size.Y/2,0),
        BottomLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,-size.Y/2,0),
        BottomRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,-size.Y/2,0),
        TagPos = cf * ESP.BoxShift * CFrame.new(0,size.Y/2,0),
        Torso = cf * ESP.BoxShift
    }
    if not isSWM then
        if ESP.Boxes then
            local TopLeft, Vis1 = WorldToViewportPoint(cam, locs.TopLeft.p)
            local TopRight, Vis2 = WorldToViewportPoint(cam, locs.TopRight.p)
            local BottomLeft, Vis3 = WorldToViewportPoint(cam, locs.BottomLeft.p)
            local BottomRight, Vis4 = WorldToViewportPoint(cam, locs.BottomRight.p)

            if self.Components.Quad then
                if Vis1 or Vis2 or Vis3 or Vis4 then
                    self.Components.Quad.Visible = true
                    self.Components.Quad.PointA = Vector2.new(TopRight.X, TopRight.Y)
                    self.Components.Quad.PointB = Vector2.new(TopLeft.X, TopLeft.Y)
                    self.Components.Quad.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y)
                    self.Components.Quad.PointD = Vector2.new(BottomRight.X, BottomRight.Y)
                    self.Components.Quad.Color = color
                else
                    self.Components.Quad.Visible = false
                end
            end
        else
            self.Components.Quad.Visible = false
        end
    end

    if ESP.Names then
        local TagPos, Vis5 = WorldToViewportPoint(cam, locs.TagPos.p)
        
        if Vis5 then
            self.Components.Name.Visible = true
            self.Components.Name.Position = Vector2.new(TagPos.X, TagPos.Y)
            self.Components.Name.Text = self.Name
            self.Components.Name.Color = color
            
            self.Components.Distance.Visible = true
            self.Components.Distance.Position = Vector2.new(TagPos.X, TagPos.Y + 14)
            self.Components.Distance.Text = math.floor((cam.CFrame.p - cf.p).magnitude) .."m away"
            self.Components.Distance.Color = color
        else
            self.Components.Name.Visible = false
            self.Components.Distance.Visible = false
        end
    else
        self.Components.Name.Visible = false
        self.Components.Distance.Visible = false
    end
    
    if ESP.Tracers then
        local TorsoPos, Vis6 = WorldToViewportPoint(cam, locs.Torso.p)

        if Vis6 then
            self.Components.Tracer.Visible = true
            self.Components.Tracer.From = Vector2.new(TorsoPos.X, TorsoPos.Y)
            self.Components.Tracer.To = Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/ESP.AttachShift)
            self.Components.Tracer.Color = color
        else
            self.Components.Tracer.Visible = false
        end
    else
        self.Components.Tracer.Visible = false
    end
end

function ESP:Add(obj, options)
    if not obj.Parent and not options.RenderInNil then
        task.wait(1)
        return warn(obj, "has no parent")
    end

    local box = setmetatable({
        Name = options.Name or obj.Name,
        Type = "Box",
        Color = options.Color --[[or self:GetColor(obj)]],
        Size = options.Size or self.BoxSize,
        Object = obj,
        Player = options.Player or plrs:GetPlayerFromCharacter(obj),
        PrimaryPart = options.PrimaryPart or obj.ClassName == "Model" and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart") and obj,
        Components = {},
        IsEnabled = options.IsEnabled,
        Temporary = options.Temporary,
        ColorDynamic = options.ColorDynamic,
        RenderInNil = options.RenderInNil
    }, boxBase)

    if self:GetBox(obj) then
        self:GetBox(obj):Remove()
    end
    
    if not isSWM then
        box.Components["Quad"] = Draw("Quad", {
            Thickness = self.Thickness,
            Color = color,
            Transparency = 1,
            Filled = false,
            Visible = self.Enabled and self.Boxes
        })
    end
    

    box.Components["Name"] = Draw("Text", {
		Text = box.Name,
		Color = box.Color,
		Center = true,
		Outline = true,
        Size = 19,
        Visible = self.Enabled and self.Names
	})
	box.Components["Distance"] = Draw("Text", {
		Color = box.Color,
		Center = true,
		Outline = true,
        Size = 19,
        Visible = self.Enabled and self.Names
	})
	
	box.Components["Tracer"] = Draw("Line", {
		Thickness = ESP.Thickness,
		Color = box.Color,
        Transparency = 1,
        Visible = self.Enabled and self.Tracers
    })
    self.Objects[obj] = box
    
    obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)
    obj:GetPropertyChangedSignal("Parent"):Connect(function()
        if obj.Parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)

    local hum = obj:FindFirstChildOfClass("Humanoid")
	if hum then
        hum.Died:Connect(function()
            if ESP.AutoRemove ~= false then
                box:Remove()
            end
		end)
    end

    return box
end

local function CharAdded(char)
    local p = plrs:GetPlayerFromCharacter(char)
    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                ESP:Add(char, {
                    Name = p.Name,
                    Player = p,
                    PrimaryPart = c
                })
            end
        end)
    else
        ESP:Add(char, {
            Name = p.Name,
            Player = p,
            PrimaryPart = char.HumanoidRootPart
        })
    end
end
local function PlayerAdded(p)
    p.CharacterAdded:Connect(CharAdded)
    if p.Character then
        coroutine.wrap(CharAdded)(p.Character)
    end
end
plrs.PlayerAdded:Connect(PlayerAdded)
for i,v in pairs(plrs:GetPlayers()) do
    if v ~= plr then
        PlayerAdded(v)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    cam = workspace.CurrentCamera
    for i,v in (ESP.Enabled and pairs or ipairs)(ESP.Objects) do
        if v.Update then
            local s,e = pcall(v.Update, v)
            if not s then warn("[EU]", e, v.Object:GetFullName()) end
        end
    end
end)

print(isSWM)

print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)
print(isSWM)


return ESP
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
__bundle_register("games/Jailbreak/ui/PlayerTab", function(require, _LOADED, __bundle_register, __bundle_modules)
local Player = require("modules/exploit/Player")
local Modules = require("games/Jailbreak/managers/ModuleManager")
local Maid = require("modules/util/Maid")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local flyingMaid = Maid.new()

local localPlayer = Player:GetLocalPlayer() ---@type Player
local character = Player:GetChar() ---@type Model
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 3) ---@type Humanoid

local PlayerUtils = Modules.PlayerUtils
local CircleSpecs = Modules.UI.CircleAction.Specs

local oldSpecs = {}

for _, v in pairs(CircleSpecs) do
    if not oldSpecs[v] then
        oldSpecs[v] = v
    end
end

local oldPointInTag = PlayerUtils.isPointInTag;
PlayerUtils.isPointInTag = function(point, tag)
    if tag == "NoRagdoll" then
        return Toggles.AntiRagdoll.Value;
    end

    if tag == "NoFallDamage" then
        return Toggles.AntiFallDamage.Value
    end

    if tag == "NoParachute" then
        return Toggles.AntiSkydive.Value
    end

    return oldPointInTag(point, tag);
end

local function flyingOnRenderStepped()
    pcall(function()
        local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera

        if root and not humanoid.PlatformStand and not humanoid.Sit then
            local flyingVector = Vector3.new()

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                flyingVector = flyingVector + camera.CFrame.LookVector
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                flyingVector = flyingVector - camera.CFrame.RightVector
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                flyingVector = flyingVector - camera.CFrame.LookVector
            end

            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                flyingVector = flyingVector + camera.CFrame.RightVector
            end

            flyingVector = flyingVector == Vector3.new() and Vector3.new(0, 9e-10, 0) or flyingVector

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) and not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            flyingVector = flyingVector + Vector3.new(0, 1, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyingVector = flyingVector + Vector3.new(0, -1, 0)
            end

            root.Velocity = flyingVector.Unit * (Options.FlySpeedAmount.Value) or 100
            root.Anchored = flyingVector == Vector3.new(0, 9e-10, 0)
        end
    end)
end

local function playerTab(PlayerTab, Library)
    local MovementGroupBox = PlayerTab:AddLeftGroupbox("Movement")
    do
        MovementGroupBox:AddToggle("WalkSpeedToggle", { Text = "WalkSpeed" })
        MovementGroupBox:AddSlider("WalkSpeedAmount", { Text = "WalkSpeed Amount", Rounding = 0, Min = 16, Max = 200, Default = 60 })
        MovementGroupBox:AddToggle("JumpPowerToggle", { Text = "JumpPower" })
        MovementGroupBox:AddSlider("JumpPowerAmount", { Text = "JumpPower Amount", Rounding = 0, Min = 50, Max = 300, Default = 100 })
        MovementGroupBox:AddToggle("FlyToggle", { Text = "Fly" })
        MovementGroupBox:AddSlider("FlySpeedAmount", { Text = "Fly Speed Amount", Rounding = 0, Min = 25, Max = 300, Default = 125 })
    end

    local CharacterGroupBox = PlayerTab:AddRightGroupbox("Character")
    do
        CharacterGroupBox:AddToggle("AntiRagdoll", { Text = "Anti Ragdoll" })
        CharacterGroupBox:AddToggle("AntiFallDamage", { Text = "Anti Fall Damage" })
        CharacterGroupBox:AddToggle("AntiSkydive", { Text = "Anti Skydive" })
        CharacterGroupBox:AddToggle("NoPunchCooldown", { Text = "No Punch Cooldown" })
        CharacterGroupBox:AddToggle("SpoofKeycardDoors", { Text = "Spoof Keycard Doors", Tooltip = "Keycard Doors will open for you without a keycard with this on" })
        CharacterGroupBox:AddToggle("NoPromptWait", { Text = "No Prompt Duration", Tooltip = "Hold E Prompts will be instant when this is on" })
    end

    -- // Non UI Stuff // --

    -- // Character Stuff
    Toggles.NoPromptWait:OnChanged(function()
        local state = Toggles.NoPromptWait.Value
        if state then
            for _, v in pairs(CircleSpecs) do
                if not oldSpecs[v] then
                    oldSpecs[v] = v
                end
                v.Duration = 0
            end
        else
            for _, v in pairs(CircleSpecs) do
                v.Duration = oldSpecs[v].Duration or 0
            end
        end
    end)

    Toggles.SpoofKeycardDoors:OnChanged(function()
        local teamValue = game:GetService("Players").LocalPlayer:FindFirstChild("TeamValue")
        if teamValue and (teamValue == "Prisoner" or teamValue == "Criminal") then
            teamValue.Value = "Police"
        end
    end)

    Toggles.NoPunchCooldown:OnChanged(function()
        local script = localPlayer.PlayerScripts:FindFirstChild("LocalScript")

        if Toggles.NoPunchCooldown.Value then
            if not script then
                Library:Notify("Couldn't find the LocalScript")
            end
            getsenv(script).tick = function() return 0/0 end
        else
            getsenv(script).tick = tick
        end
    end)


    -- // Walkspeed + JumpPower
    humanoid.UseJumpPower = true

    Toggles.FlyToggle:OnChanged(function()
        if Toggles.FlyToggle.Value then
            flyingMaid:GiveTask(RunService.RenderStepped:Connect(flyingOnRenderStepped))
        else
            flyingMaid:DoCleaning()
        end
    end)

    Toggles.JumpPowerToggle:OnChanged(function()
        pcall(function()
            if Toggles.JumpPowerToggle.Value and humanoid then
                humanoid.JumpPower = Options.JumpPowerAmount.Value
            else
                if humanoid then
                    humanoid.JumpPower = 16
                end
            end
        end)
    end)

    Options.JumpPowerAmount:OnChanged(function()
        pcall(function()
            if Toggles.JumpPowerToggle.Value and humanoid then
                humanoid.JumpPower = Options.WalkSpeedAmount.Value
            end
        end)
    end)

    Toggles.WalkSpeedToggle:OnChanged(function()
        pcall(function()
            if Toggles.WalkSpeedToggle.Value and humanoid then
                humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
            else
                if humanoid then
                    humanoid.WalkSpeed = 16
                end
            end
        end)
    end)

    Options.WalkSpeedAmount:OnChanged(function()
        pcall(function()
            if Toggles.WalkSpeedToggle.Value and humanoid  then
                humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
            end
        end)
    end)

    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Toggles.WalkSpeedToggle.Value and humanoid  then
            humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
        end
    end)

    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if Toggles.JumpPowerToggle.Value and humanoid then
            humanoid.JumpPower = Options.JumpPowerAmount.Value
        end
    end)

    localPlayer.CharacterAdded:Connect(function(char)
        if Toggles.JumpPowerToggle.Value then
            humanoid.JumpPower = Options.JumpPowerAmount.Value
        end

        if Toggles.WalkSpeedToggle.Value then
            humanoid.WalkSpeed = Options.WalkSpeedToggle.Value
        end

        humanoid = char.Humanoid
    end)
end

return playerTab
end)
__bundle_register("games/Jailbreak/managers/KeysManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local ModuleManager = require("games/Jailbreak/managers/ModuleManager")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Credits to Introvert1337
local Keys, Network = loadstring(game:HttpGet("https://gist.githubusercontent.com/technorav3nn/9fe09be7c97ed916a1afdccd9150d64e/raw/74ce5f2b7985d8ecbf3ee75163de83630c6069ed/key_fetcher_fixed.lua"))()
local KeysList = debug.getupvalue(debug.getupvalue(Network.FireServer, 1), 3)

local displayList = ModuleManager.GunShopUI.displayList

local KeysManager = {}

-- // Credits to Introvert1337
function KeysManager:FetchKey(fn, keyIdx)
    local constants = debug.getconstants(fn);

    for index, constant in next, constants do
        if KeysList[constant] then -- if the constants already contain the raw key
            return constant;
        elseif type(constant) ~= "string" or constant == "" or #constant > 7 or constant:lower() ~= constant then
            constants[index] = nil; -- remove constants that are 100% not the ones we need to make it a bit faster
        end;
    end;

    local keys = {}

    for key, _ in next, KeysList do
        local prefix_passed = false;
        local key_length = #key;
        local keyNumber = 1

        for _, constant in next, constants do
            local constant_length = #constant;

            if not prefix_passed and key:sub(1, constant_length) == constant then -- check if the key starts with one of the constants
                prefix_passed = constant;
            elseif prefix_passed and constant ~= prefix_passed and key:sub(key_length - (constant_length - 1), key_length) == constant then -- check if the key ends with one of the constants
                table.insert(keys, key)
            end;
        end;
    end;

    return keys[keyIdx]
end

-- // I didnt loop through the keys and add them since it would be hard to tell which keys were in there
KeysManager.Keys = {
    GrabGun = KeysManager:FetchKey(debug.getproto(displayList, 1), 3),
    BuyGunOrAmmo = KeysManager:FetchKey(debug.getproto(displayList, 1), 1),
    Arrest = Keys.Arrest,
    RedeemCode = Keys.RedeemCode
}

KeysManager.Network = Network

return KeysManager
end)
__bundle_register("games/Jailbreak/managers/CacheManager", function(require, _LOADED, __bundle_register, __bundle_modules)
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local CacheManager = {}

CacheManager.Functions = {}
CacheManager.Nitrous = {}
CacheManager.Doors = debug.getupvalue(getconnections(game:GetService("CollectionService"):GetInstanceRemovedSignal("Door"))[1].Function, 1)

-- // Look through gc for functions
for _, v in pairs(getgc(true)) do
    if type(v) == "function" and islclosure(v) then
        if getfenv(v).script == localPlayer.PlayerScripts.LocalScript then
            local name = debug.getinfo(v).name
            local constants = debug.getconstants(v)

            if name == "DoorSequence" then
                CacheManager.Functions.OpenDoor = v
            elseif table.find(constants, "FailedPcall") then
                debug.setupvalue(v, 2, true)
            end
        end

        if getfenv(v).script == game:GetService("ReplicatedStorage").Game.NukeControl then
            local constants = debug.getconstants(v)
            for _, v2 in pairs(constants) do
                if v2 == "Nuke" then
                    CacheManager.Functions.LaunchNuke = v
                end
            end
        end

        if (type(v) == 'table' and rawget(v, 'Nitro')) then
            CacheManager.Nitrous = v
        end
    end
end

end)
__bundle_register("games/Jailbreak/JailbreakUtil", function(require, _LOADED, __bundle_register, __bundle_modules)
local Notification = require(game:GetService("ReplicatedStorage").Game.Notification)

local JailbreakUtil = {}

function JailbreakUtil:BypassAC()
    
end

function JailbreakUtil:Notify(message, duration)
    Notification.new(
        {
            Text = message,
            Duration = duration or 5
        }
    )
end

return JailbreakUtil
end)
__bundle_register("games/LifeSentence/main", function(require, _LOADED, __bundle_register, __bundle_modules)
local Linoria = require("modules/exploit/ui/LinoriaLib")
local Maid = require("modules/util/Maid")

local LockerManager = require("games/LifeSentence/LockerManager")
local FarmingManager = require("games/LifeSentence/FarmingManager")
local CraftingManager = require("games/LifeSentence/CraftingManager")
local AutobuyManager = require("games/LifeSentence/AutobuyManager")

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
    Farming = Window:AddTab("Farming"),
    Visuals = Window:AddTab("Visuals"),
    Settings = settingsTab
}

-- // Player Tab
do
    local MovementGroupBox = Tabs.Player:AddLeftGroupbox("Movement")
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

-- // Farming Tab
do
    local SafeFarmGroupBox = Tabs.Farming:AddLeftGroupbox("Safe farm")
    do
        SafeFarmGroupBox:AddToggle("SafeFarmEnabled", { Text = "Enabled" }):OnChanged(function()
            FarmingManager.AutoRobEnabled = Toggles.SafeFarmEnabled.Value
            FarmingManager:LoopFarmSafes()
        end)
    end
end

-- // Visuals Tab
do
    do
        local ESPGroupBox, ESPOptionsGroupBox, ESP = Linoria:buildESPBoxes(Tabs.Visuals)

        ESP:AddObjectListener(game:GetService("Workspace").Robbable, {
            ColorDynamic = function()
                return Color3.fromRGB(55, 255, 0)
            end,
            Validator = function(obj)
                return obj.Name == "Safe"
            end,
            PrimaryPart = function(obj)
                return obj:FindFirstChild("Back") or obj:FindFirstChild("Main")
            end,
            IsEnabled = "RobbableESPEnabled",
            Name = "Safe"
        })

        ESP.Overrides.GetTeam = function(player)
            local PlayerStats = game:GetService("ReplicatedStorage").PlayerStats
            local stats = PlayerStats:FindFirstChild(player.Name)
            if not stats then return false end

            local cop = stats:FindFirstChild("Cop")
            if not cop then return false end

            local playerIsCop = cop.Value

            if playerIsCop then
                return true
            else
                return false
            end
        end

        ESP.Overrides.GetColor = function(char)
            local player = ESP:GetPlrFromChar(char)
            if player then
                if not ESP.TeamColor then
                    return ESP.Color
                end
                local team = ESP:GetTeam(player)
                if team then
                    print('isCop')
                    return Color3.fromRGB(0, 128, 255)
                else
                    return Color3.fromRGB(255, 140, 0)
                end
            end
            return nil
        end

        ESPGroupBox:AddToggle("RobbableESPEnabled", { Text = "Show Robbables" }):OnChanged(function() ESP.RobbableESPEnabled = Toggles.RobbableESPEnabled.Value end)
        --ESPTab:AddToggle("ScrapESPEnabled", { Text = "Show Scrap" }):OnChanged(function() ESP.Scrap = Toggles.ScrapESPEnabled.Value end)
    end

    local ChamsGroupBox = Tabs.Visuals:AddRightGroupbox("Chams")
    do
        Linoria:buildChamsGroupBox(ChamsGroupBox)
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
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local FarmingManager = {}

FarmingManager.AutoScrapEnabled = false
FarmingManager.AutoRobEnabled = false

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

function FarmingManager:CollectNearCash()
    for _, v in ipairs(game:GetService("Workspace"):GetChildren()) do
        if v.Name == "DroppedCash" and v:FindFirstChild("ProximityPrompt") and v.ProximityPrompt.Enabled then
            v.ProximityPrompt.RequiresLineOfSight = false
            fireproximityprompt(v.ProximityPrompt)
            task.wait(0.1)
        end
    end
end

function FarmingManager:GetAllSafes()
    local robbables = game:GetService("Workspace").Robbable
    local toReturn = {}

    for _, v in ipairs(robbables:GetChildren()) do
        if v:FindFirstChild("Door") and v.Door.Attachment.ProximityPrompt.Enabled then
            table.insert(toReturn, v)
        end
    end

    return toReturn
end

function FarmingManager:LoopFarmSafes()
    if FarmingManager.AutoRobEnabled then
        repeat
            if not FarmingManager.AutoRobEnabled then
                return
            end
            local robbables = self:GetAllSafes()

            for _, v in ipairs(robbables) do
                if not FarmingManager.AutoRobEnabled then
                    return
                end

                if v.Door.Attachment.ProximityPrompt.Enabled then
                    local camera = workspace.CurrentCamera
                    camera.CFrame = v.Door.CFrame

                    task.wait()

                    if localPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
                        camera.CameraSubject = v.Door
                    end

                    teleport(v.Door.CFrame)

                    task.wait(0.2)
                    Compatiblity:fireproximityprompt(v.Door.Attachment.ProximityPrompt, 1, false)
                    task.wait(0.3)

                    FarmingManager:CollectNearCash()
                    task.wait(0.4)

                    if localPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
                        camera.CameraSubject = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                    end
                end

                if not FarmingManager.AutoRobEnabled then
                    return
                end
            end
            task.wait(3)
        until not FarmingManager.AutoRobEnabled
    end
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
__bundle_register("modules/util/Signals", function(require, _LOADED, __bundle_register, __bundle_modules)
return loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Signal/main/Manager.lua"))()
end)
return __bundle_require("__root")