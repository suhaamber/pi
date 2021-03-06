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
"("     {return LB; }
")"     {return RB; }
"["     {return LSB; }
"]"     {return RSB; }
"int"   {yylval.data_type = 0; return INT; }
"char"  {yylval.data_type = 1; return CHAR; }
"float" {yylval.data_type = 2; return FLOAT; }
"string" {yylval.data_type = 3;return STRING; }
"main"  {return MAIN; }
"void"  {return VOID; }
"if"    {return IF; }
"for"   {return FOR; }
"else"  {return ELSE; }
"while" {return WHILE; }
"break" {return BREAK; }
"continue"  {return CONTINUE; }
"input"	{return INPUT; }
"output" {return OUTPUT; }
"return" {return RETURN;}

[\"](.*)[\"] { strcpy(yylval.const_string, yytext);  return CONST_STRING; }
[\'](.)[\'] { yylval.const_char = yytext[1]; return CONST_CHAR; }
[-]?[0-9]+[.][0-9]+    {yylval.const_float = atof(yytext); return CONST_FLOAT; }
[-]?[1-9][0-9]*     {yylval.const_int = atoi(yytext); return CONST_INT; }
[0]                 {yylval.const_int = 0; return CONST_INT; }

\/\/(.*) { 	char *p = yytext; 
			p+=2;
			strcpy(yylval.comment, p);  return COMMENT; }
"/*"([^*]|\*+[^*/])*\*+"/" { 
								char str_temp[100];
								for(int i = 0, j = 0; yytext[i]!=0; i++)
								{  
									if(yytext[i]=='\n')
										continue; 
									else if(yytext[i]=='*' && yytext[i+1]=='/')
									{
										yytext[i] = 0;
										break;
									}
									str_temp[j++] = yytext[i];
								} 
								char *p = str_temp; 
								p+=2;
								strcpy(yylval.comment, p);  return COMMENT; }

","     {return COMMA; }
";"	{return SEMICOLON; }
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

[a-zA-Z_][a-zA-Z0-9_]*  { strcpy(yylval.variable ,yytext); return VARIABLE;}
[\n\t ]+  {/*new line or space*/}
. {printf("invalid character sequence %s\n",yytext); exit(0);}


%%

int yywrap(void)
{
    return 1; 
}