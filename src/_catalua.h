#pragma once
#ifndef _CATALUA_H
#define _CATALUA_H

#include "action.h"
#include "fault.h"
#include "mapdata.h"
#include "ranged.h"
#include "active_item_cache.h"
#include "field.h"
#include "mapgen.h"
#include "recipe.h"
#include "activity_handlers.h"
#include "filesystem.h"
#include "mapgen_functions.h"
#include "recipe_dictionary.h"
#include "activity_type.h"
#include "fire.h"
#include "mapgenformat.h"
#include "recipe_groups.h"
#include "addiction.h"
#include "flag.h"
#include "mapsharing.h"
#include "rect_range.h"
#include "advanced_inv.h"
#include "font_loader.h"
#include "martialarts.h"
#include "regional_settings.h"
#include "ammo.h"
#include "fragment_cloud.h"
#include "material.h"
#include "requirements.h"
#include "anatomy.h"
#include "fungal_effects.h"
#include "math_defines.h"
#include "ret_val.h"
#include "animation.h"
#include "game.h"
#include "mattack_actors.h"
#include "rng.h"
#include "artifact.h"
#include "game_constants.h"
#include "mattack_common.h"
#include "rotatable_symbols.h"
#include "assign.h"
#include "game_inventory.h"
#include "melee.h"
#include "safemode_ui.h"
#include "auto_pickup.h"
#include "game_ui.h"
#include "messages.h"
#include "scenario.h"
#include "ballistics.h"
#include "gamemode.h"
#include "scent_map.h"
#include "basecamp.h"
#include "gates.h"
#include "mission.h"
#include "bionics.h"
#include "generic_factory.h"
#include "mission_companion.h"
#include "bodypart.h"
#include "get_version.h"
#include "mod_manager.h"
#include "shadowcasting.h"
#include "bonuses.h"
#include "gun_mode.h"
#include "mod_tileset.h"
#include "calendar.h"
#include "harvest.h"
#include "monattack.h"
#include "simple_pathfinding.h"
#include "cata_algo.h"
#include "help.h"
#include "mondeath.h"
#include "simplexnoise.h"
#include "iexamine.h"
#include "mondefense.h"
#include "skill.h"
#include "cata_utility.h"
#include "init.h"
#include "monexamine.h"
#include "skill_boost.h"
#include "catacharset.h"
#include "input.h"
#include "monfaction.h"
#include "sounds.h"
#include "cellular_automata.h"
#include "int_id.h"
#include "mongroup.h"
#include "speech.h"
#include "char_validity_check.h"
#include "inventory.h"
#include "monster.h"
#include "start_location.h"
#include "character.h"
#include "inventory_ui.h"
#include "monstergenerator.h"
#include "string_formatter.h"
#include "clzones.h"
#include "io.h"
#include "morale.h"
#include "string_id.h"
#include "color.h"
#include "io_tags.h"
#include "morale_types.h"
#include "string_input_popup.h"
#include "color_loader.h"
#include "item.h"
#include "mtype.h"
#include "submap.h"
#include "common_types.h"
#include "item_action.h"
#include "mutation.h"
#include "text_snippets.h"
#include "compatibility.h"
#include "item_category.h"
#include "name.h"
#include "tileray.h"
#include "computer.h"
#include "item_factory.h"
#include "npc.h"
#include "trait_group.h"
#include "construction.h"
#include "item_group.h"
#include "npc_class.h"
#include "translations.h"
#include "coordinate_conversions.h"
#include "item_location.h"
#include "npc_favor.h"
#include "trap.h"
#include "coordinates.h"
#include "item_search.h"
#include "npctalk.h"
#include "tuple_hash.h"
#include "craft_command.h"
#include "item_stack.h"
#include "npctrade.h"
#include "tutorial.h"
#include "crafting.h"
#include "iteminfo_query.h"
#include "omdata.h"
#include "ui.h"
#include "crafting_gui.h"
#include "itype.h"
#include "optional.h"
#include "uistate.h"
#include "crash.h"
#include "iuse.h"
#include "options.h"
#include "units.h"
#include "creature.h"
#include "iuse_actor.h"
#include "output.h"
#include "veh_interact.h"
#include "creature_tracker.h"
#include "iuse_software.h"
#include "overlay_ordering.h"
#include "veh_type.h"
#include "cursesdef.h"
#include "iuse_software_kitten.h"
#include "overmap.h"
#include "veh_utils.h"
#include "cursesport.h"
#include "iuse_software_lightson.h"
#include "overmap_connection.h"
#include "vehicle.h"
#include "damage.h"
#include "iuse_software_minesweeper.h"
#include "overmap_location.h"
#include "vehicle_group.h"
#include "debug.h"
#include "iuse_software_snake.h"
#include "overmap_types.h"
#include "vehicle_selector.h"
#include "debug_menu.h"
#include "iuse_software_sokoban.h"
#include "overmap_ui.h"
#include "dependency_tree.h"
#include "json.h"
#include "overmapbuffer.h"
#include "visitable.h"
#include "dialogue.h"
#include "lightmap.h"
#include "path_info.h"
#include "vitamin.h"
#include "dialogue_win.h"
#include "line.h"
#include "pathfinding.h"
#include "vpart_position.h"
#include "dispersion.h"
#include "live_view.h"
#include "pickup.h"
#include "vpart_range.h"
#include "drawing_primitives.h"
#include "loading_ui.h"
#include "pimpl.h"
#include "editmap.h"
#include "main_menu.h"
#include "platform_win.h"
#include "effect.h"
#include "map.h"
#include "player.h"
#include "emit.h"
#include "map_extras.h"
#include "player_activity.h"
#include "weather.h"
#include "enums.h"
#include "map_item_stack.h"
#include "pldata.h"
#include "weather_gen.h"
#include "event.h"
#include "map_iterator.h"
#include "popup.h"
#include "weighted_list.h"
#include "explosion.h"
#include "map_memory.h"
#include "posix_time.h"
#include "worldfactory.h"
#include "faction.h"
#include "map_selector.h"
#include "profession.h"
#include "projectile.h"
#include "pickup.h"
#include "panels.h"
#include "faction_camp.h"
#include "sounds.h"
#include "magic.h"
#include "handle_liquid.h"
#include "faction.h"
#include "behavior.h"
#include "avatar.h"
#include "scent_block.h"

#if defined(TILES)
#include "cata_tiles.h"
#include "pixel_minimap.h"
#endif // TILES

#include "lua/kaguya.hpp"

using namespace catacurses;
using namespace om_direction;
using namespace sounds;
using namespace Pickup;
using namespace behavior;
using namespace npc_factions;

extern std::stringstream lua_output_stream;
extern std::stringstream lua_error_stream;
extern bool lua_running_console;

void init_lua();
void dummy();
void _autogen_lua_register(kaguya::State &lua);

kaguya::State& get_luastate();
void lua_loadmod( const std::string &base_path, const std::string &main_file_name );
void register_iuse( const std::string type, const kaguya::LuaRef &f );
void register_monattack( const std::string type, const kaguya::LuaRef &f );
void add_msg_wrapper( const std::string &text );
void popup_wrapper( const std::string &text );
bool query_yn_wrapper( const std::string &text );
std::string string_input_popup_wrapper( const std::string &title, int width,
        const std::string &desc );
uilist *create_uilist();
uilist *create_uilist_no_cancel();
calendar &get_calendar_turn_wrapper();
time_duration get_time_duration_wrapper( const int t );
monster *get_monster_at( const tripoint & p );
Creature *get_critter_at( const tripoint & p );
npc *get_npc_at( const tripoint & p );
monster *create_monster( const mtype_id &mon_type, const tripoint &p );
std::string get_omt_id( const overmap &om, const tripoint &p );
const ter_t &get_terrain_type( int id );
cata::optional<tripoint> lua_global_choose_adjacent( const std::string & msg, const bool allow_vertical = false );

template<class T>
T* const_off( const T* ptr )
{
    return const_cast<T*>( ptr );
}
template<class T>
T& const_off( const T& ref )
{
    return const_cast<T&>( ref );
}

namespace kaguya
{
template <typename T>
struct lua_type_traits<cata::optional< T >> {
    typedef cata::optional< T > get_type;
    typedef const cata::optional< T > &push_type;
    static bool strictCheckType( lua_State *l, int index ) {
        return lua_type_traits<T>::strictCheckType( l, index );
    }
    static bool checkType( lua_State *l, int index ) {
        return lua_type_traits<T>::checkType( l, index );
    }
    static get_type get( lua_State *l, int index ) {
        const typename traits::remove_reference<T>::type *pointer = get_const_pointer(
                    l, index, types::typetag<typename traits::remove_reference<T>::type>() );
        if( !pointer ) {
            throw LuaTypeMismatch();
        }
        return *pointer;
    }
    static int push( lua_State *l, push_type v ) {
        if( !v ) {
            lua_pushnil( l );
            return 1;
        }
        return util::object_push( l, *v );
    }
};
}
#endif
