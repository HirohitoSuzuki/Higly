%token OP1 OP2 ']' '[' ')'
%token '(' '.' OP3 SIZEOF '&'
%token '*' '+' '-' '~' '!'
%token '/' '%' OP4 OP5 '<'
%token '>' OP6 OP7 OP8 OP9
%token '^' '|' OP10 OP11 '?'
%token ':' '=' OP12 OP13 OP14
%token OP15 OP16 OP17 OP18 OP19
%token OP20 OP21 ','
%token IDENTIFIER INT_LITERAL FLOAT_LITERAL STRING_LITERAL
%{
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#define YYSTYPE Node*
#define CNUM 3

typedef struct node {
  char* name;
  struct node* child[CNUM];
} Node;

char* dcode;
Node* tree;

Node* makeNode(char* na, Node* c1, Node* c2, Node* c3){
  Node *n;
  n = (Node*)malloc(sizeof(Node));
  n->name = (char*)malloc(strlen(na)*sizeof(char));
  strcpy(n->name, na);
  n->child[0] = c1;
  n->child[1] = c2;
  n->child[2] = c3;
  return n;
}

int code_append(char** s1, char* s2){
  int size = strlen(*s1) + strlen(s2);
  char* tmp;
  tmp = (char*)realloc(*s1, sizeof(char) * (size+1));
  if (tmp == NULL){
	  free(*s1);
    return -1;
  }
  *s1 = tmp;
  strcat(*s1, s2);
  return 0;
}

int drawGraph(Node* t){
  static int symbol_num = 0;
  char *child_name[CNUM];
  char* tmp;
  char* ctmp[CNUM];
  int self_symbol_num = 0;
  int child_symbol_num[3];
  int child_num = 0;
  int i = 0;
  
  if(t == NULL) return 0;
  self_symbol_num = symbol_num;

  for(i=0;i<CNUM;i++){
    child_symbol_num[i] = ++symbol_num;
    drawGraph(t->child[i]);
  }

  for(i=0;i<CNUM;i++){
    if(t->child[i]){
      child_name[i] = t->child[i]->name;
      child_num++;
    }
  }

  tmp = (char*)malloc(15*sizeof(char));
  snprintf(tmp, 15, "symbol%d", self_symbol_num);
  for(i=0;i<child_num;i++){
    ctmp[i] = (char*)malloc(15*sizeof(char));
    snprintf(ctmp[i], 15, "symbol%d", child_symbol_num[i]);
  }

  code_append(&dcode, tmp);
  if(child_num != 0){
    code_append(&dcode, " -- ");
    code_append(&dcode, ctmp[0]);
    if(child_num >= 2){
      for(i=1;i<child_num;i++){
        code_append(&dcode, ", ");
        code_append(&dcode, ctmp[i]);
      }
    }
  }
  code_append(&dcode, ";\n");
  //"symbol1 -- symbol2, symbol3;"

  if(child_num != 0){
    code_append(&dcode, tmp);
    code_append(&dcode, "[label = \"");
    code_append(&dcode, t->name);
    code_append(&dcode, "\"];\n");
    //"symbol1 = [label = "+"];"

    for(i=0;i<child_num;i++){
      code_append(&dcode, ctmp[i]);
      code_append(&dcode, "[label = \"");
      code_append(&dcode, child_name[i]);
      code_append(&dcode, "\"];\n");
      //"symbol2 = [label = "identifier"];"
    }
  }

  return 0;
}
%}

%%

expression
  : commaExpression{ tree = $1; }
  ;

commaExpression
  : commaExpression ',' assignExpression  { $$ = makeNode("','", $1, $3, NULL); }
  | assignExpression
  ;

assignExpression
  : unaryExpression '=' assignExpression  { $$ = makeNode("'='", $1, $3, NULL); }
  | unaryExpression OP12 assignExpression  { $$ = makeNode("OP12", $1, $3, NULL); }
  | unaryExpression OP13 assignExpression  { $$ = makeNode("OP13", $1, $3, NULL); }
  | unaryExpression OP14 assignExpression  { $$ = makeNode("OP14", $1, $3, NULL); }
  | unaryExpression OP15 assignExpression  { $$ = makeNode("OP15", $1, $3, NULL); }
  | unaryExpression OP16 assignExpression  { $$ = makeNode("OP16", $1, $3, NULL); }
  | unaryExpression OP17 assignExpression  { $$ = makeNode("OP17", $1, $3, NULL); }
  | unaryExpression OP18 assignExpression  { $$ = makeNode("OP18", $1, $3, NULL); }
  | unaryExpression OP19 assignExpression  { $$ = makeNode("OP19", $1, $3, NULL); }
  | unaryExpression OP20 assignExpression  { $$ = makeNode("OP20", $1, $3, NULL); }
  | unaryExpression OP21 assignExpression  { $$ = makeNode("OP21", $1, $3, NULL); }
  | conditionExpression
  ;

conditionExpression
  : boolOr '?' expression ':' conditionExpression  { $$ = makeNode("'?'':'", $1, $3, $5); }
  | boolOr
  ;

boolOr
  : boolOr OP11 boolAnd  { $$ = makeNode("OP11", $1, $3, NULL); }
  | boolAnd
  ;

boolAnd
  : boolAnd OP10 bitwiseOr  { $$ = makeNode("OP10", $1, $3, NULL); }
  | bitwiseOr
  ;

bitwiseOr
  : bitwiseOr '|' bitwiseXor  { $$ = makeNode("'|'", $1, $3, NULL); }
  | bitwiseXor
  ;

bitwiseXor
  : bitwiseXor '^' bitwiseAnd  { $$ = makeNode("'^'", $1, $3, NULL); }
  | bitwiseAnd
  ;

bitwiseAnd
  : bitwiseAnd '&' equalityExpression  { $$ = makeNode("'&'", $1, $3, NULL); }
  | equalityExpression
  ;

equalityExpression
  : equalityExpression OP8 relationalExpression  { $$ = makeNode("OP8", $1, $3, NULL); }
  | equalityExpression OP9 relationalExpression  { $$ = makeNode("OP9", $1, $3, NULL); }
  | relationalExpression
  ;

relationalExpression
  : relationalExpression '<' shiftExpression  { $$ = makeNode("'<'", $1, $3, NULL); }
  | relationalExpression '>' shiftExpression  { $$ = makeNode("'>'", $1, $3, NULL); }
  | relationalExpression OP6 shiftExpression  { $$ = makeNode("OP6", $1, $3, NULL); }
  | relationalExpression OP7 shiftExpression  { $$ = makeNode("OP7", $1, $3, NULL); }
  | shiftExpression
  ;

shiftExpression
  : shiftExpression OP4 additiveExpression  { $$ = makeNode("OP4", $1, $3, NULL); }
  | shiftExpression OP5 additiveExpression  { $$ = makeNode("OP5", $1, $3, NULL); }
  | additiveExpression
  ;

additiveExpression
  : additiveExpression '+' multiplecativeExpression  { $$ = makeNode("'+'", $1, $3, NULL); }
  | additiveExpression '-' multiplecativeExpression  { $$ = makeNode("'-'", $1, $3, NULL); }
  | multiplecativeExpression
  ;

multiplecativeExpression
  : multiplecativeExpression '*' castExpression  { $$ = makeNode("'*'", $1, $3, NULL); }
  | multiplecativeExpression '/' castExpression  { $$ = makeNode("'/'", $1, $3, NULL); }
  | multiplecativeExpression '%' castExpression  { $$ = makeNode("'%'", $1, $3, NULL); }
  | castExpression
  ;

castExpression
  : '(' type_name ')' castExpression  { $$ = makeNode("'(' type_name ')'", $2, NULL, NULL); }
  | unaryExpression
  ;

unaryExpression
  : OP1 unaryExpression  { $$ = makeNode("OP1", $2, NULL, NULL); }
  | OP2 unaryExpression  { $$ = makeNode("OP2", $2, NULL, NULL); }
  | SIZEOF unaryExpression  { $$ = makeNode("SIZEOF", $2, NULL, NULL); }
  | '&' castExpression  { $$ = makeNode("'&'", $2, NULL, NULL); }
  | '*' castExpression  { $$ = makeNode("'*'", $2, NULL, NULL); }
  | '+' castExpression  { $$ = makeNode("'+'", $2, NULL, NULL); }
  | '-' castExpression  { $$ = makeNode("'-'", $2, NULL, NULL); }
  | '~' castExpression  { $$ = makeNode("'~'", $2, NULL, NULL); }
  | '!' castExpression  { $$ = makeNode("'!'", $2, NULL, NULL); }
  | postfixExpression
  ;

postfixExpression
  : postfixExpression OP1  { $$ = makeNode("OP1", $1, NULL, NULL); }
  | postfixExpression OP2  { $$ = makeNode("OP2", $1, NULL, NULL); }
  | postfixExpression '[' expression ']'  { $$ = makeNode("'[' expression ']'", $1, NULL, NULL); }
  | postfixExpression '(' ')'  { $$ = makeNode("'(' ')'", $1, NULL, NULL); }
  | postfixExpression '(' argumentExpressionList ')'  { $$ = makeNode("'(' argumentExpressionList ')'", $1, NULL, NULL); }
  | postfixExpression '.' IDENTIFIER  { $$ = makeNode("'.'", $1, $3, NULL); }
  | postfixExpression OP3 IDENTIFIER  { $$ = makeNode("OP3", $1, $3, NULL); }
  | primaryExpression
  ;

primaryExpression
  : IDENTIFIER  { $$ = makeNode("IDENTIFIER", NULL, NULL, NULL); }
  | INT_LITERAL  { $$ = makeNode("INT_LITERAL", NULL, NULL, NULL); }
  | FLOAT_LITERAL  { $$ = makeNode("FLOAT_LITERAL", NULL, NULL, NULL); }
  | STRING_LITERAL  { $$ = makeNode("STRING_LITERAL", NULL, NULL, NULL); }
  | '(' expression ')'  { $$ = makeNode("'('')'", $2, NULL, NULL); }
  ;

%%
#include "lex.yy.c"

int main(void){
  if(yyparse()==0){
    printf("parse is successfull.\n");
  }else{
    return -1;
  }

  dcode = (char*)calloc(1, sizeof(char));
  code_append(&dcode, "graph type{\n");
  if(drawGraph(tree) == 0){
    printf("file output complete.\n");
  }else{
    printf("file output error.\n");
  }
  code_append(&dcode, "}");

  FILE *fp;
  fp = fopen("tree.dot", "w");
  fputs(dcode, fp);
  fclose(fp);

  return 0;
}
