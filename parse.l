%{
#include <stdlib.h>
#include "node.h"
#include "parse.tab.h"
%}

MUL_OP "*"
DIV_OP "div"
MOD_OP "mod"
PLUS_OP "+"
MINUS_OP "-"
EQ_OP "="
NEQ_OP "!="
L_OP "<"
G_OP ">"
LEQ_OP "<="
GEQ_OP ">="

%%

[1-9][0-9]*|0	{
			yylval.iValue = atoi(yytext);
			//printf("* Lex yylval : %d\n",yylval.iValue);
			printf("\nFrom LEX: returning token=num with value=%d\n",yylval.iValue);
			return num;
		}
false|true	{
			if (yytext == "false")
				yylval.bValue = 0;
			else
				yylval.bValue = 1;
			printf("\nFrom LEX: returning token=boollit with value=%d\n",yylval.bValue );
			return boollit;
		}
[A-Z][A-Z0-9]*	{
			yylval.sString = NULL;
			char* temp = malloc(sizeof(yytext));
			strcpy(temp,yytext);
			yylval.sString = temp;
			//yylval.sString = yytext;
			//printf("	Lex yylval : %s\n",yylval);
			//printf("	Lex yytext : %s\n",yytext);
			printf("\nFrom LEX: returning token=ident with value=%s\n", yylval.sString);
			return ident;
		}
"("		{
			printf("\nFrom LEX: returning token=LP with value=NULL" );
			return LP;
		}
")"		{
			printf("\nFrom LEX: returning token=RP with value=NULL" );
			return RP;
		}
":="		{
			printf("\nFrom LEX: returning token=ASGN with value=NULL" );
			return ASGN;
		}
";"		{
			printf("\nFrom LEX: returning token=SC with value=NULL" );
			return SC;
		}
{MUL_OP}|{DIV_OP}|{MOD_OP}	{
			yylval.iValue = stringToEnum(yytext);
			printf("\nFrom LEX: returning token=OP2 with value=%d",yylval.iValue );
			return OP2;
		}
{PLUS_OP}|{MINUS_OP}		{
			yylval.iValue = stringToEnum(yytext);
			printf("\nFrom LEX: returning token=OP3 with value=%d",yylval.iValue );
			return OP3;
		}
{EQ_OP}|{NEQ_OP}|{L_OP}|{G_OP}|{LEQ_OP}|{GEQ_OP}	{
					yylval.iValue = stringToEnum(yytext);
					printf("\nFrom LEX: returning token=OP4 with value=%d",yylval.iValue );
					return OP4;
				}
"if"		{
			printf("\nFrom LEX: returning token=IF with value=NULL" );
			return IF;
		}
"then"		{
			printf("\nFrom LEX: returning token=THEN with value=NULL" );
			return THEN;
		}
"else"		{
			printf("\nFrom LEX: returning token=ELSE with value=NULL" );
			return ELSE;
		}
"begin"		{
			printf("\nFrom LEX: returning token=BEGIN_STMT with value=NULL" );
			return BEGIN_STMT;
		}
"end"		{
			printf("\nFrom LEX: returning token=END with value=NULL" );
			return END;
		}
"while"		{
			printf("\nFrom LEX: returning token=WHILE with value=NULL" );
			return WHILE;
		}
"do"		{
			printf("\nFrom LEX: returning token=DO with value=NULL" );
			return DO;
		}
"program"	{
			printf("\nFrom LEX: returning token=PROGRAM with value=NULL" );
			return PROGRAM;
		}
"var"		{
			printf("\nFrom LEX: returning token=VAR with value=NULL" );
			return VAR;
		}
"as"		{
			printf("\nFrom LEX: returning token=AS with value=NULL" );
			return AS;
		}
"int"		{
			printf("\nFrom LEX: returning token=INT with value=NULL" );
			return INT;
		}
"bool"		{
			printf("\nFrom LEX: returning token=BOOL with value=NULL" );
			return BOOL;
		}
"writeInt"	{
			printf("\nFrom LEX: returning token=WRITEINT with value=NULL" );
			return WRITEINT;
		}
"readInt"	{
			printf("\nFrom LEX: returning token=READINT with value=NULL" );
			return READINT;
		}

%%
int stringToEnum(char* string)
{
	if (!strcmp(string,  "*"))
		return MUL_OP;
	if (!strcmp(string, "div"))
        	return DIV_OP;
	if (!strcmp(string, "mod"))
        	return MOD_OP;
	if (!strcmp(string, "+"))
        	return PLUS_OP;
	if (!strcmp(string, "-"))
   		return MINUS_OP;
	if (!strcmp(string, "="))
        	return EQ_OP;
	if (!strcmp(string, "!="))
        	return NEQ_OP;
	if (!strcmp(string, "<"))
        	return L_OP;
	if (!strcmp(string, ">"))
        	return G_OP;
	if (!strcmp(string, "<="))
        	return LEQ_OP;
	if (!strcmp(string, ">="))
        	return GEQ_OP;
}
