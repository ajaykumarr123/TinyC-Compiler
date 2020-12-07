%{
	#include <stdio.h>
	#include <string.h>
	#include "y.tab.h"
	extern void yyerror(const char *);
%}

/* regular definitions */

/***KEYWORD***/
KEYWORD 					"break"|"case"|"char"|"continue"|"default"|"do"|"double"|"else"|"extern"|"float"|"for"|"goto"|"switch"|"typedef"|"union"|"void"|"while"|"if"|"int"|"long"|"return"|"short"|"sizeof"|"static"|"struct"|"volatile"|"inline"|"const"|"restrict"

	
/***IDENTIFIER***/
IDENTIFIER 					{IDENTIFIER_NONDIGIT}({IDENTIFIER_NONDIGIT}|{DIGIT})*
IDENTIFIER_NONDIGIT 		[_a-zA-Z]
DIGIT						[0-9]


/***CONSTANTS***/
CONSTANT					{INTEGER_CONSTANT}|{FLOATING_CONSTANT}|{CHARACTER_CONSTANT}

INTEGER_CONSTANT			"0"|{NONZERO_DIGIT}({DIGIT})*
NONZERO_DIGIT				[1-9]

FLOATING_CONSTANT			({FRACTIONAL_CONSTANT}{EXPONENT_PART}?)|({DIGIT_SEQUENCE}{EXPONENT_PART})
FRACTIONAL_CONSTANT			({DIGIT_SEQUENCE}?"."{DIGIT_SEQUENCE})|({DIGIT_SEQUENCE}".")
EXPONENT_PART				("e"{SIGN}?{DIGIT_SEQUENCE})|("E"{SIGN}?{DIGIT_SEQUENCE})
SIGN 						"+"|"-"
DIGIT_SEQUENCE				{DIGIT}({DIGIT})*

CHARACTER_CONSTANT			"\'"{C_CHAR_SEQUENCE}"\'"
C_CHAR_SEQUENCE				{C_CHAR}+
C_CHAR 						[^("\'"|"\\"|"\n")]
ESCAPE_SEQUENCE				"\'"|"\""|"\?"|"\\"|"\a"|"\b"|"\f"|"\n"|"\r"|"\t"|"\v"

/***STRING_LITERALS****/
STRING_LITERAL 				"\""{S_CHAR_SEQUENCE}?"\""
S_CHAR_SEQUENCE				{S_CHAR}+
S_CHAR  					[^("\""|"\\"|"\n")]


/****PUNCTUATORS****/
PUNCTUATOR 					"["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"				

%x single_line_comment multi_line_comment

%%

"//"						  {BEGIN(single_line_comment);}
<single_line_comment>[^\n]	  {}
<single_line_comment>"\n"	  {BEGIN(INITIAL);}
<single_line_comment><<EOF>>  {BEGIN(INITIAL);}

"/*"						  {BEGIN(multi_line_comment);}
<multi_line_comment>[^*]	  {}
<multi_line_comment>"*"[^/]	  {}
<multi_line_comment>"*/"	  {BEGIN(INITIAL);}


{KEYWORD}		{
if(strcmp(yytext,"break")==0)			{ return BREAK; }
if(strcmp(yytext,"case")==0)			{ return CASE; }
if(strcmp(yytext,"char")==0)		  	{ return CHAR; }
if(strcmp(yytext,"continue")==0)		{ return CONTINUE; }
if(strcmp(yytext,"default")==0)			{ return DEFAULT; }
if(strcmp(yytext,"do")==0)				{ return DO; }
if(strcmp(yytext,"double")==0)			{ return DOUBLE; }
if(strcmp(yytext,"else")==0)			{ return ELSE; }
if(strcmp(yytext,"extern")==0)			{ return EXTERN; }
if(strcmp(yytext,"float")==0)			{ return FLOAT; }
if(strcmp(yytext,"for")==0)				{ return FOR; }
if(strcmp(yytext,"goto")==0)			{ return GOTO; }
if(strcmp(yytext,"switch")==0)			{ return SWITCH; }
if(strcmp(yytext,"typedef")==0)			{ return TYPEDEF; }
if(strcmp(yytext,"union")==0)			{ return UNION; }
if(strcmp(yytext,"void")==0)			{ return VOID; }
if(strcmp(yytext,"while")==0)			{ return WHILE; }
if(strcmp(yytext,"if")==0)				{ return IF; }
if(strcmp(yytext,"int")==0)				{ return INT; }
if(strcmp(yytext,"long")==0)			{ return LONG; }
if(strcmp(yytext,"return")==0)			{ return RETURN; }
if(strcmp(yytext,"short")==0)			{ return SHORT; }
if(strcmp(yytext,"sizeof")==0)			{ return SIZEOF; }
if(strcmp(yytext,"static")==0)			{ return STATIC; }
if(strcmp(yytext,"struct")==0)			{ return STRUCT; }
if(strcmp(yytext,"volatie")==0)			{ return VOLATILE; }
if(strcmp(yytext,"inline")==0)			{ return INLINE; }
if(strcmp(yytext,"const")==0)			{ return CONST; }
if(strcmp(yytext,"restrict")==0)		{ return RESTRICT; }
}


{IDENTIFIER}	{
	return IDENTIFIER;
}

{CONSTANT}	{
	return CONSTANT;
}

{STRING_LITERAL} {
	return STRING_LITERAL;
}

{PUNCTUATOR}	{
	if(strcmp(yytext,"[") == 0) return SQUARE_BRACKET_START;
	if(strcmp(yytext,"]") == 0) return SQUARE_BRACKET_END;
	if(strcmp(yytext,"(") == 0) return CIRCULAR_BRACKET_START;
	if(strcmp(yytext,")") == 0) return CIRCULAR_BRACKET_END;
	if(strcmp(yytext,"{") == 0) return CURLY_BRACKET_START;
	if(strcmp(yytext,"}") == 0) return CURLY_BRACKET_END;
	if(strcmp(yytext,"++") == 0) return INC;
	if(strcmp(yytext,"--") == 0) return DEC;
	if(strcmp(yytext,"*") == 0) return MUL;
	if(strcmp(yytext,"-") == 0) return SUB;
	if(strcmp(yytext,"+") == 0) return ADD;
	if(strcmp(yytext,"!") == 0) return EXCLAIM;
	if(strcmp(yytext,"/") == 0) return DIV;
	if(strcmp(yytext,"%") == 0) return MOD;
	if(strcmp(yytext,"<") == 0) return LT;
	if(strcmp(yytext,">") == 0) return GT;
	if(strcmp(yytext,"<=") == 0) return LTE;
	if(strcmp(yytext,">=") == 0) return GTE;
	if(strcmp(yytext,"==") == 0) return EQ_CHECK;
	if(strcmp(yytext,"!=") == 0) return NOT_EQ_CHECK;
	if(strcmp(yytext,"<<") == 0) return SHIFT_LEFT;
	if(strcmp(yytext,">>") == 0) return SHIFT_RIGHT;
	if(strcmp(yytext,"~") == 0) return BITWISE_NOT;
	if(strcmp(yytext,"&") == 0) return BITWISE_AND;
	if(strcmp(yytext,"^") == 0) return BITWISE_XOR;
	if(strcmp(yytext,"|") == 0) return BITWISE_OR;
	if(strcmp(yytext,"&&") == 0) return AND;
	if(strcmp(yytext,"||") == 0) return OR;
	if(strcmp(yytext,"?") == 0) return QUESTION;
	if(strcmp(yytext,":") == 0) return COLON;
	if(strcmp(yytext,";") == 0) return SEMICOLON;
	if(strcmp(yytext,"...") == 0) return DOTS;
	if(strcmp(yytext,"=") == 0) return ASSIGN;
	if(strcmp(yytext,"<<=") == 0) return SHIFTL_EQ;
	if(strcmp(yytext,">>=") == 0) return SHIFTR_EQ;
	if(strcmp(yytext,"*=") == 0) return MULT_EQ;
	if(strcmp(yytext,"/=") == 0) return DIV_EQ;
	if(strcmp(yytext,"%=") == 0) return MOD_EQ;
	if(strcmp(yytext,"+=") == 0) return ADD_EQ;
	if(strcmp(yytext,"-=") == 0) return SUB_EQ;
	if(strcmp(yytext,"&=") == 0) return BITWISE_AND_EQ;
	if(strcmp(yytext,"^=") == 0) return BITWISE_XOR_EQ;
	if(strcmp(yytext,"|=") == 0) return BITWISE_OR_EQ;
	if(strcmp(yytext,",") == 0) return COMMA;
	if(strcmp(yytext,"#") == 0) return HASH;
	if(strcmp(yytext,".") == 0) return DOT;
	if(strcmp(yytext,"->") == 0) return IMPLIES;
}

{ESCAPE_SEQUENCE}|" "		{ /* do nothing and no return */}

%%




