--luacheck: globals autofill
--[[
ConfigurationChangedData
Table with the following fields:
old_version :: string (optional): Old version of the map. Present only when loading map version other than the current version.
new_version :: string (optional): New version of the map. Present only when loading map version other than the current version.
mod_changes :: dictionary string → ModConfigurationChangedData: Dictionary of mod changes. It is indexed by mod name.
ModConfigurationChangedData
Table with the following fields:
old_version :: string: Old version of the mod. May be nil if the mod wasn't previously present (i.e. it was just added).
new_version :: string: New version of the mod. May be nil if the mod is no longer present (i.e. it was just removed).
--]]
--local mod_name = MOD.name or "not-set"
local migrations = {"2.0.0"}
local changes = {}


--Mark all migrations as complete during Init.
function changes.on_init(version)
    local list = {}
    for _, migration in ipairs(migrations) do
        list[migration] = version
    end
    return list
end

function changes.on_configuration_changed(event)
    changes["map-change-always-first"]()
    if event.data.mod_changes then
        changes["any-change-always-first"]()
        if event.data.mod_changes[script.mod_name] then
            local this_mod_changes = event.data.mod_changes[script.mod_name]
            changes.on_mod_changed(this_mod_changes)
            log("Version changed from ".. tostring(this_mod_changes.old_version) .. " to " .. tostring(this_mod_changes.new_version), 2)
        end
        changes["any-change-always-last"]()
    end
    changes["map-change-always-last"]()
end

function changes.on_mod_changed(this_mod_changes)
    global._changes = global._changes or {}
    local old = this_mod_changes.old_version or MOD.version
    local migration_index = 1
    if old then -- Find the last installed version
        for i, ver in ipairs(migrations) do
            if old == ver and global._changes[ver] then
                --previous version found
                migration_index = i + 1
            end
        end
    end
    changes["mod-change-always-first"]()
    for i = migration_index, #migrations do
        if changes[migrations[i]] then
            changes[migrations[i]](this_mod_changes)
            global._changes[migrations[i]] = this_mod_changes.old_version or 0
            MOD.log("Migration completed for version ".. migrations[i], 1)
        end
    end
    changes["mod-change-always-last"]()
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--[[Always run these before any migrations]]
changes["map-change-always-first"] = function()
end

changes["any-change-always-first"] = function()
end

changes["mod-change-always-first"] = function()
end

-------------------------------------------------------------------------------
--[[Version change code make sure to include the version in
--migrations table above.]]--

--Major changes made
changes["2.0.0"] = function ()
    game.print("Autofill upgraded to version 2.0.0, Forcing full reset")
    global = {}
    Event.dispatch(Event.core_events.init)
end

-------------------------------------------------------------------------------
--[[Always run these at the end ]]--

changes["mod-change-always-last"] = function()
end

changes["any-change-always-last"] = function()
    -- autofill.sets.verify_default_sets()
    -- autofill.sets.update_and_verify_saved_sets()
end

changes["map-change-always-last"] = function()
end

-------------------------------------------------------------------------------
return changes
