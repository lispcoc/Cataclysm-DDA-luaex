dofile("lua/lua_classes.lua")
dofile("lua/lua_classes_override.lua")

-- This adds the int_id wrappers from the class definition as real classes.
-- All int_id<T>s have the same interface, so we only need to add some mark to T, that this class
-- T has an int_id of some name.
-- In the class definition: add "int_id" = "XXX" (XXX is the typedef id that is used by C++).
local new_classes = {}
for name, value in pairs(classes) do
    if value.int_id then
        -- This is the common int_id<T> interface:
        local t = {
            by_value = true,
            has_equal = true,
            -- IDs *could* be constructed from int, but where does the Lua script get the int from?
            -- The int is only exposed as int_id<T>, so Lua should never know about it.
            attributes = { },
            -- Copy and default constructor
            new = { { value.int_id }, { } },
            functions = {
                -- Use with care, only for displaying the value for debugging purpose!
                { name = "to_i", rval = "int", args = { } },
                { name = "obj", rval = name .. "&", args = { } },
            }
        }
        if value.string_id then
            -- Allow conversion from int_id to string_id
            t[#t.functions] = { name = "id", rval = value.string_id, args = { } }
            -- And creation of an int_id from a string_id
            t.new = { { value.string_id }, { } }
        end
        new_classes[value.int_id] = t
    end
    -- Very similar to int_id above
    if value.string_id then
        local t = {
            by_value = true,
            has_equal = true,
            -- Copy and default constructor and construct from plain string.
            new = { { value.string_id }, { }, { "string" } },
            attributes = { },
            functions = {
                { name = "str", rval = "string", args = { } },
                { name = "is_valid", rval = "bool", args = { } },
                { name = "obj", rval = name .. "&", args = { } },
            }
        }
        if value.int_id then
            t.functions[#t.functions] = { name = "id", rval = value.int_id, args = { } }
        end
        new_classes[value.string_id] = t
    end
end
for name, value in pairs(new_classes) do
    classes[name] = value
end
new_classes = classes

dofile("lua-build-scripts/class_definitions.lua")
local old_classes = classes

local miss_class = {}
local miss_func = {}

function class_name_map(old_name)
    local map = {
        game = "lua_game",
        volume = "units__volume",
        mass = "units__mass",
    }
    if map[old_name] then
        return map[old_name]
    end
    return old_name
end

function search_func(cls, func_name)
    local found = false
    for _, f in ipairs(cls.functions) do
        if func_name == f.name then
            found = true
            break
        end
    end
    if (not found) and (cls.parent) then
        found = search_func(new_classes[cls.parent], func_name)
    end
    return found
end

for name, cls in pairs(old_classes) do
    new_cls = new_classes[class_name_map(name)]
    if not new_cls then
        table.insert(miss_class, name)
    else
        for _, f1 in ipairs(cls.functions) do
            local found = search_func(new_cls, f1.name)
            if not found then
                table.insert(miss_func, name .. ':' .. f1.name)
            end
        end
    end
end

print("Missing classes: ")
for _, v in ipairs(miss_class) do
    print("    " .. v)
end

print("Missing functions: ")
for _, v in ipairs(miss_func) do
    print("    " .. v)
end
