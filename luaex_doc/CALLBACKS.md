# Callbacks

Following Lua-callbacks exist.

__Note for `player_id`:__ Value of -1 (when game is not started) or 1 (when game is started) are used for player character, values bigger than 1 are used for npcs.

## game-related

### `on_savegame_loaded()`

Runs when saved game is loaded.

### `on_new_player_created()`

Runs when new player is created;

## calendar-related

### `on_turn_passed()`

Runs once each turn.

### `on_minute_passed()`

Runs once per minute.

### `on_hour_passed`
Runs once per hour (at the beginning of the hour).

### `on_day_passed()`

Runs once per day (at midnight).

### `on_year_passed()`

Runs once per year (on first day of the year at midnight).

## player and npc-related

### `on_player_skill_increased(player_id, source, skill_id, level)`

Runs whenever player or npc skill is increased.

| argument   | type   | Description
|---         |---     |---
| player_id  | int    | Unique ID. 
| source     | string | Source of skill increase.
| skill_id   | string | Skill ID.
| level      | int    | Skill level.

### `on_skill_increased()`

Runs whenever player or npc skill is increased. This is legacy callback functon.

### `on_player_dodge(player_id, source, difficulty)`

Runs whenever player or npc have dodged.

| argument   | type      | Description
|---         |---        |---
| player_id  | int       | Unique ID. 
| source     | Creature& | Source of attack.
| difficulty | float     | Difficulty of dodge.

### `on_player_hit(player_id, source, bp)`

Runs whenever player or npc were hit.

| argument   | type      | Description
|---         |---        |---
| player_id  | int       | Unique ID. 
| source     | Creature& | Source of attack.
| bp         | body_part | Attacked body part.

### `on_player_hit(player_id, source, body_part)`

Runs whenever player or npc were hurt.

| argument   | type      | Description
|---         |---        |---
| player_id  | int       | Unique ID. 
| source     | Creature& | Source of attack.
| disturb    | bool      | Whether you were disturbed.

### `on_player_mutation_gain(player_id, mutation_id)`

Runs whenever player or npc gains mutation.

| argument    | type      | Description
|---          |---        |---
| player_id   | int       | Unique ID. 
| mutation_id | string    | mutation ID.

### `on_player_mutation_loss(player_id, mutation_id)`

Runs whenever player or npc loses mutation.

| argument    | type      | Description
|---          |---        |---
| player_id   | int       | Unique ID. 
| mutation_id | string    | mutation ID.

### `on_player_stat_change(player_id, stat_id, stat_value)`

Runs whenever player or npc stats are changed.

| argument    | type      | Description
|---          |---        |---
| player_id   | int       | Unique ID. 
| stat_id     | string    | Stat ID.
| stat_value  | int       | New stat value.

### `on_player_effect_int_changes(player_id, effect_id, intensity, bp)`

Runs whenever intensity of effect on player or npc has changed.

| argument    | type      | Description
|---          |---        |---
| player_id   | int       | Unique ID. 
| effect_id   | string    | Effect ID.
| intensity   | int       | New intensity.
| bp          | body_part | Body part.

### `on_player_item_wear(player_id, it)`

Runs whenever player or npc wears some clothes on.

| argument    | type      | Description
|---          |---        |---
| player_id   | int       | Unique ID. 
| it          | item&     | Item you wear.

### `on_player_item_takeoff(player_id, it)`

Runs whenever player or npc takes some clothes off.

| argument    | type      | Description
|---          |---        |---
| player_id   | int       | Unique ID. 
| it          | item&     | Item you take off.

### `on_player_item_takeoff(player_id, mission_id)`

Runs whenever player or npc is assigned to mission.

| argument    | type      | Description
|---          |---        |---
| player_id   | int       | Unique ID. 
| mission_id  | int       | Mission ID.

### `on_mission_finished(player_id, mission_id)`

Runs whenever player or npc finishes the mission.

| argument    | type      | Description
|---          |---        |---
| player_id   | int       | Unique ID. 
| mission_id  | int       | Mission ID.

## player activity-related

__Note:__ Following functions can not be called from mod-added player activity now.

### `on_activity_call_do_turn_started(act_id, player_id)`

Runs whenever player activity turn started.

| argument    | type      | Description
|---          |---        |---
| act_id      | string    | Activity ID.
| player_id   | int       | Unique ID. 

### `on_activity_call_do_turn_finished(act_id, player_id)`

Runs whenever player activity turn ended.

| argument    | type      | Description
|---          |---        |---
| act_id      | string    | Activity ID.
| player_id   | int       | Unique ID. 

### `on_activity_call_finish_started(act_id, player_id)`

Runs whenever player activity finish started.

| argument    | type      | Description
|---          |---        |---
| act_id      | string    | Activity ID.
| player_id   | int       | Unique ID. 

### `on_activity_call_finish_finished(act_id, player_id)`

Runs whenever player activity finish ended.

| argument    | type      | Description
|---          |---        |---
| act_id      | string    | Activity ID.
| player_id   | int       | Unique ID. 

