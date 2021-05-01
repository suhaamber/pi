%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	int yylex(void);
	int yyerror(const char *s);
    int success=1; 
	int current_data_type, dimension_count = 0; 
	int array_with_dimensions[5]; 

	struct symbol_table_row
	{
		char var_name[30]; 
		int data_type, dimension, dimension_sequence[5]; 
	}; 

	struct symbol_table 
	{
		struct symbol_table_row var_list[20]; 
		int var_count; 
	} symbol_tables[5]; 

	int current_symbol_table = -1; 
	int in_function = 0; 

	extern void insert_to_table(char var[30], int type, int new_dim, int new_dim_seq[5]); 
	extern void return_type(char var[30]);
	extern void check_dimensions(char var[30],int is_array, int dimension_count[5]); 

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
%token MAIN VOID 
%token IF ELSE WHILE BREAK FOR CONTINUE RETURN
%token CONST_CHAR CONST_INT CONST_STRING CONST_FLOAT
%token COMMENT SEMICOLON
%token COMMA PLUS MINUS EXP STAR DIV MOD 
%token GTE LTE GT LT 
%token EQCOMPARE NEQCOMPARE EQ NOT AND OR
%token VARIABLE INPUT OUTPUT

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
PROGRAM: PACKAGES FUNCTIONS MAIN_FUNC

PACKAGES: 	PACKAGE PACKAGES 
			| 

PACKAGE: IMPORT VARIABLE

FUNCTIONS: FUNCTION FUNCTIONS
			|

FUNCTION: DATA_TYPE FUNCTION_NAME LB  { 
		in_function = 1; 
		current_symbol_table++; 
		symbol_tables[current_symbol_table].var_count = -1; 
} PARAMETER_LIST RB BLOCK
			| DATA_TYPE FUNCTION_NAME LB RB BLOCK

DATA_TYPE: 	  INT {
				$$=$1;
			current_data_type=$1;
			}
			| CHAR {
				$$=$1;
			current_data_type=$1;
			}
			| FLOAT {
				$$=$1;
			current_data_type=$1;
			}
			| STRING {
				$$=$1;
			current_data_type=$1;}

PARAMETER_LIST:   PARAMETER COMMA PARAMETER_LIST 
				| PARAMETER

PARAMETER: DATA_TYPE VARIABLE DECLARATION_SEQUENCE {
				insert_to_table($2, current_data_type, dimension_count, array_with_dimensions); 
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
			}
			| DATA_TYPE VARIABLE {
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
				insert_to_table($2, current_data_type, dimension_count, array_with_dimensions); 
			}

MAIN_FUNC: VOID MAIN LB RB BLOCK

BLOCK: LCB {
	if(!in_function)
	{
		current_symbol_table++; 
		symbol_tables[current_symbol_table].var_count = -1; 
	}
} STATEMENTS RCB {
	current_symbol_table--; 
	in_function = 0; 
}

STATEMENTS: STATEMENT STATEMENTS
			|

STATEMENT: IF_BLOCK 
	| WHILE LB EXPRESSION RB LOOP_BLOCK
	| FOR LB ASSIGNMENT SEMICOLON EXPRESSION SEMICOLON ASSIGNMENT RB LOOP_BLOCK
	| RETURN VARIABLE SEMICOLON
	| RETURN CONSTANT SEMICOLON
	| ASSIGNMENT SEMICOLON
	| FUNCTION_NAME LB FUNCTION_VARIABLE_LIST RB SEMICOLON
	| BLOCK
	| SEMICOLON
	| COMMENT
	| DECLARATION SEMICOLON

FUNCTION_NAME: VARIABLE 
				| INPUT 
				| OUTPUT

FUNCTION_VARIABLE_LIST: ELEMENT COMMA FUNCTION_VARIABLE_LIST 
						| ELEMENT

ELEMENT: CONSTANT 
		| VARIABLE DIMENSION_SEQUENCE

LOOP_BLOCK: LCB LOOP_STATEMENTS RCB

LOOP_STATEMENTS: LOOP_STATEMENT LOOP_STATEMENTS 
				| 

LOOP_STATEMENT: STATEMENT 
				| BREAK 
				| CONTINUE 

IF_BLOCK: IF LB EXPRESSION RB BLOCK ELSE IF_BLOCK
	| IF LB EXPRESSION RB BLOCK ELSE BLOCK  
	| IF LB EXPRESSION RB BLOCK 

CONSTANT: CONST_INT | CONST_FLOAT | CONST_CHAR | CONST_STRING

ASSIGNMENT: VARIABLE DIMENSION_SEQUENCE EQ ASSIGNMENT_RHS

ASSIGNMENT_RHS: EXPRESSION 
				| FUNCTION_NAME LB FUNCTION_VARIABLE_LIST RB

EXPRESSION: NOT EXPRESSION 
			| EXPRESSION BINOP EXPRESSION 
			| EXPRESSION RELOP EXPRESSION 
			| EXPRESSION LOGOP EXPRESSION 
			| LB EXPRESSION RB
			| ELEMENT

DIMENSION_SEQUENCE: LSB CONST_INT RSB DIMENSION_SEQUENCE
				| LSB VARIABLE RSB DIMENSION_SEQUENCE
				|

DECLARATION: DATA_TYPE VAR_LIST 

VAR_LIST: VARIABLE {
		dimension_count = 0; 
		for(int i=0; i<5; i++) 
		{
			array_with_dimensions[i] = 0; 
		}
		insert_to_table($1, current_data_type, dimension_count, array_with_dimensions);
} VALUE COMMA VAR_LIST 
			| VARIABLE DECLARATION_SEQUENCE {
				insert_to_table($1, current_data_type, dimension_count, array_with_dimensions); 
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
			} COMMA VAR_LIST
			| VARIABLE DECLARATION_SEQUENCE {
				insert_to_table($1, current_data_type, dimension_count, array_with_dimensions); 
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
			}
			| VARIABLE {
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
				insert_to_table($1, current_data_type, dimension_count, array_with_dimensions);} VALUE

VALUE: EQ CONSTANT 
		|

DECLARATION_SEQUENCE: LSB CONST_INT RSB {
	array_with_dimensions[dimension_count] = $2; 
	dimension_count++;
}DECLARATION_SEQUENCE
		
		| LSB CONST_INT RSB {
			array_with_dimensions[dimension_count] = $2; 
	dimension_count++;
		}

BINOP: PLUS
        |MINUS
        |STAR
        |DIV
        |MOD
		|EXP

RELOP: EQCOMPARE
        |NEQCOMPARE
        |LTE
        |LT
        |GTE
        |GT

LOGOP: AND 
        |OR 

%%

extern void insert_to_table(char var[30], int type, int new_dim, int new_dim_seq[5])
{
	int i; 
	int current_var_count = symbol_tables[current_symbol_table].var_count; 
	for(i=0; i<current_var_count; i++)
	{
		extern int yylineno; 
		if(strcmp(symbol_tables[current_symbol_table].var_list[i].var_name, var)==0)
		{
			printf("Multiple declarations of %s in this block.\n", var); 
			exit(0);
		}
	}

	struct symbol_table_row
	{
		char var_name[30]; 
		int data_type, dimension, dimension_sequence[5]; 
	}; 

	int temp_var_count = ++symbol_tables[current_symbol_table].var_count; 
	strcpy(symbol_tables[current_symbol_table].var_list[temp_var_count].var_name, var);
	symbol_tables[current_symbol_table].var_list[temp_var_count].data_type = type;
	symbol_tables[current_symbol_table].var_list[temp_var_count].dimension = new_dim; 
	for(int i=0; i<5; i++)
	{
		symbol_tables[current_symbol_table].var_list[temp_var_count].dimension_sequence[i] = new_dim_seq[i]; 
	}

	printf("%s, %d, %d, [", var, type, new_dim);
	for(int j = 0; j<5; j++)
	{
		printf("%d", new_dim_seq[j]); 
	}
}

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