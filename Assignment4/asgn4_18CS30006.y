%{ 
	#include <stdio.h>

	extern int yylex();
	void yyerror(char *s);
%}

%union 
{
int intval;
}

%token BREAK CASE CHAR CONTINUE DEFAULT DO DOUBLE ELSE EXTERN FLOAT FOR GOTO SWITCH TYPEDEF UNION VOID WHILE IF INT LONG RETURN SHORT SIZEOF STATIC STRUCT VOLATILE INLINE CONST RESTRICT

%token IDENTIFIER CONSTANT STRING_LITERAL

%token SQUARE_BRACKET_START SQUARE_BRACKET_END CIRCULAR_BRACKET_START CIRCULAR_BRACKET_END CURLY_BRACKET_START CURLY_BRACKET_END

%token QUESTION COLON SEMICOLON DOTS ASSIGN 
%token DOT IMPLIES INC DEC BITWISE_AND MUL ADD SUB BITWISE_NOT EXCLAIM DIV MOD SHIFT_LEFT SHIFT_RIGHT LT GT 

%token MULT_EQ DIV_EQ MOD_EQ ADD_EQ SUB_EQ SHIFTL_EQ SHIFTR_EQ BITWISE_AND_EQ BITWISE_XOR_EQ BITWISE_OR_EQ LTE GTE EQ_CHECK NOT_EQ_CHECK BITWISE_XOR BITWISE_OR AND OR
%token COMMA HASH 

%start translation_unit

%%

primary_expression
	: IDENTIFIER
	{printf(" primary_expression \n");}
	| CONSTANT
	{printf(" primary_expression \n");}
	| STRING_LITERAL
	{printf(" primary_expression \n");}
	| CIRCULAR_BRACKET_START expression CIRCULAR_BRACKET_END
	{printf(" primary_expression \n");}
	;


postfix_expression
	: primary_expression
	{printf(" postfix_expression \n");}
	| postfix_expression SQUARE_BRACKET_START expression SQUARE_BRACKET_END
	{printf(" postfix_expression \n");}
	| postfix_expression CIRCULAR_BRACKET_START argument_expression_list_opt CIRCULAR_BRACKET_END
	{printf(" postfix_expression \n");}
	| postfix_expression DOT IDENTIFIER
	{printf(" postfix_expression \n");}
	| postfix_expression IMPLIES IDENTIFIER
	{printf(" postfix_expression \n");}
	| postfix_expression INC
	{printf(" postfix_expression \n");}
	| postfix_expression DEC
	{printf(" postfix_expression \n");}
	| CIRCULAR_BRACKET_START type_name CIRCULAR_BRACKET_END CURLY_BRACKET_START initializer_list CURLY_BRACKET_END
	{printf(" postfix_expression \n");}
	| CIRCULAR_BRACKET_START type_name CIRCULAR_BRACKET_END CURLY_BRACKET_START initializer_list COMMA CURLY_BRACKET_END
	{printf(" postfix_expression \n");}
	;

argument_expression_list_opt
	: argument_expression_list
	| %empty
    ;

argument_expression_list
	: assignment_expression
	{printf(" argument_expression_list \n");}
	| argument_expression_list COMMA assignment_expression
	{printf(" argument_expression_list \n");}
	;

unary_expression
	: postfix_expression
	{printf(" unary_expression \n");}
	| INC unary_expression
	{printf(" unary_expression \n");}
	| DEC unary_expression
	{printf(" unary_expression \n");}
	| unary_operator cast_expression
	{printf(" unary_expression \n");}
	| SIZEOF unary_expression
	{printf(" unary_expression \n");}
	| SIZEOF CIRCULAR_BRACKET_START type_name CIRCULAR_BRACKET_END
	{printf(" unary_expression \n");}
	;

unary_operator
	: BITWISE_AND
	{printf(" unary_operator \n");}
	| MUL
	{printf(" unary_operator \n");}
	| ADD
	{printf(" unary_operator \n");}
	| SUB
	{printf(" unary_operator \n");}
	| BITWISE_NOT
	{printf(" unary_operator \n");}
	| EXCLAIM
	{printf(" unary_operator \n");}
	;

cast_expression
	: unary_expression
	{printf(" cast_expression \n");}
	| CIRCULAR_BRACKET_START type_name CIRCULAR_BRACKET_END cast_expression
	{printf(" cast_expression \n");}
	;

multiplicative_expression
	: cast_expression
	{printf(" multiplicative_expression \n");}
	| multiplicative_expression MUL cast_expression
	{printf(" multiplicative_expression \n");}
	| multiplicative_expression DIV cast_expression
	{printf(" multiplicative_expression \n");}
	| multiplicative_expression MOD cast_expression
	{printf(" multiplicative_expression \n");}
	;

additive_expression
	: multiplicative_expression
	{printf(" additive_expression \n");}
	| additive_expression ADD multiplicative_expression
	{printf(" additive_expression \n");}
	| additive_expression SUB multiplicative_expression
	{printf(" additive_expression \n");}
	;

shift_expression
	: additive_expression
	{printf(" shift_expression \n");}
	| shift_expression SHIFT_LEFT additive_expression
	{printf(" shift_expression \n");}
	| shift_expression SHIFT_RIGHT additive_expression
	{printf(" shift_expression \n");}
	;

relational_expression
	: shift_expression
	{printf(" relational_expression \n");}
	| relational_expression LT shift_expression
	{printf(" relational_expression \n");}
	| relational_expression GT shift_expression
	{printf(" relational_expression \n");}
	| relational_expression LTE shift_expression
	{printf(" relational_expression \n");}
	| relational_expression GTE shift_expression
	{printf(" relational_expression \n");}
	;

equality_expression
	: relational_expression
	{printf(" equality_expression \n");}
	| equality_expression EQ_CHECK relational_expression
	{printf(" equality_expression \n");}
	| equality_expression NOT_EQ_CHECK relational_expression
	{printf(" equality_expression \n");}
	;

and_expression
	: equality_expression
	{printf(" and_expression \n");}
	| and_expression BITWISE_AND equality_expression
	{printf(" and_expression \n");}
	;

exclusive_or_expression
	: and_expression
	{printf(" exclusive_or_expression \n");}
	| exclusive_or_expression BITWISE_XOR and_expression
	{printf(" exclusive_or_expression \n");}
	;

inclusive_or_expression
	: exclusive_or_expression
	{printf(" inclusive_or_expression \n");}
	| inclusive_or_expression BITWISE_OR exclusive_or_expression
	{printf(" inclusive_or_expression \n");}
	;

logical_and_expression
	: inclusive_or_expression
	{printf(" logical_and_expression \n");}
	| logical_and_expression AND inclusive_or_expression
	{printf(" logical_and_expression \n");}
	;

logical_or_expression
	: logical_and_expression
	{printf(" logical_or_expression \n");}
	| logical_or_expression OR logical_and_expression
	{printf(" logical_or_expression \n");}
	;

conditional_expression
	: logical_or_expression
	{printf(" conditional_expression \n");}
	| logical_or_expression QUESTION expression COLON conditional_expression
	{printf(" conditional_expression \n");}
	;

assignment_expression
	: conditional_expression
	{printf(" assignment_expression \n");}
	| unary_expression assignment_operator assignment_expression
	{printf(" assignment_expression \n");}
	;

assignment_operator
	: ASSIGN
	{printf(" assignment_operator \n");}
	| MULT_EQ
	{printf(" assignment_operator \n");}
	| DIV_EQ
	{printf(" assignment_operator \n");}
	| MOD_EQ
	{printf(" assignment_operator \n");}
	| ADD_EQ
	{printf(" assignment_operator \n");}
	| SUB_EQ
	{printf(" assignment_operator \n");}
	| SHIFTL_EQ
	{printf(" assignment_operator \n");}
	| SHIFTR_EQ
	{printf(" assignment_operator \n");}
	| BITWISE_AND_EQ
	{printf(" assignment_operator \n");}
	| BITWISE_XOR_EQ
	{printf(" assignment_operator \n");}
	| BITWISE_OR_EQ
	{printf(" assignment_operator \n");}
	;

expression
	: assignment_expression
	{printf(" expression \n");}
	| expression COMMA assignment_expression
	{printf(" expression \n");}
	;

constant_expression
	: conditional_expression
	{printf(" constant_expression \n");}
	;

declaration
	: declaration_specifiers init_declarator_list_opt SEMICOLON
	{printf(" Declaration \n");}
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers_opt
	{printf(" declaration_specifiers \n");}
	| type_specifier declaration_specifiers_opt
	{printf(" declaration_specifiers \n");}
	| type_qualifier declaration_specifiers_opt
	{printf(" declaration_specifiers \n");}
	| function_specifier declaration_specifiers_opt
	{printf(" declaration_specifiers \n");}
	;

declaration_specifiers_opt
	: declaration_specifiers
	| %empty
	;

init_declarator_list
	: init_declarator
	{printf(" init_declarator_list \n");}
	| init_declarator_list COMMA init_declarator
	{printf(" init_declarator_list \n");}
	;

init_declarator_list_opt
	: init_declarator_list
	| %empty
	;

init_declarator
	: declarator
	{printf(" init_declarator \n");}
	| declarator ASSIGN initializer
	{printf(" init_declarator \n");}
	;

storage_class_specifier
	: EXTERN
	{printf(" storage_class_specifier \n");}
	| STATIC
	{printf(" storage_class_specifier \n");}
	;

type_specifier
	: VOID
	{printf(" type_specifier \n");}
	| CHAR
	{printf(" type_specifier \n");}
	| SHORT
	{printf(" type_specifier \n");}
	| INT
	{printf(" type_specifier \n");}
	| LONG
	{printf(" type_specifier \n");}
	| FLOAT
	{printf(" type_specifier \n");}
	| DOUBLE
	{printf(" type_specifier \n");}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list_opt
	{printf(" specifier_qualifier_list \n");}
	| type_qualifier specifier_qualifier_list_opt
	{printf(" specifier_qualifier_list \n");}
	;

specifier_qualifier_list_opt
	: specifier_qualifier_list
	| %empty
	;

type_qualifier
	: CONST
	{printf(" type_qualifier \n");}
	| RESTRICT
	{printf(" type_qualifier \n");}
	| VOLATILE
	{printf(" type_qualifier \n");}
	;

function_specifier
	: INLINE
	{printf(" function_specifier \n");}
	;

declarator
	: pointer_opt direct_declarator
	{printf(" declarator \n");}
	;

pointer_opt
	: pointer
	| %empty
	;

direct_declarator
	: IDENTIFIER
	{printf(" direct_declarator \n");}
	| CIRCULAR_BRACKET_START declarator CIRCULAR_BRACKET_END
	{printf(" direct_declarator \n");}
	| direct_declarator SQUARE_BRACKET_START  type_qualifier_list_opt assignment_expression_opt SQUARE_BRACKET_END
	{printf(" direct_declarator \n");}
	| direct_declarator SQUARE_BRACKET_START STATIC type_qualifier_list_opt assignment_expression SQUARE_BRACKET_END
	{printf(" direct_declarator \n");}
	| direct_declarator SQUARE_BRACKET_START type_qualifier_list STATIC assignment_expression SQUARE_BRACKET_END
	{printf(" direct_declarator \n");}
	| direct_declarator SQUARE_BRACKET_START type_qualifier_list_opt MUL SQUARE_BRACKET_END
	{printf(" direct_declarator \n");}
	| direct_declarator CIRCULAR_BRACKET_START parameter_type_list CIRCULAR_BRACKET_END
	{printf(" direct_declarator \n");}
	| direct_declarator CIRCULAR_BRACKET_START identifier_list_opt CIRCULAR_BRACKET_END
	{printf(" direct_declarator \n");}
	;

pointer
	: MUL type_qualifier_list_opt
	{printf(" pointer \n");}
	| MUL type_qualifier_list_opt pointer
	{printf(" pointer \n");}
	;

type_qualifier_list_opt
	: type_qualifier_list
	| %empty
	;

assignment_expression_opt
	: assignment_expression
	| %empty
	;

identifier_list_opt
	: identifier_list
	| %empty
	;

type_qualifier_list
	: type_qualifier
	{printf(" type_qualifier_list \n");}
	| type_qualifier_list type_qualifier
	{printf(" type_qualifier_list \n");}
	;


parameter_type_list
	: parameter_list
	{printf(" parameter_type_list \n");}
	| parameter_list COMMA DOTS
	{printf(" parameter_type_list \n");}
	;

parameter_list
	: parameter_declaration
	{printf(" parameter_list \n");}
	| parameter_list COMMA parameter_declaration
	{printf(" parameter_list \n");}
	;

parameter_declaration
	: declaration_specifiers declarator
	{printf(" parameter_declaration \n");}
	| declaration_specifiers
	{printf(" parameter_declaration \n");}
	;

identifier_list
	: IDENTIFIER
	{printf(" identifier_list \n");}
	| identifier_list COMMA IDENTIFIER
	{printf(" identifier_list \n");}
	;

type_name
	: specifier_qualifier_list
	{printf(" type_name \n");}
	;

initializer
	: assignment_expression
	{printf(" initializer \n");}
	| CURLY_BRACKET_START initializer_list CURLY_BRACKET_END
	{printf(" initializer \n");}
	| CURLY_BRACKET_START initializer_list COMMA CURLY_BRACKET_END
	{printf(" initializer \n");}
	;

initializer_list
	: designation_opt initializer
	{printf(" initializer_list \n");}
	| initializer_list COMMA designation_opt initializer
	{printf(" initializer_list \n");}
	;

designation_opt
	: designation
	| %empty
	;

designation
	: designator_list ASSIGN
	{printf(" designation \n");}
	;

designator_list
	: designator
	{printf(" designator_list \n");}
	| designator_list designator
	{printf(" designator_list \n");}
	;

designator
	: SQUARE_BRACKET_START constant_expression SQUARE_BRACKET_END
	{printf(" designator \n");}
	| DOT IDENTIFIER
	{printf(" designator \n");}
	;

statement
	: labeled_statement
	{printf(" Statement \n");}
	| compound_statement
	{printf(" Statement \n");}
	| expression_statement
	{printf(" Statement \n");}
	| selection_statement
	{printf(" Statement \n");}
	| iteration_statement
	{printf(" Statement \n");}
	| jump_statement
	{printf(" Statement \n");}
	;

labeled_statement
	: IDENTIFIER COLON statement
	{printf(" labeled_statement \n");}
	| CASE constant_expression COLON statement
	{printf(" labeled_statement \n");}
	| DEFAULT COLON statement
	{printf(" labeled_statement \n");}
	;

compound_statement
	: CURLY_BRACKET_START block_item_list_opt CURLY_BRACKET_END
	{printf(" compound_statement \n");}
	;

block_item_list_opt
	: block_item_list
	| %empty
	;

block_item_list
	: block_item
	{printf(" block_item_list \n");}
	| block_item_list block_item
	{printf(" block_item_list \n");}
	;

block_item
	: declaration
	{printf(" block_item \n");}
	| statement
	{printf(" block_item \n");}
	;

expression_statement
	: expression_opt SEMICOLON
	{printf(" expression_statement \n");}
	;

expression_opt
	: expression
	| %empty
	;

selection_statement
	: IF CIRCULAR_BRACKET_START expression CIRCULAR_BRACKET_END statement
	{printf(" selection_statement \n");}
	| IF CIRCULAR_BRACKET_START expression CIRCULAR_BRACKET_END statement ELSE statement
	{printf(" selection_statement \n");}
	| SWITCH CIRCULAR_BRACKET_START expression CIRCULAR_BRACKET_END statement
	{printf(" selection_statement \n");}
	;

iteration_statement
	: WHILE CIRCULAR_BRACKET_START expression CIRCULAR_BRACKET_END statement
	{printf(" iteration_statement \n");}
	| DO statement WHILE CIRCULAR_BRACKET_START expression CIRCULAR_BRACKET_END SEMICOLON
	{printf(" iteration_statement \n");}
	| FOR CIRCULAR_BRACKET_START expression_opt SEMICOLON expression_opt SEMICOLON expression_opt CIRCULAR_BRACKET_END statement
	{printf(" iteration_statement \n");}
	| FOR CIRCULAR_BRACKET_START declaration expression_opt SEMICOLON expression_opt CIRCULAR_BRACKET_END statement
	{printf(" iteration_statement \n");}
	;

jump_statement
	: GOTO IDENTIFIER SEMICOLON
	{printf(" jump_statement \n");}
	| CONTINUE SEMICOLON
	{printf(" jump_statement \n");}
	| BREAK SEMICOLON
	{printf(" jump_statement \n");}
	| RETURN expression_opt SEMICOLON
	{printf(" jump_statement \n");}
	;

translation_unit
	: external_declaration
	{printf(" Translation_unit \n");}
	| translation_unit external_declaration
	{printf(" Translation_unit \n");}
	;

external_declaration
	: function_definition
	{printf(" external_declaration \n");}
	| declaration
	{printf(" external_declaration \n");}
	;

function_definition
	: declaration_specifiers declarator declaration_list_opt compound_statement
	{printf(" function_definition \n");}
	;

declaration_list_opt
	: declaration_list
	| %empty
	;

declaration_list
	: declaration
	{printf(" declaration_list \n");}
	| declaration_list declaration
	{printf(" declaration_list \n");}
	;

%%
void yyerror(char *s) {
	printf("The error is: %s\n", s);
}
