/*
Assignment 6
Semester: Autumn 2020

Name1: Ajay Kumar(18CS30006)
Name2: Ashish Gour(18CS30008)
*/


#include "myl.h"
int printStr(char *str) 
{
    int size=0;
    
    // get the string length
    while(str[size]!='\0')
    {
        size++;
    }

    /* inline assembly line commands for system call to print "temp" to STDOUT*/
    __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(str),"d"(size)
        );

    return size;
}


int readInt(int *int_ptr) 
{
    // max 100 characters accepted
	char arr[100];
	int is_neg = 0;
	int val = 0;
    int count = 0;
    int byte_count = 20;
	
    __asm__ __volatile__ (
          "movl $0, %%eax \n\t"
          "movq $1, %%rdi \n\t"
          "syscall \n\t"
          :
          :"S"(arr), "d"(byte_count)
    ) ;

    if (arr[count] == '-'){
        is_neg = -1;
        count++;
    }
    else{
        is_neg = 1;
    }

    while(arr[count] != '\n' && arr[count] != ' ' && arr[count] != '\t'){
        // printf("%d\n", arr[count]);
        if (( ((int)arr[count]-'0' > 9) || ((int)arr[count]-'0' < 0) )) 
            return ERR;
        val *= 10;
        val += (arr[count] - '0');
        count++;
    }

    if (is_neg == -1){
        val = -1 * val;
    }
    *int_ptr = val;
	return OK;
}


int printInt(int n)
{
	char arr[100];
	int i=0;
    int neg_flag=0;
    if(!n){
        arr[i++]='0';
    } 
    else
    {
        if(n < 0)
        {
            neg_flag=1;
            n*=-1;
        }
        while(n)
        {
            arr[i++] = n%10 + '0';
            n/=10;
        }
        if(neg_flag) arr[i++]='-';
        for(int j=0,k=i-1;j<k;j++,k--)
        {
            char swa = arr[j];
            arr[j] = arr[k];
            arr[k] = swa;
        }
    }

	/* inline assembly code*/
	__asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(arr),"d"(i)
        );

    return i;
}

int readFlt(float *flt_ptr) {
	// max 100 characters accepted
	char arr[100];
	int is_neg = 0, pow_10 = 0;
	float val = 0.00;
    int dot_encountered = 0;
    int count = 0;
    int byte_count = 20;
	
    __asm__ __volatile__ (
          "movl $0, %%eax \n\t"
          "movq $1, %%rdi \n\t"
          "syscall \n\t"
          :
          :"S"(arr), "d"(byte_count)
    ) ;

    if (arr[count] == '-'){
        is_neg = -1;
        count++;
    }
    else{
        is_neg = 1;
    }

    while(arr[count] != '\n' && arr[count] != ' ' && arr[count] != '\t'){
        // printf("%f\n", (float)val);
        // printf("%c\n", arr[count]);
        if ((((int)arr[count]-'0' > 9) || ((int)arr[count]-'0' < 0)) && (arr[count]!='.')) 
            return ERR;
        else if (arr[count]=='.' && dot_encountered){
            return ERR;
        }
        if (arr[count] == '.'){
            dot_encountered = 1;
            count++;
            continue;
        }
        if (dot_encountered){
            int  temp_div = 10;
            for (int k=0; k<pow_10; k++){
                temp_div *= 10;
            }
            // printf("\n\n%f\n\n" ,(float)(arr[count] - '0') / temp_div);
            val += ((float)(arr[count] - '0') / temp_div);
            pow_10++;
        }
        else{
            val *= 10.00;
            val = val + (float)(arr[count] - '0');
        }
        count++;
    }

    if (is_neg == -1){
        val = -1 * val;
    }
    *flt_ptr = val;
	return OK;
}

int printFlt(float f){
	char arr[100];
    char zero = '0';
    int i=0;
    // handle negative float number
    if(f<0)
    {
        arr[i]='-';
        f=(-1.0)*f;
        i++;
    }
	int a=(int)f;
    int j,k,count_bytes;
	// Take the decimal part out of the number
    float b = (float)f-(float)a;
    
    if(a==0)
    {
        // if there is zero only
        arr[i]=zero;
        i++;
    }

    else
    {
       while(a!=0)
        {
            int dig=a%10;
            arr[i]=(char)(zero+dig);
            a/=10;
            i++;
        }
        if(arr[0]=='-')
        {
            j=1;
        }
        else j=0;
        k=i-1;
        // reverse numbers to print in right order
        while(j<k)
        {
            char temp=arr[j];
            arr[j]=arr[k];
            arr[k]=temp;
            j++;
            k--;
        }
    }

    // handle the decimal part separately
    // printf("\n%f\n", b);
    if(b!=0)
    {
        arr[i]='.';
        i++;
        int p = 0;
        while( p < 7 )
        {
            b=b*10;
            int dig=(int)b;
            arr[i]=(char)(zero+dig);
            i++;
            b=b-dig;
            p++;
        }
	}
    count_bytes = i;
    __asm__ __volatile__ (
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        :"S"(arr), "d"(count_bytes)
    );

    return count_bytes;
}

