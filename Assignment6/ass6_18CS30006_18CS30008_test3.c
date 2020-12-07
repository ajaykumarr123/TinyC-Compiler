//testing printStr printInt readInt
int printStr(char *s);
int printInt(int n);
int readInt(int *x);

int compare(int x,int y)
{
    if (x==y)
    printStr("Both are equal ");

    if (x > y)
    printStr("x is greater than y ");

    if (x < y)
    printStr("y is greater than x");

    return 1;
}

int main()
{
    printStr("Enter x: ");
    int x;
    readInt(&x);

    printStr("Enter y: ");
    int y;
    readInt(&y);

    compare(x,y);


    return 0; 
}

