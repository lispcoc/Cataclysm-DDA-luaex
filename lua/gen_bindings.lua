dofile("lua/lua_classes.lua")

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function gen_constructors(cls_cpp_name, t, indent)
    indent = indent or ''
    constructors = {}
    for key, args in pairs(t) do
        str = cls_cpp_name .. '(' .. table.concat(args, ', ') .. ')'
        table.insert(constructors, str)
    end
    return indent .. 'sol::constructors<' .. table.concat(constructors, ', ') .. '>()'
end

function gen_attributes(cls_cpp_name, t, indent)
    indent = indent or ''
    attributes = {}
    for name, data in pairs(t) do
        if not data.reference then
            str = ""
            if data.static then
                -- not support
            else
                if data.writable then
                    str = indent .. '.addProperty("' .. name .. '", &' .. cls_cpp_name .. '::' .. name .. ')'
                else
                    str = indent .. '.addProperty("' .. name .. '", &' .. cls_cpp_name .. '::' .. name .. ')'
                end
            end
            if str ~= "" then
                table.insert(attributes, str)
            end
        end
    end
    return attributes
end

function gen_functions(cls_cpp_name, t, indent)
    indent = indent or ''
    lines = {}
    functions = {}
    -- check overloaded functions
    for key, data in ipairs(t) do
        name = data.name
        if data.static then
            --not supported
        else
            if not functions[name] then
                functions[name] = {}
            end
            table.insert(functions[name], data)
        end
    end
    for key, data_list in pairs(functions) do
        str = ''
        name = data_list[1].name
        func_str_list = {}
        for _, data in ipairs(data_list) do
            func_str = 'static_cast<' .. data.rval .. '('
            func_str = func_str .. cls_cpp_name .. '::'
            func_str = func_str .. '*)('
            if data.optional_args then
                all_args = TableConcat(data.args, data.optional_args)
            else
                all_args = data.args 
            end
            arg_str = table.concat(all_args, ', ')
            func_str = func_str .. arg_str .. ')'
            if data.const then
                func_str = func_str .. ' const'
            end
            func_str = func_str .. '>(&' .. cls_cpp_name .. '::' .. name .. ')'
            table.insert(func_str_list, func_str)
        end
        if #func_str_list == 1 then
            str = indent .. '.addFunction("' .. name .. '", '
        else
            str = indent .. '.addOverloadedFunctions("' .. name .. '", '
        end
        str = str .. table.concat(func_str_list, ',') .. ')'
        if str ~= '' then
            table.insert(lines, str)
        end
    end
    return lines
end

-- generate string_id
string_id_classes = {}
for key, cls in pairs(classes) do
    if cls.string_id then
        new_t = {
            cpp_name = cls.string_id,
            new = {
                {cls.string_id},
                {},
                {"std::string"},
            },
            attributes = {},
            functions = {
                {name = "str", rval = "const std::string &", args = {}, const = true},
                {name = "is_valid", rval = "bool", args = {}, const = true},
                {name = "obj", rval = 'const ' .. cls.cpp_name .. "&", args = {}, const = true},
            },
        }
        table.insert(string_id_classes, new_t)
    end
end
for key, cls in pairs(string_id_classes) do
    classes[cls.cpp_name] = cls
end

-- generate int_id
int_id_classes = {}
for key, cls in pairs(classes) do
    if cls.int_id then
        new_t = {
            cpp_name = cls.int_id,
            new = {
                {cls.int_id},
                {},
            },
            attributes = {},
            functions = {
                {name = "to_i", rval = "int", args = {}, const = true},
                {name = "obj", rval = 'const ' .. cls.cpp_name .. "&", args = {}, const = true},
            },
        }
        table.insert(int_id_classes, new_t)
    end
end
for key, cls in pairs(int_id_classes) do
    classes[cls.cpp_name] = cls
end

keys = {}
for key,_ in pairs(classes) do
    table.insert(keys, key)
end
table.sort(keys, function(a,b) return string.lower(a) < string.lower(b) end)

string_ids = {}

cpp_template_header = {
    '#include "../_catalua.h"',
}

autogen_functions = {}

for _, key in pairs(keys) do
    value = classes[key]
    lines = {}
    table.insert(lines, 'lua["' .. key .. '"].setClass(kaguya::UserdataMetatable<' .. value.cpp_name .. '>()')
    lines = TableConcat(lines, gen_attributes(value.cpp_name, value.attributes, '    '))
    lines = TableConcat(lines, gen_functions(value.cpp_name, value.functions, '    '))
    table.insert(lines, '    );')
    f_str = '_autogen_lua_' .. key .. '_bindings'
    table.insert(autogen_functions, f_str)

    f = io.open("src/lua/" .. key .. "_bindings.cpp", "w")
    f:write(table.concat(cpp_template_header, '\n') .. '\n\n')
    f:write('void ' .. f_str .. '(kaguya::State &lua)\n')
    f:write('{\n')
    f:write('    ' .. table.concat(lines, '\n    ') .. '\n')
    f:write('}\n')
    f:close()
end
f = io.open("src/lua/_autogen_lua_register.cpp", "w")
f:write(table.concat(cpp_template_header, '\n') .. '\n\n')
for _, f_str in ipairs(autogen_functions) do
    f:write('void ' .. f_str .. '(kaguya::State &lua);\n')
end
f:write('\n')
f:write('void _autogen_lua_register(kaguya::State &lua)\n')
f:write('{\n')
for _, f_str in ipairs(autogen_functions) do
    f:write('    ' .. f_str .. '(lua);\n')
end
f:write('}\n')
f:close()
