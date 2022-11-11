local Aiming = require("modules/exploit/aiming/Aiming")

repeat task.wait() until Aiming.Loaded

Aiming.Settings.Enabled = true
Aiming.Settings.TeamCheck = false

local AimingManager = {}

AimingManager.Aiming = Aiming

function AimingManager:Toggle(state)
    Aiming.Settings.Enabled = state
end

return AimingManager