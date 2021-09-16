
# THIS MAKEFILE WAS AUTOMATICALLY GENERATED VIA CONFIGURE SCRIPT. PLEASE DO NOT MODIFY IT.

.PHONY: clean, mrproper

CC = gcc
OCC = gcc
CFLAGS = -Wall -O0
DEPS = $(wildcard test/test_1_fieldmult.S)
DEPH = param.h mode.h
OBJ = main.o


hom_ec17: main.c $(DEPH) $(DEPS)
	$(CC) $(CFLAGS) $? -o $@ 

# clean
clean:
	rm -rf *~ rm -rf *.o rm -rf rm src/*~ rm -rf src/*.o rm -rf test/*~
	rm -rf hom_ec17

