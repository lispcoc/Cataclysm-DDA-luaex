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
            kaguya::State &lua = get_luastate();
            
            try {
                lua["__cdda_lua_iuse_functions"]["__tmpret"] = lua["__cdda_lua_iuse_functions"][type]( &it, a, pos );
                try {
                    ret = lua["__cdda_lua_iuse_functions"]["__tmpret"];
                } catch( const std::exception & ) {
                    // do nothing
                }
            } catch( const std::exception &err ) {
                debugmsg( _( "Lua error: %1$s" ), err.what() );
            }
            return ret;
        }
        iuse_actor *clone() const override {
            return new lua_iuse_actor( *this );
        }
};

class lua_mattack_actor : public mattack_actor
{
    public:
        lua_mattack_actor( const mattack_id &id ) : mattack_actor( id ) { }
        ~lua_mattack_actor() override = default;

        bool call( monster &m ) const override {
            bool ret  = false;
            kaguya::State &lua = get_luastate();
            
            try {
                lua["__cdda_lua_mattack_functions"]["__tmpret"] = lua["__cdda_lua_mattack_functions"][id]( &m );
                try {
                    ret = lua["__cdda_lua_mattack_functions"]["__tmpret"];
                } catch( const std::exception & ) {
                    // do nothing
                }
            } catch( const std::exception &err ) {
                debugmsg( _( "Lua error: %1$s" ), err.what() );
            }
            return ret;
        }
        mattack_actor *clone() const override {
            return new lua_mattack_actor( *this );
        }
        void load_internal( JsonObject &, const std::string & ) override {}
};

kaguya::State *lua_ptr = nullptr;
bool lua_running_console = false;

// Keep track of the current mod from which we are executing, so that
// we know where to load files from.
std::string lua_file_path;

static std::unique_ptr<uilist> uilist_instance;

std::stringstream lua_output_stream;
std::stringstream lua_error_stream;

void _autogen_lua_global_bindings( kaguya::State &lua );

void Item_factory::add_actor_lua( iuse_actor *ptr )
{
    add_actor( ptr );
}

void MonsterGenerator::add_attack_lua( const mtype_special_attack &wrapper )
{
    add_attack( wrapper );
}

void game_myPrint( kaguya::VariadicArgType args )
{
    for( auto v : args ) {
        lua_output_stream << v.get<std::string>();
    }
    lua_output_stream << std::endl;
}

void lua_error_handler( int errCode, const char *szError )
{
    std::string error_str = szError;
    if( lua_running_console ) {
        lua_error_stream << "Lua error (" << errCode << "): " << error_str;
        return;
    }
    debugmsg( _( "Lua error (%d): %2$s" ), errCode, error_str );
}

void init_lua()
{
    if( lua_ptr != nullptr ) {
        delete lua_ptr;
    }
    lua_ptr = new kaguya::State;
    kaguya::State &lua = *lua_ptr;
    lua.setErrorHandler( lua_error_handler );

    _autogen_lua_register( lua );

    lua["__cdda_lua_iuse_functions"] = kaguya::NewTable();
    lua["__cdda_lua_mattack_functions"] = kaguya::NewTable();
    lua["__cdda_internal_functions"] = kaguya::NewTable();
    lua["__cdda_internal_functions"]["print"] = kaguya::function( game_myPrint );
    lua.dofile( "lua/autoexec.lua" );
}

kaguya::State &get_luastate()
{
    if( lua_ptr == nullptr ) {
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
        get_luastate().dofile( full_path );
        lua_file_path.clear();
    }
}

//
// Lua global functions
//
void register_iuse( const std::string type, const kaguya::LuaRef &f )
{
    kaguya::LuaTable tbl = get_luastate()["__cdda_lua_iuse_functions"];
    tbl[type] = f;
    item_controller->add_actor_lua( lua_iuse_actor( type ).clone() );
}

void register_monattack( const std::string type, const kaguya::LuaRef &f )
{
    kaguya::LuaTable tbl = get_luastate()["__cdda_lua_mattack_functions"];
    tbl[type] = f;
    auto actor = new lua_mattack_actor( type );
    MonsterGenerator::generator().add_attack_lua( mtype_special_attack( actor ) );
}

void add_msg_wrapper( const std::string &text )
{
    add_msg( text );
}

void popup_wrapper( const std::string &text )
{
    popup( "%s", text.c_str() );
}

bool query_yn_wrapper( const std::string &text )
{
    return query_yn( text );
}

std::string string_input_popup_wrapper( const std::string &title, int width,
                                        const std::string &desc )
{
    return string_input_popup().title( title ).width( width ).description( desc ).query_string();
}

uilist *create_uilist()
{
    uilist_instance.reset( new uilist() );
    return uilist_instance.get();
}

uilist *create_uilist_no_cancel()
{
    uilist_instance.reset( new uilist() );
    uilist_instance->allow_cancel = false;
    return uilist_instance.get();
}

calendar &get_calendar_turn_wrapper()
{
    return calendar::turn;
}

time_duration get_time_duration_wrapper( const int t )
{
    return time_duration::from_turns( t );
}

monster *get_monster_at( const tripoint &p )
{
    return g->critter_at<monster>( p );
}

Creature *get_critter_at( const tripoint &p )
{
    return g->critter_at<Creature>( p );
}

npc *get_npc_at( const tripoint &p )
{
    return g->critter_at<npc>( p );
}

monster *create_monster( const mtype_id &mon_type, const tripoint &p )
{
    monster new_monster( mon_type, p );
    if( !g->add_zombie( new_monster ) ) {
        return nullptr;
    } else {
        return g->critter_at<monster>( p );
    }
}

std::string get_omt_id( const overmap &om, const tripoint &p )
{
    return om.get_ter( p ).id().str();
}

const ter_t &get_terrain_type( int id )
{
    return ter_id( id ).obj();
}

//
// Dummy functions
//
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
