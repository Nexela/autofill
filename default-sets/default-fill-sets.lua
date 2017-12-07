--[[
    These are available globaly for everyone.
    If there is not a set by the same name in the player, force or global table then sets from default are used.

    group (string):
    a group is a string representation of a group, when placed all entities that are in the same group in your hand and quickbar
    will be counted for autofilling resources.

    slots (array):
    an arrary containing tables of slot definitions

        type (string):
        currently only fuel, ammo or module

        category (string):
        the fuel/ammo/module category to use

        limit (number):
        the maximum amount of the item to put in this slot

        priority (string):
        "max" = use the item with the highest value in your main inventory that is in the category table for the set.
        "min" = use the item with the lowest value in your main inventory that is in the category table for the set.
        "qty" = use the item you have the most of in your main inventory that is in the category table for the set.
--]]
return {
    ["car"] = {
        group = nil,
        slots = {
            {type = "fuel", category = "chemical", priority = "max"},
            {type = "ammo", category = "bullet", priority = "qty"}
        }
    },
    ["tank"] = {
        group = nil,
        slots = {
            {type = "fuel", category = "chemical", priority = "min"},
            {type = "fuel", category = "chemical", priority = "min"},
            {type = "ammo", category = "bullet", priority = "qty"},
            {type = "ammo", category = "cannon-shell", priority = "qty"}
        }
    },
    ["locomotive"] = {
        group = "locomotives",
        slots = {
            {type = "fuel", category = "chemical", priority = "max"}
        }
    },
    ["artillery-wagon"] = {
        group = "artillery",
        slots = {
            {type = "ammo", category = "artillery-shell", priority = "qty", limit = 5}
        }
    },
    ["boiler"] = {
        group = "burners",
        slots = {
            {type = "fuel", category = "chemical", priority = "max", limit = 5}
        }
    },
    ["burner-inserter"] = {
        group = "burners",
        slots = {
            {type = "fuel", category = "chemical", priority = "max", limit = 5}
        }
    },
    ["burner-mining-drill"] = {
        group = "burners",
        slots = {
            {type = "fuel", category = "chemical", priority = "max", limit = 5}
        }
    },
    ["stone-furnace"] = {
        group = "furnaces",
        slots = {
            {type = "fuel", category = "chemical", priority = "max", limit = 5}
        }
    },
    ["steel-furnace"] = {
        group = "furnaces",
        slots = {
            {type = "fuel", category = "chemical", priority = "max", limit = 5}
        }
    },
    ["gun-turret"] = {
        group = "turrets",
        slots = {
            {type = "ammo", category = "bullet", priority = "qty", limit = 10}
        }
    },
    ["beacon"] = {
        group = "beacons",
        slots = {
            {type = "module", category = "speed", priority = "max", limit = 1},
            {type = "module", category = "speed", priority = "max", limit = 1}
        }
    }
}
