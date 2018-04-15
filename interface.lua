--[REMOTE INTERFACES]-- Command Line and access from other mods is enabled here.
local interface = {}

local Event = require('stdlib/event/event')
local Sets = require('autofill/sets')
local Inspect = require('stdlib/utils/vendor/inspect')

interface.console = require('stdlib/utils/scripts/console')

local function options(name)
    return {
        comment = false,
        sparse = true,
        compact = true,
        indent = '  ',
        nocode = true,
        name = name or nil,
        metatostring = false,
    }
end

--Dump the "global" to logfile
function interface.write_global(name)
    if name and type(name) == 'string' then
        game.write_file(MOD.fullname .. '/global.lua', serpent.block(global[name], options('global')))
    else
        game.write_file(MOD.fullname .. '/global.lua', serpent.block(global, options('global')))
        game.write_file(MOD.fullname .. '/global-I.lua', Inspect(global))

    end
end

--Dump the MOD data to logfile
function interface.write_MOD_global(name)
    if name and type(name) == 'string' then
        game.write_file(MOD.fullname .. '/MOD.lua', serpent.block(MOD[name], options('MOD')))
    else
        game.write_file(MOD.fullname .. '/MOD.lua', serpent.block(MOD, options('MOD')))
    end
end

--Dump the MOD data to logfile
function interface.write_default_sets(name)
    if name and type(name) == 'string' then
        game.write_file(MOD.fullname .. '/default_sets.lua', serpent.block(Sets.default[name], options('default_sets')))
    else
        game.write_file(MOD.fullname .. '/default_sets.lua', serpent.block(table.fullcopy(Sets.default), options('default_sets')))
    end
end

--[Reset functions]-- Complete reset of the mod. Wipes everything.
interface.reset_mod = function()
    global = {}
    Event.dispatch({name = Event.core_events.init})
end

--[Toggle functions]--
--interface.toggle_or_set_global_enabled = autofill.globals.toggle_paused
--interface.toggle_or_set_player_enabled = autofill.players.toggle_paused

--[Insert functions]--
function interface.insert_player_set()
end
function interface.insert_force_set()
end
function interface.insert_global_set()
end

return interface
