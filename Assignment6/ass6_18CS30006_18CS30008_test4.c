//Finding n-th fibonacci number 
int fib(int n) 
{ 
  int arr[20];   
  int i; 
  arr[0] = 0; 
  arr[1] = 1; 
  for (i = 2; i <= n; i++) { 
      arr[i] = arr[i-1] + arr[i-2]; 
  } 
  return arr[n]; 
} 
  
int main () //main function
{ 
  int n = 12; 
  int fibonacci;
  fibonacci = fib(n);
  return 0; 
} 