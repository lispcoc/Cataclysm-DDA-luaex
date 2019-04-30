#define SOL_CHECK_ARGUMENTS 1
#include <cassert>
#include <iostream>
#include <set>
#include <string>
#include <type_traits>
#include <functional>

#include "_catalua.h"

kaguya::State *lua_ptr = nullptr;
void _autogen_lua_global_bindings(kaguya::State &lua);

auto dummy_gun_mode = gun_mode();
template<>
const gun_mode &string_id<gun_mode>::obj() const
{
    return dummy_gun_mode;
}
template<>
bool string_id<gun_mode>::is_valid() const
{
    return false;
}
template<>
bool string_id<activity_type>::is_valid() const
{
    return false;
}

void lua_error_handler( int errCode, const char * szError )
{
    std::string error_str = szError;
    debugmsg( _( "Lua error (%d): %2$s" ), errCode, error_str );
}

void init_lua()
{
    if(lua_ptr != nullptr){
        delete lua_ptr;
    }
    lua_ptr = new kaguya::State;
    kaguya::State &lua = *lua_ptr;
    lua.setErrorHandler(lua_error_handler);

    _autogen_lua_register(lua);

    lua.dofile("test.lua");
}

kaguya::State& get_luastate()
{
    if( lua_ptr == nullptr ){
        throw std::runtime_error( "Lua State is not found." );
    }
    kaguya::State &lua = *lua_ptr;
    // update Lua global values
    _autogen_lua_global_bindings(lua);
    return lua;
}

void register_iuse( const std::string, kaguya::LuaFunction )
{
    printf("to be done");
}

#if 0 //LUAINTF test
#define LUAINTF_LINK_LUA_COMPILED_IN_CXX 0
#include "LuaIntf/LuaIntf.h"
#include "lua/sol.hpp"

//#define LUA_MEMFN(t, r, m, ...) static_cast<r(t::*)(__VA_ARGS__)>(&t::m)
#define LUA_MEMFN_CONST(t, r, m, ...) static_cast<r(t::*)(__VA_ARGS__) const>(&t::m)

void dummy()
{
    sol::state lua;
    lua.open_libraries(sol::lib::base, sol::lib::math);
    sol::table metatable;
    lua_State *L = lua.lua_state();
    #include "lua/lua_bindings.cpp"
}
#endif