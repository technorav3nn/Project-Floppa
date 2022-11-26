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