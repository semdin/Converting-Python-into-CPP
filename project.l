digit	[0-9]
letter	[A-Za-z]
%{
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  #include <iostream>
  using namespace std;
  int linenum=1;
  int tabCounter = 1;

  /*

  [0-9]+ { yylval.int_val = atoi(yytext); return INTEGER; }
  [0-9].[0-9]+ { yylval.float_val = atof(yytext); return FLOAT; }
  "[^"]" { yylval.str_val = strdup(yytext); return STRING; }

  */

%}
%%

"+"|"-"|"/"|"*"	{yylval.str=strdup(yytext); return OPERATOR;}
":" return COLON;
"=" {yylval.str=strdup(yytext); return EQUAL;}
"=="|"!="|"<"|"<="|">"|">="	{yylval.str=strdup(yytext); return COMPARISON;}
"if" {yylval.str=strdup(yytext); return IF;}
"elif" {yylval.str=strdup("else if"); return ELIF;}
"else" {yylval.str=strdup(yytext); return ELSE;}
{digit}+ {yylval.str=strdup(yytext); return DIGIT;}
{digit}+(\.){digit}+ {yylval.str=strdup(yytext); return FLOAT;}
{letter}({letter}|{digit})*	{yylval.str=strdup(yytext); return IDENTIFIER;}
\"[^"]*\"     {yylval.str=strdup(yytext); return STRING;}
\n {linenum++; return NEWLINE;}
\t {tabCounter++;}

" "
%%