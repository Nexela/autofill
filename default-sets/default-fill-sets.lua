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
local fuel_with_limit = {type = 'fuel', category = 'chemical', priority = 'max', limit = 5}
local fuel_max = {type = 'fuel', category = 'chemical', priority = 'max'}
local ammo_bullet_qty = {type = 'ammo', category = 'bullet', priority = 'qty', limit = 20}

local sets = {
    ['car'] = {slots = {fuel_max, ammo_bullet_qty}},
    ['tank'] = {
        group = nil,
        slots = {
            {type = 'fuel', category = 'chemical', priority = 'min'},
            {type = 'fuel', category = 'chemical', priority = 'min'},
            {type = 'ammo', category = 'bullet', priority = 'qty'},
            {type = 'ammo', category = 'cannon-shell', priority = 'qty'}
        }
    },
    ['locomotive'] = {group = 'locomotives', slots = {fuel_max}},
    ['artillery-wagon'] = {
        group = 'artillery',
        slots = {{type = 'ammo', category = 'artillery-shell', priority = 'qty', limit = 5}}
    },
    ['boiler'] = {group = 'burners', slots = {fuel_with_limit}},
    ['burner-inserter'] = {group = 'burners', slots = {fuel_with_limit}},
    ['burner-mining-drill'] = {group = 'burners', slots = {fuel_with_limit}},
    ['stone-furnace'] = {group = 'furnaces', slots = {fuel_with_limit}},
    ['steel-furnace'] = {group = 'furnaces', slots = {fuel_with_limit}},
    ['gun-turret'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['artillery-turret'] = {group = 'artillery', slots = {{type = 'ammo', category = 'artillery-shell', priority = 'qty', limit = 5}}},
    ['beacon'] = {
        group = 'beacons',
        slots = {
            {type = 'module', category = 'speed', priority = 'max', limit = 1},
            {type = 'module', category = 'speed', priority = 'max', limit = 1}
        }
    },
    -- End Vanilla --
    ['farl'] = {group = 'locomotives', slots = {fuel_max}},
    ['shuttleTrain'] = {group = 'locomotives', slots = {fuel_max}},
    ['boiler-3'] = {group = 'burners', slots = {fuel_with_limit}},
    ['boiler-2'] = {group = 'burners', slots = {fuel_with_limit}},
    ['boiler-4'] = {group = 'burners', slots = {fuel_with_limit}},
    ['mixing-furnace'] = {group = 'burners', slots = {fuel_with_limit}},
    ['chemical-boiler'] = {group = 'burners', slots = {fuel_with_limit}},
    ['bob-gun-turret-2'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['bob-gun-turret-3'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['bob-gun-turret-4'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['bob-gun-turret-5'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['bob-sniper-turret-1'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['bob-sniper-turret-2'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['bob-sniper-turret-3'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['y_turret_gun1f12'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['y_turret_gun2f12'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['y_turret_plasma'] = {group = 'plasmaturrets', slots = {{type = 'ammo', category = 'ammo-yi-plasma', priority = 'qty', limit = 20}}},
    ['y_turret_flame'] = {group = 'plasmaturrets', slots = {{type = 'ammo', category = 'ammo-yi-chem', priority = 'qty', limit = 20}}},
    ['bob-diesel-locomotive-2'] = {group = 'locomotives', slots = {fuel_max, fuel_max}},
    ['bob-diesel-locomotive-3'] = {group = 'locomotives', slots = {fuel_max, fuel_max, fuel_max}},
    ['bob-armoured-diesel-locomotive'] = {group = 'locomotives', slots = {fuel_max, fuel_max}},
    ['y-boiler-t2'] = {group = 'burners', slots = {fuel_with_limit}},
    ['y-boiler-t3'] = {group = 'burners', slots = {fuel_with_limit}},
    ['y-boiler-iv'] = {group = 'burners', slots = {fuel_with_limit}},
    ['y-obninsk-reactor'] = {group = 'burners', slots = {fuel_with_limit}},
    ['ammobox-gun-turret-2'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['hvmg-turret'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['bob-tank-2'] = {
        slots = {
            fuel_with_limit,
            fuel_with_limit,
            fuel_with_limit,
            {type = 'ammo', category = 'bullet', priority = 'qty', limit = 20},
            {type = 'ammo', category = 'cannon-shell', priority = 'qty', limit = 20},
            {type = 'ammo', category = 'artillery-shell', priority = 'qty', limit = 20}
        }
    },
    ['bob-tank-3'] = {
        slots = {
            fuel_with_limit,
            fuel_with_limit,
            fuel_with_limit,
            fuel_with_limit,
            {type = 'ammo', category = 'bullet', priority = 'qty', limit = 20},
            {type = 'ammo', category = 'battery', priority = 'qty', limit = 20},
            {type = 'ammo', category = 'cannon-shell', priority = 'qty', limit = 20},
            {type = 'ammo', category = 'artillery-shell', priority = 'qty', limit = 20}
        }
    },
    ['bulldozer'] = {slots = {fuel_max, fuel_max}}, --Bulldozer
    ['burner-ore-crusher'] = {group = 'burners', slots = {fuel_with_limit}}, --Angels
    ['diesel-locomotive-mk2'] = {group = 'locomotives', slots = {fuel_max, fuel_max, fuel_max}},
    ['diesel-locomotive-mk3'] = {group = 'locomotives', slots = {fuel_max, fuel_max, fuel_max}},
    ['gun-turret-mk2'] = {group = 'turrets', slots = {ammo_bullet_qty}},
    ['exploration-vehicle'] = {slots = {fuel_max, ammo_bullet_qty}}
}

return sets

--     ["5d-gun-turret-big"] = {priority = order.default, group = "turrets", limits = {10}, "ammo-bullets"},
--     ["5d-gun-turret-small"] = {priority = order.default, group = "turrets", limits = {10}, "ammo-bullets"},
--     ["gunship"] = {slots = {2, 1, 1}, "fuels-all", "ammo-bullets", "ammo-rockets"},
--     ["cargo-plane"] = {slots = {6, 1, 1}, "fuels-all", "ammo-bullets"},
--     ["jet"] = {slots = {3, 1, 1}, "fuels-all", "ammo-bullets", "ammo-rockets"},
--     ["flying-fortress"] = {slots = {4, 1, 1}, "fuels-all", "ammo-bullets", "ammo-shells"},
--     ["car-flamer"] = {priority = 3, slots = {1, 1}, "fuels-all", "gi-ammo-flame"},
--     ["auto-tank-wlsk"] = {priority = 3, slots = {2, 1, 1}, "fuels-all", "gi-ammo-auto45", "ammo-shotgun"},
--     ["flame-tank-wlsk"] = {priority = 3, slots = {2, 1, 1}, "fuels-all", "ammo-shells", "gi-ammo-flame"},
--     ["nade-tank-wlsk"] = {priority = 3, slots = {2, 1}, "fuels-all", "gi-ammo-artillery"},
--     ["auto-tank"] = {priority = 3, slots = {2, 1, 1}, "fuels-all", "gi-ammo-auto45", "ammo-shotgun"},
--     ["flame-tank"] = {priority = 3, slots = {2, 1, 1}, "fuels-all", "ammo-shells", "gi-ammo-flame"},
--     ["nade-tank"] = {priority = 3, slots = {2, 1}, "fuels-all", "gi-ammo-artillery"},
--     ["rocket-tank"] = {priority = 3, slots = {2, 1, 1}, "fuels-all", "gi-ammo-rocket", "ammo-shells"},
--     ["mine-tank"] = {priority = 3, slots = {2, 1, 1}, "fuels-all", "gi-ammo-mine", "ammo-shotgun"},
--     ["super-tank"] = {priority = 3, slots = {4, 1, 1, 1}, "fuels-all", "gi-ammo-auto45", "gi-ammo-artillery", "ammo-bullets"},
--     ["super-tank-alternate"] = {priority = 3, slots = {4, 1, 1, 1}, "fuels-all", "ammo-shells", "gi-ammo-flame", "gi-ammo-mine"},
--     ["super-tank-wmd"] = {priority = 3, slots = {4, 1, 1}, "fuels-all", "gi-ammo-wmd", "gi-ammo-auto45"},
--     ["flame-tank"] = {priority = 3, slots = {2, 1, 1}, "fuels-all", "tw-ammo-flame", "ammo-bullets"},
--     ["hydra-tank"] = {priority = 3, slots = {2, 1, 1}, "fuels-all", "tw-ammo-rocket", "ammo-bullets"},
--     ["heavy-tank"] = {priority = 3, slots = {2, 2, 1}, "fuels-all", "ammo-shells", "tw-ammo-belt"},
--     ["light-tank"] = {priority = 3, slots = {2, 1}, "fuels-all", "ammo-bullets"},
--     ["buggy"] = {priority = 3, slots = {1, 1}, "fuels-all", "ammo-bullets"}, --Gimprovments
--     ["burner-generator"] = {group = "burners", slots = {2}, limits = {10}, "fuels-all"}, -- Kspower
--     ["mega-tank"] = {priority = 3, slots = {3, 1, 1}, "fuels-all", "mo-ammo-goliath", "ammo-bullets"}, --MoMods
--     ["supertank"] = {priority = 3, slots = {2, 1, 1}, "fuels-all", "ammo-shells", "ammo-bullets"} --SuperTank
