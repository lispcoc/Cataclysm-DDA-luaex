dofile(arg[2])

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
                if data.writable then
                    str = indent .. '.addStaticVariable("' .. name .. '", &' .. cls_cpp_name .. '::' .. name .. ', true)'
                else
                    --str = indent .. '.addStaticVariable("' .. name .. '", &' .. cls_cpp_name .. '::' .. name .. ', false)'
                end
            else
                if data.writable then
                    str = indent .. '.addVariableRef("' .. name .. '", &' .. cls_cpp_name .. '::' .. name .. ', true)'
                else
                    str = indent .. '.addVariable("' .. name .. '", &' .. cls_cpp_name .. '::' .. name .. ', false)'
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
    functions = {}
    for key, data in pairs(t) do
        name = data.name
        if not data.static then
            str = indent .. '.addFunction("' .. name .. '", '
        else
            str = indent .. '.addStaticFunction("' .. name .. '", '
        end
        func_str = 'static_cast<' .. data.rval .. '('
        if not data.static then
            func_str = func_str .. cls_cpp_name .. '::'
        end
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
        str = str .. func_str .. ')'
        table.insert(functions, str)
    end
    return functions
end

for key, value in pairs(classes) do
    lines = {}
    print("LuaIntf::LuaBinding(L)")
    table.insert(lines, '    .beginClass<' .. value.cpp_name ..'>("' .. key .. '")')
    lines = TableConcat(lines, gen_attributes(value.cpp_name, value.attributes, '    '))
    lines = TableConcat(lines, gen_functions(value.cpp_name, value.functions, '    '))
    print(table.concat(lines, '\n    '))
    print('    .endClass();')
end
