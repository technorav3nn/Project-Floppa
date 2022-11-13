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