int our()
{
    int i;
    for(i=0 ;i<=399;)
    {
        if(i>='A'&& i<='Z')
          i=32+i;
        else if(i>='a'&& i<='z')
          i=32;

        i=i+2;
    }
    return i;
}

void main()
{
    int far;
    int near=0;
    far=our();
}