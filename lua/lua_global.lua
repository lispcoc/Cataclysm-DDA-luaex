global_references = {
    g = { cpp_name = "g.get()", type = "game &", },
    map = { cpp_name = "kaguya::standard::ref(g->m)", type = "map &", },
    player = { cpp_name = "g->u", type = "player &", },
}

global_functions = {
    { name = "register_iuse", rval = "void", args = { "const std::string", "kaguya::LuaFunction", }, },
}
