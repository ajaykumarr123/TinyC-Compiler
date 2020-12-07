%{

#include <bits/stdc++.h>
#include <cstdlib>
#include <sstream>
#include "ass6_18CS30006_18CS30008_translator.h"
#include "y.tab.h"
extern int yylex();
void yyerror(string s);
extern string Type;
vector <string> allstrings;
using namespace std;
%}


%union {
  int intval;
  float floatval;
  char* charval;
  int instr;
  sym* symp;
  symtype* symtp;
  expr* E;
  statement* S;
  Array* A;
  char unaryOperator;
}

%token POINTSTO
%token INCREMENT
%token DECREMENT
%token LEFTSHIFT
%token RIGHTSHIFT
%token LESSTHANOREQUAL
%token GREATERTHANOREQUAL
%token EQUALSTO
%token NOTEQUAL
%token AND
%token OR
%token ELLIPSIS

%token MULTIPLYEQUAL
%token DIVIDEEQUAL
%token PERCENTEQUAL
%token PLUSEQUAL
%token MINUSEQUAL
%token LEFTSHIFTEQUAL
%token RIGHTSHIFTEQUAL
%token ANDEQUAL
%token OREQUAL
%token XOREQUAL
%expect 2
%token AUTO
%token RESTRICT
%token UNSIGNED
%token BREAK 
%token EXTERN
%token RETURN
%token VOID
%token CASE 
%token FLOAT
%token SHORT
%token VOLATILE
%token CHAR
%token FOR
%token SIGNED
%token WHILE
%token CONST 
%token GOTO
%token SIZEOF
%token BOOL
%token CONTINUE
%token IF
%token STATIC
%token COMPLEX
%token DEFAULT
%token INLINE
%token STRUCT
%token IMAGINARY
%token DO
%token INT
%token SWITCH
%token LONG
%token TYPEDEF
%token ELSE
%token REGISTER
%token UNION
%token <symp> IDENTIFIER
%token <intval> INT_CONST
%token <charval> FLOAT_CONST
%token <charval> CHAR_CONST
%token <charval> STRING_LITERAL


%token OPENSQUAREBRACKET
%token CLOSESQUAREBRACKET
%token OPENROUNDBRACKET
%token CLOSEROUNDBRACKET
%token OPENFLOWERBRACKET
%token CLOSEFLOWERBRACKET
%token QUESTION
%token COLON
%token SEMICOLON
%token EQUAL
%token XOR
%token VERTICALSLASH
%token AMPERSAND
%token ASTERISK
%token PLUS
%token MINUS
%token TILDE
%token EXCLAMATION
%token PERIOD
%token FORWARDSLASH
%token PERCENT
%token LESSTHAN
%token GREATERTHAN
%token COMMA
%token HASH


%token WS

%start translation_unit
// to remove else ambiguity
%right THEN ELSE

// Expressions
%type <E>
	expression
	primary_expression 
	multiplicative_expression
	additive_expression
	shift_expression
	relational_expression 
	equality_expression
	AND_expression
	XOR_expression
	OR_expression
	logical_AND_expression
	logical_OR_expression
	conditional_expression
	assignment_expression
	expression_statement

%type <intval> argument_expression_list

// Array to be used later
%type <A> postfix_expression
	unary_expression
	cast_expression

%type <unaryOperator> unary_operator
%type <symp> constant initializer
%type <symp> direct_declarator init_declarator declarator
%type <symtp> pointer

// Auxillary non terminals M and N
%type <instr> M
%type <S> N


// Statements
%type <S>  statement
	labeled_statement 
	compound_statement
	selection_statement
	iteration_statement
	jump_statement
	block_item
	block_item_list

%%

primary_expression: IDENTIFIER
	{
		$$ = new expr();
		$$->loc = $1;
		$$->type = "NONBOOL";
	}
	| constant 
	{
		$$ = new expr();
		$$->loc = $1;
	}
	| STRING_LITERAL 
	{
		$$ = new expr();
		symtype* tmp = new symtype("PTR");
		$$->loc = gentemp(tmp, $1);
		$$->loc->type->ptr = new symtype("CHAR");

		allstrings.push_back($1);
		stringstream strs;
		strs << allstrings.size()-1;
		string temp_str = strs.str();
		char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);
		emit("EQUALSTR", $$->loc->name, str);

	}
	| OPENROUNDBRACKET expression CLOSEROUNDBRACKET
	{
		$$ = $2;
	}
	;

constant: INT_CONST
	{
		stringstream strs;
		strs << $1;
		string temp_str = strs.str();
		char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);
		$$ = gentemp(new symtype("INTEGER"), str);
		emit("EQUAL", $$->name, $1);
	}
	| FLOAT_CONST
	{
		$$ = gentemp(new symtype("FLOAT"), string($1));
		emit("EQUAL", $$->name, string($1));
	}
	| CHAR_CONST
	{
		$$ = gentemp(new symtype("CHAR"),$1);
		emit("EQUAL", $$->name, string($1));
	}
	;

postfix_expression: primary_expression
	{
		$$ = new Array ();
		$$->Array = $1->loc;
		$$->loc = $$->Array;
		$$->type = $1->loc->type;
	}
	| postfix_expression OPENSQUAREBRACKET expression CLOSESQUAREBRACKET
	{
		$$ = new Array();
		$$->Array = $1->loc;					// copy the base
		$$->type = $1->type->ptr;				// type = type of element
		$$->loc = gentemp(new symtype("INTEGER"));		// store computed address
		
		
		if ($1->cat=="ARR") {						
			sym* t = gentemp(new symtype("INTEGER"));
			stringstream strs;
		    strs <<size_type($$->type);
		    string temp_str = strs.str();
		    char* intStr = (char*) temp_str.c_str();
			string str = string(intStr);				
 			emit ("MULT", t->name, $3->loc->name, str);
			emit ("ADD", $$->loc->name, $1->loc->name, t->name);
		}
 		else {
 			stringstream strs;
		    strs <<size_type($$->type);
		    string temp_str = strs.str();
		    char* intStr1 = (char*) temp_str.c_str();
			string str1 = string(intStr1);		
	 		emit("MULT", $$->loc->name, $3->loc->name, str1);
 		}
 		// Mark that it contains array address and first time computation is done
		$$->cat = "ARR";
	}
	| postfix_expression OPENROUNDBRACKET CLOSEROUNDBRACKET
	{
		// no semantic action required at this stage
	}
	| postfix_expression OPENROUNDBRACKET argument_expression_list CLOSEROUNDBRACKET
	{
		$$ = new Array();
		$$->Array = gentemp($1->type);
		stringstream strs;
	    strs <<$3;
	    string temp_str = strs.str();
	    char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);		
		emit("CALL", $$->Array->name, $1->Array->name, str);
	}
	| postfix_expression PERIOD IDENTIFIER
	{
		// no semantic action required at this stage
	}
	| postfix_expression POINTSTO IDENTIFIER
	{
		// no semantic action required at this stage
	}
	| postfix_expression INCREMENT
	{
		$$ = new Array();

		// copy $1 to $$
		$$->Array = gentemp($1->Array->type);
		emit ("EQUAL", $$->Array->name, $1->Array->name);

		// Increment $1
		emit ("ADD", $1->Array->name, $1->Array->name, "1");
	}
	| postfix_expression DECREMENT
	{
		$$ = new Array();

		// copy $1 to $$
		$$->Array = gentemp($1->Array->type);
		emit ("EQUAL", $$->Array->name, $1->Array->name);

		// Decrement $1
		emit ("SUB", $1->Array->name, $1->Array->name, "1");
	}
	| OPENROUNDBRACKET type_name CLOSEROUNDBRACKET OPENFLOWERBRACKET initializer_list CLOSEFLOWERBRACKET
	{
		$$ = new Array();
		$$->Array = gentemp(new symtype("INTEGER"));
		$$->loc = gentemp(new symtype("INTEGER"));
	}
	|  OPENROUNDBRACKET type_name CLOSEROUNDBRACKET OPENFLOWERBRACKET initializer_list COMMA CLOSEFLOWERBRACKET
	{
		$$ = new Array();
		$$->Array = gentemp(new symtype("INTEGER"));
		$$->loc = gentemp(new symtype("INTEGER"));
	}
	;

argument_expression_list: assignment_expression
	{
		emit ("PARAM", $1->loc->name);
		$$ = 1;
	}
	| argument_expression_list COMMA assignment_expression
	{
		emit ("PARAM", $3->loc->name);
		$$ = $1+1;
	}
	;

unary_expression: postfix_expression
	{
		$$ = $1;
	}
	| INCREMENT unary_expression
	{
		// Increment $2
		emit ("ADD", $2->Array->name, $2->Array->name, "1");

		// Use the same value as $2
		$$ = $2;
	}
	| DECREMENT unary_expression
	{
		// Decrement $2
		emit ("SUB", $2->Array->name, $2->Array->name, "1");

		// Use the same value as $2
		$$ = $2;
	}
	| unary_operator cast_expression
	{
		$$ = new Array();
		switch ($1) {
			case '&':
				$$->Array = gentemp((new symtype("PTR")));
				$$->Array->type->ptr = $2->Array->type; 
				emit ("ADDRESS", $$->Array->name, $2->Array->name);
				break;
			case '*':
				$$->cat = "PTR";
				$$->loc = gentemp ($2->Array->type->ptr);
				emit ("PTRR", $$->loc->name, $2->Array->name);
				$$->Array = $2->Array;
				break;
			case '+':
				$$ = $2;
				break;
			case '-':
				$$->Array = gentemp(new symtype($2->Array->type->type));
				emit ("UMINUS", $$->Array->name, $2->Array->name);
				break;
			case '~':
				$$->Array = gentemp(new symtype($2->Array->type->type));
				emit ("BNOT", $$->Array->name, $2->Array->name);
				break;
			case '!':
				$$->Array = gentemp(new symtype($2->Array->type->type));
				emit ("LNOT", $$->Array->name, $2->Array->name);
				break;
			default:
				break;
		}
	}
	| SIZEOF unary_expression
	{
		// no semantic action required at this stage
	}
	| SIZEOF OPENROUNDBRACKET type_name CLOSEROUNDBRACKET
	{
		// no semantic action required at this stage
	}
	;

unary_operator: AMPERSAND
	{
		$$ = '&';
	}
	| ASTERISK 
	{
		$$ = '*';
	}
	| PLUS
	{
		$$ = '+';
	}
	| MINUS
	{
		$$ = '-';
	}
	| TILDE
	{
		$$ = '~';
	}
	| EXCLAMATION
	{
		$$ = '!';
	}
	;		

cast_expression: unary_expression
	{
		$$=$1;
	}
	| OPENROUNDBRACKET type_name CLOSEROUNDBRACKET cast_expression
	{
		$$=$4;
	}
	;

multiplicative_expression: cast_expression
	{
		$$ = new expr();
		if ($1->cat=="ARR") { // Array
			$$->loc = gentemp($1->loc->type);
			emit("ARRR", $$->loc->name, $1->Array->name, $1->loc->name);
		}
		else if ($1->cat=="PTR") { // Pointer
			$$->loc = $1->loc;
		}
		else { // otherwise
			$$->loc = $1->Array;
		}
	}
	| multiplicative_expression ASTERISK cast_expression
	{
		if (typecheck ($1->loc, $3->Array) ) {
			$$ = new expr();
			$$->loc = gentemp(new symtype($1->loc->type->type));
			emit ("MULT", $$->loc->name, $1->loc->name, $3->Array->name);
		}
		else {
			cout << "Type Error"<< endl;
		}
	}
	| multiplicative_expression FORWARDSLASH cast_expression
	{
		if (typecheck ($1->loc, $3->Array) ) {
			$$ = new expr();
			$$->loc = gentemp(new symtype($1->loc->type->type));
			emit ("DIVIDE", $$->loc->name, $1->loc->name, $3->Array->name);
		}
		else {
			cout << "Type Error"<< endl;
		}
	}
	| multiplicative_expression PERCENT cast_expression
	{
		if (typecheck ($1->loc, $3->Array) ) {
			$$ = new expr();
			$$->loc = gentemp(new symtype($1->loc->type->type));
			emit ("MODOP", $$->loc->name, $1->loc->name, $3->Array->name);
		}
		else {
			cout << "Type Error"<< endl;
		}
	}
	;

additive_expression: multiplicative_expression 
	{
		$$=$1;
	}
	|additive_expression PLUS multiplicative_expression 
	{
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->loc = gentemp(new symtype($1->loc->type->type));
			emit ("ADD", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	|additive_expression MINUS multiplicative_expression 
	{
			if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->loc = gentemp(new symtype($1->loc->type->type));
			emit ("SUB", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

shift_expression: additive_expression{
		$$=$1;
	}
	|shift_expression LEFTSHIFT additive_expression 
	{
		if ($3->loc->type->type == "INTEGER") {
			$$ = new expr();
			$$->loc = gentemp (new symtype("INTEGER"));
			emit ("LEFTOP", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	|shift_expression RIGHTSHIFT additive_expression
	{
		if ($3->loc->type->type == "INTEGER") {
			$$ = new expr();
			$$->loc = gentemp (new symtype("INTEGER"));
			emit ("RIGHTOP", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;	

relational_expression: shift_expression 
	{
		$$=$1;
	}
	|relational_expression LESSTHAN shift_expression 
	{
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("LT", "", $1->loc->name, $3->loc->name);
			emit ("GOTO", "");
		}
		else cout << "Type Error"<< endl;
	}
	|relational_expression GREATERTHAN shift_expression 
	{
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("GT", "", $1->loc->name, $3->loc->name);
			emit ("GOTO", "");
		}
		else cout << "Type Error"<< endl;
	}
	|relational_expression LESSTHANOREQUAL shift_expression 
	{
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("LE", "", $1->loc->name, $3->loc->name);
			emit ("GOTO", "");
		}
		else cout << "Type Error"<< endl;
	}
	|relational_expression GREATERTHANOREQUAL shift_expression 
	{
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("GE", "", $1->loc->name, $3->loc->name);
			emit ("GOTO", "");
		}
		else cout << "Type Error"<< endl;
	}
	;

equality_expression: relational_expression
	{
		$$=$1;
	}
	|equality_expression EQUALSTO relational_expression 
	{
		if (typecheck ($1->loc, $3->loc)) {
			convertBool2Int ($1);
			convertBool2Int ($3);

			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("EQOP", "", $1->loc->name, $3->loc->name);
			emit ("GOTO", "");
		}
		else cout << "Type Error"<< endl;
	}
	|equality_expression NOTEQUAL relational_expression 
	{
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convertBool2Int ($1);
			convertBool2Int ($3);

			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("NEOP", "", $1->loc->name, $3->loc->name);
			emit ("GOTO", "");
		}
		else cout << "Type Error"<< endl;
	}
	;

AND_expression: equality_expression
	{
		$$=$1;
	}
	|AND_expression AMPERSAND equality_expression 
	{
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convertBool2Int ($1);
			convertBool2Int ($3);
			
			$$ = new expr();
			$$->type = "NONBOOL";

			$$->loc = gentemp (new symtype("INTEGER"));
			emit ("BAND", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

XOR_expression: AND_expression
	{
		$$=$1;
	}
	|XOR_expression XOR AND_expression 
	{
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convertBool2Int ($1);
			convertBool2Int ($3);
			
			$$ = new expr();
			$$->type = "NONBOOL";

			$$->loc = gentemp (new symtype("INTEGER"));
			emit ("XOR", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

OR_expression: XOR_expression
	{
		$$=$1;
	}
	| OR_expression VERTICALSLASH XOR_expression
	{
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convertBool2Int ($1);
			convertBool2Int ($3);
			
			$$ = new expr();
			$$->type = "NONBOOL";

			$$->loc = gentemp (new symtype("INTEGER"));
			emit ("INOR", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

logical_AND_expression: OR_expression
	{
		$$=$1;
	}
	| logical_AND_expression N AND M OR_expression 
	{
		convertInt2Bool($5);

		// convert $1 to bool and backpatch using N
		backpatch($2->nextlist, nextinstr());
		convertInt2Bool($1);

		$$ = new expr();
		$$->type = "BOOL";

		backpatch($1->truelist, $4);
		$$->truelist = $5->truelist;
		$$->falselist = merge ($1->falselist, $5->falselist);
	}
	;

logical_OR_expression: logical_AND_expression
	{
		$$=$1;
	}
	|logical_OR_expression N OR M logical_AND_expression 
	{
		convertInt2Bool($5);

		// convert $1 to bool and backpatch using N
		backpatch($2->nextlist, nextinstr());
		convertInt2Bool($1);

		$$ = new expr();
		$$->type = "BOOL";

		backpatch ($$->falselist, $4);
		$$->truelist = merge ($1->truelist, $5->truelist);
		$$->falselist = $5->falselist;
	}
	;

M 	: %empty{	// To store the address of the next instruction
		$$ = nextinstr();
	};

N 	: %empty { 	// gaurd against fallthrough by emitting a goto
		$$  = new statement();
		$$->nextlist = makelist(nextinstr());
		emit ("GOTO","");
	}

conditional_expression: logical_OR_expression
	{
		$$=$1;
	}
	|logical_OR_expression N QUESTION M expression N COLON M conditional_expression 
	{
		$$->loc = gentemp($5->loc->type);
		$$->loc->update($5->loc->type);
		emit("EQUAL", $$->loc->name, $9->loc->name);
		list<int> l = makelist(nextinstr());
		emit ("GOTO", "");

		backpatch($6->nextlist, nextinstr());
		emit("EQUAL", $$->loc->name, $5->loc->name);
		list<int> m = makelist(nextinstr());
		l = merge (l, m);
		emit ("GOTO", "");

		backpatch($2->nextlist, nextinstr());
		convertInt2Bool($1);
		backpatch ($1->truelist, $4);
		backpatch ($1->falselist, $8);
		backpatch (l, nextinstr());
	}
	;

assignment_expression: conditional_expression
	{
		$$=$1;
	}
	|unary_expression assignment_operator assignment_expression 
	{
		if($1->cat=="ARR") {
			$3->loc = conv($3->loc, $1->type->type);
			emit("ARRL", $1->Array->name, $1->Array->name, $3->loc->name);	
			}
		else if($1->cat=="PTR") {
			emit("PTRL", $1->Array->name, $3->loc->name);	
			}
		else{
			$3->loc = conv($3->loc, $1->Array->type->type);
			emit("EQUAL", $1->Array->name, $3->loc->name);
			}
		$$ = $3;
	}
	;

assignment_operator: EQUAL
	{
		// no semantic action required at this stage
	}
	| MULTIPLYEQUAL
	{
		// no semantic action required at this stage
	}
	| DIVIDEEQUAL
	{
		// no semantic action required at this stage
	}
	| PERCENTEQUAL
	{
		// no semantic action required at this stage
	}
	| PLUSEQUAL
	{
		// no semantic action required at this stage
	}
	| MINUSEQUAL	
	{
		// no semantic action required at this stage
	}
	| LEFTSHIFTEQUAL	
	{
		// no semantic action required at this stage
	}
	| RIGHTSHIFTEQUAL
	{
		// no semantic action required at this stage
	}
	| ANDEQUAL
	{
		// no semantic action required at this stage
	}
	| XOREQUAL
	{
		// no semantic action required at this stage
	}
	| OREQUAL
	{
		// no semantic action required at this stage
	}
	;

expression: assignment_expression
	{
		$$=$1;
	}
	| expression COMMA assignment_expression
	{
		// no semantic action required at this stage
	}
	;

constant_expression: conditional_expression
	{
		// no semantic action required at this stage
	}
	;


declaration: declaration_specifiers SEMICOLON
	{
		// no semantic action required at this stage
	}
	| declaration_specifiers init_declarator_list SEMICOLON
	{
		// no semantic action required at this stage
	}
	;

declaration_specifiers: storage_class_specifier
	{
		// no semantic action required at this stage
	}
	| storage_class_specifier declaration_specifiers
	{
		// no semantic action required at this stage
	}
	| type_specifier
	{
		// no semantic action required at this stage
	}
	| type_specifier declaration_specifiers
	{
		// no semantic action required at this stage
	}
	| type_qualifier
	{
		// no semantic action required at this stage
	}
	| type_qualifier declaration_specifiers
	{
		// no semantic action required at this stage
	}
	| function_specifier 
	{
		// no semantic action required at this stage
	}
	| function_specifier declaration_specifiers
	{
		// no semantic action required at this stage
	}
	;	

init_declarator_list: init_declarator
	{
		// no semantic action required at this stage
	}
	| init_declarator_list COMMA init_declarator
	{
		// no semantic action required at this stage
	}
	;

init_declarator: declarator
	{
		$$=$1;
	}
	| declarator EQUAL initializer
	{
		if ($3->initial_value!="") $1->initial_value=$3->initial_value;
		emit ("EQUAL", $1->name, $3->name);
	}
	;

storage_class_specifier: EXTERN
	{
		// no semantic action required at this stage
	}
	| STATIC
	{
		// no semantic action required at this stage
	}
	| AUTO
	{
		// no semantic action required at this stage
	}
	| REGISTER
	{
		// no semantic action required at this stage
	}
	;	

type_specifier: VOID 
	{
		Type="VOID";
	}
	| CHAR 
	{
		Type="CHAR";
	}
	| SHORT 
	| INT 
	{
		Type="INTEGER";
	}
	| LONG
	| FLOAT 
	{
		Type="FLOAT";
	}
	| SIGNED
	| UNSIGNED
	| BOOL
	| COMPLEX
	| IMAGINARY
	;


specifier_qualifier_list: type_specifier specifier_qualifier_list
	{
		// no semantic action required at this stage
	}
	| type_specifier
	{
		// no semantic action required at this stage
	}
	| type_qualifier specifier_qualifier_list
	{
		// no semantic action required at this stage
	}
	| type_qualifier
	{
		// no semantic action required at this stage
	}
	;	




type_qualifier: CONST
	{
		// no semantic action required at this stage
	}
	| VOLATILE
	{
		// no semantic action required at this stage
	}
	| RESTRICT
	{
		// no semantic action required at this stage
	}
	;

function_specifier: INLINE
	{
		// no semantic action required at this stage
	}
	;

declarator: pointer direct_declarator
	{
		symtype * t = $1;
		while (t->ptr !=NULL) t = t->ptr;
		t->ptr = $2->type;
		$$ = $2->update($1);
	}
	| direct_declarator
	{
		// no semantic action required at this stage
	}
	;

direct_declarator: IDENTIFIER
	{
		$$ = $1->update(new symtype(Type));
		currentSymbol = $$;
	}
	| OPENROUNDBRACKET declarator CLOSEROUNDBRACKET
	{
		$$=$2;
	}
	| direct_declarator OPENSQUAREBRACKET  type_qualifier_list assignment_expression CLOSESQUAREBRACKET
	{
		// no semantic action required at this stage
	}
	| direct_declarator OPENSQUAREBRACKET  type_qualifier_list CLOSESQUAREBRACKET
	{
		// no semantic action required at this stage
	}
	| direct_declarator OPENSQUAREBRACKET assignment_expression CLOSESQUAREBRACKET
	{
		symtype * t = $1 -> type;
		symtype * prev = NULL;
		while (t->type == "ARR") {
			prev = t;
			t = t->ptr;
		}
		if (prev==NULL) {
			int temp = atoi($3->loc->initial_value.c_str());
			symtype* s = new symtype("ARR", $1->type, temp);
			$$ = $1->update(s);
		}
		else {
			prev->ptr =  new symtype("ARR", t, atoi($3->loc->initial_value.c_str()));
			$$ = $1->update ($1->type);
		}
	}
	| direct_declarator OPENSQUAREBRACKET CLOSESQUAREBRACKET
	{
		symtype * t = $1 -> type;
		symtype * prev = NULL;
		while (t->type == "ARR") {
			prev = t;
			t = t->ptr;
		}
		if (prev==NULL) {
			symtype* s = new symtype("ARR", $1->type, 0);
			$$ = $1->update(s);
		}
		else {
			prev->ptr =  new symtype("ARR", t, 0);
			$$ = $1->update ($1->type);
		}
	}
	| direct_declarator OPENSQUAREBRACKET STATIC type_qualifier_list_opt assignment_expression CLOSESQUAREBRACKET
	{
		// no semantic action required at this stage
	}
	| direct_declarator OPENSQUAREBRACKET type_qualifier_list_opt ASTERISK CLOSESQUAREBRACKET
	{
		// no semantic action required at this stage
	}
	| direct_declarator OPENROUNDBRACKET CT parameter_type_list CLOSEROUNDBRACKET
	{
		table->name = $1->name;

		if ($1->type->type !="VOID") {
			sym *s = table->lookup("return");
			s->update($1->type);		
		}
		$1->nested=table;
		$1->category = "function";
		table->parent = globalTable;
		changeTable (globalTable);				// Come back to globalsymbol table
		currentSymbol = $$;
	}
	| direct_declarator OPENROUNDBRACKET identifier_list CLOSEROUNDBRACKET
	{
		// no semantic action required at this stage
	}
	| direct_declarator OPENROUNDBRACKET CT CLOSEROUNDBRACKET
	{
		table->name = $1->name;

		if ($1->type->type !="VOID") {
			sym *s = table->lookup("return");
			s->update($1->type);		
		}
		$1->nested=table;
		$1->category = "function";
		table->parent = globalTable;
		changeTable (globalTable);				// Come back to globalsymbol table
		currentSymbol = $$;
	}
	;

CT
	: %empty 
	{ 															// Used for changing to symbol table for a function
		if (currentSymbol->nested==NULL) changeTable(new symtable(""));	// Function symbol table doesn't already exist
		else {
			changeTable (currentSymbol ->nested);						// Function symbol table already exists
			emit ("FUNC", table->name);
		}
	}
	;

type_qualifier_list_opt: %empty
	| type_qualifier_list
	;	

pointer: ASTERISK
	{
		$$ = new symtype("PTR");
	}
	| ASTERISK type_qualifier_list
	{
		// no semantic action required at this stage
	}
	| ASTERISK pointer
	{
		$$ = new symtype("PTR", $2);
	}
	| ASTERISK type_qualifier_list pointer
	{
		// no semantic action required at this stage
	}
	;

type_qualifier_list: type_qualifier
	{
		// no semantic action required at this stage
	}
	| type_qualifier_list type_qualifier
	{
		// no semantic action required at this stage
	}
	;


parameter_type_list: parameter_list
	{
		// no semantic action required at this stage
	}
	| parameter_list COMMA ELLIPSIS
	{
		// no semantic action required at this stage
	}
	;

parameter_list: parameter_declaration
	{
		// no semantic action required at this stage
	}
	| parameter_list COMMA parameter_declaration
	{
		// no semantic action required at this stage
	}
	;

parameter_declaration: declaration_specifiers declarator
	{
		$2->category = "param";
	}
	| declaration_specifiers
	{
		// no semantic action required at this stage
	}
	;

identifier_list: IDENTIFIER
	{
		// no semantic action required at this stage
	}
	| identifier_list COMMA IDENTIFIER
	{
		// no semantic action required at this stage
	}
	;

type_name: specifier_qualifier_list
	{
		// no semantic action required at this stage
	}
	;


initializer: assignment_expression
	{
		$$ = $1->loc;
	}
	| OPENFLOWERBRACKET initializer_list CLOSEFLOWERBRACKET
	{
		// no semantic action required at this stage
	}
	| OPENFLOWERBRACKET initializer_list COMMA CLOSEFLOWERBRACKET
	{
		// no semantic action required at this stage
	}
	;

initializer_list: initializer
	{
		// no semantic action required at this stage
	}
	| designation initializer
	{
		// no semantic action required at this stage
	}
	| initializer_list COMMA initializer
	{
		// no semantic action required at this stage
	}
	| initializer_list COMMA designation initializer
	{
		// no semantic action required at this stage
	}
	;

designation: designator_list EQUAL
	{
		// no semantic action required at this stage
	}
	;

designator_list: designator
	{
		// no semantic action required at this stage
	}
	| designator_list designator
	{
		// no semantic action required at this stage
	}
	;

designator: OPENSQUAREBRACKET constant_expression CLOSESQUAREBRACKET
	{
		// no semantic action required at this stage
	}
	| PERIOD IDENTIFIER
	{
		// no semantic action required at this stage
	}
	;	

statement: labeled_statement
	{
		// no semantic action required at this stage
	}
	| compound_statement
	{
		$$=$1;
	}
	| expression_statement
	{
		$$ = new statement();
		$$->nextlist = $1->nextlist;
	}
	| selection_statement
	{
		$$=$1;
	}
	| iteration_statement
	{
		$$=$1;
	}
	| jump_statement
	{
		$$=$1;
	}
	;

labeled_statement: IDENTIFIER COLON statement
	{
		$$ = new statement();
	}
	| CASE constant_expression COLON statement
	{
		$$ = new statement();
	}
	| DEFAULT COLON statement
	{
		$$ = new statement();
	}
	;

compound_statement: OPENFLOWERBRACKET CLOSEFLOWERBRACKET
	{
		$$ = new statement();
	}
	| OPENFLOWERBRACKET block_item_list CLOSEFLOWERBRACKET
	{
		$$=$2;
	}
	;

block_item_list: block_item
	{
		$$=$1;
	}
	| block_item_list M block_item
	{
		$$=$3;
		backpatch ($1->nextlist, $2);
	}
	;

block_item: declaration
	{
		$$ = new statement();
	}
	| statement
	{
		$$ = $1;
	}
	;	

expression_statement: SEMICOLON
	{
		$$ = new expr();
	}
	| expression SEMICOLON
	{
		$$=$1;
	}
	;

selection_statement: IF OPENROUNDBRACKET expression N CLOSEROUNDBRACKET M statement N %prec THEN
	{
		backpatch ($4->nextlist, nextinstr());
		convertInt2Bool($3);
		$$ = new statement();
		backpatch ($3->truelist, $6);
		list<int> temp = merge ($3->falselist, $7->nextlist);
		$$->nextlist = merge ($8->nextlist, temp);
	}
	|IF OPENROUNDBRACKET expression N CLOSEROUNDBRACKET M statement N ELSE M statement 
	{
		backpatch ($4->nextlist, nextinstr());
		convertInt2Bool($3);
		$$ = new statement();
		backpatch ($3->truelist, $6);
		backpatch ($3->falselist, $10);
		list<int> temp = merge ($7->nextlist, $8->nextlist);
		$$->nextlist = merge ($11->nextlist,temp);
	}
	|SWITCH OPENROUNDBRACKET expression CLOSEROUNDBRACKET statement 
	{
		// no semantic action required at this stage
	}
	;

iteration_statement:
	WHILE M OPENROUNDBRACKET expression CLOSEROUNDBRACKET M statement 
	{
		$$ = new statement();
		convertInt2Bool($4);
		// M1 to go back to boolean again
		// M2 to go to statement if the boolean is true
		backpatch($7->nextlist, $2);
		backpatch($4->truelist, $6);
		$$->nextlist = $4->falselist;
		// Emit to prevent fallthrough
		stringstream strs;
	    strs << $2;
	    string temp_str = strs.str();
	    char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);

		emit ("GOTO", str);
	}
	|DO M statement M WHILE OPENROUNDBRACKET expression CLOSEROUNDBRACKET SEMICOLON 
	{
		$$ = new statement();
		convertInt2Bool($7);
		// M1 to go back to statement if expression is true
		// M2 to go to check expression if statement is complete
		backpatch ($7->truelist, $2);
		backpatch ($3->nextlist, $4);

		$$->nextlist = $7->falselist;
	}
	|FOR OPENROUNDBRACKET expression_statement M expression_statement CLOSEROUNDBRACKET M statement
	{
		$$ = new statement();
		convertInt2Bool($5);
		backpatch ($5->truelist, $7);
		backpatch ($8->nextlist, $4);
		stringstream strs;
	    strs << $4;
	    string temp_str = strs.str();
	    char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);

		emit ("GOTO", str);
		$$->nextlist = $5->falselist;
	}
	|FOR OPENROUNDBRACKET expression_statement M expression_statement M expression N CLOSEROUNDBRACKET M statement
	{
		$$ = new statement();
		convertInt2Bool($5);
		backpatch ($5->truelist, $10);
		backpatch ($8->nextlist, $4);
		backpatch ($11->nextlist, $6);
		stringstream strs;
	    strs << $6;
	    string temp_str = strs.str();
	    char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);
		emit ("GOTO", str);
		$$->nextlist = $5->falselist;
	}
	;


jump_statement: GOTO IDENTIFIER SEMICOLON
	{
		$$ = new statement();
	}
	| CONTINUE SEMICOLON
	{
		$$ = new statement();
	}
	| BREAK SEMICOLON
	{
		$$ = new statement();
	}
	| RETURN expression SEMICOLON
	{
		$$ = new statement();
		emit("RETURN",$2->loc->name);
	}
	| RETURN SEMICOLON
	{
		$$ = new statement();
		emit("RETURN","");
	}
	;

translation_unit:external_declaration
	{
		// no semantic action required at this stage
	}
	| translation_unit external_declaration
	{
		// no semantic action required at this stage
	}
	;

external_declaration: function_definition
	{
		// no semantic action required at this stage
	}
	| declaration
	{
		// no semantic action required at this stage
	}
	;

function_definition: declaration_specifiers declarator declaration_list CT compound_statement
	{
		// no semantic action required at this stage
	}
	| declaration_specifiers declarator CT compound_statement
	{
		emit("FUNCEND", table->name);
		table->parent = globalTable;
		changeTable (globalTable);
	}	
	;

declaration_list: declaration
	{
		// no semantic action required at this stage
	}
	| declaration_list declaration
	{
		// no semantic action required at this stage
	}
	;
%%

void yyerror(string s) 
{
	cout<<s<<endl;
}
