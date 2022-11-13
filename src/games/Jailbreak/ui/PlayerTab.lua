local Player = require("modules/exploit/Player")
local Modules = require("games/Jailbreak/managers/ModuleManager")

local localPlayer = Player:GetLocalPlayer() ---@type Player
local character = Player:GetChar() ---@type Model
local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 3) ---@type Humanoid

local function playerTab(PlayerTab)
    local MovementGroupBox = PlayerTab:AddLeftGroupbox("Movement")
    do
        MovementGroupBox:AddToggle("WalkSpeedToggle", { Text = "WalkSpeed" })
        MovementGroupBox:AddSlider("WalkSpeedAmount", { Text = "WalkSpeed Amount", Rounding = 0, Min = 16, Max = 200, Default = 100 })
    end

    -- // Non UI Stuff
    Toggles.WalkSpeedToggle:OnChanged(function()
        humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
    end)

    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Toggles.WalkSpeedToggle.Value then
            humanoid.WalkSpeed = Options.WalkSpeedAmount.Value
        end
    end)
end

return playerTab