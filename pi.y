%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	int yylex(void);
	int yyerror(const char *s);
    int success=1; 

%}

%union{
int data_type;
char variable[30];
int const_int;
float const_float; 
char const_char; 
char const_string[100];
}

%token IMPORT LCB RCB LB RB LSB RSB
%token INT CHAR FLOAT string
%token MAIN VOID 
%token IF ELSE WHILE BREAK FOR CONTINUE
%token CONST_CHAR CONST_INT CONST_STRING const_float
%token COMMENT
%token COMMA PLUS MINUS EXP STAR DIV MOD 
%token GTE LTE GT LT 
%token EQCOMPARE NEQCOMPARE EQ NOT AND OR
%token VARIABLE

%left PLUS MINUS MOD STAR DIV
%left OR AND EQCOMPARE NEQCOMPARE
%left GTE GT LTE LT

%right EXP
%right NOT

%token<data_type>INT
%token<data_type>CHAR
%token<data_type>FLOAT
%token<data_type>STRING

%type<data_type>DATA_TYPE
%type<variable>VARIABLE
%type<const_int>CONST_INT
%type<const_float>CONST_FLOAT
%type<const_string>CONST_STRING
%type<const_char>CONST_CHAR

%start PROGRAM

%%

%%

int main()
{
    yyparse();
    if(success)
    	printf("Parsing Successful\n"); 
    return 0;
}

int yyerror(const char *msg)
{
	extern int yylineno;
	printf("Parsing Failed\nLine Number: %d %s\n",yylineno,msg);
	success = 0;
	return 0;
}