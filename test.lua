
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

function test(a,b,c)
    map:add_item(player:pos(),item("lua_test_item"))
    player:mutate()
    position = player:pos()
    position.x =position.x +1 
    player:setpos(position)
    return 0
end

register_iuse("lua_test",test)
