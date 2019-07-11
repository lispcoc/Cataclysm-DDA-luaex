package.path = package.path .. ";./lua/?.lua" --Windows/Linux
package.path = package.path .. ";/usr/share/cataclysm-dda/lua/?.lua" --Linux(via make install)

log = require("log")
log.init("./config/lua-log.log")

-- lua5.2 compatibility
unpack = table.unpack or unpack

if not math.pow then
    math.pow = function (x, y)
        return x^y
    end
end

print = function(...)
    local arg = {...}
    for k, v in ipairs(arg) do
        arg[k] = tostring(v)
    end
    __cdda_internal_functions.print(unpack(arg))
end

-- table containing our mods
mods = { }

-- mod callback
function mod_callback(callback_name, ...)
    rval = nil
    for modname, mod_instance in pairs(mods) do
        if type(mod_instance[callback_name]) == "function" then
            rval = mod_instance[callback_name](...)
        end
    end
    return rval
end

function resolve_name(name)
    local a = _G
    for key in string.gmatch(name, "([^%.]+)(%.?)") do
        if a[key] then
            a = a[key]
        else
            return nil
        end
    end
    return a
end

function function_exists(name)
    return type(resolve_name(name)) == 'function'
end

function table_length(name)
  local length = 0
  if (name ~= nil) then
      for _ in pairs(name) do
        length = length + 1
      end
  end
  return length
end

-- Constructs `time_duration` with given `int` value (which is number of turns). 
function TURNS(turns)
    if( function_exists( "game.get_time_duration" ) ) then
        return game.get_time_duration( turns )
    else
        return nil
    end
end

function MINUTES(turns)
    if( function_exists( "game.get_time_duration" ) ) then
        return game.get_time_duration( turns * 60 )
    else
        return nil
    end
end

function HOURS(turns)
    if( function_exists( "game.get_time_duration" ) ) then
        return game.get_time_duration( turns * 60 * 60 )
    else
        return nil
    end
end

function DAYS(turns)
    if( function_exists( "game.get_time_duration" ) ) then
        return game.get_time_duration( turns * 60 * 60 * 24 )
    else
        return nil
    end
end
