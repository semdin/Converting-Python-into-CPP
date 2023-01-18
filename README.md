# flex-bison
Converting Python code into C++ code by using flex(lex) and yacc(bison)

This code just can convert some Python codes into C++ code by using lex and yacc.

In order to use program you should compile project.l and project.y. I already put Makefile for you to compile it. So you will get an out called "project".


<b> How To Run The Program <b>

To do that, you should use this sample code in your bash:

./project exampleInput.txt > exampleOutput.txt

So your exampleInput.txt should contain python codes. Then you will get the C++ code as exampleOutput.txt. I also add example inputs in a folder. So you can easily get examples.

To understand how the program works. You can check Documents folder. Everything is explained in there.

For example:

Our input.txt is:

```
x=5
y=7
z=3.14
if x<z:
	if y<z:
		result=z*x-y
		result=result/2
	else:
		result=z*x+y
		result=result/2
		if result>y:
			result=result/x
	y=x*2
elif y<x:
	result=z
else:
	result=z*x*x*y
x=y
```

-------------------------------

Our output will be like below:

```
void main()
{
	int x_int,y_int;
	float result_flt,z_flt;

	x_int = 5;
	y_int = 7;
	z_flt = 3.14;
	if( x_int < z_flt )
	{
		if( y_int < z_flt )
		{
			result_flt = z_flt * x_int - y_int;
			result_flt = result_flt / 2;
		}
		else
		{
			result_flt = z_flt * x_int + y_int;
			result_flt = result_flt / 2;
			if( result_flt > y_int )
			{
				result_flt = result_flt / x_int;
			}
		}
		y_int = x_int * 2;
	}
	else if( y_int < x_int )
	{
		result_flt = z_flt;
	}
	else
	{
		result_flt = z_flt * x_int * x_int * y_int;
	}
	x_int = y_int;
}
```




