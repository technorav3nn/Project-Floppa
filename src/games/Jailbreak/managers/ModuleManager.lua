local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Game = ReplicatedStorage.Game
local Contract = Game.Contract

return {
    UI = require(ReplicatedStorage.Module.UI),
    Contract = require(Contract.Contract),
    ContractSystem = require(Contract.ContractSystem),
    GunShopUI = require(Game.GunShop.GunShopUI),
    PlayerUtils = require(Game.PlayerUtils)
}