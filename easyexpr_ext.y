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
  : relationalExpression '<' multiplicativeExpression
  | relationalExpression '>' multiplicativeExpression
  | relationalExpression OP3 multiplicativeExpression
  | relationalExpression OP4 multiplicativeExpression
  | multiplicativeExpression
  ;

multiplicativeExpression
  : multiplicativeExpression '*' additiveExpression
  | multiplicativeExpression '/' additiveExpression
  | multiplicativeExpression '%' additiveExpression
  | additiveExpression
  ;

additiveExpression
  : additiveExpression '+' prefixExpression
  | additiveExpression '-' prefixExpression
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
