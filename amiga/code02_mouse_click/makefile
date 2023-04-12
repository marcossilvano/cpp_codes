CC=m68k-amigaos-gcc
CFLAGS=-mcrt=nix13

EXES=prog1

all: $(EXES)

clean:
	rm -f $(EXES)

prog1: *.c
	$(CC) $(CFLAGS) -o $@ $?