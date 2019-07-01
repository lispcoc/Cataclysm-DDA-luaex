from lxml import etree
import lxml.html
import re
import os
import sys

cmd_args = sys.argv

valid_types = [
    'avatar',
    'bool',
    'body_part',
    'std::string',
    'units::mass',
    'units::volume',
    'int',
    'float',
    'item',
    'int',
    'itype',
    'player',
    'gun_mode',
    'effect_type',
    'calendar',
    'mutation_branch',
    'Character',
    'item_stack_iterator',
    'map_stack',
    'game',
    'activity_type',
    'player_activity',
    'bionic',
    'bionic_data',
    'morale_type_data',
    'encumbrance_data',
    'stats',
    'npc_companion_mission',
    'npc_personality',
    'npc_opinion',
    'npc',
    'point',
    'tripoint',
    'uilist',
    'field_entry',
    'field',
    'map',
    'ter_t',
    'furn_t',
    'Creature',
    'monster',
    'recipe',
    'martialart',
    'material_type',
    'start_location',
    'ma_buff',
    'ma_technique',
    'Skill',
    'quality',
    'npc_template',
    'species_type',
    'ammunition_type',
    'MonsterGroup',
    'mtype',
    'mongroup',
    'overmap',
    'nc_color',
    'time_duration',
    'time_point',
    'trap',
    'w_point',
    'void',
    'long',
    'double',
    'item_location',
    'item_stack',
]

lua_typemap = {
    'game': 'lua_game',
}

blacklist_type = [
    'inventory_item_menu_positon',
    'points_left',
    'game::Creature_range',
    'game::monster_range',
    'game::npc_range',
    'item_tweaks',
    'default_charges_tag',
    'solitary_tag',
    'mon_action_defend',
    'mon_action_death',
    'mon_action_attack',
    'Attitude',
]

blacklist_function = [
    'melee_attack',
    'build_obstacle_cache',
]


def check_blacklist_type(type):
    for b in blacklist_type:
        reg = re.compile(r"\b" + b + r"\b")
        if reg.search(type):
            return True
    return False

# =======================================================
#
# CppFunction
#
# =======================================================


class CppFunction:
    def __init__(self):
        self.name = ''
        self.definition = None
        self.args = []
        self.optional_args = []
        self.type = None
        self.const = False
        self.static = False
        self.virtual = False
        self.parent = None

    @classmethod
    def load_from_xml(cls, xml_memberdef, parent = None):
        if xml_memberdef.attrib['prot'] == 'public':
            if xml_memberdef.attrib['kind'] == 'function':
                argsstring = xml_memberdef.find('argsstring').text
                if argsstring and re.search(r'delete$', argsstring):
                    return None
                new_func = CppFunction()
                new_func.name = xml_memberdef.find('name').text
                new_func.definition = xml_memberdef.find('definition').text
                new_func.type = etree.tostring(
                    xml_memberdef.find('type'), method="text")
                for p in xml_memberdef.iter('param'):
                    s = etree.tostring(p.find('type'), method="text")
                    if p.find('defval') != None:
                        new_func.optional_args.append(s)
                    else:
                        new_func.args.append(s)
                if xml_memberdef.attrib['const'] == 'yes':
                    new_func.const = True
                if xml_memberdef.attrib['static'] == 'yes':
                    new_func.static = True
                if xml_memberdef.attrib['virt'] == 'pure-virtual':
                    new_func.virtual = True
                if parent:
                    new_func.parent = parent
                return new_func
        return None

    def str(self):
        string = "{ "
        if self.name != self.luaName():
            string += 'name = "' + self.luaName() + '", '
            string += 'cpp_name = "' + self.name + '", '
        else:
            string += 'name = "' + self.luaName() + '", '
        string += 'rval = '
        # if CppType(self.type).name == "null":
        #    string += 'nil, '
        # else:
        #    string += '"' + CppType(self.type).definition + '", '
        string += '"' + self.strRVal() + '", '
        string += 'args = { '
        for a in self.args:
            string += '"' + self.strArgWithNamespace(a, self.parent) + '", '
        string += '}, '
        if len(self.optional_args):
            string += 'optional_args = { '
            for a in self.optional_args:
                string += '"' + self.strArgWithNamespace(a, self.parent) + '", '
            string += '}, '
        if self.const:
            string += 'const = true, '
        else:
            string += 'const = false, '
        if self.static:
            string += 'static = true, '
        else:
            string += 'static = false, '
        string += '}'
        return string

    def strRVal(self):
        lua_rval_map = {
            'operator int': 'int',
            'operator float': 'float',
            'operator double': 'double',
        }
        if self.name in lua_rval_map.keys():
            return lua_rval_map[self.name]
        if not self.definition:
            return ''
        #if re.match(r'^operator', self.name):
        #    return ''
        r = re.sub(r'\s+[^\s]+$', '', self.definition)
        r = re.sub(r'static ', '', r)
        r = re.sub(r'constexpr ', '', r)
        r = re.sub(r'virtual ', '', r)
        return self.strArgWithNamespace(r, self.parent)

    def strArgWithNamespace(self, arg, parent):
        t = CppType(arg)
        cls = None
        for typedef in typedefs.keys():
            if typedef == (parent + '::' + t.name):
                return t.definition.replace(t.name, typedef)
        for cls2 in all_cpp_classes:
            if cls2.cpp_name == parent:
                cls = cls2
        if cls and cls.base:
            return self.strArgWithNamespace(arg, cls.base)
        return t.definition

    def isValid(self):
        if self.isInvalidOp():
            return False
        #if self.virtual:
        #    return False
        if self.name in blacklist_function:
            return False
        if check_blacklist_type(self.strRVal()):
            return False
        for a in self.args:
            if re.search(r"typename ", CppType(a).definition):
                return False
            if re.search(r"std::function", CppType(a).definition):
                return False
            if re.search(r'\(\*?\)', CppType(a).definition):
                return False
            if re.search(r'&&', CppType(a).definition):
                return False
            if check_blacklist_type(CppType(a).name):
                return False
        for a in self.optional_args:
            if re.search(r"typename ", CppType(a).definition):
                return False
            if re.search(r'\(\*?\)', CppType(a).definition):
                return False
            if check_blacklist_type(CppType(a).name):
                return False
        return True

    def isInvalidOp(self):
        if not re.match(r'^operator', self.name):
            return False
        if self.name == 'operator int':
            return False
        if self.name == 'operator[]':
            return False
        return True

    def luaName(self):
        lua_name_map = {
            'operator int': '_op_int',
            'operator float': '_op_float',
            'operator double': '_op_double',
            'operator[]': '_op_bracket',
        }
        if self.name in lua_name_map.keys():
            return lua_name_map[self.name]
        return self.name

# =======================================================
#
# CppVariable
#
# =======================================================


class CppVariable:
    def __init__(self):
        self.name = None
        self.type = None
        self.static = False

    @classmethod
    def load_from_xml(cls, xml_memberdef):
        if xml_memberdef.attrib['prot'] == 'public':
            if xml_memberdef.attrib['kind'] == 'variable':
                new_var = CppVariable()
                new_var.name = xml_memberdef.find('name').text
                new_var.type = etree.tostring(
                    xml_memberdef.find('type'), method="text")
                new_var.type = new_var.type.replace('\n', '')
                new_var.type = new_var.type.replace('\r', '')
                new_var.type = re.sub(r'\s+$', '', new_var.type)
                if xml_memberdef.attrib['static'] == 'yes':
                    new_var.static = True
                return new_var
        return None

    def str(self):
        string = self.name + ' = { '
        string += 'type = "' + self.type + '", '
        string += 'writable = '
        if self.isWritable():
            string += 'true, '
        else:
            string += 'false, '
        string += 'reference = '
        if self.isReference():
            string += 'true, '
        else:
            string += 'false, '
        string += 'static = '
        if self.isStatic():
            string += 'true, '
        else:
            string += 'false, '
        string += '}'
        return string

    def isStatic(self):
        if self.static:
            return True
        return False

    def isWritable(self):
        t = CppType(self.type)
        if t.is_const or t.is_static or self.isReference():
            return False
        if re.search(r'pimpl', t.name):
            return False
        return True

    def isReference(self):
        t = CppType(self.type)
        if t.is_ref:
            return True
        return False

    def isValid(self):
        if check_blacklist_type(CppType(self.type).name):
            return False
        if CppType(self.type).is_constexpr:
            return False
        return True

# =======================================================
#
# CppType
#
# =======================================================


class CppType:
    lua_typemap = {
        'std::string': 'string',
        'void': 'null',
        'long': 'int',
        'double': 'float',
    }

    def __init__(self, definition):
        self.definition = definition
        self.is_static = False
        self.is_const = False
        self.is_constexpr = False
        self.is_ptr = False
        self.is_ref = False
        self.name = ''
        self.parseCppDefinition()

    def parseCppDefinition(self):
        s = self.definition
        self.definition = re.sub(r'\s+$', '', s)
        s = re.sub(r'\s+$', '', s)
        self.is_static = re.search(r'static ', s)
        s = re.sub(r'static ', '', s)
        self.is_const = re.search(r'const ', s)
        s = re.sub(r'const ', '', s)
        self.is_constexpr = re.search(r'constexpr ', s)
        self.is_const = self.is_const or self.is_constexpr
        s = re.sub(r'constexpr ', '', s)
        self.is_ptr = re.search(r'\*', s)
        s = re.sub(r'\s+\*$', '', s)
        self.is_ref = re.search(r'\&', s)
        s = re.sub(r'\s+\&$', '', s)
        if not self.is_const:
            self.is_const = re.search(r'\s+const$', s)
        s = re.sub(r'\s+const$', '', s)
        self.name = s

    def isWritable(self):
        if self.is_const:
            return False
        return True

    def lua_rval(self):
        s = self.name
        if s in CppType.lua_typemap.keys():
            s = CppType.lua_typemap[s]
        if self.is_ref or self.is_ptr:
            s += '&'
        return s

    def lua_arg(self):
        s = self.name
        if s in CppType.lua_typemap.keys():
            s = CppType.lua_typemap[s]
        return s

    def isValid(self):
        return self.name in valid_types

# =======================================================
#
# CppClass
#
# =======================================================


class CppClass:
    def __init__(self):
        self.name = None
        self.cpp_name = None
        self.string_id = None
        self.int_id = None
        self.attributes = []
        self.functions = []
        self.base = None
        self.abstract = False

    @classmethod
    def load_from_xml(cls, xml_compounddef):
        new_class = CppClass()
        new_class.cpp_name = xml_compounddef.find('compoundname').text
        new_class.name = new_class.cpp_name
        if new_class.name in lua_typemap.keys():
            new_class.name = lua_typemap[new_class.name]
        new_class.name = new_class.name.replace(':', '_')
        if 'abstract' in xml_compounddef.attrib.keys():
            if xml_compounddef.attrib['abstract'] == 'yes':
                new_class.abstract = True
        # function
        for member in xml_compounddef.iter('memberdef'):
            new_func = CppFunction.load_from_xml(member, new_class.cpp_name)
            if new_func:
                new_class.functions.append(new_func)

            new_attribute = CppVariable.load_from_xml(member)
            if new_attribute:
                new_class.attributes.append(new_attribute)
        # base class
        s = xml_compounddef.find('basecompoundref')
        if not s == None and s.text in valid_types:
            new_class.base = s.text
        return new_class

    def str(self, indent=''):
        s = self.name + ' = {' + '\n'
        s += '    cpp_name = "' + self.cpp_name + '",\n'
        if self.base:
            s += '    parent = "' + self.base + '",\n'
        if self.string_id:
            s += '    string_id = "' + self.string_id + '",\n'
        if self.int_id:
            s += '    int_id = "' + self.int_id + '",\n'
        s += '    new = {' + '\n'
        if not self.abstract:
            for f in self.functions:
                if self.cpp_name == f.name:
                    for num in range(len(f.optional_args) + 1):
                        tmp_func = CppFunction()
                        tmp_func.args = f.args
                        tmp_func.optional_args = f.optional_args[0:num]
                        s += '        '
                        if not tmp_func.isValid():
                            s += '--'
                        s += '{ '
                        for a in tmp_func.args:
                            s += '"' + CppType(a).definition + '", '
                        for a in tmp_func.optional_args:
                            s += '"' + CppType(a).definition + '", '
                        s += '},\n'
        s += '    },' + '\n'
        s += '    attributes = {' + '\n'
        for a in self.attributes:
            s += '        '
            if not a.isValid():
                s += '--'
            s += a.str() + ',\n'
        s += '    },' + '\n'
        s += '    functions = {' + '\n'
        for f in self.functions:
            if self.cpp_name == f.name or ('~' + self.cpp_name) == f.name:
                continue
            # if re.match(r'^operator', f.name) :
            #    continue
            s += '        '
            if not f.isValid():
                s += '--'
            s += f.str() + ',\n'
        s += '    }' + '\n'
        s += '},'
        s = indent + ('\n' + indent).join(s.split('\n'))
        return s


# =======================================================
#
# CppEnum
#
# =======================================================


class CppEnum:
    def __init__(self):
        self.name = None
        self.cpp_name = None
        self.parent = None
        self.values = []
        self.refid = None
        self.as_class = False

    @classmethod
    def load_from_xml(cls, xml_memberdef, tree):
        if xml_memberdef.attrib['prot'] == 'public':
            if xml_memberdef.attrib['kind'] == 'enum':
                new_enum = CppEnum()
                new_enum.cpp_name = xml_memberdef.find('name').text
                location = xml_memberdef.find('location')
                if re.search(r'\.cpp$', location.attrib['file']):
                    return None
                if re.search(r'^@', new_enum.cpp_name):
                    return None
                new_enum.name = new_enum.cpp_name
                if new_enum.name in lua_typemap.keys():
                    new_enum.name = lua_typemap[new_enum.name]
                new_enum.name = new_enum.name.replace(':', '_')
                for enumvalue in xml_memberdef.iter('enumvalue'):
                    valname = enumvalue.find('name').text
                    new_enum.values.append(valname)
                new_enum.parent = CppEnum.getParentClass(xml_memberdef)
                if new_enum.parent and re.search(r'^anonymous_namespace', new_enum.parent):
                    return None
                new_enum.refid = xml_memberdef.attrib['id']
                return new_enum
        return None

    @classmethod
    def getParentClass(cls, element):
        parent = element.getparent()
        if len(parent):
            if 'kind' in parent.attrib.keys():
                if parent.attrib['kind'] == 'class' or parent.attrib['kind'] == 'struct':
                    tmp_cls = CppClass.load_from_xml(parent)
                    return tmp_cls.cpp_name
                else:
                    return CppEnum.getParentClass(parent)
        return None

    @classmethod
    def searchCodeLine(cls, tree, refid):
        lines = tree.xpath("//codeline [@refid='" + refid + "']")
        if len(lines):
            return etree.tostring(lines[0], method="text")
        return None

    def str(self, indent=''):
        s = self.name + ' = {' + '\n'
        if self.parent:
            s += '    cpp_name = "' + self.parent + '::' + self.cpp_name + '",\n'
        else:
            s += '    cpp_name = "' + self.cpp_name + '",\n'
        s += '    values = {' + '\n'
        for v in self.values:
            v2 = v
            if self.as_class:
                v2 = self.cpp_name + '::' + v2
            if self.parent:
                v2 = self.parent + '::' + v2
            s += '        {"' + v + '", "' + v2 + '"},\n'
        s += '    },' + '\n'
        s += '},'
        s = indent + ('\n' + indent).join(s.split('\n'))
        return s


def get_xml_files(path):
    xml_files = []
    if os.path.isdir(path):
        files = os.listdir(path)
        for file in files:
            if os.path.isfile(path + '/' + file):
                xml_files.append(path + '/' + file)
    return xml_files


xml_files = get_xml_files(cmd_args[1])
all_cpp_classes = []
all_cpp_enums = []
string_ids = {}
int_ids = {}
typedefs = {}

xml_files = filter(lambda x: re.search(r'_8cpp\.xml', x) == None, xml_files)

for xml_file in xml_files:
    tree = etree.parse(xml_file)
    root = tree.getroot()

    compounds = tree.xpath("//compounddef[@kind='class' or @kind='struct']")
    # Enumurate all types
    for compound in compounds:
        new_class = CppClass.load_from_xml(compound)
        if new_class.cpp_name in valid_types:
            all_cpp_classes.append(new_class)

    # Generate typedefs
    members = tree.xpath("//memberdef[@kind='typedef']")
    for member in members:
        definition = member.find('definition')
        tmp = etree.tostring(definition, method="text")
        tmp2 = re.findall(r'^using\s+(.+)\s+=\s+(.+)', tmp)
        if len(tmp2):
            typedefs[tmp2[0][0]] = tmp2[0][1]

    # string_id
    members = tree.xpath("//memberdef[@kind='typedef']")
    for member in members:
        definition = member.find('definition')
        tmp = etree.tostring(definition, method="text")
        tmp2 = re.findall(r'^using (\w+)\s+=\s+string_id<([\w:]+)>', tmp)
        if len(tmp2):
            string_id_class = tmp2[0][1]
            string_id_type = tmp2[0][0]
            string_ids[string_id_class] = string_id_type

    # int_id
    members = tree.xpath("//memberdef[@kind='typedef']")
    for member in members:
        definition = member.find('definition')
        tmp = etree.tostring(definition, method="text")
        tmp2 = re.findall(r'^using (\w+)\s+=\s+int_id<([\w:]+)>', tmp)
        if len(tmp2):
            int_id_class = tmp2[0][1]
            int_id_type = tmp2[0][0]
            int_ids[int_id_class] = int_id_type

    # enum
    members = tree.xpath("//memberdef[@kind='enum']")
    for member in members:
        new_enum = CppEnum.load_from_xml(member, tree)
        if new_enum:
            all_cpp_enums.append(new_enum)

# parse Enums
for xml_file in xml_files:
    tree = etree.parse(xml_file)
    for e in all_cpp_enums:
        if not e.as_class:
            lines = tree.xpath("//codeline[@refid='" + e.refid + "']")
            if len(lines):
                line = etree.tostring(lines[0], method="text")
                if re.match(r'enum\s*class', line):
                    e.as_class = True


for si in string_ids.keys():
    if string_ids[si] not in valid_types:
        valid_types.append(string_ids[si])

for ii in int_ids.keys():
    if int_ids[ii] not in valid_types:
        valid_types.append(int_ids[ii])

for cls in all_cpp_classes:
    if cls.cpp_name in string_ids.keys():
        cls.string_id = string_ids[cls.cpp_name]
    if cls.cpp_name in int_ids.keys():
        cls.int_id = int_ids[cls.cpp_name]

all_cpp_classes = sorted(all_cpp_classes, cmp=lambda x,y: cmp(x.name.lower(), y.name.lower()))
print('classes = {')
for c in all_cpp_classes:
    print(c.str('    '))
print('}')

all_cpp_enums = sorted(all_cpp_enums, cmp=lambda x,y: cmp(x.name.lower(), y.name.lower()))
print('enums = {')
for e in all_cpp_enums:
    print(e.str('    '))
print('}')
