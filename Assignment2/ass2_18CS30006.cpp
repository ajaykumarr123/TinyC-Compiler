#include "toylib.h"
char HEXA[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

int find(char x)
{	
	int f=-1;
	for(int i = 0; i < 16; i++)
	{
		if(HEXA[i] == x)
		{
			f=i;
			break;;
		}
	}
		return f;
}

int printStringUpper(char *a)
{	
	int temp=0;
	while(a[temp]!='\0')
	{
		temp++;
	}

	    char b[temp + 1];
    for(int i = 0; i < temp; i++)
    {
    	if(a[i] >= 'a' && a[i] <= 'z')
    	{
    		b[i] = a[i] - 32;
    	}
    	else
    	{
    		b[i] = a[i];
    	}
    }
    b[temp] = '\n';
    __asm__ __volatile__ (
        "movl $1, %%eax\n\t"
        "movq $1, %%rdi\n\t"
        "syscall \n\t"
        :
        :"S"(b), "d"(temp + 1)
    );
    return (temp);
}

int readHexInteger(int* n)
{
	char c[2];
	int first=1;
	int f=0;
	long long int res=0;
    while(1)
	{
		__asm__ __volatile__  (    
	 		"syscall"
	 		:
	 		:"a"(0), "D"(0), "S"(c), "d"(1)		
	 	);

      	char b = c[0];
      	if(b == '-')
			{
				if(first)
					f = 1;
				else 
					return BAD;

				first=0;
				continue;
			}

     	else if (b== 32 || b == '\t' || b == '\n' || b == '\0')
        	break;
        

	    else if(b >= 'a' && b <= 'z')
	    		b -= 32;
	   
	   
	    else if ((b >= 'G' && b <= 'Z') || b == '.') 
	    		return BAD;    
	    

	    res=res*16+find(b);
	    first=0;
	}
	if(f)
		res*=(-1);
	*n = res;
    return GOOD;
}

int printHexInteger(int n)
{
    int sign = 1;
    if(n < 0)
    {
        sign = -1;
        n *= (-1);
    }

    int SZ=0,k=n;

    while(k)
    {
    	k/=16;
    	SZ++;
    }

    char *a = new char[SZ];
   
    int ii = 0,size=SZ;
    while(n)
    {
        a[ii] = HEXA[n % 16];
        n /= 16;
        ii++;
    }

    char b[size + 1];
    for (int i = 0; i < size; i++)
        b[i] = a[size - i - 1];
    
    if (sign == -1)
    {
        char c[size+2];
        c[0] = '-';
        for (int i = 0; i < size; i++)
        {
            c[i + 1] = b[i];
        }
        c[size + 1] = '\n';
        __asm__ __volatile__ (

            "movl $1, %%eax\n\t"
            "movq $1, %%rdi\n\t"
            "syscall \n\t"
            :
            :"S"(c), "d"(size + 2)
        );
        return size + 1;
    }
    else
    {
        b[size] = '\n';
        __asm__ __volatile__ (

            "movl $1, %%eax\n\t"
            "movq $1, %%rdi\n\t"
            "syscall \n\t"
            :
            :"S"(b), "d"(size + 1)
        );
        return size;
    }
}

int readFloat(float *n)
{
	char c[2];
	bool flag = 0;
	bool first = 1;
	bool dec = 0; 
	double div = 1;
	float a = 0;
	while(1)
	{
		__asm__ __volatile__  (    
	 		"syscall"
	 		:
	 		:"a"(0), "D"(0), "S"(c), "d"(1)		
	 	);
	
		char b = c[0];
		if(b == '\n' or b == '\0' or b == ' ')
		{
			break;
		}

		if(b == '-')
		{
			if(first)
			{
				flag = 1;
			}
			else 
				return BAD;
		}
		else if(b == '.')
		{
			if(dec)
				return BAD;
			else 
				dec = 1;
		}
		else if(b >= '0' or b <= '9')
		{
			if(!dec)
				a *= 10;
			double temp=(b-'0');
			a += (double)(temp)/div;
		}
		
		if(dec)
			div *= 10;
		first=0;
	}
	if(flag)
		a*=-1;

	*n=a;
	return GOOD;
}

int printFloat(float f)
{
	if(f==0)
	{
		char c[2]="0";
		__asm__ __volatile__ (
			"movl $1, %%eax \n\t"
			"movq $1, %%rdi \n\t"
			"syscall \n\t"
			:
			:"S"(c), "d"(1)
		);
		return GOOD;
	}

	int neg= (f<0) ? 1: 0;

	if(neg)
		f*=-1;

	float temp=f;
	int before=0;

	while(f>1)
	{
		before++;
		f/=10;
	}

	int after=0;
	while(temp!=(float)((int)temp))
	{
		temp*=10;
		after++;
	}

	int size = before+after+1;
	if(neg)
		size++;
	if(before==0)
		size++;

	char c[size];

	int in=0;
	if(neg)
		c[in++]='-';
	if(before==0)
		c[in++]='0';

	for(int i=0;i<before;i++)
	{
		f*=10;
		int p=(int)f%10;
		c[in++]=(char)(p+'0');
	}
	c[in++]='.';
	for(int i=0;i<(after);i++)
	{
		f*=10;
		int p=(int)f%10;
		c[in++]=(char)(p+'0');
	}

	__asm__ __volatile__  (
			"movl $1, %%eax \n\t"
			"movq $1, %%rdi \n\t"
			"syscall \n\t"
			:
			:"S"(c), "d"(size)
		);
	return size;

}
