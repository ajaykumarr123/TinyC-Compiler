//testing printStr printInt readInt
int printStr(char *s);
int printInt(int n);
int readInt(int *x);

int increment_by_5(int x)
{
    x=x+5;

    return x;
}

int main()
{
    printStr("Enter Number: ");
    int x;
    readInt(&x);

    x = increment_by_5(x);

    printStr("The number after increment by 5 is ");
    printInt(x);

    return 0; 
}

