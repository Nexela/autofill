require("stdlib.core")
require("stdlib.event.event")
require("stdlib.event.gui")

--Set up default MOD global variables.
--These "globals" are not stored in saves
MOD = {}
MOD.name = "autofill"
MOD.version = "2.0.0"
MOD.fullname = "AutoFill"
MOD.if_name = "af"
MOD.interface = require("interface")
MOD.commands = require("commands")
MOD.path = "__" .. MOD.name .. "__"
MOD.config = require("config")
MOD.log = require("stdlib.log.logger").new(MOD.fullname, "log", MOD.config.DEBUG or false, {log_ticks = true, file_extension = "log"})
MOD.sets = require("autofill.sets")

if MOD.config.DEBUG then
    log("Debug quickstart enabled")
    require("stdlib.utils.scripts.quickstart")
end

local function new_player_data()
    local new = {
        sets = {
            type = "player",
            fill_sets = {},
        },
        limits = true,
        groups = true,
        enabled = true
    }
    new.sets.item_sets = table.deepcopy(global.sets.item_sets)
    setmetatable(new.sets.fill_sets, MOD.sets.mt.players(new))
    return new
end

local function new_force_data()
    local new = {
        enabled = true,
        sets = {
            type = "force",
            fill_sets = {}
        }
    }
    setmetatable(new.sets.fill_sets, MOD.sets.mt.forces())
    return new
end

local Player = require("stdlib.event.player").additional_data(new_player_data)
local Force = require("stdlib.event.force").additional_data(new_force_data)

Event.toggle_player_paused = script.generate_event_name()
Event.toggle_player_enabled = script.generate_event_name()
Event.build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
Event.death_events = {defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}

local changes = require("changes")
Event.register(Event.core_events.configuration_changed, changes.on_configuration_changed)

local function on_init()
    global._changes = changes.on_init(game.active_mods[MOD.name] or MOD.version)
    global.enabled = true
    global.sets = {
        fill_sets = {},
        item_sets = MOD.sets.build_item_sets()
    }
    Player.init()
    Force.init()

    -- Set all metatables
    MOD.sets.on_load()
end
Event.register(Event.core_events.init, on_init)

local function on_load()
    -- Set all metatables
    MOD.sets.on_load()
end
Event.register(Event.core_events.load, on_load)

Player.register_events()
Force.register_events()

--[[Hotkeys]]
local function hotkey_fill(event)
    local player, pdata = Player.get(event.player_index)
    local entity = player.selected
    if entity and global.enabled and pdata.enabled then
        local set = pdata.sets.fill_sets[entity.name]
        if set then
            log("Not yet")
        --fill_entity(entity, pdata, set)
        end
    end
end
Event.register("autofill-hotkey-fill", hotkey_fill)

local function toggle_limits(event)
    local player, pdata = Player.get(event.player_index)
    pdata.limits = not pdata.limits
    if pdata.limits then
        player.print({"autofill.toggle-limits-on"})
    else
        player.print({"autofill.toggle-limits-off"})
    end
end
Event.register("autofill-toggle-limits", toggle_limits)

local function toggle_groups(event)
    local player, pdata = Player.get(event.player_index)
    pdata.groups = not pdata.groups
    if pdata.groups then
        player.print({"autofill.toggle-groups-on"})
    else
        player.print({"autofill.toggle-groups-off"})
    end
end
Event.register("autofill-toggle-groups", toggle_groups)

--[[Events]]
--Event.register(defines.events.on_research_finished, research_finished)

local autofill = require("autofill.autofill")
Event.register(defines.events.on_built_entity, autofill)

--Add commands
commands.add_command(MOD.if_name, MOD.commands.help, MOD.commands.command)

--Add the remote interface.
remote.add_interface(MOD.if_name, MOD.interface)
