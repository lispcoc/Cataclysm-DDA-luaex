template<>  struct lua_type_traits<###cpp_name###> {
	typedef ###cpp_name### get_type;
	typedef const ###cpp_name###& push_type;

    static bool strictCheckType(lua_State *l, int index) {
        return lua_type_traits<luaInt>::strictCheckType(l, index);
    }
    static bool checkType(lua_State *l, int index) {
        return lua_type_traits<luaInt>::checkType(l, index);
    }
	static get_type get(lua_State* l, int index)
	{
		size_t size = 0;
		const char* buffer = lua_tolstring(l, index, &size);
        if (buffer) {
            std::string s = std::string(buffer, size);
            std::cout << s << std::endl;
            kaguya::State& lua = get_luastate();
            if(lua["enums"]["###name###"][s] != kaguya::NilValue()){
                return lua["enums"]["###name###"][s];
            }
        }
		return static_cast<get_type>(lua_type_traits<luaInt>::get(l, index));
	}
    static int push(lua_State *l, push_type s) {
        return util::push_args(l, static_cast<typename lua_type_traits<int64_t>::push_type>(s));
    }
};
