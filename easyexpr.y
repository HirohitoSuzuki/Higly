%token '+' '-' OP1 OP2 '*'
%token '/' '%' '<' '>' OP3
%token OP4 '?' ':'
%token IDENTIFIER FLOAT_LITERAL INT_LITERAL STRING_LITERAL

%%

expression
  : conditionalExpression
  ;

conditionalExpression
  : conditionalExpression '?' conditionalExpression ':' relationalExpression
  | relationalExpression
  ;

relationalExpression
  : relationalExpression '<' additiveExpression
  | relationalExpression '>' additiveExpression
  | relationalExpression OP3 additiveExpression
  | relationalExpression OP4 additiveExpression
  | additiveExpression
  ;

additiveExpression
  : additiveExpression '+' multiplicativeExpression
  | additiveExpression '-' multiplicativeExpression
  | multiplicativeExpression
  ;

multiplicativeExpression
  : multiplicativeExpression '*' prefixExpression
  | multiplicativeExpression '/' prefixExpression
  | multiplicativeExpression '%' prefixExpression
  | prefixExpression
  ;

prefixExpression
  : prefixExpression OP1
  | prefixExpression OP2
  | unaryExpression
  ;

unaryExpression
  : '+' unaryExpression
  | '-' unaryExpression
  | atom
  ;

atom
  : IDENTIFIER
  | INT_LITERAL
  | FLOAT_LITERAL
  | STRING_LITERAL
  | '(' expression ')'
  ;

%%
#include "lex.yy.c"

int main(void){
  if(yyparse()==0){
    printf("parse is successfull.\n");
  }else{
    return -1;
  }

  return 0;
}
