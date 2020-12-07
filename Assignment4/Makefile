a.out: lex.yy.o y.tab.o asgn4_18CS30006_main.o
	gcc lex.yy.o y.tab.o asgn4_18CS30006_main.o -lfl

asgn4_18CS30006.o: asgn4_18CS30006_main.c
	gcc -c asgn4_18CS30006_main.c

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c -lfl

y.tab.o: y.tab.c
	gcc -c y.tab.c

lex.yy.c: asgn4_18CS30006.l y.tab.h
	flex asgn4_18CS30006.l

y.tab.c y.tab.h: asgn4_18CS30006.y
	yacc -dtv asgn4_18CS30006.y -Wno-yacc

clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o asgn4_18CS30006_main.o y.output a.out asgn4_18CS30006_output.txt

test: 
	./a.out < asgn4_18CS30006_test.c > asgn4_18CS30006_output.txt