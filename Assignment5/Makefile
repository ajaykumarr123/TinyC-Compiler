all: a.out
	
	./a.out < ass5_18CS30006_18CS30008_test1.c > ass5_18CS30006_18CS30008_quads1.out
	./a.out < ass5_18CS30006_18CS30008_test2.c > ass5_18CS30006_18CS30008_quads2.out
	./a.out < ass5_18CS30006_18CS30008_test3.c > ass5_18CS30006_18CS30008_quads3.out
	./a.out < ass5_18CS30006_18CS30008_test4.c > ass5_18CS30006_18CS30008_quads4.out
	./a.out < ass5_18CS30006_18CS30008_test5.c > ass5_18CS30006_18CS30008_quads5.out
	./a.out < ass5_18CS30006_18CS30008_test6.c > ass5_18CS30006_18CS30008_quads6.out

	@echo "DONE"

a.out: lex.yy.o y.tab.o ass5_18CS30006_18CS30008_translator.o
	g++ lex.yy.o y.tab.o ass5_18CS30006_18CS30008_translator.o -lfl

ass5_18CS30006_18CS30008_translator.o: ass5_18CS30006_18CS30008_translator.cxx ass5_18CS30006_18CS30008_translator.h
	g++ -c ass5_18CS30006_18CS30008_translator.h
	g++ -c ass5_18CS30006_18CS30008_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

y.tab.o: y.tab.c
	g++ -c y.tab.c

lex.yy.c: ass5_18CS30006_18CS30008.l y.tab.h ass5_18CS30006_18CS30008_translator.h
	flex ass5_18CS30006_18CS30008.l

y.tab.c y.tab.h: ass5_18CS30006_18CS30008.y
	yacc -dtv ass5_18CS30006_18CS30008.y -Wno-yacc

clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o ass5_18CS30006_18CS30008_translator.o y.output a.out ass5_18CS30006_18CS30008_translator.h.gch 
