from __future__ import print_function
from parser import *

class mode():
    NOTSET = 0
    IMMEDIATE = 1
    ABSOLUTE = 2
    ZP_ABSOLUTE = 3
    INDIRECT = 4
    INDEXED_INDI = 5
    INDI_INDEXED = 6

class CodeLine ():
    cmd = []               # Tokens that will represent one line in memory. LIST
    lin_err = 0            # Error tokens in list tokens? INT
    adr_mode = mode.NOTSET # Mode Enum
    latest = TokenType.NONE
    passed = True         # Passed test?
    parens = 0

    def __init__ (self, cmd = [], lin_err = 0, adr_mode = mode.NOTSET,  passed = True, latest = TokenType.NONE, parens = 0):
        self.cmd = cmd
        self.lin_err = lin_err
        self.adr_mode = adr_mode
        self.passed = passed
        self.latest = latest
        self.parens = parens

    def copy (self):
        new_cl = CodeLine(self.cmd, self.lin_err, self.passed, self.latest)
        return new_cl

    def reset(self):
        self.cmd = []
        self.lin_err = 0
        self.adr_mode = mode.NOTSET
        self.passed = True
        self.latest = TokenType.NONE

    def printerror(self):
        print("error at line ", self.lin_err)
        for token in self.cmd:
            token.printself()

    def printmore(self):
        for token in self.cmd:
            token.printself()

    def printformat(self):
        for token in self.cmd:
            print (token.str.upper(), " ", end='')
        print ("")


    # What tokens are allowed to show up next?
    # W00t W00t!!!
    def isValidNext(self, type):
        #print (self.latest, type)

        if ((self.latest == TokenType.NONE) and
        (type == TokenType.OPCODE) or
        (type == TokenType.BRANCH) or
        (type == TokenType.LABEL)):
            return True

        elif self.latest == TokenType.BRANCH and type == TokenType.REF:
            return True

        elif self.latest == TokenType.LABEL and type == TokenType.END:
            return True

        elif (self.latest == TokenType.OPCODE and
        ((type == TokenType.HTAG) or
        (type == TokenType.DOLLAR) or
        (type == TokenType.LPAREN))):
            return True

        elif self.latest == TokenType.DOLLAR and type == TokenType.HEXA:
            return True

        elif (self.latest == TokenType.HTAG and
        ((type == TokenType.DECI) or
        (type == TokenType.DOLLAR))):
            return True

        elif self.latest == TokenType.LPAREN and type == TokenType.HEXA:
            return True

        elif (self.latest == TokenType.HEXA and
        ((type == TokenType.COMMA) or
        (type == TokenType.RPAREN) or
        (type == TokenType.END))):
            return True

        elif self.latest == TokenType.DECI and type == TokenType.END:
            return True

        elif self.latest == TokenType.COMMA and (type == TokenType.XREG or type == TokenType.YREG):
            return True

        elif (((self.latest == TokenType.XREG) or (self.latest == TokenType.YREG)) and
        ((type == TokenType.RPAREN) or
        (type == TokenType.END))):
            return True

        elif (self.latest == TokenType.RPAREN and (type == TokenType.END or
        type == TokenType.COMMA)):
            return True

        elif self.latest == TokenType.REF and type == TokenType.END:
            return True
        return False

    def setLatest(self, type):
        self.latest = type

    def getLatest(self):
        return self.latest_token

    def addToken(self, token):
        self.cmd.append(token)

def analyse(tokens, codeList):
    codeLine = CodeLine()
    for token in tokens:

        if not codeLine.passed:
            codeLine.printerror()
            return

        if token.type == TokenType.END:
            if codeLine.parens != 0: #PARENS MISSING!!
                codeLine.printerror()
                return
            tmp = codeLine.copy()
            codeList.append(tmp)
            codeLine.printmore()
            print ("<--------->")
            codeLine.reset()

        elif token.type == TokenType.DOLLAR:
            codeLine.setLatest(token.getType())

        elif token.type != TokenType.COMMENT:
            codeLine.passed = codeLine.passed and codeLine.isValidNext(token.getType())
            codeLine.lin_err = token.line

            if token.type == TokenType.LPAREN:
                codeLine.parens += 1
            elif token.type == TokenType.RPAREN:
                codeLine.parens -= 1

            codeLine.addToken(token)
            codeLine.setLatest(token.getType())

#def getModeTemplate(mode):


#def comparator(codeList):




def readInstruction(codeLine):#Returns addressing mode
    instruction = codeLine.cmd[0]
    if codeLine.cmd[1] == TokenType.LPAREN:#Indirect addrmode
        pass



def main():
    codeList = []
    tokens = lex("asm")
    parse(tokens)
    #for token in tokens:
    #    token.printself()
    #print (" ")
    analyse(tokens, codeList)

    for code in codeList:
        code.printformat()
        #print ("-----------")


if __name__=="__main__":
    main()
