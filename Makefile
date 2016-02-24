PLC=gplc
PLFLAGS=--no-top-level

SRC=main.pl io.pl chem.pl chem_parser.pl parser.pl
OBJ=main.o io.o chem.o chem_parser.o parser.o

CLUTTER=*.o *~


chem:
	$(PLC) $(PLFLAGS) main.pl

object: $(OBJ)

%.o: %.pl
	$(PLC) -c $<


clean:
	rm -f $(CLUTTER)
