from __future__ import print_function
import os


dec = "1234567890"
hexa = "1234567890abcdef"
letter = "abcdefghijklmnopqrstuvwxyz_:"
opt = ",.;()[]#$-"

class TokenType():
    # Some of these are not used..
    # Some will be used or changed into in parsing step.
    ERR = -1

    NONE = 0
    HEXA = 1
    DECI = 2
    LETTER = 3
    OPCODE = 17
    MODE = 20

    COMMA = 4
    DOT = 5
    SCOMMENT = 6
    COLON = 7
    LPAREN = 8
    RPAREN = 9
    LBRACKET = 10
    RBRACKET = 11
    SLASH = 12
    HTAG = 13
    DOLLAR = 14
    COMMENT = 15
    WORD = 16
    LABEL = 18
    BRANCH = 19
    REF = 21
    END = 22
    XREG = 23
    YREG = 24

class Token ():
    str = ""    #Actual string that token represents.
    type = TokenType.NONE #Enum type.
    s_type = TokenType.NONE
    line = -1   #Line index in file. (for debugging later on).
    index = -1  #Line index after removal of line breaks.

    def __init__(self, str = "", type = TokenType.NONE, line = -1, index = -1):
        self.type = type
        self.str = str
        self.line = line
        self.index = index

    def printself (self):
        print (self.str, self.type, self.line, self.index)

    def isDec (self):
        def isDec_int(str):
            if len(str) == 1:
                return str in dec
            else:
                return str[0] in dec and isDec_int(str[1:])
        return isDec_int(self.str)

    def isHex (self):
        def isHex_int(str):
            if len(str) == 1:
                return str in hexa
            else:
                return str[0] in hexa and isHex_int(str[1:])
        return isHex_int(self.str)

    def isLabel (self):
        def isLabel_int(str):
            if len(str) == 1:
                if str == ':':
                    return True
                return False
            else:
                return str[0] in letter and isLabel_int(str[1:])
        return isLabel_int(self.str)

    def isComment (self):
        res = (self.type == TokenType.SCOMMENT or self.type == TokenType.COMMENT)
        return res

    def getType(self):
        return self.type



def genTokens(string, tokenList, row, index):
    # Expects one string as input from generated list of possible tokens.
    tok = Token()
    for char in string:

        # Token has already been determinded  to be of type LETTER.
        if charLetOrDec(char) and tok.type == TokenType.WORD:
            tok.str += char

        # If Token is of type NONE, init as LETTER.
        elif charLetOrDec(char) and tok.type == TokenType.NONE:
            tok = Token(char, TokenType.WORD,row, index)

        # If Token is of type NONE, init as curent type.
        elif charOpt(char) and tok.type == TokenType.NONE:
            tok = Token(char, getType(char), row, index)
            tok.s_type = TokenType.MODE
            tokenList.append(tok)
            tok = Token()
        # If token already is inited as something else,
        # add that to list and re-init.
        elif charOpt(char) and tok.type != TokenType.NONE:
            tokenList.append(tok)
            tok = Token(char, getType(char), row, index)
            tok.s_type = TokenType.MODE
            tokenList.append(tok)
            tok = Token()

        # If char is of unknown or unwanted value, init as ERR.
        elif isOthers(char):
            tokenList.append(tok)
            tok = Token(char, TokenType.ERR, row, index)
            tokenList.append(tok)
            tok = Token()

    if tok.type != TokenType.NONE:
        tokenList.append(tok)

def charDec (char):
    return (char in dec)

def charHex (char):
    return (char in hexa)

def charLetter (char):
    return (char in letter)

def charLetOrDec (char):
    return (char in letter or char in dec)

def charOpt (char):
    return (char in opt)



def isOthers (char):
    test = not charLetter(char) and not charOpt(char)
    return test

def getType(char):
    if isOthers(char):
        return TokenType.ERR

    if char == "#":
        return TokenType.HTAG
    elif char == "$":
        return TokenType.DOLLAR
    elif char == ":":
        return TokenType.COLON
    elif char == ";":
        return TokenType.COMMENT
    elif char == "[":
        return TokenType.LBRACKET
    elif char == "]":
        return TokenType.RBRACKET
    elif char == "(":
        return TokenType.LPAREN
    elif char == ")":
        return TokenType.RPAREN
    elif char == ",":
        return TokenType.COMMA
    elif char == ".":
        return TokenType.DOT
    elif isLetter(char):
        return TokenType.LETTER
    #elif char == "-":
    #    return TokenType.COMMENT

def getCode (_file_):
    rowList = []
    row = 0
    index = -1
    with open(_file_) as openFile:
        for line in openFile:
            row += 1
            lowerLine = line.lower()
            split = lowerLine.split()
            if split != []:
                index += 1

            for elem in split:
                rowList.append((elem, row, index))
            rowList.append(("endofline", row, index))

    return rowList

# Lexer() returns a list with tokens.
def lex(_file_):
    tokenList = []
    wordList = getCode(_file_)
    for elem in wordList:
        genTokens(elem[0], tokenList, elem[1], elem[2])

    #for token in tokenList:
        #token.printself()

    return tokenList

def main():
    print ("main in lexer.py")
    print ("call from parser..")

if __name__=="__main__":
    main()
