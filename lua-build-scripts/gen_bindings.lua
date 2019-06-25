dofile("lua/lua_classes.lua")
dofile("lua/lua_classes_override.lua")
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

function gen_attributes_wrappar(cls_cpp_name, t, indent)
    indent = indent or ''
    local attributes = {}
    for name, data in pairs(t) do
        local str = ''
        local type_def = data.type
        local is_ptr = false
        local is_ref = false
        if string.match(data.type, "%*$") then
            is_ptr = true
        end
        if string.match(data.type, "%&$") then
            is_ref = true
        end
        type_def = 'auto'
        if data.static then
            str = str .. indent .. type_def .. ' __get_' .. name .. '(const ' .. cls_cpp_name .. '*) { return ' .. cls_cpp_name .. '::' .. name .. '; }\n'
        elseif is_ref then
            str = str .. indent .. type_def .. '* __get_' .. name .. '(const ' .. cls_cpp_name .. '* self) { return &self->' .. name .. '; }\n'
        elseif is_ptr then
            str = str .. indent .. type_def .. ' __get_' .. name .. '(const ' .. cls_cpp_name .. '* self) { return const_off(self->' .. name .. '); }\n'
        end
        if data.writable then
            if data.static then
                str = str .. indent .. 'void __set_' .. name .. '(' .. cls_cpp_name .. '*, ' .. data.type ..' val) { ' .. cls_cpp_name .. '::' .. name .. ' = val; }\n'
            elseif is_ref or is_ptr then
                str = str .. indent .. 'void __set_' .. name .. '(' .. cls_cpp_name .. '* self, ' .. data.type ..' val) { self->' .. name .. ' = val; }\n'
            end
        end
        if str ~= '' then
            table.insert(attributes, str)
        end
end
    return attributes
end

function gen_attributes(cls_cpp_name, t, indent)
    indent = indent or ''
    attributes = {}
    for name, data in pairs(t) do
        local is_ptr = false
        local is_ref = false
        if string.match(data.type, "%*$") then
            is_ptr = true
        end
        if string.match(data.type, "%&$") then
            is_ref = true
        end
        if data.static or is_ptr or is_ref then
            if data.writable then
                str = indent .. '.addProperty("' .. name .. '", __get_' .. name .. ', __set_' .. name .. ')'
            else
                str = indent .. '.addProperty("' .. name .. '", __get_' .. name .. ')'
            end
        else
            str = indent .. '.addProperty("' .. name .. '", &' .. cls_cpp_name .. '::' .. name .. ')'
        end
        table.insert(attributes, str)
    end
    return attributes
end

function gen_wrappar_functions(cls_cpp_name, cls_lua_name, t, indent)
    indent = indent or ''
    local lines = {}
    local functions = {}
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
            local tmp_rval = data.rval
            if not string.match(tmp_rval, "^const ") then
                -- do not return pointer if constant rval
                tmp_rval = string.gsub(tmp_rval, "%&$", "*")
            end
            local tmp_conv_ref = (tmp_rval ~= data.rval)
            if data.rval == '' then
                if cpp_name == 'operator int' then
                    tmp_rval = 'int'
                else
                    break
                end
            end
            local wrappar_func_name = cls_lua_name .. '__' .. name .. '_wrappar_' .. fon
            local func_str = tmp_rval .. ' ' .. wrappar_func_name .. '('
            local an = 0
            local args_str_t_1 = {cls_cpp_name .. '* self'}
            local args_str_t_2 = {}
            local self_def = 'self->'
            if cls_cpp_name == '' then
                self_def = ''
                args_str_t_1 = {}
            elseif data.const then
                self_def = 'static_cast<const ' .. cls_cpp_name .. '*>(self)->'
            end
            for _, a in ipairs(data.args) do
                table.insert(args_str_t_1, a .. ' v' .. an)
                table.insert(args_str_t_2, 'v' .. an)
                an = an + 1
            end
            if data.optional_args then
                table.insert(args_str_t_1, 'kaguya::VariadicArgType args')
            end
            func_str = func_str .. table.concat(args_str_t_1, ', ')
            func_str = func_str .. '){\n'
            local args_str = table.concat(args_str_t_2, ', ')
            if data.optional_args then
                for i = 1, #data.optional_args do
                    func_str = func_str .. indent .. 'if( args.size() >= ' .. (#data.optional_args - i + 1) .. ' ){\n'
                    func_str = func_str .. indent .. indent
                    if data.rval ~= 'void' then
                        func_str = func_str  .. 'return '
                        if tmp_conv_ref then
                            func_str = func_str  .. '&'
                        end
                    end
                    func_str = func_str  .. self_def .. cpp_name .. '('
                    local opt_args_str_t = {}
                    for j = 1, (#data.optional_args - i + 1) do
                        table.insert(opt_args_str_t, 'args[' .. (j - 1) .. '].get<' .. data.optional_args[j] .. '>()')
                    end
                    func_str = func_str .. table.concat(TableConcat(args_str_t_2, opt_args_str_t), ', ')
                    func_str = func_str .. ');\n'
                    if data.rval == 'void' then
                        func_str = func_str  .. indent .. indent .. 'return;\n'
                    end
                    func_str = func_str .. indent .. '}\n'
                end
            end
            func_str = func_str .. indent
            if data.rval ~= 'void' then
                func_str = func_str  .. 'return '
                if tmp_conv_ref then
                    func_str = func_str  .. '&'
                end
            end
            func_str = func_str .. self_def .. cpp_name .. '(' .. args_str .. ');\n'
            func_str = func_str .. '}'
            table.insert(func_str_list, func_str)
            fon = fon + 1
        end
        str = str .. table.concat(func_str_list, '\n')
        if str ~= '' then
            table.insert(lines, str)
        end
    end
    return lines
end

function gen_functions(cls_cpp_name, cls_lua_name, t, indent)
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
            func_str = cls_lua_name .. '__' .. name .. '_wrappar_' .. fon
            table.insert(func_str_list, func_str)
            fon = fon + 1
        end
        str = indent .. '.addOverloadedFunctions("' .. name .. '", '
        str = str .. table.concat(func_str_list, ',') .. ')'
        if str ~= '' then
            table.insert(lines, str)
        end
    end
    return lines
end


function gen_inheritance(cls_data)
    local t = {}
    if not cls_data.parent then
        return nil
    end
    table.insert(t, cls_data.parent)
    for key, next_cls in pairs(classes) do
        if next_cls.cpp_name == cls_data.parent then
            local ret = gen_inheritance(next_cls)
            if ret then
                t = TableConcat(t, ret)
            end
            break
        end
    end
    return t
end

function gen_enum_type_traits(name, cpp_name)
    local f = io.open("lua-build-scripts/template/enum_type_traits.h", "r")
    local t = {}
    for line in f:lines() do
        local new_line = string.gsub(line, "###name###", name)
        new_line = string.gsub(new_line, "###cpp_name###", cpp_name)
        table.insert(t, new_line)
    end
    return table.concat(t, "\n")
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

function in_table (t, chk)
    for _,key in ipairs(t) do
        if key == chk then
            return true
        end
    end
    return false
end

keys_new = {}
while #keys ~= #keys_new do
    for _,key in pairs(keys) do
        parent = classes[key].parent
        if in_table(keys_new, key) then
        elseif parent == nil or in_table(keys_new, parent) then
            table.insert(keys_new, key)
        end
    end
end
keys = keys_new

string_ids = {}

cpp_template_header = {
    '#include "../_catalua.h"',
    '#include "_autogen_lua_enum_bindings_traits.cpp"',
}

autogen_functions = {}

for _, key in pairs(keys) do
    local value = classes[key]
    local lines = {}
    local constructors = gen_constructors(value.cpp_name, value.new, '    ')
    local inheritance = gen_inheritance(value)
    local register_cls = value.cpp_name
    if inheritance then
        register_cls = register_cls .. ', kaguya::MultipleBase<' .. table.concat(inheritance, ', ') .. '>'
    end
    table.insert(lines, 'lua["' .. key .. '"].setClass(kaguya::UserdataMetatable<' .. register_cls .. '>()')
    if constructors ~= nil then
        table.insert(lines, constructors)
    end
    lines = TableConcat(lines, gen_attributes(value.cpp_name, value.attributes, '    '))
    lines = TableConcat(lines, gen_functions(value.cpp_name, key, value.functions, '    '))
    table.insert(lines, '    );')
    local f_str = '_autogen_lua_' .. key .. '_bindings'
    table.insert(autogen_functions, f_str)

    local global_lines = gen_wrappar_functions(value.cpp_name, key, value.functions, '    ')
    global_lines = TableConcat(global_lines, gen_attributes_wrappar(value.cpp_name, value.attributes))
    f = io.open("src/lua/" .. key .. "_bindings.cpp", "w")
    f:write(table.concat(cpp_template_header, '\n') .. '\n\n')
    f:write(table.concat(global_lines, '\n') .. '\n\n')
    f:write('void ' .. f_str .. '(kaguya::State &lua)\n')
    f:write('{\n')
    f:write('    ' .. table.concat(lines, '\n    ') .. '\n')
    f:write('}\n')
    f:close()
end

-- global bindings
do
    local global_lines = gen_wrappar_functions('', '', global_functions, '    ')
    f = io.open("src/lua/_autogen_lua_global_bindings.cpp", "w")
    f:write(table.concat(cpp_template_header, '\n') .. '\n\n')
    f:write(table.concat(global_lines, '\n') .. '\n\n')
    f:write('void _autogen_lua_global_bindings(kaguya::State &lua)\n')
    f:write('{\n')
    --   global references
    for key, data in pairs(global_references) do
        f:write('    lua["' .. key .. '"] = ' .. data.cpp_name.. ';\n')
    end
    --   global functions
    f:write('    lua["game"] = kaguya::NewTable();\n')
    for _, data in pairs(global_functions) do
        f:write('    lua["game"]["' .. data.name .. '"] = __' .. data.name.. '_wrappar_0;\n')
    end
    f:write('}\n')
    f:close()
    table.insert(autogen_functions, "_autogen_lua_global_bindings")
end


-- enums traits
f = io.open("src/lua/_autogen_lua_enum_bindings_traits.cpp", "w")
f:write('#include "../_catalua.h"\n\n')
f:write('namespace kaguya{\n')
for key, data in pairs(enums) do
    f:write(gen_enum_type_traits(key, data.cpp_name))
    f:write('\n')
end
f:write('}\n\n')
f:close()

-- enums
f = io.open("src/lua/_autogen_lua_enum_bindings.cpp", "w")
f:write(table.concat(cpp_template_header, '\n') .. '\n\n')
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
