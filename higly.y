%nonassoc '<' '>' OP15 OP16
%left ',' '?' ':' OP11 OP12
%left '|' '^' '&' OP13 OP14
%left '+' '-' '*' '/' '%'
%left OP17 OP20 OP21 SIZEOF '~'
%left '!' AWAIT OP22
%right '=' OP1 OP2 OP3 OP4
%right OP5 OP6 OP7 OP8 OP9
%right OP10
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
int dcode_size;
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

int dcode_append(char* s){
  dcode_size += strlen(s);
  char* tmp;
  tmp = (char*)realloc(dcode, sizeof(char) * (dcode_size+1));
  if (tmp == NULL){
	  free(dcode);
    return -1;
  }
  dcode = tmp;
  strcat(dcode, s);
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

  dcode_append(tmp);
  if(child_num != 0){
    dcode_append(" -- ");
    dcode_append(ctmp[0]);
    if(child_num >= 2){
      for(i=1;i<child_num;i++){
        dcode_append(", ");
        dcode_append(ctmp[i]);
      }
    }
  }
  dcode_append(";\n");
  //"symbol1 -- symbol2, symbol3;"

  if(child_num != 0){
    dcode_append(tmp);
    dcode_append("[label = \"");
    dcode_append(t->name);
    dcode_append("\"];\n");
    //"symbol1 = [label = "+"];"

    for(i=0;i<child_num;i++){
      dcode_append(ctmp[i]);
      dcode_append("[label = \"");
      dcode_append(child_name[i]);
      dcode_append("\"];\n");
      //"symbol2 = [label = "identifier"];"
    }
  }

  return 0;
}
%}

%%

expression
  : commaExpression  { tree = $1; }
;

commaExpression
  : assignExpression
  | commaExpression ',' assignExpression  { $$ = makeNode(",", $1, $3, NULL); }
  ;

assignExpression
  : conditionExpression
  | conditionExpression '=' assignExpression  { $$ = makeNode("=", $1, $3, NULL); }
  | conditionExpression OP1 assignExpression  { $$ = makeNode("+=", $1, $3, NULL); }
  | conditionExpression OP2 assignExpression  { $$ = makeNode("-=", $1, $3, NULL); }
  | conditionExpression OP3 assignExpression  { $$ = makeNode("*=", $1, $3, NULL); }
  | conditionExpression OP4 assignExpression  { $$ = makeNode("/=", $1, $3, NULL); }
  | conditionExpression OP5 assignExpression  { $$ = makeNode("%=", $1, $3, NULL); }
  | conditionExpression OP6 assignExpression  { $$ = makeNode("<<=", $1, $3, NULL); }
  | conditionExpression OP7 assignExpression  { $$ = makeNode(">>=", $1, $3, NULL); }
  | conditionExpression OP8 assignExpression  { $$ = makeNode("&=", $1, $3, NULL); }
  | conditionExpression OP9 assignExpression  { $$ = makeNode("^=", $1, $3, NULL); }
  | conditionExpression OP10 assignExpression  { $$ = makeNode("|=", $1, $3, NULL); }
  ;

conditionExpression
  : boolOr
  | conditionExpression '?' conditionExpression ':' boolOr  { $$ = makeNode("?:", $1, $3, $5); }
  ;

boolOr
  : boolAnd
  | boolOr OP11 boolAnd  { $$ = makeNode("||", $1, $3, NULL); }
  ;

boolAnd
  : bitwiseOr
  | boolAnd OP12 bitwiseOr  { $$ = makeNode("&&", $1, $3, NULL); }
  ;

bitwiseOr
  : bitwiseXor
  | bitwiseOr '|' bitwiseXor  { $$ = makeNode("|", $1, $3, NULL); }
  ;

bitwiseXor
  : bitwiseAnd
  | bitwiseXor '^' bitwiseAnd  { $$ = makeNode("^", $1, $3, NULL); }
  ;

bitwiseAnd
  : equaltiveExpression
  | bitwiseAnd '&' equaltiveExpression  { $$ = makeNode("&", $1, $3, NULL); }
  ;

equaltiveExpression
  : rerativeExpression
  | equaltiveExpression OP13 rerativeExpression  { $$ = makeNode("==", $1, $3, NULL); }
  | equaltiveExpression OP14 rerativeExpression  { $$ = makeNode("=!", $1, $3, NULL); }
  ;

rerativeExpression
  : additiveExpression
  | additiveExpression '<' additiveExpression  { $$ = makeNode("<", $1, $3, NULL); }
  | additiveExpression '>' additiveExpression  { $$ = makeNode(">", $1, $3, NULL); }
  | additiveExpression OP15 additiveExpression  { $$ = makeNode("<=", $1, $3, NULL); }
  | additiveExpression OP16 additiveExpression  { $$ = makeNode(">=", $1, $3, NULL); }
  ;

additiveExpression
  : multplecativeExpression
  | additiveExpression '+' multplecativeExpression  { $$ = makeNode("+", $1, $3, NULL); }
  | additiveExpression '-' multplecativeExpression  { $$ = makeNode("-", $1, $3, NULL); }
  ;

multplecativeExpression
  : castExpression
  | multplecativeExpression '*' castExpression  { $$ = makeNode("*", $1, $3, NULL); }
  | multplecativeExpression '/' castExpression  { $$ = makeNode("/", $1, $3, NULL); }
  | multplecativeExpression '%' castExpression  { $$ = makeNode("%", $1, $3, NULL); }
  ;

castExpression
  : unaryExpression
  | OP17 castExpression  { $$ = makeNode("(type_name)", $2, NULL, NULL); }
  ;

unaryExpression
  : paClass
  | OP20 unaryExpression  { $$ = makeNode("++", $2, NULL, NULL); }
  | OP21 unaryExpression  { $$ = makeNode("--", $2, NULL, NULL); }
  | SIZEOF unaryExpression  { $$ = makeNode("sizeof", $2, NULL, NULL); }
  | '~' unaryExpression  { $$ = makeNode("~", $2, NULL, NULL); }
  | '!' unaryExpression  { $$ = makeNode("!", $2, NULL, NULL); }
  | '+' unaryExpression  { $$ = makeNode("+", $2, NULL, NULL); }
  | '-' unaryExpression  { $$ = makeNode("-", $2, NULL, NULL); }
  | '&' unaryExpression  { $$ = makeNode("&", $2, NULL, NULL); }
  | '*' unaryExpression  { $$ = makeNode("*", $2, NULL, NULL); }
  ;

paClass
  : primaryExpression
  | postfixExpression  { $$ = makeNode("postfixExpression", NULL, NULL, NULL); }
  | awaitExpression  { $$ = makeNode("awaitExpression", NULL, NULL, NULL); }
  ;

postfixExpression
  : paClass OP20  { $$ = makeNode("++", $1, NULL, NULL); }
  | paClass OP21  { $$ = makeNode("--", $1, NULL, NULL); }
  ;

awaitExpression
  : AWAIT paClass  { $$ = makeNode("await", $2, NULL, NULL); }
  | OP22 paClass paClass  { $$ = makeNode("+@+", $2, $3, NULL); }
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

  dcode_size = 1;
  dcode = (char*)calloc(1, sizeof(char));
  dcode_append("graph type{\n");
  dcode_append("dpi=\"200\";\n");
  dcode_append("node [fontname=\"DejaVu Serif Italic\"];\n");
  if(drawGraph(tree) == 0){
    printf("file output complete.\n");
  }else{
    printf("file output error.\n");
  }
  dcode_append("}");

  FILE *fp;
  char *filename = "tree.dot";
  fp = fopen(filename, "w");
  fputs(dcode, fp);
  fclose(fp);

  return 0;
}
