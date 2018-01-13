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
MOD.config = {DEBUG = false}
MOD.log = require("stdlib.log.logger").new(MOD.fullname, "log", MOD.config.DEBUG or false, {log_ticks = true, file_extension = "log"})
MOD.sets = require("autofill.sets")

if MOD.config.DEBUG then
    log("Debug quickstart enabled")
    require("stdlib.utils.scripts.quickstart")
end

local Player = require("stdlib.event.player")
local Force = require("stdlib.event.force")

Event._new_player_data = function()
    local new = {
        sets = {
            type = "player",
            fill_sets = {},
            item_sets = {}
        },
        limits = true,
        groups = true,
        enabled = true
    }
    MOD.sets.load_player(new.sets)
    return new
end

Event.toggle_player_paused = script.generate_event_name()
Event.toggle_player_enabled = script.generate_event_name()
Event.build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
Event.death_events = {defines.events.on_pre_player_mined_item, defines.events.on_entity_died}

local function on_init()
    global.enabled = true
    global.default_item_sets = MOD.sets.build_item_sets()
    global.sets = {
        fill_sets = {},
        item_sets = {}
    }
    MOD.sets.load_global()
    Force.init()
    Player.init()
    game.print("Autofill Installed")
end
Event.register(Event.core_events.init, on_init)

local Changes = require("stdlib/event/changes")
Changes.register_events()

local function on_load()
    -- Set all metatables
    MOD.sets.on_load()
end
Event.register(Event.core_events.load, on_load)

Force.register_events()
Player.register_events()

local autofill = require("autofill.autofill")
Event.register(defines.events.on_built_entity, autofill)

--[Hotkeys]--
local function hotkey_fill(event)
    local player = Player.get(event.player_index)
    if player.selected then
        event.created_entity = player.selected
        autofill(event)
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

--Add commands
commands.add_command(MOD.if_name, MOD.commands.help, MOD.commands.command)

--Add the remote interface.
remote.add_interface(MOD.if_name, MOD.interface)
