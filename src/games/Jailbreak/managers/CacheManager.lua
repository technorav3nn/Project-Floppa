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
