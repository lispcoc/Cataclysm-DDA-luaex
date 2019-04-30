
function on_turn_passed()
    print(player:pos().x,player:pos().y,player:pos().z)
end
function on_minute_passed()
end
function on_hour_passed()
end
function on_day_passed()
end
function on_year_passed()
end
register_iuse("a",on_minute_passed)
