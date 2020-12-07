a.out : lex.yy.c ass3_18CS30006_main.c header.h
		gcc ass3_18CS30006_main.c lex.yy.c -lfl

lex.yy.c :	header.h ass3_18CS30006.l
		flex ass3_18CS30006.l

clean :
	rm -f a.out lex.yy.c

run : a.out
	./a.out