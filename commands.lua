local commands = {}

commands.help = "Autofill Help"

local function priority(global, player, set, params)
    local stack = player.cursor_stack
    local name = stack.name
    local category = stack.type == "ammo" and stack.prototype.get_ammo_type().category
    if category and MOD.sets.set_ammo_priority(set, category, name, tonumber(params[3]) or 1) then
        local msg = {"", "Priority for ", {"item-name." .. name}, " is set to ", set["ammo"][category][name]}
        return global and game.print(msg) or player.print(msg)
    end
end

function commands.command(event)
    local player = game.players[event.player_index]
    local pdata = global.players[event.player_index]
    local params = event.parameter and event.parameter:split(" ") or {}

    if params[1]:lower() == "priority" then
        if player.cursor_stack.valid_for_read then
            if params[2]:lower() == "global" and player.admin then
                priority(true, player, global.sets.item_sets, params)
            elseif params[2]:lower() == "player" then
                priority(true, player, pdata.sets.item_sets, params)
            end
        else
            player.print({"", "Must be holding an item in your hand to change priority"})
        end
    end
end

return commands
