global_references = {
    g = { cpp_name = "g.get()", type = "game *", },
    map = { cpp_name = "&g->m", type = "map *", },
    player = { cpp_name = "&g->u", type = "player *", },
}

global_functions = {
    { name = "register_iuse", rval = "void", args = { "const std::string", "const kaguya::LuaRef", }, },
    { name = "add_msg", cpp_name = "add_msg_wrapper", rval = "void", args = { "std::string", }, },
}
