-------------------------------------------------------------------------------
--[[sets.lua: Defines all set and table data]]
-------------------------------------------------------------------------------
--game.print(global.players[1].sets.fill_sets["stone-furnace"].group)
local Core = require("stdlib.core")
local sets = {}

--[Functions]
sets.set_ammo_priority =
    function(set, category, name, priority)
    if set and set["ammo"] and set["ammo"][category] and set["ammo"][category][name] then
        local mt = getmetatable(set)
        setmetatable(set, {})
        set.ammo = set.ammo or {}
        set.ammo[category] = set.ammo[category] or {}
        set.ammo[category][name] = priority
        setmetatable(set, mt)
        return true
    end
end

sets.build_item_sets =
    function()
    local set = {
        fuel = {},
        ammo = {},
        module = {}
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

--[Defaults]
sets.default = {
    fill_sets = Core.prequire("default-sets.default-fill-sets") or {},
    item_sets = {} -- populated in global during on_init and config_changed
}

--[Metatable Information]
sets.mt = {
    fill_sets = {
        --Create index from global to autofill.defaut
        global = function()
            return {__index = sets.default.fill_sets}
        end,
        --Create index from global.players[index] to global.item_sets
        players = function()
            return {__index = global.sets.fill_sets}
        end
    },
    item_sets = {
        --Create index from global to autofill.defaut
        global = function()
            return {__index = global.default_item_sets}
        end,
        --Create index from global.players[index] to global.item_sets
        players = function()
            return {__index = global.sets.item_sets}
        end
    }
}

--[Load]
sets.on_load = function()
    if global and global._changes and global._changes["2.0.2"] then
        -- Set metatable on global to default file sets
        setmetatable(global.sets.fill_sets, sets.mt.fill_sets.global())
        setmetatable(global.sets.item_sets, sets.mt.item_sets.global())
        -- set metatable on players to global sets
        for index in pairs(global.players) do
            setmetatable(global.players[index].sets.fill_sets, sets.mt.fill_sets.players())
            setmetatable(global.players[index].sets.item_sets, sets.mt.item_sets.players())
        end
    end
end

return sets
