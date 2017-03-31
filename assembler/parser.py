# Expectation from correct syntax for each row:
# - Labels comes first. could be more than one in theory.
# - OP code comes after label.
# - Operands comes last.
# - Defined labels must end with ":"
# -

#
# TODO: /////////////////////////////////////////////////////////////////
# Fixxa så vi appendar till listan istället för att 'ibland' returnera listan
# addr_mode läggs sist i token_listan tills det att vi skapar Instruction i
# parse_line. VARFÖR HETER DEN LABEL_LIST?
# /////////////////////////////////////////////////////////////////////////


import os

numeric = '0123456789'
alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'


class Instruction():
    tokens = []
    addr_mode = None
    row = None
    def __init__(self, tokens = [], addr_mode = None, row = None):
        self.tokens = tokens
        self.addr_mode = addr_mode
        self.row = row



class Number():
    name = None
    line = None
    adr_mode = None
    def __init__(self, name = "", line = -1):
        self.name = name
        self.line = line

class Label():
    name = None
    line = None
    def __init__(self, name = "", line = -1):
        self.name = name
        self.line = line

class Operator():
    name = None
    line = None
    def __init__(self, name = "", line = -1):
        self.name = name
        self.line = line

# ---------------------------------
# Parse functions, one for each type.
# ---------------------------------
def parse_line(line):
    tokens, rest = parse_label(line,label_list = [])
    rest = parse_operator(rest,tokens)
    if not rest:
        print("ERROR: OP NOT FOUND")
        for elem in tokens:
            print(elem.name)

# Parse label returns given label and the rest of the line.
def parse_label(line,label_list):
    result, rest = read(line, str.isalpha)
    if not isOP(result) and rest[0] == ':':
        label_list.append(Label(result))
        return parse_label(rest[1:].strip(),label_list)
    else:
        return (label_list,result+" "+rest)


def parse_operator(line,label_list):
    result, rest = read(line, str.isalpha)
    if isOP(result):
        label_list.append(Operator(result))
        return rest
    else:
        return None

def parse_number(line,label_list):
    isDeci = True
    if line[0] == '$':
        line = line[1:]
        isDeci = False
    result, rest = read(line,isHex)
    if not result:
        print 'Not a number'
        return (None, rest)
    if isDeci:
        result = hex(int(result)[2:])
    return (Number(result), rest)

# ---------------------------------
# Parse addr_mode, returns False or tokens if correct
# ---------------------------------

def parse_operand(line,label_list):#returns addr_mode & remaining tokens
    func_list = [parse_immediate, parse_abs, parse_zp_abs,\
    parse_abs_index, parse_indirect, parse_zp_indirect,\
    parse_index_indirect, parse_indirect_index]
    for func in func_list:
        result, addr_mode = func(line, line_list)
        if result:
            return (line_list,addr_mode)#borde ha kvarvarande tokens




def parse_immediate(line, line_list):
    if line[0] == '#':
        result, rest = parse_number(line[1:], lista)
        if not result and rest:
            print 'immediate ERROR'
            return (False, -1)
        line_list.append(result)
        return (True, 0)

#def parse_abs(line):
#def parse_zp_abs(line):
#def parse_abs_index(line):
#def parse_indirect(line):
#def parse_zp_indirect
#def parse_index_indirect(line):
#def parse_indirect_index(line):


def isOP(string):
    opCodes = ['adc','and','asl','bit','clc','clv',\
               'cmp','dex','eor','inx','jmp','jsr',\
               'lda','lsr','bcs','beq','bmi','bne',\
               'bpl','bvs','nop','ora','pha','pla',\
               'rts','sbc','sec','sta','tax','txa',\
               'tay','tya']
    return string in opCodes

def isHex(char):
    hexes = "1234567890abcdef"
    return char in hexes

# Returns tuple with first elemen is part of line that is true in func.
def read(line, func):
    length = 0

    while length < len(line) and func(line[length]):
        length += 1

    result = line[:length]
    rest = line[length:].strip()

    return (result, rest)






# Returns a list containing each line of _file.
def read_file(_file):
    lines = []
    with open(_file) as open_file:
        for line in open_file:
            curr_line = line.strip()
            curr_line = curr_line.lower()
            lines.append(curr_line)
    return lines


def main():
    a = read_file("asm3")
    for line in a:
        parse_line(line)
        print line




if __name__=="__main__":
    main()
