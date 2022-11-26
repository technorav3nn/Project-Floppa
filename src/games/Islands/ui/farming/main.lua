return function (Library, Window)
    local FarmingTab = Window:AddTab("Farming")

    require("games/Islands/ui/farming/OreFarm")(Library, Window, FarmingTab)
    require("games/Islands/ui/farming/MobFarm")(Library, Window, FarmingTab)
end