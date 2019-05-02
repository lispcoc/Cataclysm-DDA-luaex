function test(a,b,c)
    map:add_item(player:pos(),item("lua_test_item"))
    player:mutate()
    position = player:pos()
    position.x =position.x +1 
    player:setpos(position)
    return 0
end

register_iuse("lua_test",test)
