// C program for swapping two numbers using pointers
void swap(int* a, int* b)
{
	int temp = *a;
	*a = *b;
	*b = temp;
}

int main()
{
	int a=3,b=2;
	swap(&a,&b);
	return 0;
}

