from enum import Enum
import os

class TokenType(Enum):
    NONE = 0
    NUMBER = 1
    INSTRUCTION = 2
    LABEL = 3
    HTAG = 4
    COMMA = 5
    COMMENT = 6
    RBRACKET = 7
    LBRACKET = 8
    COLON = 9
    DOLLAR = 10

    #DEFINE

class Token:
    TokenType = TokenType.NONE
    tokenStr = "Null"
    row = -1

    def __init__(self, TokenType, tokenStr, row):
        self.TokenType = TokenType
        self.tokenStr = tokenStr
        self.row = row

    def tokenPrint(self):
        print self.TokenType+" "+self.tokenStr+" row:"+self.row


def main():
    tokenList = []
    row = -1
    fileName = input("Enter file name:")
    with open('fileName') as openFile:
        #Make Lowercase???
        for line in openfile:
            row += 1
            wordList = line.split()
            for str in wordList:
                evalWord(str, row, tokenList)


def evalWord(str, row, tokenList):

    if isStructure(str[0]):
        type = getStructureType(str[0])
        token = Token(type, str[0], row)
        tokenList.append(token)
        if str[1:]: evalWord(str[1:])

    elif str[len(str)-1] == ":":#Label is prioritized since a label can also be 3 characters long
        token = Token(TokenType.LABEL,str, row)
        tokenList.append(token)

    elif isInstruction(str[0:2]):
        token = Token(TokenType.INSTRUCTION, str, row)
        if str[1:]: evalWord(str[1:])#Unnecessary, since we already assume the code is written properly

    elif isNumber(str):
        token = Token(TokenType.NUMBER,str, row)
        tokenList.append(token)

    else:
        token = Token(TokenType.NONE,str, row)
        tokenList.append(token)


def getWordList(file):
    f = open('file','r')
    string = f.read()
    f.close()
    wordList = string.spit()
    return [string, wordList]


def isNumber(str):
    for c in str:
        if not c in "1234567890ABCDEF":
            return False
        return True


def isCharacter(char):
    characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return char in characters


def isStructure(char):
    structure = ";:,[]()#$"
    return char in structure


def isInstruction(str):
    instructions = ["ADC","AND","ASL","BCS","BEQ","BIT","BMI","BNE","BPL","BVS","CLC","CLV","CMP","DEX","EOR","INX","JMP","JSR","LDA","LSR","NOP","ORA","PHA","PLA","RTS","SBC","SEC","STA","TAX","TXA","TAY","TYA"]
    for elem in instructions:
        if elem == str:
            return True
    return False


def getStructureType(char):
    if char == ",":
        return TokenType.COMMA
    elif char == "#":
        return TokenType.HTAG
    elif char == ";":
        return TokenType.COMMENT
    elif char == "[":
        return TokenType.LBRACKET
    elif char == "]":
        return TokenType.RBRACKET
    elif char == ":":
        return TokenType.COLON
    elif char == "$":
        return TokenType.DOLLAR


if __name__ == "__main__":
    main()
