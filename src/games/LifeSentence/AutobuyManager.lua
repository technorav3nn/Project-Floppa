local Character = require("modules/exploit/Character")
local teleport = require("games/LifeSentence/TpBypass")

local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local buttons = game:GetService("Workspace").Buttons

local AutobuyManager = {}

AutobuyManager.Items = {}
AutobuyManager.ItemNames = {}
AutobuyManager.Buttons = {}

for _, button in ipairs(buttons:GetChildren()) do
    if button:FindFirstChild("Button") then
        AutobuyManager.Buttons[button.ToolName.Value] = button
    end
end

for itemName, _ in pairs(AutobuyManager.Buttons) do
    table.insert(AutobuyManager.Items, itemName)
end

function AutobuyManager:BuyItem(name)
    local button = AutobuyManager.Buttons[name]
    if button ~= nil then
        local prompt = button.Button:FindFirstChildWhichIsA("ProximityPrompt")
        local oldCFrame = Character:GetCFrame()

        -- // Makes it so that we can use it without our camera seeing it
        prompt.RequiresLineOfSight = false

        teleport(prompt.Parent.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.3)
        fireproximityprompt(prompt, math.huge)
        task.wait()
        teleport(oldCFrame)

        -- // Sometimes the character trips so i added this
        localPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    else
        error("couldn't find button with tool name: " .. name)
    end
end

return AutobuyManager