%token ',' '=' OP1 OP2 OP3
%token OP4 OP5 OP6 OP7 OP8
%token OP9 OP10 '?' ':' OP11
%token OP12 '|' '^' '&' OP13
%token OP14 '<' '>' OP15 OP16
%token '+' '-' '*' '/' '%'
%token TYPE_NAME OP17 OP18 SIZEOF '~'
%token '!' AWAIT
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
  : conditionExpression '=' assignExpression  { $$ = makeNode("'='", $1, $3, NULL); }
  | conditionExpression OP1 assignExpression  { $$ = makeNode("OP1", $1, $3, NULL); }
  | conditionExpression OP2 assignExpression  { $$ = makeNode("OP2", $1, $3, NULL); }
  | conditionExpression OP3 assignExpression  { $$ = makeNode("OP3", $1, $3, NULL); }
  | conditionExpression OP4 assignExpression  { $$ = makeNode("OP4", $1, $3, NULL); }
  | conditionExpression OP5 assignExpression  { $$ = makeNode("OP5", $1, $3, NULL); }
  | conditionExpression OP6 assignExpression  { $$ = makeNode("OP6", $1, $3, NULL); }
  | conditionExpression OP7 assignExpression  { $$ = makeNode("OP7", $1, $3, NULL); }
  | conditionExpression OP8 assignExpression  { $$ = makeNode("OP8", $1, $3, NULL); }
  | conditionExpression OP9 assignExpression  { $$ = makeNode("OP9", $1, $3, NULL); }
  | conditionExpression OP10 assignExpression  { $$ = makeNode("OP10", $1, $3, NULL); }
  | conditionExpression
  ;

conditionExpression
  : conditionExpression '?' conditionExpression ':' boolOr  { $$ = makeNode("'?'':'", $1, $3, $5); }
  | boolOr
  ;

boolOr
  : boolOr OP11 boolAnd  { $$ = makeNode("OP11", $1, $3, NULL); }
  | boolAnd
  ;

boolAnd
  : boolAnd OP12 bitwiseOr  { $$ = makeNode("OP12", $1, $3, NULL); }
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
  : bitwiseAnd '&' equaltiveExpression  { $$ = makeNode("'&'", $1, $3, NULL); }
  | equaltiveExpression
  ;

equaltiveExpression
  : equaltiveExpression OP13 rerativeExpression  { $$ = makeNode("OP13", $1, $3, NULL); }
  | equaltiveExpression OP14 rerativeExpression  { $$ = makeNode("OP14", $1, $3, NULL); }
  | rerativeExpression
  ;

rerativeExpression
  : additiveExpression '<' additiveExpression  { $$ = makeNode("'<'", $1, $3, NULL); }
  | additiveExpression '>' additiveExpression  { $$ = makeNode("'>'", $1, $3, NULL); }
  | additiveExpression OP15 additiveExpression  { $$ = makeNode("OP15", $1, $3, NULL); }
  | additiveExpression OP16 additiveExpression  { $$ = makeNode("OP16", $1, $3, NULL); }
  | additiveExpression
  ;

additiveExpression
  : additiveExpression '+' multplecativeExpression  { $$ = makeNode("'+'", $1, $3, NULL); }
  | additiveExpression '-' multplecativeExpression  { $$ = makeNode("'-'", $1, $3, NULL); }
  | multplecativeExpression
  ;

multplecativeExpression
  : multplecativeExpression '*' castExpression  { $$ = makeNode("'*'", $1, $3, NULL); }
  | multplecativeExpression '/' castExpression  { $$ = makeNode("'/'", $1, $3, NULL); }
  | multplecativeExpression '%' castExpression  { $$ = makeNode("'%'", $1, $3, NULL); }
  | castExpression
  ;

castExpression
  : TYPE_NAME castExpression  { $$ = makeNode("TYPE_NAME", $2, NULL, NULL); }
  | unaryExpression
  ;

unaryExpression
  : OP17 unaryExpression  { $$ = makeNode("OP17", $2, NULL, NULL); }
  | OP18 unaryExpression  { $$ = makeNode("OP18", $2, NULL, NULL); }
  | SIZEOF unaryExpression  { $$ = makeNode("SIZEOF", $2, NULL, NULL); }
  | '~' unaryExpression  { $$ = makeNode("'~'", $2, NULL, NULL); }
  | '!' unaryExpression  { $$ = makeNode("'!'", $2, NULL, NULL); }
  | '+' unaryExpression  { $$ = makeNode("'+'", $2, NULL, NULL); }
  | '-' unaryExpression  { $$ = makeNode("'-'", $2, NULL, NULL); }
  | '&' unaryExpression  { $$ = makeNode("'&'", $2, NULL, NULL); }
  | '*' unaryExpression  { $$ = makeNode("'*'", $2, NULL, NULL); }
  | paClass
  ;

paClass
  : postfixExpression
  | awaitExpression
  | primaryExpression
  ;

postfixExpression
  : paClass OP17  { $$ = makeNode("OP17", $1, NULL, NULL); }
  | paClass OP18  { $$ = makeNode("OP18", $1, NULL, NULL); }
  ;

awaitExpression
  : AWAIT paClass  { $$ = makeNode("AWAIT", $2, NULL, NULL); }
  ;

primaryExpression
  : IDENTIFIER  { $$ = makeNode("IDENTIFIER", NULL, NULL, NULL); }
  | INT_LITERAL  { $$ = makeNode("INT_LITERAL", NULL, NULL, NULL); }
  | FLOAT_LITERAL  { $$ = makeNode("FLOAT_LITERAL", NULL, NULL, NULL); }
  | STRING_LITERAL  { $$ = makeNode("STRING_LITERAL", NULL, NULL, NULL); }
  ;

%%
#include "lex.yy.c"

int main(void){
  if(yyparse()==0){
    printf("parse is sucsessfull.\n");
  }else{
    return -1;
  }

  dcode = (char*)calloc(1, sizeof(char));
  code_append(&dcode, "graph type{\n");
  code_append(&dcode, "dpi=\"200\";\n");
  code_append(&dcode, "node [fontname=\"DejaVu Serif Italic\"];\n");
  if(drawGraph(tree) == 0){
    printf("file output complete.\n");
  }else{
    printf("file output error.\n");
  }
  code_append(&dcode, "}");

  FILE *fp;
  char *filename = "tree.dot";
  fp = fopen(filename, "w");
  fputs(dcode, fp);
  fclose(fp);

  return 0;
}
