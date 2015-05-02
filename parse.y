%{
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "node.h"
#include "bufferutil.h"
#include <string.h>
extern FILE *yyin;
extern yylineno;
char* buffer[1];
char bufferForReadExpr[20];
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
	PROGRAM declarations BEGIN_STMT statementSequence END { $$ = opr(PROGRAM, 3, $2, $4,str("end"));
	printf("\n-- Tree traversal -- \n\n");
	printf("#include<stdio.h>\n");
	printf("void main()\n");
	initializeBuffer(buffer);
	printBuffer(buffer);
	ex($$);
	//printf("\n\n---- Reducing to program production\n"); 
	} 
	;
declarations:
	VAR ident AS type SC declarations { $$ = opr(AS, 4, $4,var($2),opr(SC,0),$6);}//printf("---- Reducing to declarations production\n"); 
	| { $$ = NULL; /*printf("---- Reducing to declarations production\n")*/; }
	;
type:
	INT { $$ = str("int");} // printf("^^^^ Reducing to type production\n"); 
	| BOOL { $$ = str("bool"); /*printf("^^^^ Reducing to type production\n");*/ }
	;
statementSequence:
	statement SC statementSequence { $$ = opr(SC, 2, $1, $3); /*printf("---- Reducing to statementSequence production \n");*/ }
	| { $$ = NULL; /*printf("---- Reducing to statementSequence production \n")*/;}
	;
statement:
	assignment { $$ = $1;/*printf("---- Reducing to statement production \n");*/ }
	| ifStatement { $$ = $1; /*printf("---- Reducing to statement production \n");*/ }
	| whileStatement { $$ = $1; /*printf("---- Reducing to statement production \n");*/}
	| writeInt { $$ = $1; /*printf("---- Reducing to statement production \n");*/}
	;
assignment:
	ident ASGN expression { $$ = opr(ASGN, 2, var($1), $3); /*printf("---- Reducing to assignment production \n");*/}
	| ident ASGN READINT { $$ = opr(ASGN, 2, var($1), opr(READINT,0)); /*printf("---- Reducing to assignment production \n");*/}
	;
ifStatement:
	IF expression THEN statementSequence elseClause END { $$ = opr(IF, 4, $2, $4, $5, str("end")); /*printf("---- Reducing to ifstatement production \n");*/}
	;
elseClause:
	ELSE statementSequence { $$ = opr(ELSE, 1, $2);/*printf("---- Reducing to elseclause production \n");*/ }
	| { $$ = NULL; /*printf("---- Reducing to elseclause production \n");*/}
	;
whileStatement:
	WHILE expression DO statementSequence END { $$ = opr(WHILE, 3, $2, $4,str("end")); /*printf("---- Reducing to whilestatement production \n");*/ }
	;
writeInt:
	WRITEINT expression { $$ = opr(WRITEINT, 1, $2); /*printf("---- Reducing to writeInt production \n"); */ }
	;
expression:
	simpleExpression { $$ = $1; /*printf("==== Reducing to expression \n");*/}
	| simpleExpression OP4 simpleExpression { $$ = opr($2, 2, $1, $3); /*printf("==== Reducing to expression production\n");*/}
	;
simpleExpression:
	term OP3 term { $$ = opr($2, 2, $1, $3); /*printf("==== Reducing to simpleexpression production\n");*/}
	| term { $$ = $1; /*printf(" *** Reducing to simpleexpression production \n");*/}
	;
term:
	factor OP2 factor { $$ = opr($2, 2, $1, $3); 
	/*printf("------------------------------- %d : %d \n",$2,$3);
	if($2 == 1 && $3 == 0){
		printf(">>>>>>>>>>>>>>>>>>>>>>>> %d \n",$2);printf(" #### Reducing to term production \n"); 
		yyerror("Divide by zero error ");
	} */
	}
	| factor { $$ = $1; /*printf(" #### Reducing to term production \n");*/}
	;
factor:
	ident { $$ = var($1);/*printf("```` Reducing to factor production\n"); */}
	| num { //printf("\n\n[[[[[[[[[[[[[[[[[ %d ]]]]]]]]]]]]]]]]] \n\n",$1); 
		if(!($1>=-2147483647 && $1<=2147483647)){
			yyerror("Integer overflow occured at line number ");
		}
		$$ = lit($1); /*printf("```` Reducing to factor production\n"); */}
	| boollit { $$ = lit($1); /*printf("```` Reducing to factor production\n");*/}
	| LP expression RP { $$ = $2; /*printf("```` Reducing to factor production\n");*/}
	;
%%

char* getStringForConstant(int num){
	switch(num){
		case 0:
			return "*";
		case 1:
			return "/";
		case 2:
			return "%";
		case 3:
			return "+";
		case 4:
			return "-";
		case 5:
			return "==";
		case 6:
			return "!=";
		case 7:
			return "<";
		case 8:
			return ">";
		case 9:
			return "<=";
		case 10:
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

void printNode(nodeType* tmpNode){
	switch(tmpNode->type){			
		case typeLit:
			printf("%d ",tmpNode->lit.value);
			break;
		case typeVar:
			printf("%s ",tmpNode->var.name);
			break;
		case typeStr:
			printf("%s ",tmpNode->str.name);
		break;
	}
}


char* readExpr(nodeType* p){
	switch(p->type){
		case typeVar:
			return p->var.name;
			break;
		case typeLit:{
			sprintf(bufferForReadExpr,"%d",p->lit.value);
			char* temp = malloc(sizeof(bufferForReadExpr));
			strcpy(temp,bufferForReadExpr);
		 	return temp; 
			break;
			}
		case typeOp:{
			char *part1,*part2,*part3;
			part2 = getStringForConstant(p->op.operation);
			part1 = readExpr(p->op.operands[0]);
			part3 = readExpr(p->op.operands[1]);
			if(part1!=NULL && part3!=NULL){
			}
		 	strcat(part1,part2);
			strcat(part1,part3);
			return part1;
			break;
		}
	}
}

int ex(nodeType *p){
	if(!p){
	//	printf("####### Tree NULL\n");
		return 1;
	}	

	switch(p->type){
		case typeLit:
			printf("%d ",p->lit.value);
			break;
		case typeVar:
			printf("%s; ",p->var.name);
			break;
		case typeStr:{
			if(strcmp(p->str.name,"end")==0)
				printf("\n}\n");
			else
				printf("%s ",p->str.name);
			break;
			}
		case typeOp:{
		       	switch(p->op.operation){
				case 280://printf
					{
						char* child = readExpr(p->op.operands[0]);
						printf("\nprintf(\"%s\",%s);","%d",child);
					}
					break;
				case 274://end-->}
					printf("}\n");
					break;
				case 277: //program --> printing {
					printf("{\n");
					break;				
				case 267: //semicolon
					addToBuffer(buffer,getStringForConstant(p->op.operation));
					break;
				case 266: //equals
					{					
				//		printf("entering in to =");
						char *lhs, *rhs;
						lhs = readExpr(p->op.operands[0]);
					 	nodeType* node= p->op.operands[1];
						// if 2nd child is scanf
						if(node->op.operation == 281 )
						{	
							rhs = getStringForConstant(node->op.operation);
							char ampercentAndVariable[] = "&";
							strcat(ampercentAndVariable, lhs);
				//			printf("\nampercent variable =%s\n", ampercentAndVariable);
							printf("\nscanf(\"%s\",%s);","%d",ampercentAndVariable);
						}
						else
						{							
							rhs = readExpr(p->op.operands[1]);
							printf("\n%s = %s;",lhs,rhs);
						}						
					}	
					initializeBuffer(buffer);
					break;

			 	case 270: {//If case
					nodeType* condition = p->op.operands[0];
					printf("\nif (%s %s %s){",readExpr(condition->op.operands[0]),getStringForConstant(condition->op.operation),
						readExpr(condition->op.operands[1]));
					}
					break;
				case 275: {//while case
					nodeType* condition1 = p->op.operands[0];
					printf("\nwhile (%s %s %s){",
					readExpr(condition1->op.operands[0]),getStringForConstant(condition1->op.operation),
						readExpr(condition1->op.operands[1]));

					}
					break;
				case 272: //else case
					printf("\n}else{\n");
					p = p->op.operands[0];
					break;
				}	

			int count = 0;	
			while(count<p->op.num_ops){
				nodeType* tmpNode = p->op.operands[count];
				count += 1;
				// when p is poiting to one of "IF"/"WHILE" its first child will be expression which will be already printed. So need not call ex() on that child here again
				//Hence, avoiding calling ex() on first child of if
				if(p->op.operation==270  && count == 1)
					continue;
				// and also similar to while
				if(p->op.operation==275  && count == 1)
					continue;
				//if p is pointing to "=" then we would have already written both children/ so just skil entire loop itself because all, LHS=RHS is already written to output
				if(p->op.operation==266)
					break;
				if(p->op.operation==280)
					break;
				ex(tmpNode);
			}
			break;
			}
		default:
			printf("\nIn default ...... :o :o :o :o :o :o :o :o :o \n");
	}

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
	 //printf("%s\n", s);
	 //printf("%d: %s at %s\n", yylineno, s, yytext);
	 printf("Error : %s : %d \n",s,yylineno);
	 printf("Syntax Error\n\n");
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
