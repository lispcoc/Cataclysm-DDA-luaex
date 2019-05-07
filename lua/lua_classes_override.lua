classes_override = {
    Character = {
        functions = {
            { name = "find_parent", rval = "item *", args = { "const item &" }, const = false, static = false, },
            { name = "find_parent", rval = "const item *", args = { "const item &" }, const = true, static = false, },
            { name = "parents", rval = "std::vector<item *>", args = { "const item &" }, const = false, static = false, },
            { name = "parents", rval = "std::vector<const item *>", args = { "const item &" }, const = true, static = false, },
            { name = "has_item", rval = "bool", args = { "const item &" }, const = true, static = false, },
            { name = "has_quality", rval = "bool", args = { "const quality_id &" }, optional_args = { "int", "int" }, const = true, static = false, },
            { name = "max_quality", rval = "int", args = { "const quality_id &" }, const = true, static = false, },
            { name = "charges_of", rval = "long", args = { "const std::string &",  }, optional_args = { "long", "const std::function<bool( const item & )> &" }, const = true, static = false, },
            { name = "amount_of", rval = "int", args = { "const std::string &",  }, optional_args = { "bool", "int", "const std::function<bool( const item & )> &" }, const = true, static = false, },
            { name = "has_amount", rval = "bool", args = { "const std::string &", "int" }, optional_args = { "bool", "const std::function<bool( const item & )> &" }, const = true, static = false, },
            { name = "remove_item", rval = "item", args = { "item &",  }, const = false, static = false, },
        }
    },
    item = {
        functions = {
            { name = "find_parent", rval = "item *", args = { "const item &" }, const = false, static = false, },
            { name = "find_parent", rval = "const item *", args = { "const item &" }, const = true, static = false, },
            { name = "parents", rval = "std::vector<item *>", args = { "const item &" }, const = false, static = false, },
            { name = "parents", rval = "std::vector<const item *>", args = { "const item &" }, const = true, static = false, },
            { name = "has_item", rval = "bool", args = { "const item &" }, const = true, static = false, },
            { name = "has_quality", rval = "bool", args = { "const quality_id &" }, optional_args = { "int", "int" }, const = true, static = false, },
            { name = "max_quality", rval = "int", args = { "const quality_id &" }, const = true, static = false, },
            { name = "charges_of", rval = "long", args = { "const std::string &",  }, optional_args = { "long", "const std::function<bool( const item & )> &" }, const = true, static = false, },
            { name = "amount_of", rval = "int", args = { "const std::string &",  }, optional_args = { "bool", "int", "const std::function<bool( const item & )> &" }, const = true, static = false, },
            { name = "has_amount", rval = "bool", args = { "const std::string &", "int" }, optional_args = { "bool", "const std::function<bool( const item & )> &" }, const = true, static = false, },
            { name = "remove_item", rval = "item", args = { "item &",  }, const = false, static = false, },
        }
    },
    lua_game = {
        functions = {
            { name = "critter_by_id", cpp_name = "critter_by_id<Creature>", rval = "Creature *", args = { "int", }, const = false, static = false, },
            { name = "critter_at", cpp_name = "critter_at<Creature>", rval = "Creature *", args = { "const tripoint &", }, optional_args = { "bool", }, const = false, static = false, },
            { name = "critter_at", cpp_name = "critter_at<Creature>", rval = "const Creature *", args = { "const tripoint &", }, optional_args = { "bool", }, const = true, static = false, },
        }
    },
    units__volume = {
        cpp_name = "units::volume",
        new = {
            { },
        },
        attributes = {
        },
        functions = {
            { name = "value", rval = "const int &", args = { }, const = true, static = false, },
        }
    },
    units__mass = {
        cpp_name = "units::mass",
        new = {
            { },
        },
        attributes = {
        },
        functions = {
            { name = "value", rval = "const int &", args = { }, const = true, static = false, },
        }
    },
}

for key, data in pairs(classes_override) do
    if classes[key] then
        if data.functions then
            for _, func in pairs(data.functions) do
                table.insert(classes[key].functions, func)
            end
        end
    else
        classes[key] = data
    end
end
