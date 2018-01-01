--[REMOTE INTERFACES]-- Command Line and access from other mods is enabled here.
local interface = {}

interface.console = require("stdlib/utils/scripts/console")

--Dump the "global" to logfile
function interface.write_global(name)
    if name and type(name) == "string" then
        game.write_file(MOD.fullname.."/global.lua", serpent.block(global[name], {comment=false, sparse=true, compact=true, indent="    "}))
    else
        game.write_file(MOD.fullname.."/global.lua", serpent.block(global, {comment=false, sparse=true, compact=true, indent="    "}))
    end
end

--Dump the MOD data to logfile
function interface.write_MOD_global(name)
    if name and type(name) == "string" then
        game.write_file(MOD.fullname.."/MOD.lua", serpent.block(MOD[name], {comment=false, sparse=true, compact=true, indent="    "}))
    else
        game.write_file(MOD.fullname.."/MOD.lua", serpent.block(MOD, {comment=false, sparse=true, compact=true, indent="    "}))
    end
end

--Dump the MOD data to logfile
function interface.write_default_sets(name)
    if name and type(name) == "string" then
        game.write_file(MOD.fullname.."/default_sets.lua", serpent.block(MOD.sets.default[name], {comment=false, sparse=true, compact=false, indent="    "}))
    else
        game.write_file(MOD.fullname.."/default_sets.lua", serpent.block(MOD.sets.default, {comment=false, sparse=true, compact=false, indent="    "}))
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
