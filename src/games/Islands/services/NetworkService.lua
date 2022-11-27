local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local remotesPath = ReplicatedStorage.rbxts_include.node_modules.net.out._NetManaged

local uuid = HttpService:GenerateGUID(false)

local NetworkService = {}

NetworkService.UnfinishedRemoteNames = {}
NetworkService.Remotes = {}

-- // its so easy its insane

-- // get the remote names
for _, v in pairs(getgc()) do
    if type(v) == "function" and islclosure(v) then
        if getfenv(v).script.Name == "sword" then
            local info = debug.getinfo(v)
            if info.name == "attemptHit" then
                local promiseDeferOne = debug.getproto(v, 1)
                local promiseDeferTwo = debug.getproto(promiseDeferOne, 1)
                
                NetworkService.UnfinishedRemoteNames.EntityHit = debug.getconstants(promiseDeferTwo)[1]
            end
        end
    end
    -- EDoykrNuwmlnz
end

-- // find the remotes in _NetManaged
for _, v in ipairs(remotesPath:GetChildren()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        if string.find(v.Name, NetworkService.UnfinishedRemoteNames.EntityHit) then
            NetworkService.Remotes.EntityHit = v
        end
    end
end

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

function NetworkService:FireEntityHit(args)
    --[[
        arguments example:
        local ohString1 = "5f770d78-6db7-4424-bc68-8b3df68cc6a9"
        local ohTable2 = {
            [1] = {
                ["crit"] = true,
                ["hitUnit"] = .slime (put the slime path here lol)
            }
        }

        in the remote:
        NetworkService:FireEntityHit({
            crit = true,
            hitUnit = game.Workspace.SlimePath.IForgot.Lmao
        })
    ]]

    NetworkService.Remotes.EntityHit:FireServer(uuid, {
        [1] = args
    })
end

return NetworkService