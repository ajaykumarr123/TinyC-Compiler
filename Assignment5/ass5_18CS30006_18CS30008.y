%{
	#include <iostream>              
	#include <cstdlib>
	#include <string>
	#include <stdio.h>
	#include <sstream>

	#include "ass5_18CS30006_18CS30008_translator.h"

	extern int yylex();
	void yyerror(string s);
	extern string variable_type;

	using namespace std;

%}


%union {           

	char unaryOp;
	char* charval;

	int inst_no;	
	int intval;	

	Expression* Exp;	
	Statement* ss;	

	Symtyp* Sym_type;
	Sym* Symp;	
	Array* ARR; 
		
} 

%token <Symp> IDENTIFIER 		 		
%token <intval> INTEGER_CONSTANT			
%token <charval> FLOATING_CONSTANT
%token <charval> CHARACTER_CONSTANT		
%token <charval> STRING_LITERAL			
		
%token BREAK CASE CHAR CONTINUE DEFAULT DO DOUBLE ELSE  EXTERN FLOAT FOR GOTO SWITCH TYPEDEF UNION VOID WHILE IF INT LONG RETURN SHORT SIZEOF STATIC STRUCT VOLATILE INLINE CONST RESTRICT 
			 		
%token SQUARE_BRACKET_START SQUARE_BRACKET_END CIRCULAR_BRACKET_START CIRCULAR_BRACKET_END CURLY_BRACKET_START CURLY_BRACKET_END LTE GTE EQ_CHECK NOT_EQ_CHECK BITWISE_XOR BITWISE_OR AND OR
%token QUESTION COLON SEMICOLON DOTS ASSIGN COMMA HASH 
%token MULT_EQ DIV_EQ MOD_EQ ADD_EQ SUB_EQ SHIFTL_EQ SHIFTR_EQ BITWISE_AND_EQ BITWISE_XOR_EQ BITWISE_OR_EQ 
%token DOT IMPLIES INC DEC BITWISE_AND MUL ADD SUB BITWISE_NOT EXCLAIM DIV MOD SHIFT_LEFT SHIFT_RIGHT LT GT 

%start translation_unit
// to remove else ambiguity
%right "then" ELSE

%type <intval> argument_expression_list argument_expression_list_opt
%type <unaryOp> unary_operator

//Statements
%type <ss>  statement
%type <ss> compound_statement
%type <ss> selection_statement
%type <ss> iteration_statement
%type <ss> labeled_statement 
%type <ss> jump_statement
%type <ss> block_item
%type <ss> block_item_list
%type <ss> block_item_list_opt

//Expressions
%type <Exp> expression
%type <Exp> primary_expression 
%type <Exp> multiplicative_expression
%type <Exp> additive_expression
%type <Exp> shift_expression
%type <Exp> relational_expression
%type <Exp> equality_expression
%type <Exp> and_expression
%type <Exp> exclusive_or_expression
%type <Exp> inclusive_or_expression
%type <Exp> logical_and_expression
%type <Exp> logical_or_expression
%type <Exp> conditional_expression
%type <Exp> assignment_expression
%type <Exp> expression_statement

%type <Symp> direct_declarator init_declarator declarator
%type <Sym_type> pointer
%type <Symp> initializer

// Array to be used later
%type <ARR> postfix_expression 
%type <ARR> unary_expression cast_expression

// Auxillary non terminals M and N
%type <inst_no> M
%type <ss> N

%%

M
	: %empty 						// To store the address of the next instruction
	{
		$$=nextinstr();
	}   
	;

N
	: %empty						// Guard against fallthrough by emitting a goto
	{
		$$ =new Statement();           
		$$->nextlist=makelist(nextinstr());
		emit("goto","");
	}
	;

primary_expression
	: IDENTIFIER                     					   
	{ 	
		$$=new Expression();                     		 
		$$->loc=$1;	
		$$->type="NOT-BOOL";	
	}
	| INTEGER_CONSTANT          					   
	{   
		$$=new Expression();	
		string p=IntToString_conversion($1);
		$$->loc=gentemp(new Symtyp("int"),p);
		emit("=",$$->loc->sn,p);	
	}
	| FLOATING_CONSTANT        	  					  
	{    
		$$=new Expression();
		$$->loc=gentemp(new Symtyp("float"),$1);
		emit("=",$$->loc->sn,string($1));
	}
	| CHARACTER_CONSTANT       	  					  
	{    
		$$=new Expression();	
		$$->loc=gentemp(new Symtyp("char"),$1);
		emit("=",$$->loc->sn,string($1));
		
	}
	| STRING_LITERAL        					  
	{   
		$$=new Expression();
		$$->loc=gentemp(new Symtyp("ptr"),$1);
		$$->loc->type->arrtype=new Symtyp("char");
	}
	| CIRCULAR_BRACKET_START expression CIRCULAR_BRACKET_END       
	{ $$=$2;}
	;

//change-table
CT
	: %empty 						
	{ 													
		if(cur_sym->nested==NULL) 			//if Function symbol table doesn't exist already
		{
				changeTable(new Symtable(""));	
		}
		else 								// if Function symbol table exist already
		{
			changeTable(cur_sym ->nested);						
			emit("label", ST->sn);	
		}
	}
	;


postfix_expression
	: primary_expression      				      
	{		
		$$=new Array();
		$$->Array=$1->loc;		
		$$->type=$1->loc->type;		
		$$->loc=$$->Array;	
	}
	| postfix_expression SQUARE_BRACKET_START expression SQUARE_BRACKET_END 
	{ 	
		
		$$=new Array();
								
		$$->Array=$1->Array;			    // copying the base		
		$$->type=$1->type->arrtype;		    // type = type of element
		$$->loc=gentemp(new Symtyp("int"));	// store computed address
		$$->arr_typ="arr";					
		
		// New address =(if only) already computed + $3 * new width
		if($1->arr_typ=="arr") 		// if already computed
		{		
			
			Sym* t=gentemp(new Symtyp("int"));
			int p=computeSize($$->type);
			string str=IntToString_conversion(p);
			emit("*",t->sn,$3->loc->sn,str);
			emit("+",$$->loc->sn,$1->loc->sn,t->sn);
		}
		else 						  //if a 1D Array, simply calculate size
		{                       
			int p=computeSize($$->type);
			string str=IntToString_conversion(p);
			emit("*",$$->loc->sn,$3->loc->sn,str);	
		}
	}
	| postfix_expression CIRCULAR_BRACKET_START argument_expression_list_opt CIRCULAR_BRACKET_END       

	{	
		$$=new Array();		
		$$->Array=gentemp($1->type);	
		string str=IntToString_conversion($3);	
		emit("call",$$->Array->sn,$1->Array->sn,str);
	}
	| postfix_expression DOT IDENTIFIER 
	{ /*semantic action is not required here*/ }
	| postfix_expression IMPLIES IDENTIFIER  
	{ /*semantic action is not required here*/ }
	| postfix_expression INC              
	{ 
		$$=new Array();		
		$$->Array=gentemp($1->Array->type);    //copy $1 to $$		
		emit("=",$$->Array->sn,$1->Array->sn);
		emit("+",$1->Array->sn,$1->Array->sn,"1");	//increase $1
	}
	| postfix_expression DEC               
	{
		$$=new Array();	
		$$->Array=gentemp($1->Array->type);    //copy $1 to $$
		emit("=",$$->Array->sn,$1->Array->sn);
		emit("-",$1->Array->sn,$1->Array->sn,"1");	//decrease $1
	}
	| CIRCULAR_BRACKET_START type_name CIRCULAR_BRACKET_END CURLY_BRACKET_START initializer_list CURLY_BRACKET_END 
	{ /*semantic action is not required here*/ }
	| CIRCULAR_BRACKET_START type_name CIRCULAR_BRACKET_END CURLY_BRACKET_START initializer_list COMMA CURLY_BRACKET_END 
	{ /*semantic action is not required here*/ }
	;

argument_expression_list
	: assignment_expression    
	{
		$$=1;                                     	
		emit("param",$1->loc->sn);	
	}
	| argument_expression_list COMMA assignment_expression     
	{	
		$$=$1+1;                                 		 
		emit("param",$3->loc->sn);
	}
	;


argument_expression_list_opt
	: argument_expression_list    
	{ 
		$$=$1; 
	}  
	| %empty 
	{	 
		$$=0; 
	}           
	;

cast_expression
	: unary_expression  { $$=$1; }                       //simply equating                      
	| CIRCULAR_BRACKET_START type_name CIRCULAR_BRACKET_END cast_expression         
	{ 
		
		$$=new Array();	
		$$->Array=conv($4->Array,variable_type);            
	}
	;

unary_operator
	: BITWISE_AND 	
	{ 
		$$='&'; 	
	}       
	| MUL  		
	{
		$$='*'; 
	}
	| ADD  		
	{ 
		$$='+'; 
	}
	| SUB  		
	{ 
		$$='-'; 
	
	}
	| BITWISE_NOT  
	{ 
		$$='~'; 
	} 
	| EXCLAIM  
	{
		$$='!'; 	
	}
	;

unary_expression
	: postfix_expression   
	{ $$=$1; }                       //simply equating 					 
	| INC unary_expression       //add 1                   
	{  	
		emit("+",$2->Array->sn,$2->Array->sn,"1");
		$$=$2;
		
	}
	| DEC unary_expression       //decrease 1                
	{
		emit("-",$2->Array->sn,$2->Array->sn,"1");
		$$=$2;
	}
	| unary_operator cast_expression                      
	{			
		$$=new Array();
		switch($1)
		{	  
			case '&':                                      
				$$->Array=gentemp((new Symtyp("ptr")));
				$$->Array->type->arrtype=$2->Array->type; 
				emit("=&",$$->Array->sn,$2->Array->sn);
				break;
			case '*':                         
				$$->arr_typ="ptr";
				$$->loc=gentemp($2->Array->type->arrtype);
				$$->Array=$2->Array;
				emit("=*",$$->loc->sn,$2->Array->sn);
				break;
			case '+':  
				$$=$2;
				break;                   
			case '-':				  
				$$->Array=gentemp(new Symtyp($2->Array->type->type));
				emit("uminus",$$->Array->sn,$2->Array->sn);
				break;
			case '~':                  
				$$->Array=gentemp(new Symtyp($2->Array->type->type));
				emit("~",$$->Array->sn,$2->Array->sn);
				break;
			case '!':			
				$$->Array=gentemp(new Symtyp($2->Array->type->type));
				emit("!",$$->Array->sn,$2->Array->sn);
				break;
		}
	}
	;




multiplicative_expression
	: cast_expression  
	{
		$$ = new Expression();            							    
		if($1->arr_typ=="arr") 			  
		{
			$$->loc = gentemp($1->loc->type);	
			emit("=[]", $$->loc->sn, $1->Array->sn, $1->loc->sn);    
		}
		else if($1->arr_typ=="ptr")        
		{ 
			$$->loc = $1->loc;       	
		}
		else
		{
			$$->loc = $1->Array;	
		}
	}
	| multiplicative_expression MUL cast_expression          
	{ 
		
		if(typecheck($1->loc, $3->Array))         
		{
			$$ = new Expression();	
			$$->loc = gentemp(new Symtyp($1->loc->type->type));
			emit("*", $$->loc->sn, $1->loc->sn, $3->Array->sn);		
		}
		else
		{
			cout << "!Error,Types doesn't match"<< "\n";
		}
	}
	| multiplicative_expression DIV cast_expression     
	{
		
		if(typecheck($1->loc, $3->Array))
		{
			$$ = new Expression();
			$$->loc = gentemp(new Symtyp($1->loc->type->type));
			emit("/", $$->loc->sn, $1->loc->sn, $3->Array->sn);
		}
		else
		{
			cout << "!Error,Types doesn't match"<< "\n";
		}
	}
	| multiplicative_expression MOD cast_expression   
	{
		
		if(typecheck($1->loc, $3->Array))
		{
			$$ = new Expression();
			$$->loc = gentemp(new Symtyp($1->loc->type->type));
			emit("%", $$->loc->sn, $1->loc->sn, $3->Array->sn);		
		}
		else
		{
			cout << "!Error,Types doesn't match"<< "\n";
		}
	}
	;

additive_expression
	: multiplicative_expression   { $$=$1; }                       //simply equating           
	| additive_expression ADD multiplicative_expression     
	{
		
		if(typecheck($1->loc, $3->loc))    //comparing symbol types
		{
			$$ = new Expression();	
			$$->loc = gentemp(new Symtyp($1->loc->type->type));	
			emit("+", $$->loc->sn, $1->loc->sn, $3->loc->sn);	
		}
		else
		{
			cout << "!Error,Types doesn't match"<< "\n";
		}
	}
	| additive_expression SUB multiplicative_expression   
	{
		
		if(typecheck($1->loc, $3->loc))    //comparing symbol types
		{	
			$$ = new Expression();		
			$$->loc = gentemp(new Symtyp($1->loc->type->type));	
			emit("-", $$->loc->sn, $1->loc->sn, $3->loc->sn);
			
			
		}
		else
		{
			cout << "!Error,Types doesn't match"<< "\n";
		}
	}
;

relational_expression
	: shift_expression   { $$=$1; }                       //simply equating             
	| relational_expression LT shift_expression
	{
		if(typecheck($1->loc, $3->loc))    //comparing symbol types 
		{    								
			$$ = new Expression();		
			$$->type = "bool";         	 				//new type is boolean            
			$$->truelist = makelist(nextinstr());       //makelist for truelist and falselist
			$$->falselist = makelist(nextinstr()+1);
			emit("<", "", $1->loc->sn, $3->loc->sn);    //emit statement if a<b goto ..   
			emit("goto", "");	      				    //emit statement goto ..		
		}
		else
		{
			cout << "!Error,Types doesn't match"<< "\n";
		}
	}
	| relational_expression GT shift_expression         
	{
		if(typecheck($1->loc, $3->loc))    //comparing symbol types 
		{			
			$$ = new Expression();	
			$$->type = "bool";         	 //new type is boolean
			$$->truelist = makelist(nextinstr());     //makelist for truelist and falselist
			$$->falselist = makelist(nextinstr()+1);
			emit(">", "", $1->loc->sn, $3->loc->sn);	//emit statement if a>b goto ..
			emit("goto", "");	         //emit statement goto ..
		}
		else
		{
			cout << "!Error,Types doesn't match"<< "\n";
		}	
	}
	| relational_expression LTE shift_expression			
	{
		if(typecheck($1->loc, $3->loc))    //comparing symbol types 
		{		
			$$ = new Expression();		
			$$->type = "bool";         	 				//new type is boolean
			$$->truelist = makelist(nextinstr());       //makelist for truelist and falselist
			$$->falselist = makelist(nextinstr()+1);
			emit("<=", "", $1->loc->sn, $3->loc->sn);	//emit statement if a<=b goto ..
			emit("goto", "");	        			    //emit statement goto ..	
		}
		else
		{
			cout << "!Error,Types doesn't match"<< "\n";
		}		
	}
	| relational_expression GTE shift_expression 			
	{
		if(typecheck($1->loc, $3->loc))    //comparing symbol types
		{
			
			$$ = new Expression();
			
			$$->type = "bool";         	 				//new type is boolean	
			$$->truelist = makelist(nextinstr());       //makelist for truelist and falselist
			
			$$->falselist = makelist(nextinstr()+1);
			
			emit(">=", "", $1->loc->sn, $3->loc->sn);	//emit statement if a>=b goto ..
			
			
			emit("goto", "");	         				//emit statement goto ..
			
			
		}

		else
			cout << "!Error,Types doesn't match"<< "\n";
		
	}
	;


shift_expression
	: additive_expression   { $$=$1; }                       //simply equating             
	| shift_expression SHIFT_LEFT additive_expression   
	{ 
		
		if(($3->loc->type->type == "int"))
		{		
			$$ = new Expression();		
			$$->loc = gentemp(new Symtyp("int"));	
			emit("<<", $$->loc->sn, $1->loc->sn, $3->loc->sn);		
		}
		else
		{
			cout << "!Error,Types doesn't match"<< "\n";
		}
	}
	| shift_expression SHIFT_RIGHT additive_expression
	{ 	
		if(($3->loc->type->type == "int"))
		{	
			$$ = new Expression();		
			$$->loc = gentemp(new Symtyp("int"));
			emit(">>", $$->loc->sn, $1->loc->sn, $3->loc->sn);
			
		
		}
		else
		{
			cout << "!Error,Types doesn't match"<< "\n";
		}
	}
	;


equality_expression
	: relational_expression  
	{ $$=$1; }                       //simply equating					
	| equality_expression NOT_EQ_CHECK relational_expression  
	{
		if(typecheck($1->loc, $3->loc))    //comparing symbol types 
		{			
			
			BoolToInt_conversion($1);	
			
			BoolToInt_conversion($3);
			
			$$ = new Expression();                
			
			$$->type = "bool";         	 //new type is boolean
			
			$$->truelist = makelist(nextinstr());     //makelist for truelist and falselist
			
			$$->falselist = makelist(nextinstr()+1);
			
			emit("!=", "", $1->loc->sn, $3->loc->sn);
			emit("goto", "");	         //emit statement goto ..
		}
		else
			cout << "!Error,Types doesn't match"<< "\n";
		
	}
	| equality_expression EQ_CHECK relational_expression 
	{
		if(typecheck($1->loc, $3->loc))    //comparing symbol types               
		{
			
			BoolToInt_conversion($1);                 
				
			BoolToInt_conversion($3);
			
			$$ = new Expression();
			
			$$->type = "bool";         	 //new type is boolean
			
			$$->truelist = makelist(nextinstr());     //makelist for truelist and falselist           
			
			$$->falselist = makelist(nextinstr()+1); 
			
			emit("==", "", $1->loc->sn, $3->loc->sn);     
			emit("goto", "");	         //emit statement goto ..			
			
		}
		else
			cout << "!Error,Types doesn't match"<< "\n";
	}

	
	;

and_expression
	: equality_expression  
	{ 	
		$$=$1; 
	}					
	| and_expression BITWISE_AND equality_expression 
	{
		if(typecheck($1->loc, $3->loc))    //comparing symbol types        
		{
			              
			BoolToInt_conversion($1);                            
			BoolToInt_conversion($3);
			
			$$ = new Expression();
			
			$$->type = "NOT-BOOL";                  
			
			$$->loc = gentemp(new Symtyp("int"));
			
			emit("&", $$->loc->sn, $1->loc->sn, $3->loc->sn);              
				
		}
		else
			cout << "!Error,Types doesn't match"<< "\n";
		
	}
	;

logical_and_expression
	: inclusive_or_expression  
	{
	 	$$=$1; 
	}			
	| logical_and_expression N AND M inclusive_or_expression     
	{ 
		
		IntToBool_conversion($5);        		
		backpatch($2->nextlist, nextinstr());       		
		IntToBool_conversion($1);                 		
		$$ = new Expression();    		
		$$->type = "bool";         	 //new type is boolean		
		backpatch($1->truelist, $4);       		
		$$->truelist = $5->truelist;       
		$$->falselist = merge($1->falselist, $5->falselist);   	
	}
	;

logical_or_expression
	: logical_and_expression   
	{ 
		$$=$1; 
	}			
	| logical_or_expression N OR M logical_and_expression       
	{ 
		
		IntToBool_conversion($5);					
		backpatch($2->nextlist, nextinstr());		
		IntToBool_conversion($1);				
		$$ = new Expression();				
		$$->type = "bool";         	 //new type is boolean		
		backpatch($1->falselist, $4);			
		$$->truelist = merge($1->truelist, $5->truelist);			
		$$->falselist = $5->falselist;		 				
	}
	;

inclusive_or_expression
	: exclusive_or_expression 
	{
		 $$=$1; 
	}		
	| inclusive_or_expression BITWISE_OR exclusive_or_expression          
	{ 
		if(typecheck($1->loc, $3->loc))    //comparing symbol types  
		{
			BoolToInt_conversion($1);		
			BoolToInt_conversion($3);
			$$ = new Expression();
			$$->type = "NOT-BOOL";	
			$$->loc = gentemp(new Symtyp("int"));
			emit("|", $$->loc->sn, $1->loc->sn, $3->loc->sn);
		} 

		else
			cout << "!Error,Types doesn't match"<< "\n";
		
	}
	;


exclusive_or_expression
	: and_expression  
	{
		 $$=$1; 
	}			
	| exclusive_or_expression BITWISE_XOR and_expression    
	{
		if(typecheck($1->loc, $3->loc))    //comparing symbol types    
		{
			BoolToInt_conversion($1);				
			BoolToInt_conversion($3);			
			$$ = new Expression();			
			$$->type = "NOT-BOOL";			
			$$->loc = gentemp(new Symtyp("int"));		
			emit("^", $$->loc->sn, $1->loc->sn, $3->loc->sn);			
		}
		else
			cout << "!Error,Types doesn't match"<< "\n";
		
	}
	;



conditional_expression 
	: logical_or_expression 
	{$$=$1;}      
	| logical_or_expression N QUESTION M expression N COLON M conditional_expression 
	{
		$$->loc = gentemp($5->loc->type);      
		$$->loc->update($5->loc->type);
		emit("=", $$->loc->sn, $9->loc->sn);     
		list<int> l = makelist(nextinstr());       
		emit("goto", "");	         //emit statement goto ..             
		backpatch($6->nextlist, nextinstr());       
		emit("=", $$->loc->sn, $5->loc->sn);
	
		
		list<int> m = makelist(nextinstr());        
		l = merge(l, m);					
		emit("goto", "");	         //emit statement goto ..					
		
		backpatch($2->nextlist, nextinstr());  
		IntToBool_conversion($1);                  
		backpatch($1->truelist, $4);          
		backpatch($1->falselist, $8);         	
		backpatch(l, nextinstr());
				
	}
	;

assignment_expression
	: conditional_expression {$$=$1;}        
	| unary_expression assignment_operator assignment_expression 
	 {
		if($1->arr_typ=="arr")      
		{		
			$3->loc = conv($3->loc, $1->type->type);		
			emit("[]=", $1->Array->sn, $1->loc->sn, $3->loc->sn);		
				
		}
		else if($1->arr_typ=="ptr")    
		{		
			emit("*=", $1->Array->sn, $3->loc->sn);				
		}
		else                             
		{
			$3->loc = conv($3->loc, $1->Array->type->type);
			emit("=", $1->Array->sn, $3->loc->sn);			
		}		
		$$ = $3;		
	}
	;


assignment_operator
	: ASSIGN   
	{ /*semantic action is not required here*/ }
	| MULT_EQ    
	{ /*semantic action is not required here*/ }
	| DIV_EQ    
	{ /*semantic action is not required here*/ }
	| MOD_EQ    
	{ /*semantic action is not required here*/ }
	| ADD_EQ    
	{ /*semantic action is not required here*/ }
	| SUB_EQ    
	{ /*semantic action is not required here*/ }
	| SHIFTL_EQ    
	{ /*semantic action is not required here*/ }
	| SHIFTR_EQ    
	{ /*semantic action is not required here*/ }
	| BITWISE_AND_EQ    
	{ /*semantic action is not required here*/ }
	| BITWISE_XOR_EQ    {
	 /*semantic action is not required here*/ }
	| BITWISE_OR_EQ    
	{ /*semantic action is not required here*/ }
	;

expression
	: assignment_expression {  $$=$1;  }
	| expression COMMA assignment_expression {   }
	;

constant_expression
	: conditional_expression {   }
	;

declaration
	: declaration_specifiers init_declarator_list SEMICOLON {	}
	| declaration_specifiers SEMICOLON {  	}
	;


declaration_specifiers
	: storage_class_specifier declaration_specifiers {	}
	| storage_class_specifier {	}
	| type_specifier declaration_specifiers {	}
	| type_specifier {	}
	| type_qualifier declaration_specifiers {	}
	| type_qualifier {	}
	| function_specifier declaration_specifiers {	}
	| function_specifier {	}
	;

init_declarator_list
	: init_declarator {	}
	| init_declarator_list COMMA init_declarator {	}
	;

init_declarator
	: declarator {$$=$1;}
	| declarator ASSIGN initializer 
	{
		
		if($3->val!="") $1->val=$3->val;       
		emit("=", $1->sn, $3->sn);
		
	}
	;

storage_class_specifier
	: EXTERN  { /*semantic action is not required here*/ }
	| STATIC  { /*semantic action is not required here*/ }
	;

type_specifier
	: VOID   { variable_type="void"; }          
	| CHAR   { variable_type="char"; }
	| SHORT  { /*semantic action is not required here*/ }
	| INT   { variable_type="int"; }
	| LONG   { /*semantic action is not required here*/ }
	| FLOAT   { variable_type="float"; }
	| DOUBLE   { /*semantic action is not required here*/ }
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list_opt   { /*semantic action is not required here*/ }
	| type_qualifier specifier_qualifier_list_opt  { /*semantic action is not required here*/ }
	;

specifier_qualifier_list_opt
	: %empty { /*semantic action is not required here*/ }
	| specifier_qualifier_list  { /*semantic action is not required here*/ }
	;

type_qualifier
	: CONST   
	{ /*semantic action is not required here*/ }
	| RESTRICT   
	{ /*semantic action is not required here*/ }
	| VOLATILE   
	{ /*semantic action is not required here*/ }
	;

function_specifier
	: INLINE   
	{ /*semantic action is not required here*/ }
	;

declarator
	: pointer direct_declarator 
	{		
		Symtyp *t = $1;
		while(t->arrtype!=NULL) t = t->arrtype;          		
		t->arrtype = $2->type;               		
		$$ = $2->update($1);                 				
	}
	| direct_declarator {   }
	;

direct_declarator
	: IDENTIFIER                
	{
		$$ = $1->update(new Symtyp(variable_type));	
		cur_sym = $$;	
	}
	| CIRCULAR_BRACKET_START declarator CIRCULAR_BRACKET_END {$$=$2;}       
	| direct_declarator SQUARE_BRACKET_START type_qualifier_list assignment_expression SQUARE_BRACKET_END {	}
	| direct_declarator SQUARE_BRACKET_START type_qualifier_list SQUARE_BRACKET_END {	}
	| direct_declarator SQUARE_BRACKET_START assignment_expression SQUARE_BRACKET_END 
	{
		
		Symtyp *t = $1 -> type;		
		Symtyp *prev = NULL;	
	
		while(t->type == "arr") 
		{
			prev = t;	
			t = t->arrtype;     
			
		}
		if(prev==NULL) 
		{			
			int temp = atoi($3->loc->val.c_str());     			
			Symtyp* s = new Symtyp("arr", $1->type, temp);       			
			$$ = $1->update(s);  			
		}
		else 
		{
			prev->arrtype =  new Symtyp("arr", t, atoi($3->loc->val.c_str()));    
			
			$$ = $1->update($1->type);
			
		}
	}
	| direct_declarator SQUARE_BRACKET_START SQUARE_BRACKET_END 
	{
		
		Symtyp *t = $1 -> type;
		
		Symtyp *prev = NULL;
		
		while(t->type == "arr") 
		{
			prev = t;	
			t = t->arrtype;        
			
		}
		if(prev==NULL) 
		{
			
			Symtyp* s = new Symtyp("arr", $1->type, 0);   
			$$ = $1->update(s);
				
		}
		else 
		{		
			prev->arrtype =  new Symtyp("arr", t, 0);	
			$$ = $1->update($1->type);
		}
	}
	| direct_declarator SQUARE_BRACKET_START STATIC type_qualifier_list assignment_expression SQUARE_BRACKET_END {	}
	| direct_declarator SQUARE_BRACKET_START STATIC assignment_expression SQUARE_BRACKET_END {	}
	| direct_declarator SQUARE_BRACKET_START type_qualifier_list MUL SQUARE_BRACKET_END {	}
	| direct_declarator SQUARE_BRACKET_START MUL SQUARE_BRACKET_END {	}
	| direct_declarator CIRCULAR_BRACKET_START CT parameter_type_list CIRCULAR_BRACKET_END 
	{
		
		ST->sn = $1->sn;
		
		if($1->type->type !="void") 
		{
			Sym *s = ST->lookup("return");        
			s->update($1->type);	
		}

		$1->nested=ST;       	
		ST->parent = global_Table;
		changeTable(global_Table);			
		cur_sym = $$;
		
	}
	| direct_declarator CIRCULAR_BRACKET_START identifier_list CIRCULAR_BRACKET_END 
	{	}
	| direct_declarator CIRCULAR_BRACKET_START CT CIRCULAR_BRACKET_END 
	{       
		
		ST->sn = $1->sn;
		
		if($1->type->type !="void") 
		{
			Sym *s = ST->lookup("return");
			s->update($1->type);
			
						
		}
		$1->nested=ST;
		ST->parent = global_Table;	
		changeTable(global_Table);			
		cur_sym = $$;
	}
	;

pointer
	: MUL type_qualifier_list_opt   
	{ 
		$$ = new Symtyp("ptr");
	}         
	| MUL type_qualifier_list_opt pointer 
	{ 
		$$ = new Symtyp("ptr",$3);	 
	}
	;

type_qualifier_list
	: type_qualifier   
	{ /*semantic action is not required here*/ }
	| type_qualifier_list type_qualifier   
	{ /*semantic action is not required here*/ }
	;

type_qualifier_list_opt
	: %empty   
	{ /*semantic action is not required here*/ }
	| type_qualifier_list      
	{ /*semantic action is not required here*/ }
	;

parameter_list
	: parameter_declaration   
	{ /*semantic action is not required here*/ }
	| parameter_list COMMA parameter_declaration    
	{ /*semantic action is not required here*/ }
	;

parameter_declaration
	: declaration_specifiers declarator   
	{ /*semantic action is not required here*/ }
	| declaration_specifiers   
	 { /*semantic action is not required here*/ }
	;

parameter_type_list
	: parameter_list   
	{ /*semantic action is not required here*/ }
	| parameter_list COMMA DOTS   
	{ /*semantic action is not required here*/ }
	;


identifier_list
	: IDENTIFIER	
	{ /*semantic action is not required here*/ }		  
	| identifier_list COMMA IDENTIFIER   
	{ /*semantic action is not required here*/ }
	;

type_name
	: specifier_qualifier_list   
	{ /*semantic action is not required here*/ }
	;

initializer
	: assignment_expression  
	 { $$=$1->loc; }   
	| CURLY_BRACKET_START initializer_list CURLY_BRACKET_END  
	{ /*semantic action is not required here*/ }
	| CURLY_BRACKET_START initializer_list COMMA CURLY_BRACKET_END  
	{ /*semantic action is not required here*/ }
	;

initializer_list
	: designation_opt initializer  
	{ /*semantic action is not required here*/ }
	| initializer_list COMMA designation_opt initializer   
	{ /*semantic action is not required here*/ }
	;


designator
	: SQUARE_BRACKET_START constant_expression SQUARE_BRACKET_END   
	{ /*semantic action is not required here*/ }
	| DOT IDENTIFIER 
	{ /*semantic action is not required here*/ }
	;

designation
	: designator_list ASSIGN   
	{ /*semantic action is not required here*/ }
	;


designation_opt
	: %empty   
	{ /*semantic action is not required here*/ }
	| designation   
	{ /*semantic action is not required here*/ }
	;

designator_list
	: designator    
	{ /*semantic action is not required here*/ }
	| designator_list designator   
	{ /*semantic action is not required here*/ }
	;



statement
	: labeled_statement   
	{ /*semantic action is not required here*/ }
	| compound_statement   
	{ $$=$1; }                       //simply equating
	| expression_statement   
	{ 
		$$=new Statement();             
		$$->nextlist=$1->nextlist; 
	}
	| selection_statement   
	{ $$=$1; }                       //simply equating
	| iteration_statement   
	{ $$=$1; }                       //simply equating
	| jump_statement   
	{ $$=$1; }                       //simply equating
	;


compound_statement
	: CURLY_BRACKET_START block_item_list_opt CURLY_BRACKET_END   
	{ $$=$2; } 
	;

labeled_statement
	: IDENTIFIER COLON statement   
	{ /*semantic action is not required here*/ }
	| CASE constant_expression COLON statement   
	{ /*semantic action is not required here*/ }
	| DEFAULT COLON statement   
	{ /*semantic action is not required here*/ }
	;


block_item_list_opt
	: %empty  
	{ $$=new Statement(); }     
	| block_item_list   
	{ $$=$1; }                       //simply equating       
	;

block_item_list
	: block_item   
	{ $$=$1; }                       //simply equating		
	| block_item_list M block_item    
	{ 
		$$=$3;
		backpatch($1->nextlist,$2);    
	}
	;

block_item
	: declaration   
	{ $$=new Statement(); }         
	| statement   
	{ $$=$1; }                       //simply equating			
	;

expression_statement
	: expression SEMICOLON 
	{ $$=$1;}		
	| SEMICOLON 
	{$$ = new Expression();}     
	;


jump_statement
	: GOTO IDENTIFIER SEMICOLON { $$ = new Statement(); }           
	| CONTINUE SEMICOLON { $$ = new Statement(); }			  
	| BREAK SEMICOLON { $$ = new Statement(); }				
	| RETURN expression SEMICOLON               
	{		
		$$ = new Statement();		
		emit("return",$2->loc->sn);              
	
	}
	| RETURN SEMICOLON 
	{		
		$$ = new Statement();		
		emit("return","");                        

	}
	;

selection_statement
	: IF CIRCULAR_BRACKET_START expression N CIRCULAR_BRACKET_END M statement N %prec "then"     
	{	
		backpatch($4->nextlist, nextinstr());       
		IntToBool_conversion($3);        
		$$ = new Statement();      
		backpatch($3->truelist, $6);       
		list<int> temp = merge($3->falselist, $7->nextlist);  
		$$->nextlist = merge($8->nextlist, temp);	
	}
	| IF CIRCULAR_BRACKET_START expression N CIRCULAR_BRACKET_END M statement N ELSE M statement  
	{
		backpatch($4->nextlist, nextinstr());	
		IntToBool_conversion($3);       		
		$$ = new Statement();      
		backpatch($3->truelist, $6);   
		backpatch($3->falselist, $10);
		list<int> temp = merge($7->nextlist, $8->nextlist);      
		$$->nextlist = merge($11->nextlist,temp);				
	}
	| SWITCH CIRCULAR_BRACKET_START expression CIRCULAR_BRACKET_END statement {	}      
	;

iteration_statement	
	: WHILE M CIRCULAR_BRACKET_START expression CIRCULAR_BRACKET_END M statement     
	{
		
		$$ = new Statement();   
		IntToBool_conversion($4);    
		backpatch($7->nextlist, $2);
		backpatch($4->truelist, $6);
		$$->nextlist = $4->falselist;  
	
		string str=IntToString_conversion($2);			
		emit("goto", str);
		
		
			
	}
	| DO M statement M WHILE CIRCULAR_BRACKET_START expression CIRCULAR_BRACKET_END SEMICOLON     
	{
		
		$$ = new Statement();    
		IntToBool_conversion($7);     
		backpatch($7->truelist, $2);					
		backpatch($3->nextlist, $4);					
		$$->nextlist = $7->falselist;                      
	}
	| FOR CIRCULAR_BRACKET_START expression_statement M expression_statement CIRCULAR_BRACKET_END M statement     
	{
		
		$$ = new Statement();  
		IntToBool_conversion($5);   
		backpatch($5->truelist,$7);       
		backpatch($8->nextlist,$4);       
		string str=IntToString_conversion($4);
		emit("goto", str);                
		$$->nextlist = $5->falselist;     
		
	}
	| FOR CIRCULAR_BRACKET_START expression_statement M expression_statement M expression N CIRCULAR_BRACKET_END M statement
	{
		$$ = new Statement();		
		IntToBool_conversion($5); 
		backpatch($5->truelist, $10);
		backpatch($8->nextlist, $4);
		backpatch($11->nextlist, $6);
		string str=IntToString_conversion($6);
		emit("goto", str);			
		$$->nextlist = $5->falselist;
		
	}
	;

declaration_list
	: declaration   
	{ /*semantic action is not required here*/ }
	| declaration_list declaration    
	{ /*semantic action is not required here*/ }
	;				   										  				   

declaration_list_opt
	: %empty 
	{ /*semantic action is not required here*/ }
	| declaration_list   
	{ /*semantic action is not required here*/ }
	;

function_definition
	:declaration_specifiers declarator declaration_list_opt CT compound_statement  
	{
		int next_instr=0;	 
		ST->parent=global_Table;
		changeTable(global_Table);                    		
	}
	;


external_declaration
	: function_definition 
	{ /*semantic action is not required here*/ }
	| declaration   
	{ /*semantic action is not required here*/ }
	;

translation_unit
	: external_declaration 
	{ /*semantic action is not required here*/ }
	| translation_unit external_declaration 
	{ /*semantic action is not required here*/ } 
	;

%%

void yyerror(string s) 
{       
    cout<<s<<"\n";
}
