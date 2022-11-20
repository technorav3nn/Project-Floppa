local DEBUG = true

if not game.IsLoaded then
    game.Loaded:Wait()
end

if game.PlaceId == 7860844204 then
    require("games/LifeSentence/main")
elseif game.PlaceId == 606849621 then
    require("games/Jailbreak/main")
elseif game.PlaceId == 4872321990 then
    require("games/Islands/main")
end