#define SOL_CHECK_ARGUMENTS 1
#include <cassert>
#include <iostream>
#include <set>
#include <string>
#include <type_traits>
#include <functional>

#include "_catalua.h"

class lua_iuse_actor : iuse_actor
{
    public:
        lua_iuse_actor( const std::string &type ) : iuse_actor( type ) { }
        ~lua_iuse_actor() override = default;

        void load( JsonObject & ) override {}
        long use( player &, item &it, bool a, const tripoint &pos ) const override {
            long ret  = 0;
            try {
                ret = get_luastate()["__cdda_lua_iuse_functions"][type](it, a, pos);
            } catch( const std::exception &err ) {
                debugmsg( _( "Lua error: %1$s" ), err.what() );
            }
            return ret;
        }
        iuse_actor *clone() const override {
            return new lua_iuse_actor( *this );
        }
};

kaguya::State *lua_ptr = nullptr;

// Keep track of the current mod from which we are executing, so that
// we know where to load files from.
std::string lua_file_path;

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

    lua["__cdda_lua_iuse_functions"] = kaguya::NewTable();
    lua.dofile("lua/autoexec.lua");
}

kaguya::State& get_luastate()
{
    if( lua_ptr == nullptr ){
        throw std::runtime_error( "Lua State is not found." );
    }
    kaguya::State &lua = *lua_ptr;
    // update Lua global values
    //_autogen_lua_global_bindings(lua);
    return lua;
}

void lua_loadmod( const std::string &base_path, const std::string &main_file_name )
{
    std::string full_path = base_path + "/" + main_file_name;
    if( file_exist( full_path ) ) {
        lua_file_path = base_path;
        get_luastate().dofile(full_path);
        lua_file_path.clear();
    }
}

void register_iuse( const std::string type, const kaguya::LuaRef &f )
{
    kaguya::LuaTable tbl = get_luastate()["__cdda_lua_iuse_functions"];
    tbl[type] = f;
    item_controller->add_actor_lua( lua_iuse_actor( type ).clone() );
}

void Item_factory::add_actor_lua( iuse_actor *ptr )
{
    add_actor( ptr );
}

//
// Dummy functions
//
int player::calories_for( const item & ) const
{
    return 0;
}
