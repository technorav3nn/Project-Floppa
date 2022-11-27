local NetworkService = require("games/Islands/services/NetworkService")
local NotificationService = require("games/Islands/services/NotificationService")

local IslandsUtils = require("games/Islands/IslandsUtils")

local Constants = require("games/Islands/constants")

local mobFarmMaid = require("modules/util/Maid").new()

local localPlayer = game:GetService("Players").LocalPlayer
local mobPath = game:GetService("Workspace").WildernessIsland.Entities

-- // to be replaced with the FarmingTab.Flags property, dw
local flags = {}

local function getClosestMob(mobName)
    if not table.find(Constants.HostileMobKeys, mobName) then
        NotificationService:DisplayNotification({
            message = "Couldn't find the mob ".. mobName .. ", script error."
        })
    end

    local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not root then return end

    local distance = 700
    local closest = nil

    for _, v in next, mobPath:GetChildren() do
        if v.Name == mobName and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local newDistance = localPlayer:DistanceFromCharacter(v.HumanoidRootPart.Position)
            if newDistance < distance then
                closest = v
                distance = newDistance
            end
        end
    end

    return closest
end

local connection = nil

local function killMob(mobName)
    local mob = getClosestMob(mobName)

    if not mob then return end

    IslandsUtils
        :Teleport(localPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0))
        :await()

    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health <= 0 then
            if teleportPromise then
                teleportPromise:cancel()
            end
            connection:Disconnect()
            return
        end
    
        if mob and mob.PrimaryPart ~= nil then
            local teleportPromise = IslandsUtils:Teleport(mob.PrimaryPart.CFrame + Vector3.new(0, 7, 0))
            :catch(function(err)
                NotificationService:DisplayNotification({
                    message = "Error: " .. err,
                })
            end)

            NetworkService:FireEntityHit({
                crit = true,
                hitUnit = mob
            })  
        else
            if teleportPromise then
                NotificationService:DisplayNotification({
                    message = "teleport promise exists"
                })
                teleportPromise:cancel()
            end
            connection:Disconnect()
        end
    end)
end

return function (Library, Window, FarmingTab)
    local MobFarmSection = FarmingTab:AddSection("Mob Farm", { default = false })

    flags = FarmingTab.Flags

    MobFarmSection:AddToggle("Enabled", { flag = "MobFarmEnabled" }, function()
        killMob("slime")
    end)
    MobFarmSection:AddDropdown("Mob Selected", Constants.HostileMobKeys, { default = "slime" })
end