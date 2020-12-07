#ifndef TRANSLATE
#define TRANSLATE

#include <bits/stdc++.h>

extern  char* yytext;
extern  int yyparse();

using namespace std;

#define Symtyp Symboltype

class Symtable;					//for Symbol Table
class Sym;						//for an entry in Symbol Table
class Symboltype;				//for the Symbol's type in Symbol Table
class QUAD;						//for a single entry in the Quad Array
class Quad_Arr;					//for the Array of Quads

class Symtable 
{ 					
	public:
		string sn;					//Name of the Symbol Table
		int count;					//No. of the temporary variables
		list<Sym> table; 			//The table of Symbols which is essentially a list of Sym
		Symtable* parent;			//Parent Symbol Table of the current Symbol Table
		
		Symtable (string sn="NULL");
		
		Sym* lookup (string);		
						
		void print();	
						            			
		void update();						        			
};

class Sym 
{                      
	public:
		string sn;				//Symbol's name
		Symboltype *type;			//Symbol's type
		int size;					//Symbol's size
		int offset;					//offset of Symbol
		Symtable* nested;			//pointer to the nested Symbol table
		string val;				    //initial value of the Symbol if specified

		Sym (string , string t="int", Symboltype* ptr = NULL, int width = 0);
		Sym* update(Symboltype*); 	//to update fields of an existing entry
};

class Symboltype 
{                      
	public:
		string type;					//type of Symbol
		int width;					    //size of Array (if it is an Array, else its value is 1)
		Symboltype* arrtype;			//for arrays which are multidimensional

		Symboltype(string , Symboltype* ptr = NULL, int width = 1);
};

class QUAD 
{ 			
	public:
		string res;					
		string op;					
		string argument1;				
		string argument2;				
	
		void print();	
		void type1();      
		void type2();
									
		QUAD (string , string , string op = "=", string argument2 = "");			
		QUAD (string , int , string op = "=", string argument2 = "");				
		QUAD (string , float , string op = "=", string argument2 = "");			
};

class Quad_Arr 
{ 		
	public:
		vector<QUAD> Array;		                    
		
		void print();								
};

extern Symtable* global_Table;				    //Global Symbol Table
extern Symtable* ST;						//current Symbol Table
extern Sym* cur_sym;					    //latest encountered Symbol
extern Quad_Arr quad;							//QUAD Array


struct Statement {
	list<int> nextlist;					
};

struct Array {
	string arr_typ;				
	Sym* loc;					
	Sym* Array;					
	Symboltype* type;			
};

struct Expression {
	Sym* loc;								//pointer to Symbol Table entry
	string type; 							//expression type
	list<int> truelist;						//truelist 
	list<int> falselist;					//falselist 
	list<int> nextlist;						//for statement expressions
};
Expression* IntToBool_conversion(Expression*);				//conversion from int expression to boolean
Expression* BoolToInt_conversion(Expression*);				//conversion from boolean expression to int


string IntToString_conversion(int );
string FloatToString_conversion(float );
void Add_Spaces(int );


Sym* gentemp (Symboltype* , string init = "");	  //generate a temporary variable and insert it in the current Symbol Table

//Backpatching
void backpatch (list <int> , int );
list<int> makelist (int );							    //Make a new list contaninig an integer
list<int> merge (list<int> &l1, list <int> &l2);		//Merge two lists

int nextinstr();										//Returns the next instruction number

//Emit Functions
void emit(string , string , string argument1="", string argument2 = "");  
void emit(string , string , int, string argument2 = "");		  
void emit(string , string , float , string argument2 = "");   


Sym* conv(Sym*, string);					//Type conversion
bool typecheck(Sym* &s1, Sym* &s2);			//compare two Symbol table entries
bool typecheck(Symboltype*, Symboltype*);	//compare two Symtyp objects
int computeSize (Symboltype *);				//calculate size of Symbol type
string print_type(Symboltype *);				//print Symbol type  
void changeTable (Symtable* );				//to change current table

#endif