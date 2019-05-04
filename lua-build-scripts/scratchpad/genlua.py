from lxml import etree
import lxml.html
import re
from collections import Counter
import os

class CppObj:
    valid_types = [
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
        'item_location',
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
    ]
    def __init__(self):
        self.classes = []
        self.string_ids = {}
        self.typedefs = {}

    def getClass(self, name):
        for c in self.classes:
            if c.name == name:
                return c
        return None

    def appendClass(self, new_class):
        self.classes.append(new_class)

    def deleteClass(self, name):
        del_list = []
        for c in self.classes:
            if c.name == name:
                del_list.append(c)
        for c in del_list:
            self.classes.remove(c)

    def isValidType(self, type):
        if type.type in CppObj.valid_types:
            return True
        if type.type in self.string_ids.keys():
            return True
        standardized = self.standardizedType(type)
        if standardized:
            if standardized.type in CppObj.valid_types:
                return True
            if standardized.type in self.string_ids.keys():
                return True
        return False

    def standardizedType(self, type):
        if type.type in self.typedefs.keys():
            return self.typedefs[type.type]
        return None


class CppFunction:
    def __init__(self, name = None, args  = [], optional_args = [], rval = None):
        self.name = name
        self.args  = args
        self.optional_args = optional_args
        self.rval = rval

    def str(self):
        string = "{ "
        string += 'name = "' + self.name + '", '
        string += 'rval = "' + self.rval.lua_rval() + '", '
        string += 'args = { '
        for arg in self.args:
            string += '"' + arg.lua_arg() + '", '
        string += '}, '
        if len(self.optional_args):
            string += 'optional_args = { '
            for arg in self.optional_args:
                string += '"' + arg.lua_arg() + '", '
            string += '}, '
        string += '}, '
        return string

    def isValid(self):
        if not self.rval.isValid():
            return False
        for a in self.args:
            if not a.isValid():
                return False
        for a in self.optional_args:
            if not a.isValid():
                return False
        return True


class CppAttribute:
    def __init__(self, name = None, type  = None):
        self.name = name
        self.type  = type
    def str(self):
        s = ''
        if not self.type.isValid():
            s += '--'
        s += self.name + ' = { type = "' + self.type.lua_rval() + '", '
        if self.type.isWritable():
            s += 'writable = true, '
        else:
            s += 'writable = false, '
        s += '},'
        return s

class CppType:
    lua_typemap = {
        'std::string': 'string'
    }
    def __init__(self, cpp_obj, definition = ''):
        self.definition = definition
        self.is_static = False
        self.is_const = False
        self.is_ptr = False
        self.is_ref = False
        self.type = ''
        self.cpp_obj = cpp_obj
        self.parseCppDefinition()

    def parseCppDefinition(self):
        s = self.definition
        s = re.sub(r'\s+$', '', s)
        self.is_static = re.match(r'^static ', s)
        s = re.sub(r'^static ', '', s)
        self.is_const = re.match(r'^const ', s)
        s = re.sub(r'^const ', '', s)
        self.is_ptr = re.match(r'\s+\*$', s)
        s = re.sub(r'\s+\*$', '', s)
        self.is_ref = re.match(r'\s+\&$', s)
        s = re.sub(r'\s+\&$', '', s)
        self.type = s

    def isWritable(self):
        if self.is_const:
            return False
        return True

    def isValid(self):
        if self.cpp_obj.isValidType(self):
            return True
        return False

    def lua_rval(self):
        s = self.type
        if self.cpp_obj.standardizedType(self):
            s = self.cpp_obj.standardizedType(self).type
        if self.is_ref or self.is_ptr:
            s += '&'
        return s

    def lua_arg(self):
        s = self.type
        if self.cpp_obj.standardizedType(self):
            s = self.cpp_obj.standardizedType(self).type
        return s

class CppClass:
    def __init__(self, cpp_obj, name = None, string_id = None):
        self.name = name
        self.string_id = string_id
        self.functions = []
        self.attributes = []
        self.bases = []
        self.cpp_obj = cpp_obj
        self.mapped_to = None

    def printLuaDefs(self):
        is_valid = CppType(self.cpp_obj, definition = self.name).isValid()
        if not is_valid:
            print('--[[')
        print(self.name + ' = {')
        if len(self.bases):
            print('    parent = {')
            for base in self.bases:
                print('        "' + base.name + '",')
            print('    },')
        if self.string_id:
            print('    string_id = "' + self.string_id + '",')
        print('    attributes = {')
        for attribute in self.attributes:
            print('        ' + attribute.str())
        print('    },')
        print('    functions = {')
        for function in self.functions:
            if function.isValid():
                print('        ' + function.str())
            else:
                print('        --' + function.str())
        print('    },')
        print('},')
        if not is_valid:
            print(']]--')

def get_xml_files(path):
    xml_files = []
    if os.path.isdir(path):
        files = os.listdir(path)
        for file in files:
            if os.path.isfile(path + '/' + file):
                xml_files.append(path + '/' + file)
    return xml_files

def update_class(cpp_obj, compound):
    class_name = compound.find('compoundname')
    target_class = cpp_obj.getClass(class_name.text)
    for base_text in compound.iter('basecompoundref'):
        base_class = cpp_obj.getClass(base_text.text)
        if base_class:
            target_class.bases.append(base_class)
    for member in compound.iter('memberdef'):
        if member.attrib['prot'] == 'public':
            if member.attrib['kind'] == 'variable':
                attribute_name = "!!!invalid_attribute"
                attribute_type = None
                for name in member.iter('name'):
                    attribute_name = name.text
                tmp = member.find('type')
                if tmp != None:
                    attribute_type = CppType(cpp_obj, definition = etree.tostring(tmp, method="text"))
                new_attribute = CppAttribute(name = attribute_name, type = attribute_type)
                target_class.attributes.append(new_attribute)
            if member.attrib['kind'] == 'function':
                function_name = "!!!invalid_function"
                args  = []
                optional_args = []
                rval = None
                for name in member.iter('name'):
                    function_name = name.text
                tmp = member.find('type')
                if tmp != None:
                    rval = CppType(cpp_obj, definition = etree.tostring(tmp, method="text"))
                    if rval.lua_rval() == "":
                        if function_name == 'operator int':
                            rval = CppType(cpp_obj, definition = "int" )
                for param in member.iter('param'):
                    tmp = param.find('type')
                    if tmp != None:
                        arg = CppType(cpp_obj, definition = etree.tostring(tmp, method="text"))
                        if param.find('defval') != None:
                            optional_args.append(arg)
                        else:
                            args.append(arg)
                new_function = CppFunction(name = function_name, rval = rval, args = args, optional_args = optional_args)
                target_class.functions.append(new_function)

def update_string_id(cpp_obj, compound):
    members = tree.xpath('//memberdef')
    for member in members:
        if member.attrib['kind'] == 'typedef':
            definition = member.find('definition')
            if definition != None:
                tmp = etree.tostring(definition, method="text")
                tmp2 = re.findall(r'^using (\w+)\s+=\s+string_id<([\w:]+)>', tmp)
                if len(tmp2):
                    c = cpp_obj.getClass(tmp2[0][1])
                    if c:
                        c.string_id = tmp2[0][0]
                        cpp_obj.string_ids[c.string_id] = c

def update_typedef(cpp_obj, compound):
    members = tree.xpath('//memberdef')
    for member in members:
        if member.attrib['kind'] == 'typedef':
            definition = member.find('definition')
            if definition != None:
                tmp = etree.tostring(definition, method="text")
                tmp2 = re.findall(r'^using\s+(\w+)\s+=\s+(.+)\s*', tmp)
                if len(tmp2):
                    new_class = CppClass(cpp_obj, name = tmp2[0][0])
                    mapped_to = cpp_obj.getClass(tmp2[0][1])
                    if not mapped_to:
                        cpp_obj.appendClass()
                    new_class.mapped_to = cpp_obj.getClass(tmp2[0][1])
                    cpp_obj.appendClass(new_class)

cpp_obj = CppObj()

cpp_classes = {}

#
xml_files = get_xml_files('doxygen_doc/xml')

for xml_file in xml_files:
    tree = etree.parse(xml_file)
    root = tree.getroot()

    compounds = tree.xpath('//compounddef')
    # Init Cpp Classes
    for compound in compounds:
        if compound.attrib['kind'] == 'class' or compound.attrib['kind'] == 'struct':
            class_name = compound.find('compoundname')
            cpp_obj.appendClass(CppClass(cpp_obj, name = class_name.text))

    #Init string_id
    for compound in compounds:
        if compound.attrib['kind'] == 'file':
            update_string_id(cpp_obj, compound)

    #Init typedefs
    for compound in compounds:
        if compound.attrib['kind'] == 'file':
            update_typedef(cpp_obj, compound)

# Update Classes
for xml_file in xml_files:
    tree = etree.parse(xml_file)
    root = tree.getroot()

    compounds = tree.xpath('//compounddef')
    for compound in compounds:
        if compound.attrib['kind'] == 'class':
            #Update Classes
            update_class(cpp_obj, compound)

for c in cpp_obj.classes:
    c.printLuaDefs()

#{ name = "can_pickVolume", rval = "bool", args = { "item" }, optional_args = { "bool" } },

for c in cpp_obj.classes:
    if c.mapped_to:
        print c.name, ': ', c.mapped_to
