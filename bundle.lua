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
    local mh = require("games/LifeSentence/main")
    print(mh.hi)
    mh:test()
end
end)
__bundle_register("games/LifeSentence/main", function(require, _LOADED, __bundle_register, __bundle_modules)
local Util = require("modules/util/Util")

return {
    hi = "Im from Miners Haven file!",
    test = function()
        print(Util:GetBuildId())
    end
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
return __bundle_require("__root")