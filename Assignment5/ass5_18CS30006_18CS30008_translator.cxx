#include "ass5_18CS30006_18CS30008_translator.h"
#include <bits/stdc++.h>
#include<sstream>
#include<string>
#include<iostream>

using namespace std;
#define Comp compare

Symtable* global_Table;			// Global Symbol Table	
Symtable* ST;					// current symbol table pointer
Sym* cur_sym; 					// current symbol pointer
Quad_Arr quad;					// Quad Array
string variable_type;			// Stores latest type


Symtable::Symtable(string name)        //constructor for a symbol table    
{
	(*this).sn=name;
	count=0;						   //asigning count as 0
}
Sym* Symtable::lookup(string name)     //Lookup for id in the symbol table       
{
	Sym* Symbol;
	list<Sym>::iterator it;                     
	it=table.begin();					//it is iterator for list of symbols
	while(it!=table.end()) 
	{
		if(it->sn==name) 
			return &(*it);        		//finding the name of symbol in the ST
		it++;
	}

	Symbol= new Sym(name);
	table.push_back(*Symbol);           //push symbol
	return &table.back();               //return the symbol
}
void Symtable::update()               //Update the symbol table       
{
	list<Symtable*> tb;                //list of tables
	int off;
	list<Sym>::iterator it;
	it=table.begin();
	while(it!=table.end()) 
	{
		if(it==table.begin()) 
		{
			it->offset=0;
			off=it->size;
		}
		else 
		{
			it->offset=off;
			off=it->offset+it->size;
		}
		if(it->nested!=NULL) 
			tb.push_back(it->nested);
		it++;
	}
	list<Symtable*>::iterator it1;
	it1=tb.begin();
	while(it1 !=tb.end()) 
	{
	  (*it1)->update();
	  it1++;
	}
}

void Symtable::print()                  //print the symbol table         
{	
	int next_instr=0;
	list<Symtable*> tb;                  //list of tables    
	
	cout<<"----------------------------------------------------------------------------------------------------"<<"\n";
	cout<<"Table Name: "<<(*this).sn<<"\t\t\t Parent Name: ";
	if(((*this).parent==NULL))
		cout<<"NULL"<<"\n";
	else
		cout<<(*this).parent->sn<<"\n"; 
		
	cout<<"----------------------------------------------------------------------------------------------------"<<"\n";
	cout<<"Name";             
	Add_Spaces(11);
	cout<<"Type";             
	Add_Spaces(16);
	cout<<"Initial Value";   
	Add_Spaces(7);
	cout<<"Size";             
	Add_Spaces(11);
	cout<<"Offset";           
	Add_Spaces(9);
	cout<<"Nested"<<"\n";      //Nested symbol table
	Add_Spaces(100);
	cout<<"\n";
	ostringstream str1;
	 
	for(list<Sym>::iterator it=table.begin(); it!=table.end(); it++) {         //Print details for the table
		cout<<it->sn;                                   
		Add_Spaces(15-it->sn.length());
		string type_r=print_type(it->type);      //Use PrintType to print type        
		cout<<type_r;
		Add_Spaces(20-type_r.length());
		cout<<it->val;                         	//Print initial value          
		Add_Spaces(20-it->val.length());
		cout<<it->size;                         //Print size   
		str1<<it->size;
		Add_Spaces(15-str1.str().length());
		str1.str("");
		str1.clear();
		cout<<it->offset;                        //Print size        
		str1<<it->offset;
		Add_Spaces(15-str1.str().length());
		str1.str("");
		str1.clear();
		if(it->nested==NULL) {                            
			
			cout<<"NULL"<<"\n";
				
		}
		else {
			
			cout<<it->nested->sn<<"\n";		
			tb.push_back(it->nested);
			
		}
	}
	
	cout<<"----------------------------------------------------------------------------------------------------"<<"\n";

	cout<<"\n";
	for(list<Symtable*>::iterator it=tb.begin(); it !=tb.end();++it) 
	{
    	(*it)->print();                   //print symbol table           
	}
			
}


Symtyp::Symtyp(string type,Symtyp* arrtype,int width)  		//Symbol type constructor     
{
	(*this).type=type;
	(*this).width=width;
	(*this).arrtype=arrtype;
	
}

Sym::Sym(string name, string t, Symtyp* arrtype, int width) //Symbol table entry constructor
{     
		(*this).sn=name;
		type=new Symtyp(t,arrtype,width);     //Generate type of symbol 
		size=computeSize(type);               //finding size from the type  
		offset=0;                             //set offset = 0     
		val="-";							  //assign no intial value
		nested=NULL;						  //and assign no nested table
}

Sym* Sym::update(Symtyp* t) 		//update Symbol table entry
{
		
	type=t;								//Update the new type
	(*this).size=computeSize(t);                
	
	return this;					//return the same variable
}

//Constructors for quad
QUAD::QUAD(string result,string argument1,string op,string argument2)          
{
	(*this).res=result;
	
	(*this).argument1=argument1;
	
	(*this).op=op;
	
	(*this).argument2=argument2;
	
}
QUAD::QUAD(string result,int argument1,string op,string argument2)            
{
	(*this).res=result;
	
	(*this).argument2=argument2;
	
	(*this).op=op;
	
	(*this).argument1=IntToString_conversion(argument1);
	
}
QUAD::QUAD(string result,float argument1,string op,string argument2)          
{
	(*this).res=result;
	
	(*this).argument2=argument2;
	
	(*this).op=op;
	
	(*this).argument1=FloatToString_conversion(argument1);
	
}
void QUAD::print() 			 //Printing a quad
{                                   
	
	int next_instr=0;	
	if(op=="+")
	{			
		(*this).type1();
	}
	else if(op=="-")
	{				
		(*this).type1();
	}
	else if(op=="*")
	{
		(*this).type1();
	}
	else if(op=="/")
	{			
		(*this).type1();
	}
	else if(op=="%")
	{
		(*this).type1();
	}
	else if(op=="|")
	{	
		(*this).type1();
	}
	else if(op=="&")
	{					
		(*this).type1();
	}
	else if(op=="^")
	{		
		(*this).type1();
	}
	else if(op=="<")
	{					
		(*this).type2();
	}
	else if(op==">")
	{
		
		(*this).type2();
	}
	else if(op==">>")
	{
		
		(*this).type1();
	}
	else if(op=="<<")
	{
						
		(*this).type1();
	}
	else if(op=="==")
	{
		
		(*this).type2();
	}
	else if(op=="!=")
	{	
		(*this).type2();
	}
	else if(op=="<=")
	{	
		(*this).type2();
	}
	else if(op==">=")
	{					
		(*this).type2();
	}
	else if(op=="goto")
	{					
		cout<<"goto L"<<res;
	}	
	
	else if(op=="=")
	{					
		cout<<res<<" = "<<argument1 ;
	}					
	else if(op=="=&")
	{
						
		cout<<res<<" = &"<<argument1;
	}
	else if(op=="=*")
	{	
		cout<<res<<" = *"<<argument1 ;
	}
	else if(op=="*=")
	{	
					
		cout<<"*"<<res	<<" = "<<argument1 ;
	}
	else if(op=="uminus")
	{	
		cout<<res<<" = -"<<argument1;
	}
	else if(op=="~")
	{					
		cout<<res<<" = ~"<<argument1;
	}
	else if(op=="!")
	{	
		cout<<res<<" = !"<<argument1;
	}
	else if(op=="=[]")
	{
		 cout<<res<<" = "<<argument1<<"["<<argument2<<"]";
	}
	else if(op=="[]=")
	{		 
		cout<<res<<"["<<argument1<<"]"<<" = "<< argument2;
	}
	else if(op=="return")
	{	 			
		cout<<"return "<<res;
	}
	else if(op=="call")
	{	 			
		cout<<res<<" = "<<"call "<<argument1<<", "<<argument2;
	}
	else if(op=="label")
	{	
		cout<<res<<": ";
	}
	else if(op=="param")
	{	 			
		cout<<"param "<<res;
	}	
	else
	{	
		cout<<"No Match found"<<op;
	}			
	cout<<"\n";
	
}
void QUAD::type1()
{
	cout<<res<<" = "<<argument1<<" "<<op<<" "<<argument2;
}
void QUAD::type2()
{
	cout<<"if "<<argument1<< " "<<op<<" "<<argument2<<" goto L"<<res;	
}

void Quad_Arr::print()               //print the quad Array i.e the TAC                   
{
	cout<<"----------------------------------------------------------------------------------------------------"<<"\n";
	cout<<"Three Address Code:"<<"\n";          //print 3 Address Code
	cout<<"----------------------------------------------------------------------------------------------------"<<"\n";

	int j=0;
	vector<QUAD>::iterator it;
	it=Array.begin();
	while(it!=Array.end()) 
	{
		if(it->op=="label") 	 //if label
		{  
			cout<<"\n"<<"L"<<j<<": ";
			it->print();
		}
		else {					//not label
			cout<<"L"<<j<<": ";
			Add_Spaces(4);		//give 4 spaces and then print
			it->print();
		}
		it++;j++;
	}
	cout<<"----------------------------------------------------------------------------------------------------"<<"\n";

}


/***********Emit Functions*******************/
void emit(string op, string res, string argument1, string argument2) 
{            
	QUAD *q1= new QUAD(res,argument1,op,argument2);
	
	quad.Array.push_back(*q1);
}
void emit(string op, string res, int argument1, string argument2) 
{                
	QUAD *q2= new QUAD(res,argument1,op,argument2);
	quad.Array.push_back(*q2);
}
void emit(string op, string res, float argument1, string argument2) 
{                
	QUAD *q3= new QUAD(res,argument1,op,argument2);
	quad.Array.push_back(*q3);
}
/********************************************/

void Add_Spaces(int n)
{
	for (int i = 0; i < n; ++i)
	 {
	 	cout<<" ";
	 } 		
}



bool typecheck(Sym*& s1,Sym*& s2)			// Check if the symbols have same type or not
{ 	
	Symtyp* type1=s1->type;                         
	Symtyp* type2=s2->type;
	if((typecheck(type1,type2))|| (s1=conv(s1,type2->type)) || (s2=conv(s2,type1->type))) 
		return true;	
	
	return false;
}
bool typecheck(Symtyp* t1,Symtyp* t2)		// Check if the symbols have same type or not
{ 	
	if(t1==NULL && t2==NULL) 
		return true;              
	else if(t1==NULL || t2==NULL || t1->type!=t2->type) 
		return false;                   
	else 
		return typecheck(t1->arrtype,t2->arrtype);      
}


string print_type(Symtyp* t)       //printing type to the symbol table    
{
	if(t==NULL) return "null";
	if(t->type.Comp("void")==0)	return "void";
	else if(t->type.Comp("char")==0) return "char";
	else if(t->type.Comp("int")==0) return "int";
	else if(t->type.Comp("float")==0) return "float";
	else if(t->type.Comp("ptr")==0) return "ptr("+print_type(t->arrtype)+")";      
	else if(t->type.Comp("arr")==0) 
	{
		string str=IntToString_conversion(t->width);                               
		return "arr("+str+","+print_type(t->arrtype)+")";
	}
	else if(t->type.Comp("func")==0) return "func";
	else return "_";
}

int computeSize(Symtyp* t)     //computing size            
{
	
	if(t->type.Comp("char")==0) 
		return 1;
	else if(t->type.Comp("int")==0) 
		return 4;
	else if(t->type.Comp("float")==0) 
		return  8;
	else if(t->type.Comp("arr")==0) 
		return t->width*computeSize(t->arrtype);    
	else if(t->type.Comp("ptr")==0) 
		return 4;
	else 
		return 0;
}


void changeTable(Symtable* newtable) 		// Change current symbol table
{	       
	ST = newtable;
} 

void backpatch(list<int> list1,int addr)          //backpatching       
{
	string str=IntToString_conversion(addr);         //get string form of the address    
	list<int>::iterator it;
	it=list1.begin();
	
	while( it!=list1.end()) 
	{
		quad.Array[*it].res=str;                    
		it++;
	}
}

int nextinstr() 			 //next instruction will be 1+last index and lastindex=size-1. hence return size
{
	
	return quad.Array.size();               
}

Sym* gentemp(Symtyp* t, string str_new) 	 //generate temp variable
{          
	string tmp_name = "t"+IntToString_conversion(ST->count++);            
	Sym* s = new Sym(tmp_name);					//naming that temporary variable
	(*s).type = t;
	(*s).size=computeSize(t);                       
	(*s).val = str_new;							//calculate its size
	ST->table.push_back(*s);                    //push it in Symbol Table  
	return &ST->table.back();
}

list<int> merge(list<int> &a,list<int> &b)		 //merge two existing lists a and b
{
	a.merge(b);                               	
	return a;
}

list<int> makelist(int init) //make a new list
{
	list<int> newlist(1,init);                     
	return newlist;
}


Sym* conv(Sym* s, string Type) 			//convert s to required Type
{                            
	Sym* temp=gentemp(new Symtyp(Type));	
	if((*s).type->type=="float")                                     
	{
		if(Type=="int")                                      
		{
			emit("=",temp->sn,"float2int("+(*s).sn+")");
			return temp;
		}
		else if(Type=="char")                   
		{
			emit("=",temp->sn,"float2char("+(*s).sn+")");
			return temp;
		}
		return s;
	}
	else if((*s).type->type=="int")                                 
	{
		if(Type=="float") 				
		{
			emit("=",temp->sn,"int2float("+(*s).sn+")");
			return temp;
		}
		else if(Type=="char") 								
		{
			emit("=",temp->sn,"int2char("+(*s).sn+")");
			return temp;
		}
		return s;
	}
	else if((*s).type->type=="char") 								 
	{
		if(Type=="int") 									
		{
			emit("=",temp->sn,"char2int("+(*s).sn+")");
			return temp;
		}
		if(Type=="double") 							
		{
			emit("=",temp->sn,"char2double("+(*s).sn+")");
			return temp;
		}
		return s;
	}
	return s;
}

Expression* IntToBool_conversion(Expression* E1)      //to convert int to bool 
{
	if(E1->type!="bool")                
	{
		E1->falselist=makelist(nextinstr());  		 //update the falselist, truelist and also emit general goto statements
		emit("==","",E1->loc->sn,"0");
		E1->truelist=makelist(nextinstr());
		emit("goto","");
	}
	return E1;
}

Expression* BoolToInt_conversion(Expression* E1) 	//to convert bool to int 
{
	if(E1->type=="bool") 
	{
		
		E1->loc=gentemp(new Symtyp("int"));        
		
		backpatch(E1->truelist,nextinstr());
		
		emit("=",E1->loc->sn,"true");
		
		int p=nextinstr()+1;
		
		string str=IntToString_conversion(p);
		
		emit("goto",str);
		
		backpatch(E1->falselist,nextinstr());
		
		emit("=",E1->loc->sn,"false");
		
	}
	return E1;
}

string IntToString_conversion(int a)               //to convert int to string    
{
	stringstream strs;                     
    strs<<a; 
    string temp=strs.str();
    char* integer=(char*) temp.c_str();
	string str=string(integer);
	return str;         
}

string FloatToString_conversion(float x)            //to convert float to string           
{
	std::ostringstream temp;
	temp<<x;
	return temp.str();
}


int main()
{	
	
	global_Table=new Symtable("GlobalST");                        
	ST=global_Table;
	yyparse();												
	global_Table->update();										

	global_Table->print();									
	cout<<"\n";
	quad.print();	
												
};
