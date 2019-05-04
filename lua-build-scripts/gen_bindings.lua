dofile("lua/lua_classes.lua")
dofile("lua/lua_global.lua")

function TableConcat(t1,t2)
    local t3 = {}
    for i=1,#t1 do
        t3[i] = t1[i]
    end
    for i=1,#t2 do
        t3[#t1+i] = t2[i]
    end
    return t3
end

function gen_constructors(cls_cpp_name, t, indent)
    indent = indent or ''
    constructors = {}
    for key, args in pairs(t) do
        str = cls_cpp_name .. '(' .. table.concat(args, ', ') .. ')'
        table.insert(constructors, str)
    end
    if #constructors == 0 then
        return nil
    else
        return indent .. '.setConstructors<' .. table.concat(constructors, ', ') .. '>()'
    end
end

function gen_ref_attributes_wrappar(cls_cpp_name, t, indent)
    indent = indent or ''
    local attributes = {}
    for name, data in pairs(t) do
        local str = ""
        local type_def = data.type
        if data.reference then
            if not data.writable then
                type_def = 'const ' .. type_def
            end
            str = indent .. type_def .. '* __get_' .. name .. '(const ' .. cls_cpp_name .. '* self){ return &self->' .. name .. '; }'
        elseif data.static then
            str = indent .. type_def .. ' __get_' .. name .. '(const ' .. cls_cpp_name .. '*){ return ' .. cls_cpp_name .. '::' .. name .. '; }'
        end
        if str ~= "" then
            table.insert(attributes, str)
        end
end
    return attributes
end

function gen_attributes(cls_cpp_name, t, indent)
    indent = indent or ''
    attributes = {}
    for name, data in pairs(t) do
        str = ""
        if data.reference or data.static then
            str = indent .. '.addProperty("' .. name .. '", __get_' .. name .. ')'
        else
            str = indent .. '.addProperty("' .. name .. '", &' .. cls_cpp_name .. '::' .. name .. ')'
        end
        if str ~= "" then
            table.insert(attributes, str)
        end
end
    return attributes
end

function gen_wrappar_functions(cls_cpp_name, t, indent)
    indent = indent or ''
    local lines = {}
    local functions = {}
    fn = 0
    -- check overloaded functions
    for key, data in ipairs(t) do
        name = data.name
        if not functions[name] then
            functions[name] = {}
        end
        table.insert(functions[name], data)
    end
    for key, data_list in pairs(functions) do
        local str = ''
        local name = data_list[1].name
        local cpp_name = data_list[1].cpp_name or name
        local func_str_list = {}
        local fon = 0
        for _, data in ipairs(data_list) do
            -- generate cast to resolve overloaded function
            cast = ''
            all_args = {}
            if not string.match (cpp_name, "^operator") then
                cast = data.rval .. '('
                if not data.static then
                    cast = cast .. cls_cpp_name .. '::'
                end
                cast = cast .. '*)('
                if data.optional_args then
                    all_args = TableConcat(data.args, data.optional_args)
                else
                    all_args = data.args 
                end
                arg_str = table.concat(all_args, ', ')
                cast = cast .. arg_str .. ')'
                if data.const then
                    cast = cast .. ' const'
                end
            end
            arg_n = 0
            if data.args then
                arg_n = #data.args
            end
            opt_n = arg_n
            if data.optional_args then
                opt_n = arg_n + #data.optional_args
            end
            func_str = cpp_name
            if cast == '' then
                if not data.static then
                    func_str = 'KAGUYA_MEMBER_FUNCTION_OVERLOADS(' .. cls_cpp_name .. '__' .. name .. '_wrappar_' .. fon ..', ' .. cls_cpp_name .. ', ' .. func_str ..', ' .. arg_n ..',' .. opt_n ..')'
                else
                    func_str = 'KAGUYA_FUNCTION_OVERLOADS(' .. cls_cpp_name .. '__' .. name .. '_wrappar_' .. fon .. ', ' .. cls_cpp_name .. '::' .. func_str ..', ' .. arg_n ..',' .. opt_n ..')'
                end
            else
                if not data.static then
                    func_str = 'KAGUYA_MEMBER_FUNCTION_OVERLOADS_INTERNAL(' .. cls_cpp_name .. '__' .. name .. '_wrappar_' .. fon ..', ' .. cls_cpp_name .. ', ' .. func_str ..', ' .. arg_n ..',' .. opt_n ..', (create<' .. cast .. '>()))'
                else
                    func_str = 'KAGUYA_FUNCTION_OVERLOADS_INTERNAL(' .. cls_cpp_name .. '__' .. name .. '_wrappar_' .. fon .. ', ' .. cls_cpp_name .. '::' .. func_str ..', ' .. arg_n ..',' .. opt_n ..', (create<' .. cast .. '>()))'
                end
            end
            table.insert(func_str_list, func_str)
            fn = fn + 1
            fon = fon + 1
        end
        str = str .. table.concat(func_str_list, '\n')
        if str ~= '' then
            table.insert(lines, str)
        end
    end
    return lines
end

function gen_functions(cls_cpp_name, t, indent)
    indent = indent or ''
    lines = {}
    functions = {}
    -- check overloaded functions
    for key, data in ipairs(t) do
        name = data.name
        if not functions[name] then
            functions[name] = {}
        end
        table.insert(functions[name], data)
    end
    for key, data_list in pairs(functions) do
        local str = ''
        local name = data_list[1].name
        local cpp_name = data_list[1].cpp_name or name
        local func_str_list = {}
        local fon = 0
        for _, data in ipairs(data_list) do
            func_str = cls_cpp_name .. '__' .. name .. '_wrappar_' .. fon .. '()'
            table.insert(func_str_list, func_str)
            fon = fon + 1
        end
        if #func_str_list == 1 then
            -- todo: bug check
            str = indent .. '.addOverloadedFunctions("' .. name .. '", '
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
    local value = classes[key]
    local lines = {}
    local constructors = gen_constructors(value.cpp_name, value.new, '    ')
    local inheritance = {value.cpp_name}
    if value.parent then
        table.insert(inheritance, value.parent)
    end
    table.insert(lines, 'lua["' .. key .. '"].setClass(kaguya::UserdataMetatable<' .. table.concat(inheritance, ', ') .. '>()')
    if constructors ~= nil then
        table.insert(lines, constructors)
    end
    lines = TableConcat(lines, gen_attributes(value.cpp_name, value.attributes, '    '))
    lines = TableConcat(lines, gen_functions(value.cpp_name, value.functions, '    '))
    table.insert(lines, '    );')
    local f_str = '_autogen_lua_' .. key .. '_bindings'
    table.insert(autogen_functions, f_str)

    local global_lines = gen_wrappar_functions(value.cpp_name, value.functions)
    global_lines = TableConcat(global_lines, gen_ref_attributes_wrappar(value.cpp_name, value.attributes))
    f = io.open("src/lua/" .. key .. "_bindings.cpp", "w")
    f:write(table.concat(cpp_template_header, '\n') .. '\n\n')
    f:write(table.concat(global_lines, '\n') .. '\n')
    f:write('void ' .. f_str .. '(kaguya::State &lua)\n')
    f:write('{\n')
    f:write('    ' .. table.concat(lines, '\n    ') .. '\n')
    f:write('}\n')
    f:close()
end

-- global bindings
f = io.open("src/lua/_autogen_lua_global_bindings.cpp", "w")
f:write(table.concat(cpp_template_header, '\n') .. '\n\n')
f:write('\n')
f:write('void _autogen_lua_global_bindings(kaguya::State &lua)\n')
f:write('{\n')
--   global references
for key, data in pairs(global_references) do
    f:write('    lua["' .. key .. '"] = ' .. data.cpp_name.. ';\n')
end
--   global functions
f:write('    lua["game"] = kaguya::NewTable();\n')
for _, data in pairs(global_functions) do
    cpp_name = data.cpp_name or data.name
    f:write('    lua["game"]["' .. data.name .. '"] = ' .. cpp_name.. ';\n')
end
f:write('}\n')
f:close()
table.insert(autogen_functions, "_autogen_lua_global_bindings")


-- enums
f = io.open("src/lua/_autogen_lua_enum_bindings.cpp", "w")
f:write(table.concat(cpp_template_header, '\n') .. '\n\n')
f:write('\n')
f:write('void _autogen_lua_enum_bindings(kaguya::State &lua)\n')
f:write('{\n')
f:write('    lua["enums"] = kaguya::NewTable();\n')
for key, data in pairs(enums) do
    f:write('    lua["enums"]["' .. key .. '"] = kaguya::NewTable();\n')
    for _, value in pairs(data.values) do
        f:write('    lua["enums"]["' .. key .. '"]["' .. value[1] .. '"] = ' .. value[2] .. ';\n')
    end
end
f:write('}\n')
f:close()
table.insert(autogen_functions, "_autogen_lua_enum_bindings")


-- entry point
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
