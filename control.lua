require('stdlib/core')

MOD = {
    name = 'autofill',
    path = '__autofill__',
    version = '2.0.0',
    fullname = 'AutoFill',
    if_name = 'af',
    interface = require('interface'),
    commands = require('commands')
}

local Event = require('stdlib/event/event')
local Player = require('stdlib/event/player').register_events()
local Force = require('stdlib/event/force').register_events()

Event.toggle_player_paused = script.generate_event_name()
Event.toggle_player_enabled = script.generate_event_name()
Event.build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
Event.death_events = {defines.events.on_pre_player_mined_item, defines.events.on_entity_died}

local Sets = require('autofill/sets')

--(( New Player and Force Data))--
function Player._new_player_data(force_name)
    local new = {
        sets = {
            force = force_name,
            fill_sets = {},
            fuel_sets = {},
            module_sets = {},
            ammo_sets = {}
        },
        limits = true,
        groups = true,
        enabled = true
    }
    Sets.load_player_metatables(new.sets)
    return new
end

function Force._new_force_data(player_index)
    local new = {
        sets = {
            player_index = player_index,
            fill_sets = {},
            fuel_sets = {},
            module_sets = {},
            ammo_sets = {}
        },
        enabled = true
    }
    Sets.load_force_metatables(new.sets)
    return new
end --))

--(( Init and Load))--
local function on_init()
    global.enabled = true

    local fuel, module, ammo = Sets.build_item_sets()

    global.sets = {
        fill_sets = {},
        fuel_sets = fuel,
        module_sets = module,
        ammo_sets = ammo
    }

    Sets.load_global_metatables(global.sets)
    Sets.load_default_metatables(Sets.default)

    Force.init()
    Player.init()
end
Event.register(Event.core_events.init, on_init)

require('stdlib/event/changes').register_events()

local function on_load()
    for _, pdata in pairs(global.players) do
        Sets.load_player_metatables(pdata.sets)
    end
    for _, fdata in pairs(global.forces) do
        Sets.load_force_metatables(fdata.sets)
    end
    Sets.load_global_metatables(global.sets)
    Sets.load_default_metatables(Sets.default)
end
Event.register(Event.core_events.load, on_load) --))

--(( Autofill ))--
--local autofill = require("autofill/autofill")
--Event.register(defines.events.on_built_entity, autofill)

local function hotkey_fill(event)
    local player = Player.get(event.player_index)
    if player.selected then
        event.created_entity = player.selected
    --autofill(event)
    end
end
Event.register('autofill-hotkey-fill', hotkey_fill)

local function toggle_limits(event)
    local player, pdata = Player.get(event.player_index)
    pdata.limits = not pdata.limits
    if pdata.limits then
        player.print({'autofill.toggle-limits-on'})
    else
        player.print({'autofill.toggle-limits-off'})
    end
end
Event.register('autofill-toggle-limits', toggle_limits)

local function toggle_groups(event)
    local player, pdata = Player.get(event.player_index)
    pdata.groups = not pdata.groups
    if pdata.groups then
        player.print({'autofill.toggle-groups-on'})
    else
        player.print({'autofill.toggle-groups-off'})
    end
end
Event.register('autofill-toggle-groups', toggle_groups) --))

--(( Commands and Interface ))--
commands.add_command(MOD.if_name, MOD.commands.help, MOD.commands.command)

commands.add_command('af_dump', '', MOD.commands.dump)

remote.add_interface(MOD.if_name, MOD.interface) --))

Event.register(defines.events.on_player_created, function() MOD.commands.dump() end)
