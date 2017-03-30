# Expectation from correct syntax for each row:
# - Labels comes first. could be more than one in theory.
# - OP code comes after label.
# - Operands comes last.
# - Defined labels must end with ":"
# - 
import os

numeric = '0123456789'
alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'


class Operand():
    name = None
    line = None

class Label():
    name = None
    line = None
    def __init__(self, name = "", line = -1):
        self.name = name
        self.line = line

# Parse functions, one for each type.

# Parse label returns given label and the rest of the line.
def parse_label(line, label_list):
    rest = None
    result, rest = read(line, str.isalpha)
    
    if not isOP(result) && rest[0] == ':':
        label_list.append(Label(result))
        parse_label(rest[1:],label_list)
    else:
        return (label_list,result+rest)

    
def parse_line(line):
    tokens, rest = parse_label(line,label_list = [])
 
def isOP(string):
    opCodes = ['adc','and','asl','bit','clc','clv',\
               'cmp','dex','eor','inx','jmp','jsr',\
               'lda','lsr','bcs','beq','bmi','bne',\
               'bpl','bvs','nop','ora','pha','pla',\
               'rts','sbc','sec','sta','tax','txa',\
               'tay','tya']
    return string in opCodes

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
            curr_line = curr_line.upper()
            lines.append(curr_line)
    return lines


def main():
    a = read_file("asm3")
    for line in a:
        print line

    asd = '11112222 '
    d = read(asd, str.isalpha)
    if d[0] == None:
        print "None"
    print d


if __name__=="__main__":
    main()
