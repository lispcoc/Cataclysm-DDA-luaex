package.path = package.path .. ";./lua/?.lua" --Windows/Linux
package.path = package.path .. ";/usr/share/cataclysm-dda/lua/?.lua" --Linux(via make install)

log = require("log")
log.init("./config/lua-log.log")

-- table containing our mods
mods = { }

function mod_callback(callback_name, ...)
    rval = nil
    for modname, mod_instance in pairs(mods) do
        if type(mod_instance[callback_name]) == "function" then
            rval = mod_instance[callback_name](...)
        end
    end
    return rval
end
