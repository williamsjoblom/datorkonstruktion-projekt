import sys

if len(sys.argv) != 3:
    print("Syntax bin2vhdl FILE_NAME MEM_SIZE")
    sys.exit(1)

memsize = int(sys.argv[2])

print("(")
 
count = 0

with open(sys.argv[1], "rb") as f:
    byte = f.read(1)
    while byte != "":
        if count >= memsize:
            print("!!! MEMORY FULL !!!")
        
        print('x"' + "%0.2x" % ord(byte) + '",')
        byte = f.read(1)
        count += 1
    
    while count < memsize:
        print('x"00",')
        count += 1

print(")")
