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

    local teleportPromise = IslandsUtils:Teleport(rock.CFrame)
        :andThen(function()
            return
            --[[
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
            ]]
        end)
        :catch(function(err)
            warn("Error when teleporting to ore: ", err)
        end)

    -- // used to combat the anti cheat tp-ing us back
    repeat
        if tick() - elapsed >= 6 then
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
