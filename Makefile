NASM = nasm
NASMFLAGS = -f elf64 -g -F dwarf

GCC = gcc
GCCFLAGS = -no-pie -z noexecstack -g

# CAMBIAR ESTO POR EL NOMBRE DEL ARCHIVO QUE SE DESEA COMPILAR
# NAME = probando/4of6
NAME = probando/hex_a_ASCII
# NAME = tp
SRC = $(NAME).asm
OBJ = $(NAME).o
EXE = $(NAME)

all: $(EXE)
	./$(EXE)

$(EXE): $(OBJ)
	$(GCC)  -O0 $(OBJ) -o $(EXE) $(GCCFLAGS)

$(OBJ): $(SRC)
	$(NASM) $(NASMFLAGS) -o $(OBJ) $(SRC)

clean:
	rm -f $(OBJ) $(EXE)
