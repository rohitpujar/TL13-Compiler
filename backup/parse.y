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
	PROGRAM declarations BEGIN_STMT statementSequence END { $$ = opr(PROGRAM, 2, $2, $4); ex($$); } 
	;
declarations:
	VAR ident AS type SC declarations { $$ = opr(AS, 3, var("var"), $4, $6); }
	| { $$ = NULL; }
	;
type:
	INT { $$ = str("int"); }
	| BOOL { $$ = str("int"); }
	;
statementSequence:
	statement SC statementSequence { $$ = opr(SC, 2, $1, $3); }
	| { $$ = NULL; }
	;
statement:
	assignment { $$ = $1; }
	| ifStatement { $$ = $1; }
	| whileStatement { $$ = $1; }
	| writeInt { $$ = $1; }
	;
assignment:
	ident ASGN expression { $$ = opr(ASGN, 2, var("var"), $3); }
	| ident ASGN READINT { int myInt; scanf("%d", &myInt); $$ = opr(ASGN, 2, var("var"), lit(myInt)); }
	;
ifStatement:
	IF expression THEN statementSequence elseClause END { $$ = opr(IF, 3, $2, $4, $5); }
	;
elseClause:
	ELSE statementSequence { $$ = opr(ELSE, 1, $2); }
	| { $$ = NULL; }
	;
whileStatement:
	WHILE expression DO statementSequence END { $$ = opr(WHILE, 2, $2, $4); }
	;
writeInt:
	WRITEINT expression { $$ = opr(WRITEINT, 1, $2); }
	;
expression:
	simpleExpression { $$ = $1; }
	| simpleExpression OP4 simpleExpression { $$ = opr($2, 2, $1, $3); }
	;
simpleExpression:
	term OP3 term { $$ = opr($2, 2, $1, $3); }
	| term { $$ = $1; }
	;
term:
	factor OP2 factor { $$ = opr($2, 2, $1, $3); }
	| factor { $$ = $1; }
	;
factor:
	ident { $$ = var("var"); }
	| num { $$ = lit($1); }
	| boollit { $$ = lit($1); }
	| LP expression RP { $$ = $2; }
	;
%%

int ex(nodeType *p){
	if(!p){
		printf("####### Tree NULL");
		return 0;
	}	
	nodeType *ptrleft = p->op.operands[0];
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

	printf("	yacc yylval from #str func: %s\n",yylval);
	pntr->type = typeStr;
	pntr->str.name = str;

	return pntr;
}

nodeType* var(char* name) {
	nodeType* pntr;
	printf("	yacc yylval from *var func: %s\n",yylval);
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
