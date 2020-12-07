#include <iostream>
using namespace std;
#include "toylib.h"
int main() 
{ 
  int temp,t;
  char a[100];
  
  cout << "Enter your string:";
  cin>>a;
  int size=printStringUpper(a);
  cout<<"Size of String:"<<size<<endl;


  cout<<"\nEnter Number in Hexadecimal:"<<endl;
  t = readHexInteger(&temp);
  if(t==-1)
  	cout<<"BAD"<<endl;
  else
  	cout << "Decimal: " << temp << "\n";


  cout<<"\nEnter Number in Decimal:";
  cin >> temp;
  t=printHexInteger(temp);
  if(t==-1)
   	cout<<"BAD"<<endl;
  else
   cout<<"Number of characters printed:"<<t<<endl;



  float f;
  cout<<"\nEnter float Number:"<<endl;
  readFloat(&f);
  if(t==-1)
  	cout<<"BAD"<<endl;
  else
  	cout << f << "\n";
  

  float ff;
  cout<<"\nEnter float Number:";
  cin >> ff;
  t=printFloat(ff);
  if(t==-1)
   	cout<<"\nBAD"<<endl;
  else
   cout<<"\nNumber of characters printed:"<<t<<endl;

return 0;
} 
