// C function for calculating GCD of two numbers
int GCD(int x, int y) 
{ 
    if (x == 0) 
        return y; 
    return GCD(y % x, x); 
}

int main()  //main function  
{  
    int a=45;
    int b, gcd;
    if(a==0)
    {
    	a=100;
    	b=25;
    }
    else
    {
    	if(a==100)
    		b=15;
    	else
    		b=5;
    }
    gcd = GCD(a, b);
    return 0;  
}  

