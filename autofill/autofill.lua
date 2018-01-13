local Position = require("stdlib.area.position")
local priorities = {["qty"] = "qty", ["max"] = "max", ["min"] = "min"}

local function flying_text(line, color, pos, surface)
    color = color or defines.color.red
    line = line or "missing text" --If we for some reason didn't pass a message make a message
    if not pos then
        for _, p in pairs(game.players) do
            p.surface.create_entity({name = "flying-text", position = p.position, text = line, color = color})
        end
        return
    else
        if surface then
            surface.create_entity({name = "flying-text", position = pos, text = line, color = color})
        end
    end
end

-- return false if there is a recipe and it is not enabled
-- TODO Make this better, Some items don't have the same recipe name and could
-- therefore not be enabled.
local function is_enabled(item, force)
    if force and force.recipes[item] then
        if force.recipes[item].enabled then
            return true
        else
            return false
        end
    end
    return true
end

local function _sort(t, a, b)
    return t[b] < t[a]
end

local function get_highest_value(tbl, force)
    for item in iter.spairs(tbl, _sort) do
        if game.item_prototypes[item] and is_enabled(item, force) then
            return item, game.item_prototypes[item].stack_size
        end
    end
    return nil, 0
end

local function autofill(event)
    local entity = event.created_entity
    local player, pdata = game.players[event.player_index], global.players[event.player_index]
    local ghost = entity.name == "entity-ghost" and player.mod_settings["autofill-ghost"].value
    local set = (ghost and pdata.sets.fill_sets[entity.ghost_name]) or (pdata.sets.fill_sets[entity.name] and player.mod_settings["autofill-entity"].value)
    if set and global.enabled and pdata.enabled then
        local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
        --Increment y position everytime text_pos is called
        local text_pos = Position(entity.position):increment(0, 1)

        --local fuel_slots = pcall(#entity.get_inventory(defines.inventory.fuel))
        -- local duplicate_counts = {}

        --Get inventories
        local main_inventory = player.get_inventory(defines.inventory.player_main)
        local quickbar = player.get_inventory(defines.inventory.player_quickbar)
        local vehicle_inventory = player.vehicle and player.vehicle.get_inventory(defines.inventory.car_trunk)

        local slot_counts = {}
        --further divide amongst same type slot counts
        for _, slot in ipairs(set.slots) do
            slot_counts[slot.category] = slot_counts[slot.category] or 0 + 1
        end

        --Loop through each slot in the set.
        for _, slot in ipairs(set.slots) do
            local color = defines.color.red -- Color for fying text
            local item = false -- The item to insert
            local item_count = 0 -- Total count of item in inventory and car inventory
            local insert_count = 0 -- Count of items to insert
            local group_count = 1 -- Num of items in the group. (Hand + Quickbar)

            --verify or set existing priority
            local priority = priorities[slot.priority] or "qty"

            -- START Item Count --------------------------------------------------------
            --Get the item list from player or default if no player
            --TODO META TF this up
            local item_list = table.dictionary_merge(pdata.sets.item_sets[slot.type][slot.category])

            --No item list or item list is not a table.
            if not item_list or type(item_list) ~= "table" then
                flying_text({"autofill.invalid-category"}, color, text_pos(), entity.surface)
                goto break_out
            end

            if player.cheat_mode then
                item = get_highest_value(item_list, player.force)
                item_count = 32000000
            elseif priority == "qty" or ghost then
                for item_name, _ in pairs(item_list) do
                    local proto = game.item_prototypes[item_name]
                    if proto and is_enabled(item_name, player.force) then
                        local mi = main_inventory.get_item_count(item_name)
                        local vi = vehicle_inventory and vehicle_inventory.get_item_count(item_name) or 0
                        local total = mi + vi
                        if (total > 0 and total > item_count) then
                            item = item_name
                            item_count = total
                        end
                    end
                    if not item and ghost then
                        item, item_count = get_highest_value(item_list, player.force)
                    end
                end
            elseif priority == "max" then
                for item_name, _ in iter.spairs(
                    item_list,
                    function(t, a, b)
                        return t[b] < t[a]
                    end
                ) do
                    local proto = game.item_prototypes[item_name]
                    if proto and is_enabled(item_name, player.force) then
                        local mi = main_inventory.get_item_count(item_name)
                        local vi = vehicle_inventory and vehicle_inventory.get_item_count(item_name) or 0
                        local total = mi + vi
                        if total > 0 then
                            item = item_name
                            item_count = total
                            break
                        end
                    end
                end
            elseif priority == "min" then
                for item_name, _ in iter.spairs(
                    item_list,
                    function(t, a, b)
                        return t[b] > t[a]
                    end
                ) do
                    local proto = game.item_prototypes[item_name]
                    if proto and is_enabled(item_name, player.force) then
                        local mi = main_inventory.get_item_count(item_name)
                        local vi = vehicle_inventory and vehicle_inventory.get_item_count(item_name) or 0
                        local total = mi + vi
                        if total > 0 then
                            item = item_name
                            item_count = total
                            break
                        end
                    end
                end
            end

            if not ghost then
                if not item or item_count < 1 then
                    local key_table = table.keys(item_list)
                    if key_table[1] ~= nil and game.item_prototypes[key_table[1]] then
                        flying_text({"autofill.out-of-item", slot.type}, color, text_pos(), entity.surface)
                    elseif key_table[1] ~= nil then
                        flying_text({"autofill.invalid-itemname", key_table[1]}, color, text_pos(), entity.surface)
                    end
                    goto break_out
                end
                -- END Item Count --We now have an item, and a count of the amount of items we have.

                -- START Groups -------------------------------------------------------------
                --Divide stack between group items (only items in quickbar and hand are part of the group)
                --Get count in hands
                if (set.group and pdata.groups) then
                    if player.cursor_stack.valid_for_read then
                        group_count = group_count + player.cursor_stack.count
                    end
                    for entity_name, set_table in pairs(pdata.sets) do
                        if type(set_table) == "table" and set_table.group == set.group then
                            group_count = group_count + quickbar.get_item_count(entity_name)
                        end
                    end
                end
            end
            --END Groups--

            local slot_count = slot_counts[slot.category] or 1 - 1
            if slot_count < 1 then
                slot_count = 1
            end

            local stack_size = game.item_prototypes[item].stack_size

            insert_count =
                insert_count + min(max(1, min(item_count, floor(item_count / ceil(group_count / slot_count)))), (pdata.limits and slot.limit) or stack_size)

            -- START inesertion -------------------------------------------------

            if ghost then
                local requests = entity.item_requests or {}
                requests[item] = (requests[item] or 0) + insert_count
                entity.item_requests = requests
            else
                local removed, inserted
                inserted =
                    entity.insert {
                    name = item,
                    count = insert_count
                }
                if inserted > 0 then
                    if vehicle_inventory then
                        removed =
                            vehicle_inventory.remove {
                            name = item,
                            count = inserted
                        }
                        if inserted > removed then
                            main_inventory.remove {
                                name = item,
                                count = inserted - removed
                            }
                        end
                    else
                        main_inventory.remove {
                            name = item,
                            count = inserted
                        }
                    end

                    if inserted < stack_size then
                        color = defines.color.yellow
                    elseif insert_count >= stack_size then
                        color = defines.color.green
                    end

                    if removed then
                        flying_text(
                            {
                                "autofill.insertion-from-vehicle",
                                inserted,
                                game.item_prototypes[item].localised_name,
                                removed,
                                game.entity_prototypes[player.vehicle.name].localised_name
                            },
                            color,
                            text_pos(),
                            entity.surface
                        )
                    else
                        flying_text({"autofill.insertion", inserted, game.item_prototypes[item].localised_name}, color, text_pos(), entity.surface)
                    end
                end
            end
            ::break_out::
        end
    end
end

return autofill
