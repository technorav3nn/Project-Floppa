local ModuleManager = require("games/Jailbreak/managers/ModuleManager")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Credits to Introvert1337
local Keys, Network = loadstring(game:HttpGet("https://gist.githubusercontent.com/technorav3nn/9fe09be7c97ed916a1afdccd9150d64e/raw/74ce5f2b7985d8ecbf3ee75163de83630c6069ed/key_fetcher_fixed.lua"))()
local KeysList = debug.getupvalue(debug.getupvalue(Network.FireServer, 1), 3)

local displayList = ModuleManager.GunShopUI.displayList

local KeysManager = {}

-- // Credits to Introvert1337
function KeysManager:FetchKey(fn, keyIdx)
    local constants = debug.getconstants(fn);

    for index, constant in next, constants do
        if KeysList[constant] then -- if the constants already contain the raw key
            return constant;
        elseif type(constant) ~= "string" or constant == "" or #constant > 7 or constant:lower() ~= constant then
            constants[index] = nil; -- remove constants that are 100% not the ones we need to make it a bit faster
        end;
    end;

    local keys = {}

    for key, _ in next, KeysList do
        local prefix_passed = false;
        local key_length = #key;
        local keyNumber = 1

        for _, constant in next, constants do
            local constant_length = #constant;

            if not prefix_passed and key:sub(1, constant_length) == constant then -- check if the key starts with one of the constants
                prefix_passed = constant;
            elseif prefix_passed and constant ~= prefix_passed and key:sub(key_length - (constant_length - 1), key_length) == constant then -- check if the key ends with one of the constants
                table.insert(keys, key)
            end;
        end;
    end;

    return keys[keyIdx]
end

-- // I didnt loop through the keys and add them since it would be hard to tell which keys were in there
KeysManager.Keys = {
    GrabGun = KeysManager:FetchKey(debug.getproto(displayList, 1), 3),
    BuyGunOrAmmo = KeysManager:FetchKey(debug.getproto(displayList, 1), 1),
    Arrest = Keys.Arrest,
    RedeemCode = Keys.RedeemCode
}

KeysManager.Network = Network

return KeysManager