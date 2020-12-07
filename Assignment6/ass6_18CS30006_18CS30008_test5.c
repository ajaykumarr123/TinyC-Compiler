// C function to find largest number 
int findlargest(int arr[], int n) 
{ 
    int i; 
    int max = arr[0]; 
    for (i = 1; i < n; i++) 
        if (arr[i] > max) 
            max = arr[i];
    return max; 
} 
int main() 
{ 
    int arr[] = {5, 15, 12, 90, 84}; 
    int n = 5; 
    int largest;
    largest = findlargest(arr, n);
    return 0; 
} 