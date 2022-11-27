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
        title = options.title or string.upper("Project Floppa"),
        message = options.message or "Unknown Message"
    }
    
    IslandsNotificationController:displayNotification(resolvedOptions);
end

return NotificationService