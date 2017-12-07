------------------------------------------------------------------------------------------
--[[REMOTE INTERFACES]]-- Command Line and access from other mods is enabled here.
--luacheck: globals autofill
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

-------------------------------------------------------------------------------
--[[Reset functions]]
--Complete reset of the mod. Wipes everything.
interface.reset_mod = function()
    --autofill.on_init()
end

-------------------------------------------------------------------------------
--[[Toggle functions]]
--interface.toggle_or_set_global_enabled = autofill.globals.toggle_paused
--interface.toggle_or_set_player_enabled = autofill.players.toggle_paused

-------------------------------------------------------------------------------
--[[Insert functions]]

function interface.insert_player_set()
end
function interface.insert_force_set()
end
function interface.insert_global_set()
end

-------------------------------------------------------------------------------
--[[creative-mode-functions]]

local function register_cm_interface(disable)
    --Register with creative-mode for easy testing
    if remote.interfaces["creative-mode"] and remote.interfaces["creative-mode"]["register_remote_function_to_modding_ui"] then
        MOD.log("Registering with Creative Mode")
        remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "write_global")
        remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "write_MOD_global")
        remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "write_default_sets")
        remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "reset_mod")
        --remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "verify_saved_sets")
        remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "console")
        if disable then interface.creative_mode_register = nil end
    end
end

function interface.creative_mode_register()
    register_cm_interface()
end
register_cm_interface(true)

return interface
