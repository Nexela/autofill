-------------------------------------------------------------------------------
--[[Sets.lua: Defines all set and table data]]
-------------------------------------------------------------------------------
--game.print(global.players[1].Sets.fill_sets["stone-furnace"].group)

local Sets = {}

function Sets.set_priority(set, category, name, priority)
    local current = set[category] and set[category]
    if current and current[name] then
        current[name] = priority
        return true
    end
end

function Sets.build_item_sets()
    local set = {
        fuel = {},
        ammo = {},
        module = {}
    }

    --Get Ammo's and Fuels
    for _, item in pairs(game.item_prototypes) do
        --Build fuel tables
        if item.fuel_value > 0 then
            set['fuel'][item.fuel_category] = set['fuel'][item.fuel_category] or {}
            set['fuel'][item.fuel_category or 'chemical'][item.name] = item.fuel_value / 1000000
        end

        --Build Ammo Category tables
        local ammo = item.type == 'ammo' and item.get_ammo_type()
        if ammo then
            set['ammo'][ammo.category] = set['ammo'][ammo.category] or {}
            set['ammo'][ammo.category][item.name] = 1
        end

        local module = item.type == 'module' and item
        if module then
            set['module'][module.category] = set['module'][module.category] or {}
            set['module'][module.category][module.name] = tonumber(module.name:match('%d+$')) or 1
        end
    end

    -- increase priority of vanilla bullets:
    -- TODO interface to set level
    Sets.set_priority(set.ammo, 'bullet', 'piercing-rounds-magazine', 10)
    Sets.set_priority(set.ammo, 'bullet', 'uranium-rounds-magazine', 20)

    return set.fuel, set.ammo, set.module
end

--(( Build Defaults ))
Sets.default = {
    fill_sets = prequire('default-sets/default-fill-sets') or {}
} --))

--(( Metatable Loader functions ))--
function Sets.load_player_metatables(sets)
    setmetatable(sets.fill_sets, Sets.metatables.fill_sets.player)

end

function Sets.load_force_metatables(sets)
    setmetatable(sets.fill_sets, Sets.metatables.fill_sets.force)
end

function Sets.load_global_metatables(sets)
    setmetatable(sets.fill_sets, Sets.metatables.fill_sets.global)
end

function Sets.load_default_metatables(sets)
    setmetatable(sets.fill_sets, Sets.metatables.fill_sets.default)
end --))

--(( Metatables and meta functions ))--
local function not_allowed(t, k, v)
    error("not allowed")
end

local function get_force_index(t, k, ...)
    return get_force(k, ...)
end

Sets.metatables = {
    fill_sets = {
        default = {
            __newindex = not_allowed
        },
        global = {
            __index = Sets.default.fill_sets,
            __newindex = not_allowed
        },
        force = {
            __index = function(_, k) return global.sets.fill_sets[k] end,
            __newindex = not_allowed
        },
        player = {
            __index = get_force_index,
            __newindex = not_allowed,
            __pairs = fill_set_pairs,
            __ipairs = fill_set_pairs,
        }
    }
}

--))
return Sets

--(( Old Stuff ))--
-- Sets.metatables = {
--     fill_sets = {
--         --Create index from global to autofill.defaut
--         global = function()
--             return {__index = Sets.default.fill_sets}
--         end,
--         forces = function()
--             return {__index = global.Sets.fill_sets}
--         end,
--         players = function()
--             return {__index = global.Sets.fill_sets}
--         end
--     },
--     item_sets = {
--         --Create index from global to autofill.defaut
--         global = function(class, category)
--             if category then
--                 return {__index = global.default_item_sets[class][category]}
--             elseif class then
--                 return {__index = global.default_item_sets[class]}
--             else
--                 return {__index = global.default_item_sets}
--             end
--         end,
--         --Create index from global.players[index] to global.item_sets
--         players = function(class, category)
--             if category then
--                 return {__index = global.Sets.item_sets[class][category]}
--             elseif class then
--                 return {__index = global.Sets.item_sets[class]}
--             else
--                 return {__index = global.Sets.item_sets}
--             end
--         end
--     },
--     pairs = function(t)
--         local new = table.dictionary_merge({}, t)
--         local meta = getmetatable(t)
--         while meta do
--             new = table.dictionary_merge(new, meta.__index)
--             meta = getmetatable(meta)
--         end

--         return pairs(new)
--     end
-- }

-- -- local a =
-- --     setmetatable(
-- --     {test = "A", good = "bad"},
-- --     setmetatable(
-- --         {
-- --             __index = {test = "B", good = "C"},
-- --             __pairs = Sets.mt.pairs
-- --         },
-- --         {
-- --             __index = {test = "D", good = "B", awesome = "X"},
-- --             __pairs = Sets.mt.pairs
-- --         }
-- --     )
-- -- )

-- -- for k, v in pairs(a) do
-- --     print(k .. v)
-- -- end

-- --[Load]

-- function Sets.set_item_tables(t)
--     for class, classes in pairs(t) do
--         setmetatable(t[class], Sets.mt.item_Sets.players(class))
--         for category in pairs(classes) do
--             setmetatable(t[class][category], Sets.mt.item_Sets.players(class, category))
--         end
--     end
-- end

-- function Sets.load_global()
--     setmetatable(global.Sets.fill_sets, Sets.mt.fill_Sets.global())
--     Sets.set_item_tables(global.Sets.item_sets)
-- end

-- function Sets.load_player(new_sets)
--     if new_sets then
--         setmetatable(new_Sets.fill_sets, Sets.mt.fill_Sets.players())
--         Sets.set_item_tables(new_Sets.item_sets)
--     else
--         for index in pairs(global.players) do
--             setmetatable(global.players[index].Sets.fill_sets, Sets.mt.fill_Sets.players())
--             Sets.set_item_tables(global.players[index].Sets.item_sets)
--         end
--     end
-- end

-- Sets.on_load = function()
--     if global and global._changes and global._changes["2.0.2"] then
--     -- Set metatable on global to default file sets
--         Sets.load_global()
--     -- set metatable on players to global sets
--         Sets.load_player()
--     end
-- end
--))
