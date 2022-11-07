local Util = require("modules/util/Util")

return {
    hi = "Im from Miners Haven file!",
    test = function()
        print(Util:GetBuildId())
    end
}