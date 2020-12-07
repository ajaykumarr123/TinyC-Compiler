%{
	#include "header.h"
%}

/* regular definitions */

/***KEYWORD***/
KEYWORD 					"break"|"case"|"char"|"continue"|"default"|"do"|"double"|"else"|"extern"|"float"|"for"|"goto"|"switch"|"typedef"|"union"|"void"|"while"|"if"|"int"|"long"|"return"|"short"|"sizeof"|"static"|"struct"

	
/***IDENTIFIER***/
IDENTIFIER 					{IDENTIFIER_NONDIGIT}({IDENTIFIER_NONDIGIT}|{DIGIT})*
IDENTIFIER_NONDIGIT 		[_a-zA-Z]
DIGIT						[0-9]


/***CONSTANTS***/
CONSTANT					"0"|{INTEGER_CONSTANT}|{FLOATING_CONSTANT}|{CHARACTER_CONSTANT}

INTEGER_CONSTANT			{NONZERO_DIGIT}({DIGIT})*
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


{KEYWORD}  					{ return KEYWORD; }
{IDENTIFIER} 				{ return IDENTIFIER; }
{CONSTANT} 					{ return CONSTANT; }
{STRING_LITERAL} 			{ return STRING_LITERAL; }
{PUNCTUATOR} 				{ return PUNCTUATOR; }
{ESCAPE_SEQUENCE}|" "		{ /* do nothing and no return */}

%%