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
			return num;
		}
false|true	{
			if (yytext == "false")
				yylval.bValue = 0;
			else
				yylval.bValue = 1;
			return boollit;
		}
[A-Z][A-Z0-9]*	{
			yylval.sString = NULL;
			char* temp = malloc(sizeof(yytext));
			strcpy(temp,yytext);
			yylval.sString = temp;
			//yylval.sString = yytext;
			//printf("	Lex yylval : %s\n",yylval);
			printf("	Lex yytext : %s\n",yytext);
			return ident;
		}
"("		{
			return LP;
		}
")"		{
			return RP;
		}
":="		{
			return ASGN;
		}
";"		{
			return SC;
		}
{MUL_OP}|{DIV_OP}|{MOD_OP}	{
			yylval.iValue = stringToEnum(yytext);
			return OP2;
		}
{PLUS_OP}|{MINUS_OP}		{
			yylval.iValue = stringToEnum(yytext);
			return OP3;
		}
{EQ_OP}|{NEQ_OP}|{L_OP}|{G_OP}|{LEQ_OP}|{GEQ_OP}	{
					yylval.iValue = stringToEnum(yytext);
					return OP4;
				}
"if"		{
			return IF;
		}
"then"		{
			return THEN;
		}
"else"		{
			return ELSE;
		}
"begin"		{
			return BEGIN_STMT;
		}
"end"		{
			return END;
		}
"while"		{
			return WHILE;
		}
"do"		{
			return DO;
		}
"program"	{
			return PROGRAM;
		}
"var"		{
			return VAR;
		}
"as"		{
			return AS;
		}
"int"		{
			return INT;
		}
"bool"		{
			return BOOL;
		}
"writeInt"	{
			return WRITEINT;
		}
"readInt"	{
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
