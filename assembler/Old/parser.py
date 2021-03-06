from __future__ import print_function
from lexer import *

opCodes = ['adc','and','asl','bit',\
'clc','clv','cmp','dex','eor','inx','jmp','jsr','lda','lsr',\
'nop','ora','pha','pla','rts','sbc','sec','sta','tax','txa','tay','tya']

branch = ['bcs','beq','bmi','bne','bpl','bvs']
labels = []

def parse(list):
    saveIndex = 0
    comment = False
    hexnumber = False
    decnumber = False
    for token in list:
        index = token.index

        if token.str == "endofline":
            token.type = TokenType.END
            comment = False

        elif comment and token.index == saveIndex:
            token.type = TokenType.COMMENT

        elif comment and token.index != saveIndex:
            comment = False

        elif token.isComment():
            token.type = TokenType.COMMENT
            saveIndex = token.index
            comment = True


        elif token.str in branch:
            token.type = TokenType.BRANCH

        elif token.str in opCodes:
            token.type = TokenType.OPCODE


        elif token.type == TokenType.DOLLAR:
            hexnumber = True
        elif hexnumber:
            if token.isHex():
                token.type = TokenType.HEXA
                hexnumber = False
            else:
                token.type = TokenType.ERR
                hexnumber = False

        elif token.isDec():
            token.type = TokenType.DECI
            token.str = convertToHex(token.str)

        elif token.isLabel():
            token.type = TokenType.LABEL
            labels.append(token.str[:-1])

        elif token.str in labels:
            token.type = TokenType.REF

        elif token.str == "x":
            token.type = TokenType.XREG

        elif token.str == "y":
            token.type = TokenType.YREG

def convertToHex(string):
    return hex(int(string))[2:]

def main():
    tokens = lexer("asm")

    parseTokens(tokens)

    for token in tokens:
        token.printself()




if __name__ == "__main__":
    main()
