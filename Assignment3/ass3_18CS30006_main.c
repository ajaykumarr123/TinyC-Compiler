#include<stdio.h>
#include "header.h"

extern int yylex ();
extern char* yytext;

int main()
{

	printf("\n\n---------starting interactive main---------\n\n");

	extern FILE *yyin; 
	yyin = fopen("ass3_18CS30006_test.c","r");
	
	int token;
	while(token = yylex()){
		switch (token)
		{
		case KEYWORD:
			{printf("<KEYWORD, %d, %s>\n", token, yytext); break;}
		case IDENTIFIER:
			{printf("<IDENTIFIER, %d, %s>\n", token, yytext); break;}
		case CONSTANT:
			{printf("<CONSTANT, %d, %s>\n", token, yytext); break;}
		case STRING_LITERAL:
			{printf("<STRING_LITERAL, %d, %s>\n", token, yytext); break;}
		case PUNCTUATOR:
			{printf("<PUNCTUATOR, %d, %s>\n", token, yytext); break;}
		default:
			{break;}
		}
	}

	fclose(yyin);
	return 0;
}