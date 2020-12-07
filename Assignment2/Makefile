a.out : main.o libtoylib.a
			c++ main.o -L. -ltoylib

main.o: main.cpp toylib.h
			c++ -Wall -c main.cpp


libtoylib.a: ass2_18CS30006.o
				ar -rcs libtoylib.a ass2_18CS30006.o

ass2_18CS30006.o: ass2_18CS30006.cpp toylib.h
					 c++ -Wall -c ass2_18CS30006.cpp


clean: 
			rm -rf a.out main.o libtoylib.a ass2_18CS30006.o