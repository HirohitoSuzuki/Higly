%token OP1 OP2 ']' '[' ')'
%token '(' '.' OP3 '}' '{'
%token ',' SIZEOF '&' '*' '+'
%token '-' '~' '!' '/' '%'
%token OP4 OP5 '<' '>' OP6
%token OP7 OP8 OP9 '^' '|'
%token OP10 OP11 '?' ':' '='
%token OP12 OP13 OP14 OP15 OP16
%token OP17 OP18 OP19 OP20 OP21
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

primaryExpression
  : IDENTIFIER  { $$ = makeNode("IDENTIFIER", NULL, NULL, NULL); }
  | INT_LITERAL  { $$ = makeNode("INT_LITERAL", NULL, NULL, NULL); }
  | FLOAT_LITERAL  { $$ = makeNode("FLOAT_LITERAL", NULL, NULL, NULL); }
  | STRING_LITERAL  { $$ = makeNode("STRING_LITERAL", NULL, NULL, NULL); }
  | '(' expression ')'  { $$ = makeNode("()", $2, NULL, NULL); }
  ;

postfixExpression
  : postfixExpression OP1  { $$ = makeNode("OP1", $1, NULL, NULL); }
  | postfixExpression OP2  { $$ = makeNode("OP2", $1, NULL, NULL); }
  | postfixExpression '[' expression ']'  { $$ = makeNode("'[' expression ']'", $1, NULL, NULL); }
  | postfixExpression '(' ')'  { $$ = makeNode("'(' ')'", $1, NULL, NULL); }
  | postfixExpression '(' argumentExpressionList ')'  { $$ = makeNode("'(' argumentExpressionList ')'", $1, NULL, NULL); }
  | postfixExpression '.' IDENTIFIER  { $$ = makeNode("", $1, $2, NULL); }
  | postfixExpression OP3 IDENTIFIER  { $$ = makeNode("", $1, $2, NULL); }
  | '(' type_name ')' '{' initializerList '}'
  | '(' type_name ')' '{' initializerList ',' '}'
  | primaryExpression
  ;

unaryExpression
  : OP1 unaryExpression  { $$ = makeNode("OP1", $2, NULL, NULL); }
  | OP2 unaryExpression  { $$ = makeNode("OP2", $2, NULL, NULL); }
  | SIZEOF '(' type_name ')'
  | SIZEOF unaryExpression  { $$ = makeNode("SIZEOF", $2, NULL, NULL); }
  | '&' castExpression  { $$ = makeNode("'&'", $2, NULL, NULL); }
  | '*' castExpression  { $$ = makeNode("'*'", $2, NULL, NULL); }
  | '+' castExpression  { $$ = makeNode("'+'", $2, NULL, NULL); }
  | '-' castExpression  { $$ = makeNode("'-'", $2, NULL, NULL); }
  | '~' castExpression  { $$ = makeNode("'~'", $2, NULL, NULL); }
  | '!' castExpression  { $$ = makeNode("'!'", $2, NULL, NULL); }
  | postfixExpression
  ;

castExpression
  : '(' type_name ')' castExpression  { $$ = makeNode("'(' type_name ')'", $2, NULL, NULL); }
  | unaryExpression
  ;

multiplecativeExpression
  : multiplecativeExpression '*' castExpression  { $$ = makeNode("", $1, $2, NULL); }
  | multiplecativeExpression '/' castExpression  { $$ = makeNode("", $1, $2, NULL); }
  | multiplecativeExpression '%' castExpression  { $$ = makeNode("", $1, $2, NULL); }
  | castExpression
  ;

additiveExpression
  : additiveExpression '+' multiplecativeExpression  { $$ = makeNode("", $1, $2, NULL); }
  | additiveExpression '-' multiplecativeExpression  { $$ = makeNode("", $1, $2, NULL); }
  | multiplecativeExpression
  ;

shiftExpression
  : shiftExpression OP4 additiveExpression  { $$ = makeNode("", $1, $2, NULL); }
  | shiftExpression OP5 additiveExpression  { $$ = makeNode("", $1, $2, NULL); }
  | additiveExpression
  ;

relationalExpression
  : relationalExpression '<' shiftExpression  { $$ = makeNode("", $1, $2, NULL); }
  | relationalExpression '>' shiftExpression  { $$ = makeNode("", $1, $2, NULL); }
  | relationalExpression OP6 shiftExpression  { $$ = makeNode("", $1, $2, NULL); }
  | relationalExpression OP7 shiftExpression  { $$ = makeNode("", $1, $2, NULL); }
  | shiftExpression
  ;

equalityExpression
  : equalityExpression OP8 relationalExpression  { $$ = makeNode("", $1, $2, NULL); }
  | equalityExpression OP9 relationalExpression  { $$ = makeNode("", $1, $2, NULL); }
  | relationalExpression
  ;

bitwiseAnd
  : bitwiseAnd '&' equalityExpression  { $$ = makeNode("", $1, $2, NULL); }
  | equalityExpression
  ;

bitwiseXor
  : bitwiseXor '^' bitwiseAnd  { $$ = makeNode("", $1, $2, NULL); }
  | bitwiseAnd
  ;

bitwiseOr
  : bitwiseOr '|' bitwiseXor  { $$ = makeNode("", $1, $2, NULL); }
  | bitwiseXor
  ;

boolAnd
  : boolAnd OP10 bitwiseOr  { $$ = makeNode("", $1, $2, NULL); }
  | bitwiseOr
  ;

boolOr
  : boolOr OP11 boolAnd  { $$ = makeNode("", $1, $2, NULL); }
  | boolAnd
  ;

conditionExpression
  : boolOr '?' expression ':' conditionExpression  { $$ = makeNode("'?'", $1, $2, $4); }
  | boolOr
  ;

assignExpression
  : unaryExpression '=' assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | unaryExpression OP12 assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | unaryExpression OP13 assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | unaryExpression OP14 assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | unaryExpression OP15 assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | unaryExpression OP16 assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | unaryExpression OP17 assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | unaryExpression OP18 assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | unaryExpression OP19 assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | unaryExpression OP20 assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | unaryExpression OP21 assignExpression  { $$ = makeNode("unaryExpression", $1, $3, NULL); }
  | conditionExpression
  ;

commaExpression
  : commaExpression ',' assignExpression  { $$ = makeNode("", $1, $2, NULL); }
  | assignExpression
  ;

expression
  : commaExpression{ tree = $1; }
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
