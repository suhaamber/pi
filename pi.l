%option yylineno

%{
	#include<stdio.h>
	#include<string.h>
	#include"y.tab.h"
	#include<math.h>
	extern int var_count;

%}

%%

"import" {return IMPORT; }
"{"     {return LCB; }
"}"     {return RCB; }
")"     {return LB; }
"("     {return RB; }
"["     {return LSB; }
"]"     {return RCB; }
"int"   {return INT; }
"char"  {return CHAR; }
"float" {return FLOAT; }
"string" {return STRING; }
"main"  {return MAIN; }
"void"  {return VOID; }
"if"    {return IF; }
"for"   {return FOR; }
"else"  {return ELSE; }
"while" {return WHILE; }
"break" {return BREAK; }
"continue"  {return CONTINUE; }

[\"](.*)[\"] {return CONST_STRING; }
[\'](.)[\'] {return CONST_CHAR; }
[+-]?[0-9]+[.][0-9]+    {return CONST_FLOAT; }
[+-]?[1-9][0-9]*     {return CONST_INT; }
[0]                 {return CONST_INT; }

\/\/(.*) {return COMMENT; }
"/*"([^*]|\*+[^*/])*\*+"/" {return COMMENT; }

","     {return COMMA; }
"+"     {return PLUS; }
"-"     {return MINUS; }
"**"    {return EXP; }
"*"     {return STAR; }
"/" {return DIV; }
">=" {return GTE; }
"<=" {return LTE; }
">" {return GT; }
"<" {return LT; }
"==" {return EQCOMPARE; }
"=" {return EQ; }
"&&" {return AND; }
"||" {return OR; }
"!=" {return NEQCOMPARE; }
"!" {return NOT; }
"%" {return MOD; }

[a-zA-Z][a-zA-Z0-9]*  { strcpy(yylval.variable ,yytext); return VARIABLE;}

%%

int yywrap(void)
{
    return 1; 
}