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