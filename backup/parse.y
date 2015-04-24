%{
#include <stdio.h>
#include <stdarg.h>
#include "node.h"
extern FILE *yyin;
typedef enum { false, true } bool;

//Function prototypes
nodeType* opr(int operation, int num_ops, ...);
nodeType* var(char* name);
nodeType* lit(int value);
nodeType* str(char* str);
void freeNode(nodeType *p);

//Symbol table
int sym[26];
%}

%union {
	int iValue; //Integers
	int bValue; //Booleans
	char *sString;
	nodeType *nPtr;
};

%token <iValue> num
%token <bValue> boollit
%token <iValue> OP2 OP3 OP4
%token <sString> ident
%token LP RP ASGN SC INT BOOL
%token IF THEN ELSE BEGIN_STMT END WHILE DO PROGRAM VAR AS
%token WRITEINT READINT

%type <nPtr> assignment factor expression ifStatement statementSequence elseClause whileStatement simpleExpression term statement program declarations type writeInt
%start program

%%
program:
	PROGRAM declarations BEGIN_STMT statementSequence END { $$ = opr(PROGRAM, 2, $2, $4);printf("\n-- Tree traversal -- \n\n"); ex($$);printf("---- Reducing to program production\n"); } 
	;
declarations:
	VAR ident AS type SC declarations { $$ = opr(AS, 4, $4,var($2),str(";"),$6);printf("---- Reducing to declarations production\n"); }
	| { $$ = NULL; printf("---- Reducing to declarations production\n"); }
	;
type:
	INT { $$ = str("int"); printf("^^^^ Reducing to type production\n"); }
	| BOOL { $$ = str("bool"); printf("^^^^ Reducing to type production\n");}
	;
statementSequence:
	statement SC statementSequence { $$ = opr(SC, 2, $1, $3); printf("---- Reducing to statementSequence production \n"); }
	| { $$ = NULL; printf("---- Reducing to statementSequence production \n");}
	;
statement:
	assignment { $$ = $1;printf("---- Reducing to statement production \n"); }
	| ifStatement { $$ = $1; printf("---- Reducing to statement production \n"); }
	| whileStatement { $$ = $1; printf("---- Reducing to statement production \n");}
	| writeInt { $$ = $1; printf("---- Reducing to statement production \n");}
	;
assignment:
	ident ASGN expression { $$ = opr(ASGN, 2, var($1), $3); printf("---- Reducing to assignment production \n");}
	| ident ASGN READINT { $$ = opr(ASGN, 2, var($1), opr(READINT,0)); printf("---- Reducing to assignment production \n");}
	;
ifStatement:
	IF expression THEN statementSequence elseClause END { $$ = opr(IF, 3, $2, $4, $5); printf("---- Reducing to ifstatement production \n");}
	;
elseClause:
	ELSE statementSequence { $$ = opr(ELSE, 1, $2);printf("---- Reducing to elseclause production \n"); }
	| { $$ = NULL; printf("---- Reducing to elseclause production \n");}
	;
whileStatement:
	WHILE expression DO statementSequence END { $$ = opr(WHILE, 2, $2, $4);printf("---- Reducing to whilestatement production \n"); }
	;
writeInt:
	WRITEINT expression { $$ = opr(WRITEINT, 1, $2);printf("---- Reducing to writeInt production \n"); }
	;
expression:
	simpleExpression { $$ = $1; printf("==== Reducing to expression \n");}
	| simpleExpression OP4 simpleExpression { $$ = opr($2, 2, $1, $3); printf("==== Reducing to expression production\n");}
	;
simpleExpression:
	term OP3 term { $$ = opr($2, 2, $1, $3); printf("==== Reducing to simpleexpression production\n");}
	| term { $$ = $1; printf(" *** Reducing to simpleexpression production \n");}
	;
term:
	factor OP2 factor { $$ = opr($2, 2, $1, $3);printf(" #### Reducing to term production \n"); }
	| factor { $$ = $1; printf(" #### Reducing to term production \n");}
	;
factor:
	ident { $$ = var($1);printf("```` Reducing to factor production\n"); }
	| num { $$ = lit($1); printf("```` Reducing to factor production\n"); }
	| boollit { $$ = lit($1); printf("```` Reducing to factor production\n");}
	| LP expression RP { $$ = $2; printf("```` Reducing to factor production\n");}
	;
%%

char* getStringForConstant(int num){
	switch(num){
		case 1:
			return "*";
		case 2:
			return "/";
		case 3:
			return "%";
		case 4:
			return "+";
		case 5:
			return "-";
		case 6:
			return "==";
		case 7:
			return "!=";
		case 8:
			return "<";
		case 9:
			return ">";
		case 10:
			return "<=";
		case 11:
			return ">=";
		case 264 :
			return "(";		
		case 265:
			return ")";		
		case 266:
			return "=";		
		case 267:
			return ";";		
		case 270:
			return "if";		
		case 271:
			return "{";		
		case 272:
			return "else";		
		case 274:
			return "}";		
		case 275:
			return "while";		
		case 276:
			return "{";		
		case 277:
			return "{";		
		case 280:
			return "printf()";		
		case 281:
			return "scanf()";		
		default:
		//	printf("******** Other symbol encountered ******** \n\n");
			return "";
	
	}
}

int ex(nodeType *p){
	//printf("	---------------------- Next Level -----------------------------\n");
	if(!p){
	//	printf("####### Tree NULL\n");
		return 1;
	}	

	switch(p->type){
		case typeLit:
			printf("%d\n",p->lit.value);
			break;
		case typeVar:
			printf("%s\n",p->var.name);
			break;
		case typeStr:
			printf("%s\n",p->str.name);
			break;
		case typeOp:{
			printf("%s\n",getStringForConstant(p->op.operation));
			int count = 0;	
			while(count<p->op.num_ops){
				nodeType* tmpNode = p->op.operands[count];
				count += 1;
				ex(tmpNode);
			}
			break;
			}
		default:
			printf("\nIn default ...... :o :o :o :o :o :o :o :o :o \n");
	}
//	printf("	====================== Return from current level ========================\n");
			
	/*nodeType *ptrleft = p->op.operands[0];
	//nodeType *ptrright = p->op.operands[1];
	//if(ptrright!=NULL){
	//	printf("NOT NULL \n");
	//}else
	//	printf("NULLLL \n");
	nodeType *left,*right;
	left = ptrleft->op.operands[0];
	right = ptrleft->op.operands[1];

	printf("p->operation : %d\n",p->op.operation);
	printf("ptrleft->operand[0] : %d\n",ptrleft->op.operation);

	printf("left->operand[0,1] : %s\n",left->var.name);
	printf("right->operand[0,2] : %s\n",right->str.name);

*/	
	

	//printf("left->var.name : %s\n",left->var.name);
	//printf("right->str.name : %s\n",right->str.name);
	//printf("right->var.name : %s\n",left->var.name);
	
	
/*	if(p->type == typeLit)
		printf("-- p is of type literal --");
	if(p->type == typeVar)
		printf("-- p is of type variable --");
	if(p->type == typeOp){
		printf("-- p is of type operator --");
		printf("*Operator value %d : ",p->op.operation);
	}
	if(p->type == typeStr)
		printf("-- p is of type string --");
//return 1;
i*/
}

nodeType* lit(int value) {
	nodeType* pntr;

	if ((pntr = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");

	pntr->type = typeLit;
	pntr->lit.value = value;

	return pntr;
}

nodeType* str(char* str) {
	nodeType* pntr;

	if ((pntr = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");

	//printf("	yacc yylval from #str func: %s\n",yylval);
	pntr->type = typeStr;
	pntr->str.name = str;

	return pntr;
}

nodeType* var(char* name) {
	nodeType* pntr;
	//printf("	yacc yylval from *var func: %s\n",yylval);
	if ((pntr = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");

	pntr->type = typeVar;
	pntr->var.name = name;

	return pntr;
}

nodeType* opr(int operation, int num_ops, ...) {
	va_list ap;
	nodeType* pntr;
	int i;
        	
	if ((pntr = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
//	else
//		printf("--------------------------------------------------------Size of pntr : %zu \n",sizeof(pntr));
	if ((pntr->op.operands = malloc(num_ops * sizeof(nodeType*))) == NULL)
		yyerror("out of memory");

	pntr->type = typeOp;
	pntr->op.operation = operation;
	pntr->op.num_ops = num_ops;
	va_start(ap, num_ops);
	for (i = 0; i < num_ops; i++)
		pntr->op.operands[i] = va_arg(ap, nodeType*);
		//printf("-- ap content : %zu \n",(va_arg(ap,nodeType*)));
	va_end(ap);

	return pntr;
}

int yyerror (char *s) {
	printf("%s\n", s);
	printf("String not accepted\n\n");
	//exit(-1);
}

int main(int argc, char** argv) {
	++argv, --argc;
	if (argc > 0)
		yyin = fopen(argv[0], "r");
	else
		yyin = stdin;
	do {
		yyparse();
	} while (!feof(yyin));
	printf("String accepted\n\n");
}
