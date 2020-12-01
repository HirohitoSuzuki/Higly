#include <string.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct node {
  char* name;
  struct node* left;  struct node* right;} Node;

Node* tree;
char* code;
int code_size = 0;

Node* makeNode(char* na, Node* l, Node* r){
  Node *n;
  n = (Node*)malloc(sizeof(Node));
  n->name = (char*)malloc(strlen(na)*sizeof(char));
  strcpy(n->name, na);
  n->left = l;
  n->right = r;
  return n
;}

int code_append(char* s){
  code_size += strlen(s);
  char* tmp;
  tmp = (char*)realloc(code, sizeof(char) * code_size+1);
  if (tmp == NULL){
	  free(code);
    return -1;
  }
  code = tmp;
  strcat(code, s);
  return 0;
}

int drawGraph(Node* t){
  static int symbol_num = 0;
  char *lname;
  char *rname;
  int self_num = symbol_num;
  int left_num = ++symbol_num;
  int right_num = ++symbol_num;
  int children_num;
  if(t == NULL) return 0;
  drawGraph(t->left);
  drawGraph(t->right);

  if(t->left == NULL){
    children_num = 0;
  }else{
    lname = t->left->name;
    if(t->right == NULL){
      children_num = 1;
   }else{
      rname = t->right->name;
      children_num = 2;
    }
  }

  char tmp1[15], tmp2[15], tmp3[15];

  snprintf(tmp1, 15, "symbol%d", self_num);
  if(children_num != 0){
    snprintf(tmp2, 15, "symbol%d", left_num);
    if(children_num == 2){
      snprintf(tmp3, 15, "symbol%d", right_num);
    }
  }

  code_append(tmp1);
  if(children_num != 0){
    code_append(" -- ");
    code_append(tmp2);
    if(children_num == 2){
      code_append(", ");
      code_append(tmp3);
    }
  }
  code_append(";
");
  //"symbol1 -- symbol2, symbol3;"

  if(children_num != 0){
    code_append(tmp1);
    code_append("[label = \"");
    code_append(t->name);
    code_append("\"];\n");
    //"symbol1 = [label = "+"];"

    code_append(tmp2);
    code_append("[label = \"");
    code_append(lname);
    code_append("\"];\n");
    //"symbol2 = [label = "identifier"];"

    if(children_num == 2){
      code_append(tmp3);
      code_append("[label = \"");
      code_append(rname);
      code_append("\"];\n");
      //"symbol3 = [label = "intliteral"];"
    }
  }

  return 0;
}
%nonassoc < > <= >=
%left , ? : || && | ^ & == =! + - * / % (type_name) ++ -- sizeof ~ ! await
%right = += -= *= /= %= <<= >>= &= ^= |=

%%

commmaExpression
  : assignExpression
  | commmaExpression ',' assignExpression
  ;

assignExpression
  : conditionExpression
  | conditionExpression '=' assignExpression
  | conditionExpression OP1 assignExpression
  | conditionExpression OP2 assignExpression
  | conditionExpression OP3 assignExpression
  | conditionExpression OP4 assignExpression
  | conditionExpression OP5 assignExpression
  | conditionExpression OP6 assignExpression
  | conditionExpression OP7 assignExpression
  | conditionExpression OP8 assignExpression
  | conditionExpression OP9 assignExpression
  | conditionExpression OP10 assignExpression
  ;

conditionExpression
  : boolOr
  | conditionExpression '?' conditionExpression ':' boolOr
  ;

boolOr
  : boolAnd
  | boolOr OP11 boolAnd
  ;

boolAnd
  : bitwiseOr
  | boolAnd OP12 bitwiseOr
  ;

bitwiseOr
  : bitwiseXor
  | bitwiseOr '|' bitwiseXor
  ;

bitwiseXor
  : bitwiseAnd
  | bitwiseXor '^' bitwiseAnd
  ;

bitwiseAnd
  : equaltiveExpression
  | bitwiseAnd '&' equaltiveExpression
  ;

equaltiveExpression
  : rerativeExpression
  | equaltiveExpression OP13 rerativeExpression
  | equaltiveExpression OP14 rerativeExpression
  ;

rerativeExpression
  : additiveExpression
  | additiveExpression '<' additiveExpression
  | additiveExpression '>' additiveExpression
  | additiveExpression OP15 additiveExpression
  | additiveExpression OP16 additiveExpression
  ;

additiveExpression
  : multplecativeExpression
  | additiveExpression '+' multplecativeExpression
  | additiveExpression '-' multplecativeExpression
  ;

multplecativeExpression
  : castExpression
  | multplecativeExpression '*' castExpression
  | multplecativeExpression '/' castExpression
  | multplecativeExpression '%' castExpression
  ;

castExpression
  : unaryExpression
  | OP17 castExpression
  ;

unaryExpression
  : paClass
  | OP20 unaryExpression
  | OP21 unaryExpression
  | SIZEOF unaryExpression
  | '~' unaryExpression
  | '!' unaryExpression
  | '+' unaryExpression
  | '-' unaryExpression
  | '&' unaryExpression
  | '*' unaryExpression
  ;

paClass
  : primaryExpression
  | postfixExpression
  | awaitExpression
  ;

postfixExpression
  : paClass OP20
  | paClass OP21
  ;

awaitExpression
  : AWAIT paClass
  | '+' paClass paClass
  ;

