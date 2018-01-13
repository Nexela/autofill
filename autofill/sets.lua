-------------------------------------------------------------------------------
--[[sets.lua: Defines all set and table data]]
-------------------------------------------------------------------------------
--game.print(global.players[1].sets.fill_sets["stone-furnace"].group)
local Core = require("stdlib/core")
local sets = {}

--[Functions]
function sets.set_ammo_priority(set, category, name, priority)
    if set and set["ammo"] and set["ammo"][category] and set["ammo"][category][name] then
        setmetatable(set, nil)
        set.ammo = set.ammo or {}
        set.ammo[category] = set.ammo[category] or {}
        set.ammo[category][name] = priority
        sets.set_item_tables(set)
        return true
    end
end

function sets.build_item_sets()
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
        global = function(class, category)
            if category then
                return {__index = global.default_item_sets[class][category]}
            elseif class then
                return {__index = global.default_item_sets[class]}
            else
                return {__index = global.default_item_sets}
            end
        end,
        --Create index from global.players[index] to global.item_sets
        players = function(class, category)
            if category then
                return {__index = global.sets.item_sets[class][category]}
            elseif class then
                return {__index = global.sets.item_sets[class]}
            else
                return {__index = global.sets.item_sets}
            end
        end
    },
    pairs = function(t)
        local new = table.dictionary_merge({}, t)
        local meta = getmetatable(t)
        while meta do
            new = table.dictionary_merge(new, meta.__index)
            meta = getmetatable(meta)
        end

        return pairs(new)
    end
}

-- local a =
--     setmetatable(
--     {test = "A", good = "bad"},
--     setmetatable(
--         {
--             __index = {test = "B", good = "C"},
--             __pairs = sets.mt.pairs
--         },
--         {
--             __index = {test = "D", good = "B", awesome = "X"},
--             __pairs = sets.mt.pairs
--         }
--     )
-- )

-- for k, v in pairs(a) do
--     print(k .. v)
-- end

--[Load]

function sets.set_item_tables(t)
    for class, classes in pairs(t) do
        setmetatable(t[class], sets.mt.item_sets.player(class))
        for category in pairs(classes) do
            setmetatable(t[class][category], sets.mt.item_sets.players(class, category))
        end
    end
end

function sets.load_global()
    setmetatable(global.sets.fill_sets, sets.mt.fill_sets.global())
    sets.set_item_tables(global.sets.item_sets)
end

function sets.load_player(new_sets)
    if new_sets then
        setmetatable(new_sets.fill_sets, sets.mt.fill_sets.players())
        sets.set_item_tables(new_sets.item_sets)
    else
        for index in pairs(global.players) do
            setmetatable(global.players[index].sets.fill_sets, sets.mt.fill_sets.players())
            sets.set_item_tables(global.players[index].sets.item_sets)
        end
    end
end

sets.on_load = function()
    if global and global._changes and global._changes["2.0.2"] then
    -- Set metatable on global to default file sets
        sets.load_global()
    -- set metatable on players to global sets
        sets.load_player()
    end
end

return sets
