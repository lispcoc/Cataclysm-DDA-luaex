cd lua
python gen_lua_classes.py > lua_classes.lua
cd ..
lua lua/gen_bindings.lua > src/lua/lua_bindings.cpp
