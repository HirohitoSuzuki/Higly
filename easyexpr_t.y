%token '+' '-' OP1 OP2 '*'
%token '/' '%' '<' '>' OP3
%token OP4 '?' ':'
%token IDENTIFIER FLOAT_LITERAL INT_LITERAL STRING_LITERAL
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

int codeAppend(char** s1, char* s2){
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

  codeAppend(&dcode, tmp);
  if(child_num != 0){
    codeAppend(&dcode, " -- ");
    codeAppend(&dcode, ctmp[0]);
    if(child_num >= 2){
      for(i=1;i<child_num;i++){
        codeAppend(&dcode, ", ");
        codeAppend(&dcode, ctmp[i]);
      }
    }
  }
  codeAppend(&dcode, ";\n");
  //"symbol1 -- symbol2, symbol3;"

  if(child_num != 0){
    codeAppend(&dcode, tmp);
    codeAppend(&dcode, "[label = \"");
    codeAppend(&dcode, t->name);
    codeAppend(&dcode, "\"];\n");
    //"symbol1 = [label = "+"];"

    for(i=0;i<child_num;i++){
      codeAppend(&dcode, ctmp[i]);
      codeAppend(&dcode, "[label = \"");
      codeAppend(&dcode, child_name[i]);
      codeAppend(&dcode, "\"];\n");
      //"symbol2 = [label = "identifier"];"
    }
  }

  return 0;
}
%}

%%

expression
  : conditionalExpression{ tree = $1; }
  ;

conditionalExpression
  : conditionalExpression '?' conditionalExpression ':' relationalExpression  
    { $$ = makeNode("'?'':'", $1, $3, $5); }
  | relationalExpression
  ;

relationalExpression
  : relationalExpression '<' additiveExpression
    { $$ = makeNode("'<'", $1, $3, NULL); }
  | relationalExpression '>' additiveExpression
    { $$ = makeNode("'>'", $1, $3, NULL); }
  | relationalExpression OP3 additiveExpression
    { $$ = makeNode("OP3", $1, $3, NULL); }
  | relationalExpression OP4 additiveExpression
    { $$ = makeNode("OP4", $1, $3, NULL); }
  | additiveExpression
  ;

additiveExpression
  : additiveExpression '+' multiplicativeExpression
    { $$ = makeNode("'+'", $1, $3, NULL); }
  | additiveExpression '-' multiplicativeExpression
    { $$ = makeNode("'-'", $1, $3, NULL); }
  | multiplicativeExpression
  ;

multiplicativeExpression
  : multiplicativeExpression '*' prefixExpression
    { $$ = makeNode("'*'", $1, $3, NULL); }
  | multiplicativeExpression '/' prefixExpression
    { $$ = makeNode("'/'", $1, $3, NULL); }
  | multiplicativeExpression '%' prefixExpression
    { $$ = makeNode("'%'", $1, $3, NULL); }
  | prefixExpression
  ;

prefixExpression
  : prefixExpression OP1  { $$ = makeNode("OP1", $1, NULL, NULL); }
  | prefixExpression OP2  { $$ = makeNode("OP2", $1, NULL, NULL); }
  | unaryExpression
  ;

unaryExpression
  : '+' unaryExpression  { $$ = makeNode("'+'", $2, NULL, NULL); }
  | '-' unaryExpression  { $$ = makeNode("'-'", $2, NULL, NULL); }
  | atom
  ;

atom
  : IDENTIFIER  { $$ = makeNode("IDENTIFIER", NULL, NULL, NULL); }
  | INT_LITERAL  { $$ = makeNode("INT_LITERAL", NULL, NULL, NULL); }
  | FLOAT_LITERAL  { $$ = makeNode("FLOAT_LITERAL", NULL, NULL, NULL); }
  | STRING_LITERAL  { $$ = makeNode("STRING_LITERAL", NULL, NULL, NULL); }
  | '(' expression ')'  { $$ = makeNode("()", $2, NULL, NULL); }
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
  codeAppend(&dcode, "graph type{\n");
  if(drawGraph(tree) == 0){
    printf("file output complete.\n");
  }else{
    printf("file output error.\n");
  }
  codeAppend(&dcode, "}");

  FILE *fp;
  fp = fopen("tree.dot", "w");
  fputs(dcode, fp);
  fclose(fp);

  return 0;
}
