asmGenerate: asmGenerator
	./asmGenerator 1 > ass6_18CS30006_18CS30008_quads1.out
	./asmGenerator 2 > ass6_18CS30006_18CS30008_quads2.out
	./asmGenerator 3 > ass6_18CS30006_18CS30008_quads3.out
	./asmGenerator 4 > ass6_18CS30006_18CS30008_quads4.out
	./asmGenerator 5 > ass6_18CS30006_18CS30008_quads5.out
	./asmGenerator 6 > ass6_18CS30006_18CS30008_quads6.out

asmGenerator: lex.yy.o y.tab.o ass6_18CS30006_18CS30008_translator.o ass6_18CS30006_18CS30008_target_translator.o
	g++ lex.yy.o y.tab.o ass6_18CS30006_18CS30008_translator.o \
	ass6_18CS30006_18CS30008_target_translator.o -lfl -o asmGenerator

ass6_18CS30006_18CS30008_target_translator.o: ass6_18CS30006_18CS30008_target_translator.cxx
	g++ -c ass6_18CS30006_18CS30008_target_translator.cxx

ass6_18CS30006_18CS30008_translator.o: ass6_18CS30006_18CS30008_translator.cxx ass6_18CS30006_18CS30008_translator.h
	g++ -c ass6_18CS30006_18CS30008_translator.h
	g++ -c ass6_18CS30006_18CS30008_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

y.tab.o: y.tab.c
	g++ -c y.tab.c

lex.yy.c: ass6_18CS30006_18CS30008.l y.tab.h ass6_18CS30006_18CS30008_translator.h
	flex ass6_18CS30006_18CS30008.l

y.tab.c: ass6_18CS30006_18CS30008.y
	yacc -dtv ass6_18CS30006_18CS30008.y -Wno-yacc

y.tab.h: ass6_18CS30006_18CS30008.y
	yacc -dtv ass6_18CS30006_18CS30008.y -Wno-yacc

libass3_18CS30006_18CS30008.a: ass3_18CS30006_18CS30008.o
	ar -rcs libass3_18CS30006_18CS30008.a ass3_18CS30006_18CS30008.o

ass3_18CS30006_18CS30008.o: ass3_18CS30006_18CS30008.c myl.h
	gcc -Wall -c ass3_18CS30006_18CS30008.c
	
clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o ass6_18CS30006_18CS30008_translator.o test1 test2 test3 test4 test5 y.output asmGenerator ass6_18CS30006_18CS30008_target_translator.o libass3_18CS30006_18CS30008.a ass6_18CS30006_18CS30008_1.o ass3_18CS30006_18CS30008.o ass6_18CS30006_18CS30008_2.o ass6_18CS30006_18CS30008_3.o ass6_18CS30006_18CS30008_4.o ass6_18CS30006_18CS30008_5.o *.s *.out *.gch

#Test files
test1: ass6_18CS30006_18CS30008_1.o libass3_18CS30006_18CS30008.a
	gcc -g -no-pie ass6_18CS30006_18CS30008_1.o -o test1 -L. -lass3_18CS30006_18CS30008
ass6_18CS30006_18CS30008_1.o: myl.h
	gcc -Wall -c ass6_18CS30006_18CS30008_1.s

test2: ass6_18CS30006_18CS30008_2.o libass3_18CS30006_18CS30008.a
	gcc -g -no-pie ass6_18CS30006_18CS30008_2.o -o test2 -L. -lass3_18CS30006_18CS30008
ass6_18CS30006_18CS30008_2.o: myl.h
	gcc -Wall -c ass6_18CS30006_18CS30008_2.s

test3: ass6_18CS30006_18CS30008_3.o libass3_18CS30006_18CS30008.a
	gcc -g -no-pie ass6_18CS30006_18CS30008_3.o -o test3 -L. -lass3_18CS30006_18CS30008
ass6_18CS30006_18CS30008_3.o: myl.h
	gcc -Wall -c ass6_18CS30006_18CS30008_3.s

test4: ass6_18CS30006_18CS30008_4.o libass3_18CS30006_18CS30008.a
	gcc -g -no-pie ass6_18CS30006_18CS30008_4.o -o test4 -L. -lass3_18CS30006_18CS30008
ass6_18CS30006_18CS30008_4.o: myl.h
	gcc -Wall -c ass6_18CS30006_18CS30008_4.s

test5: ass6_18CS30006_18CS30008_5.o libass3_18CS30006_18CS30008.a
	gcc -g -no-pie ass6_18CS30006_18CS30008_5.o -o test5 -L. -lass3_18CS30006_18CS30008
ass6_18CS30006_18CS30008_5.o: myl.h
	gcc -Wall -c ass6_18CS30006_18CS30008_5.s


