/*******global variables*********/
float d = 2.3;
int i, w[10];
int a1 = 4, *p, a2;
void func(int i, float a3);
char c;
/******************************/

int find_diff(int x, int y)
{
    int max,min,diff;
    max = maximum(x,y);   
    min = minimum(x,y);
    diff=max-min;
    return diff;
}

int minimum(int x, int y) 
{
   int ans;
   ans = x>y ? y:x;     //Ternary Operator
   return ans;
}

int maximum(int x, int y) 
{
   int ans;
   if(x>y)  
    ans=x;
   else
    ans=y;
   return ans;
}

int main()          //main function
{        
    int a,b,diff;
    a=19;
    b=7;
    diff=find_diff(a,b);
    return 0;
}