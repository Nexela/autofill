-------------------------------------------------------------------------------
--[[sets.lua: Defines all set and table data]]
-------------------------------------------------------------------------------
--game.print(global.players[1].sets.fill_sets["stone-furnace"].group)
local Core = require("stdlib.core")
local sets = {}

--[[Functions]]
sets.set_ammo_priority = function(set, category, name, priority)
    if set and set["ammo"] and set["ammo"][category] and set["ammo"][category][name] then
        set["ammo"][category][name] = priority
        return true
    end
end

sets.build_item_sets = function()
    local set = {
        fuel = {},
        ammo = {},
        module = {},
    }

    --Get Ammo's and Fuels
    for _, item in pairs(game.item_prototypes) do
        --Build fuel tables
        if item.fuel_value > 0 then
            set["fuel"][item.fuel_category] = set["fuel"][item.fuel_category] or {}
            set["fuel"][item.fuel_category or "chemical"][item.name] = item.fuel_value / 1000000
        end

        --Build Ammo Category tables
        local ammo = item.type == "ammo" and item.get_ammo_type()
        if ammo then
            set["ammo"][ammo.category] = set["ammo"][ammo.category] or {}
            set["ammo"][ammo.category][item.name] = 1
        end

        local module = item.type == "module" and item
        if module then
            set["module"][module.category] = set["module"][module.category] or {}
            set["module"][module.category][module.name] = tonumber(module.name:match("%d+$")) or 1
        end
    end

    -- increase priority of vanilla bullets:
    -- TODO interface to set level

    sets.set_ammo_priority(set, "bullet", "piercing-rounds-magazine", 10)
    sets.set_ammo_priority(set, "bullet", "uranium-rounds-magazine", 20)

    return set
end

--[[Defaults]]
sets.default = {}
sets.default.fill_sets = Core.prequire("default-sets.default-fill-sets")

--[[Metatable Information]]
sets.mt = {}
--Create index from global to autofill.defaut
sets.mt.global = function()
    return {__index = sets.default.fill_sets}
end

--Create index from global.forces["force_name"] to global.sets
sets.mt.forces = function()
    return {__index = global.sets.fill_sets}
end

--Create index from global.players[index] to global.forces[players[index].force]
sets.mt.players = function(data)
    local force = data.force or "player"
    return {__index = global.forces[force].sets.fill_sets}
end

--[[Load]]
sets.on_load = function()
    if global and global._changes and global._changes["2.0.0"] then
        -- Set metatable on global to default file sets
        setmetatable(global.sets.fill_sets, sets.mt.global())

        -- Set metatable on forces to global sets
        for name in pairs(global.forces) do
            setmetatable(global.forces[name].sets.fill_sets, sets.mt.forces())
        end

        -- set metatable on players to force sets
        for index in pairs(global.players) do
            setmetatable(global.players[index].sets.fill_sets, sets.mt.players(global.players[index]))
        end
    end
end

return sets
