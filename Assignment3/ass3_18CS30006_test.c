long gcd(long a, long b)
{
    if (b == 0)
        return a;
    return gcd(b, a % b); 
     
}

int Function_test(int num1, int num2)
{	
	int x=10;
	float pi=3.14;
	char c1,c2;				/*Assigning charater*/
	c1='a';
	c2='b';
	char arr[]="Remainder";	 /*Array Initialisation*/

	int rem=num1%num2;			//finding remainder
	return rem;
}