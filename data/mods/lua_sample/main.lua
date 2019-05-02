local MOD = {}
mods["lua_sample"] = MOD

log.message("main")

function MOD.on_turn_passed()
    game.add_msg("[Lua][callback]: on_turn_passed")
end

function MOD.on_minute_passed()
    game.add_msg("[Lua][callback]: on_minute_passed")
end

function MOD.on_hour_passed()
    game.add_msg("[Lua][callback]: on_hour_passed")
end

function MOD.on_day_passed()
    game.add_msg("[Lua][callback]: on_day_passed")
end

function MOD.on_year_passed()
    game.add_msg("[Lua][callback]: on_year_passed")
end
