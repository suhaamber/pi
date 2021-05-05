%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	int yylex(void);
	int yyerror(const char *s);
    int success=1; 
	int current_data_type, dimension_count = 0; 
	int in_loop = 0; 
	int number_of_tabs = 0; 
	int is_main = 0; 
	int temp_input = 0;
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
	
	struct function_table
	{
		char function_name[30];
		int return_type, number_of_parameters; 
		struct symbol_table_row parameters[10]; 
	} functions[10];

	struct for_translation
	{
		char var[30], var_for_control[30];
		int init, control, increment; 
	} for_record; 
	int in_for = 0; 
	int for_init = 0;
	int for_assign = 0; 
	int temp_number_of_parameters = 0; 
	int number_of_functions = 0; 
	char current_function[30]; 


	extern struct symbol_table_row insert_to_table(char var[30], int type, int new_dim, int new_dim_seq[5]); 
	extern void add_function(char var[30], int return_type); 
	extern void add_parameters(char var[30], struct symbol_table_row parameter); 
	extern void check_function(char var[30]);
	extern void check_parameters(); 
	extern void check_variable(char var[30]);
	extern void check_dimensions(char var[30],int dimensions, int dimension_count[5]); 
	extern struct symbol_table_row return_symbol_table_row(char var[30]); 
	extern void print_tabs(); 

%}

%union{
int data_type;
char variable[30];
int const_int;
float const_float; 
char const_char; 
char const_string[100];
char comment[150]; 
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
%type<comment>COMMENT

%start PROGRAM

%%
PROGRAM: COMMENTS PACKAGES FUNCTIONS MAIN_FUNC { printf("\nmain_func()\n\n");}

COMMENTS: COMMENT COMMENTS 
			|

PACKAGES: 	PACKAGE {printf("\n"); } PACKAGES 
			| 

PACKAGE: IMPORT { printf("import "); } VARIABLE { printf("%s", $3); }

FUNCTIONS: FUNCTION {printf("\n"); } FUNCTIONS
			|

FUNCTION: DATA_TYPE VARIABLE LB  { 
		current_symbol_table++; 
		symbol_tables[current_symbol_table].var_count = -1; 
		add_function($2, $1);
		strcpy(current_function, $2); 
		printf("def %s(", $2); 
} PARAMETER_LIST RB {printf("):\n"); } BLOCK
			| DATA_TYPE VARIABLE LB RB {
		current_symbol_table++; 
		symbol_tables[current_symbol_table].var_count = -1; 
		add_function($2, $1);
		printf("def %s()\n", $2); 
	} BLOCK 

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

PARAMETER_LIST:   PARAMETER COMMA { printf(","); } PARAMETER_LIST 
				| PARAMETER 

PARAMETER: DATA_TYPE VARIABLE { printf("%s", $2); } DECLARATION_SEQUENCE {
				struct symbol_table_row parameter = insert_to_table($2, current_data_type, dimension_count, array_with_dimensions); 
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
				add_parameters(current_function, parameter);
			}
			| DATA_TYPE VARIABLE {
				printf("%s", $2);
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
				struct symbol_table_row parameter = insert_to_table($2, current_data_type, dimension_count, array_with_dimensions); 
				add_parameters(current_function, parameter);
			}

MAIN_FUNC: VOID MAIN LB RB { printf("def main_func():\n"); } BLOCK

BLOCK: LCB {
		number_of_tabs++; 
		current_symbol_table++; 
		symbol_tables[current_symbol_table].var_count = -1; 
} STATEMENTS RCB {
	number_of_tabs--; 
	current_symbol_table--; 
}

STATEMENTS: STATEMENT STATEMENTS
			|

STATEMENT: CONDITIONAL_STATEMENTS
	| WHILE { 
		in_loop = 1;
		print_tabs(); 
		printf("while "); 
} LB EXPRESSION RB { printf(" :\n"); } BLOCK { in_loop=0; }
	| FOR { in_loop = 1;
		in_for = 1; 
		for_init = 1;
		print_tabs();  
		} LB ASSIGNMENT SEMICOLON { for_init = 0; } EXPRESSION SEMICOLON { for_assign = 1;} ASSIGNMENT RB {
		for_assign = 0; 
		in_for = 0;
		if(for_record.control!=0)
			printf("for %s in range(%d, %d, %d):\n", for_record.var, for_record.init, for_record.control, for_record.increment); 
		else 
			printf("for %s in range(%d, %s, %d):\n", for_record.var, for_record.init, for_record.var_for_control, for_record.increment); 
		 } BLOCK { in_loop = 0;}
	| RETURN VARIABLE {
		print_tabs(); 
		printf("return %s", $2);
	} DIMENSION_SEQUENCE  {
		check_variable($2); 
		check_dimensions($2, dimension_count, array_with_dimensions); 
		dimension_count = 0; 
		for(int i=0; i<5; i++) 
		{
			array_with_dimensions[i] = 0; 
		}
	} SEMICOLON {printf("\n");}
	| RETURN { print_tabs(); printf("return "); } CONSTANT SEMICOLON {printf("\n");}
	| {print_tabs();} ASSIGNMENT SEMICOLON {printf("\n");}
	| { print_tabs(); } FUNCTION_CALL SEMICOLON {printf("\n");}
	| {print_tabs();} BLOCK
	| SEMICOLON { print_tabs(); printf("\n");}
	| COMMENT { print_tabs(); 
				printf("#%s", $1);}
	| DECLARATION SEMICOLON
	| BREAK {
		if(!in_loop) {
			printf("Break statement called outside a loop block.\n");
			exit(0);
		}
		print_tabs(); 
		printf("break");
	} SEMICOLON {
		print_tabs(); 
		printf("\n");}
	| CONTINUE {
		if(!in_loop) {
			printf("Continue statement called outside a loop block.\n");
			exit(0);
		}
		print_tabs(); 
		printf("continue"); 
	} SEMICOLON {printf("\n");}

CONDITIONAL_STATEMENTS: IF_BLOCK | IF_BLOCK ELSE_BLOCK

IF_BLOCK:  IF { print_tabs(); printf("if ");} LB EXPRESSION RB {printf(":\n");} BLOCK 

ELSE_BLOCK: ELSE { printf("\n"); print_tabs(); printf("else:\n");} BLOCK 

FUNCTION_CALL: FUNCTION_NAME LB { 
	temp_number_of_parameters = 0;
	if(strcmp(current_function, "input")!=0)
		printf("(");
} FUNCTION_VARIABLE_LIST {
	for(int i = 0; i <= number_of_functions; i++)
	{
		if(strcmp(functions[i].function_name, current_function)==0)
		{
			if(functions[i].number_of_parameters!=temp_number_of_parameters)
			{
				printf("Function %s needs %d parameters.", current_function, functions[i].number_of_parameters);
				exit(0); 
			}
		}
	}
 }RB { 
	 	if(strcmp(current_function, "input")!=0)
			printf(")"); 
			}

FUNCTION_NAME: VARIABLE { 
			printf("%s", $1); 
			check_function($1);
			strcpy(current_function, $1); 				
			}
				| INPUT {
			temp_input = 1; 
			strcpy(current_function, "input"); 						
				}
				| OUTPUT {
			printf("print"); 
			strcpy(current_function, "output"); 									
				}

FUNCTION_VARIABLE_LIST: ELEMENT COMMA {
	if(strcmp(current_function, "output")==0)
	{
		printf(" + ");
	}
	else if(strcmp(current_function, "input")!=0)
	{
		printf(",");
	}
 } FUNCTION_VARIABLE_LIST 
						| ELEMENT

ELEMENT: CONSTANT {
		if(strcmp(current_function, "input")==0)
		{
			extern int yylineno; 
			printf("Cannot input literal. Line number: %d\n", yylineno);
			exit(0); 
		}
		
		temp_number_of_parameters++; 
}
		| VARIABLE {
				if(strcmp(current_function, "input")!=0)
					printf("%s", $1); 
				else
				{
					if(!temp_input) print_tabs();
					temp_input = 0; 
					printf("%s", $1);
				}
		} DIMENSION_SEQUENCE {
			check_variable($1); 
			temp_number_of_parameters++; 
			if(strcmp(current_function, "input")!=0 && strcmp(current_function, "output")!=0)
			{
				struct symbol_table_row current_parameter = return_symbol_table_row($1); 
				for(int i = 0; i < number_of_functions; i++)
				{
					if(strcmp(functions[i].function_name, current_function)==0)
					{
						int j = temp_number_of_parameters - 1;
						//check type 
						if(current_parameter.data_type != functions[i].parameters[j].data_type)
						{
							printf("Data type of %dth parameter for function %s() does not match.\n", j, $1); 
							exit(0);
						}

						int a = functions[i].parameters[j].dimension; 
						int b = current_parameter.dimension; 
						int c = dimension_count; 
						//check dimensions
						if(c!=(b-a))
						{
							printf("Array dimension don't match for %dth parameter for function %s().\n", j, $1); 
							exit(0); 
						}
						
					}
				}
			}
			dimension_count = 0; 
			for(int i=0; i<5; i++) 
			{
				array_with_dimensions[i] = 0; 
			}
			if(strcmp(current_function, "input")==0)
			printf("= input()\n"); 
		}

CONSTANT: CONST_INT {
		if(!in_for)
		printf("%d", $1);
		else if(for_assign)
			for_record.increment = $1; 
		else if(for_init)
			for_record.init = $1; 
		else if(!for_init)
			for_record.control = $1; 
} 
		| CONST_FLOAT { printf("%f", $1); } 
		| CONST_CHAR {printf("%c", $1); } 
		| CONST_STRING {printf("%s", $1); }

ASSIGNMENT: VARIABLE {
		if(!in_for)
			printf("%s", $1);
		else 
			strcpy(for_record.var, $1);
} DIMENSION_SEQUENCE {
		check_variable($1);
		check_dimensions($1, dimension_count, array_with_dimensions); 
		dimension_count = 0; 
		for(int i=0; i<5; i++) 
		{
			array_with_dimensions[i] = 0; 
		}
} EQ { 
	if(!in_for)
		printf(" = "); } ASSIGNMENT_RHS

ASSIGNMENT_RHS: EXPRESSION 
				| FUNCTION_CALL

EXPRESSION: NOT {printf(" ! "); } EXPRESSION 
			| EXPRESSION BINOP EXPRESSION 
			| EXPRESSION RELOP EXPRESSION 
			| EXPRESSION LOGOP EXPRESSION 
			| LB {printf("("); } EXPRESSION RB {printf(")"); }
			| FUNCTION_CALL
			| VARIABLE { 
			if(!in_for)	
				printf(" %s ", $1); 
			else if(!for_init && !for_assign && strcmp($1, for_record.var)!=0)
			{
				strcpy(for_record.var_for_control, $1); 
			}
		} DIMENSION_SEQUENCE {
				check_variable($1); 
				check_dimensions($1, dimension_count, array_with_dimensions); 
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
			}
			| CONSTANT

DIMENSION_SEQUENCE: LSB CONST_INT RSB {
				if(!in_for)
					printf("[%d]", $2); 
				array_with_dimensions[dimension_count] = $2; 
				dimension_count++; 
} DIMENSION_SEQUENCE
				| LSB VARIABLE RSB {
					if(!in_for)
						printf("[%s]", $2); 
					check_variable($2);
					array_with_dimensions[dimension_count] = 0; 
					dimension_count++; 
				} DIMENSION_SEQUENCE
				|

DECLARATION: DATA_TYPE VAR_LIST 

VAR_LIST: VARIABLE {
		dimension_count = 0; 
		for(int i=0; i<5; i++) 
		{
			array_with_dimensions[i] = 0; 
		}
		insert_to_table($1, current_data_type, dimension_count, array_with_dimensions);
} COMMA VAR_LIST 
			| VARIABLE DECLARATION_SEQUENCE {
				insert_to_table($1, current_data_type, dimension_count, array_with_dimensions); 
				print_tabs();
				printf("%s = ", $1); 
				for(int i = 0; i<dimension_count; i++)
					printf("[");
				printf("0]"); 
				for(int i = dimension_count-1; i>=0; i--)
				{
					printf(" * %d", array_with_dimensions[i]); 
					if(i)
						printf("]"); 
				}	
				printf("\n");
				
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
			} COMMA VAR_LIST
			| VARIABLE {
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
				insert_to_table($1, current_data_type, dimension_count, array_with_dimensions);
}  
			| VARIABLE DECLARATION_SEQUENCE {
				insert_to_table($1, current_data_type, dimension_count, array_with_dimensions); 
				dimension_count = 0; 
				for(int i=0; i<5; i++) 
				{
					array_with_dimensions[i] = 0; 
				}
			}
			
DECLARATION_SEQUENCE: LSB CONST_INT RSB {
	array_with_dimensions[dimension_count] = $2; 
	dimension_count++;
}DECLARATION_SEQUENCE
		
		| LSB CONST_INT RSB {
			array_with_dimensions[dimension_count] = $2; 
	dimension_count++;
		}

BINOP: PLUS {
		if(!in_for)	
			printf(" + "); }
        |MINUS {printf(" - "); }
        |STAR {printf(" * "); }
        |DIV {printf(" / "); }
        |MOD {printf(" %% "); }
		|EXP {printf(" ** "); }

RELOP: EQCOMPARE {printf(" == "); }
        |NEQCOMPARE {printf(" != "); }
        |LTE {printf(" <= "); }
        |LT {
			if(!in_for)
				printf(" < "); }
        |GTE {printf(" >= "); }
        |GT {printf(" <= "); }

LOGOP: AND {printf(" and "); }
        |OR {printf(" or "); }

%%

extern struct symbol_table_row insert_to_table(char var[30], int type, int new_dim, int new_dim_seq[5])
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

	int temp_var_count = ++symbol_tables[current_symbol_table].var_count; 
	strcpy(symbol_tables[current_symbol_table].var_list[temp_var_count].var_name, var);
	symbol_tables[current_symbol_table].var_list[temp_var_count].data_type = type;
	symbol_tables[current_symbol_table].var_list[temp_var_count].dimension = new_dim; 
	for(int i=0; i<5; i++)
	{
		symbol_tables[current_symbol_table].var_list[temp_var_count].dimension_sequence[i] = new_dim_seq[i]; 
	}

	return symbol_tables[current_symbol_table].var_list[temp_var_count];
}

extern struct symbol_table_row return_symbol_table_row(char var[30]){
	int counter, i; 
	for(counter = current_symbol_table; counter>=0; counter--)
    {
        for(i=0; i<=symbol_tables[counter].var_count; i++)
        {
            if(strcmp(symbol_tables[counter].var_list[i].var_name, var)==0)
            {
				return symbol_tables[counter].var_list[i]; 
			}
		}
	}
}

extern void add_function(char var[30], int new_type){
	int i; 
	extern int yylineno; 
	for(int i=0; i<number_of_functions; i++){
		if(strcmp(functions[i].function_name, var)==0)
		{
			printf("Multiple definitions of function %s in line %d", var, yylineno);
			exit(0); 
		}
	}

	strcpy(functions[number_of_functions].function_name, var); 
	functions[number_of_functions].return_type = new_type; 
	functions[number_of_functions].number_of_parameters = 0; 
	number_of_functions++; 
}

extern void add_parameters(char var[30], struct symbol_table_row parameter){
	int i; 
	
	for(int i=0; i<number_of_functions; i++){
		if(strcmp(functions[i].function_name, var)==0)
		{
			int temp = functions[i].number_of_parameters; 
			strcpy(functions[i].parameters[temp].var_name, parameter.var_name);
			functions[i].parameters[temp].data_type = parameter.data_type; 
			functions[i].parameters[temp].dimension = parameter.dimension; 
			for(int j = 0; j< 5; j++)
			{
				functions[i].parameters[temp].dimension_sequence[j] = parameter.dimension_sequence[j]; 
			}
			functions[i].number_of_parameters++;
		}
	}
}

extern void check_variable(char var[30]){
	int found_in_table = 0, i, counter;
    for(counter = current_symbol_table; counter>=0; counter--)
    {
        for(i=0; i<=symbol_tables[counter].var_count; i++)
        {
            if(strcmp(symbol_tables[counter].var_list[i].var_name, var)==0)
            {
                found_in_table = 1;
                break; 
            }
        }
    }

	//if var not found in the table
	if(!found_in_table)
	{
		extern int yylineno; 
		printf("Variable %s undeclared. Line number %d\n", var, yylineno); 
		exit(0);
	}
}

extern void check_dimensions(char var[30], int dim, int array_with_dimensions[5]){
	int i, counter; 
	extern int yylineno;
	for(counter = current_symbol_table; counter>=0; counter--)
    {
        for(i=0; i<=symbol_tables[counter].var_count; i++)
        {
            if(strcmp(symbol_tables[counter].var_list[i].var_name, var)==0)
            {
				if(dim!=symbol_tables[counter].var_list[i].dimension)
				{
					printf("Array dimension does not match. Line number %d\n", yylineno); 
					exit(0); 
				}
				for(int j=0; j<5; j++)
				{
					if(array_with_dimensions[j]<0 || array_with_dimensions[j]>symbol_tables[counter].var_list[i].dimension_sequence[j])
					{
						printf("Array index out of bounds. Line number %d\n", yylineno); 
						exit(0); 
					}
				}
				break; 
            }
        }
    }
}

extern void check_function(char var[30]){
	int i, found = 0; 
	for(i = 0; i<number_of_functions; i++)
	{
		if(strcmp(functions[i].function_name, var)==0)
		{
			found = 1; 
			break; 
		}
	}

	extern int yylineno; 
	if(!found){
		printf("Function %s() not defined. Line number: %d.\n", var, yylineno);
		exit(0); 
	}
}

extern void print_tabs()
{
	for(int i=0; i<number_of_tabs; i++)
	{
		printf("\t");
	}
}

int main()
{
    yyparse();
    //if(success)
    	//printf("Parsing Successful\n"); 
    return 0;
}

int yyerror(const char *msg)
{
	extern int yylineno;
	printf("Parsing Failed\nLine Number: %d %s\n",yylineno,msg);
	success = 0;
	return 0;
}