local commands = {}

commands.help = "Autofill Help"

function commands.command(event)
    local player = game.players[event.player_index]
    local pdata = global.players[event.player_index]
    local params = event.parameter and event.parameter:split(" ") or {}

    if params[1] == "global" and player.admin then
        if params[2] == "priority" and player.cursor_stack.valid_for_read then
            local stack = player.cursor_stack
            local name = stack.name
            local category = stack.type == "ammo" and stack.prototype.get_ammo_type().category
            if category and MOD.sets.set_ammo_priority(pdata.sets.item_sets, category, name, tonumber(params[3]) or 1) then
                player.print({"", "Priority for ", {"item-name."..name}, " is set to " , pdata.sets.item_sets["ammo"][category][name]})
            end
        end
    end
end

return commands
