# Lua MOD作成ガイド

本ビルド向けにLuaを使用したMODを作成する際のガイドおよび注意事項を記載します。

## Luaコールバック

0.D安定板同様のものが使用できます。

## アイテム使用時のLuaスクリプト

0.D安定板同様のものが使用できます。

## モンスターの特殊攻撃のLuaスクリプト

0.D安定板同様のものが使用できます。

## C++クラスのLuaへの公開状況

同梱のlua/lua_classes.luaを参照してください。  
クラス関数・変数へのアクセスの仕方は0.D安定版と同じように行えます。  
※引数や戻り値の名前にC++のconstや&、*等の修飾子がついていますが、  
これらはコード生成上の都合で付けているものなのでLuaから呼び出すときは無視してください。  

## C++のEnum(定数型)の使用方法

Enumはグローバル変数enumsにテーブルとして格納されます。  
body_partであれば「enums.body_part.bp_torso」のように読み出せます。  
どのような定数があるかはlua/lua_classes.luaを参照してください。  
定数型を関数に対して渡す際は以下の2つの記法が使えます。  

````lua
bash = player:get_armor_bash("bp_torso") -- 文字列を渡す方法(0.D安定板互換)
bash = player:get_armor_bash(enums.body_part.bp_torso) -- 数値を渡す方法(0.D安定板非互換)
````

## 0.D安定板との互換について

本体側の更新でクラスや関数の仕様が変更・削除されることがある都合上、完全な互換はありません。  
(過去の関数で重要なものが削除された場合、少ない労力で再実装できそうな場合は本ビルドで対応する可能性あり)  
0.D安定板と本ビルドの両方で使用できるMODを作成したい場合は、片方にしか存在しない関数を使用しないなどの工夫が必要です。

## 参考情報

0.D安定板で使用できた以下の関数は使用できません。(0.D-8973時点)

- monster:melee_attack
- ter_t:color
- ter_t:name
- ter_t:symbol
- Character:get_stomach_food
- Character:get_stomach_water
- Character:set_stomach_food
- Character:set_stomach_water
- Character:mod_stomach_food
- Character:mod_stomach_water
- npc_template_id:obj
- map_stack:cppbegin
- map_stack:cppend
- furn_t:color
- furn_t:name
- furn_t:symbol
- npc:is_friend
- game:do_blast
- game:draw_explosion
- game:emp_blast
- game:explosion
- game:flashbang
- game:handle_liquid
- game:inventory_item_menu
- game:nuke
- game:resonance_cascade
- game:scrambler_blast
- game:shockwave
- game:explosion
- game:explosion
- game:explosion
- game:explosion
- game:flashbang
- game:flashbang
- game:inventory_item_menu
- game:inventory_item_menu
- game:inventory_item_menu
- map:allow_camp
- map:has_adjacent_furniture
- player:melee_attack
- player:toggle_move_mode
