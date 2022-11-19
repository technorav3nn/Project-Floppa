local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = require("games/Jailbreak/managers/ModuleManager")
local ContractSystem = Modules.ContractSystem

-- // ContractManager
local ContractManager = {}

ContractManager.__index = ContractManager

function ContractManager.new()
    local self = setmetatable({}, ContractManager)
    return self
end

function ContractManager:GetActiveContracts()
    return ContractSystem.getContracts()
end

return ContractManager