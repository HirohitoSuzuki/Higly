%token '~' '!' '+' '-' '*'
%token '/' '%' OP1 OP2 OP3
%token '<' '>' OP4 OP5 INSTANCEOF
%token OP6 OP7 '&' '^' '|'
%token OP8 OP9 '?' ':' '='
%token OP10 OP11 OP12 OP13 OP14
%token OP15 OP16 OP17 OP18 OP19
%token OP20
%token IDENTIFIER FLOAT_LITERAL INT_LITERAL STRING_LITERAL
%token INC_OP DEC_OP INT

%%

expression
  : assignExpression
  ;

assignExpression
  : leftHandSide '=' assignExpression
  | leftHandSide OP10 assignExpression
  | leftHandSide OP11 assignExpression
  | leftHandSide OP12 assignExpression
  | leftHandSide OP13 assignExpression
  | leftHandSide OP14 assignExpression
  | leftHandSide OP15 assignExpression
  | leftHandSide OP16 assignExpression
  | leftHandSide OP17 assignExpression
  | leftHandSide OP18 assignExpression
  | leftHandSide OP19 assignExpression
  | leftHandSide OP20 assignExpression
  | conditionalExpression
  ;

leftHandSide
  : Name
  ;

conditionalExpression
  : conditionalOrExpression '?' expression ':' conditionalExpression
  | conditionalOrExpression
  ;

conditionalOrExpression
  : conditionalOrExpression OP9 conditionalAndExpression
  | conditionalAndExpression
  ;

conditionalAndExpression
  : conditionalAndExpression OP8 inclusiveOrExpression
  | inclusiveOrExpression
  ;

inclusiveOrExpression
  : inclusiveOrExpression '|' exclusiveOrExpression
  | exclusiveOrExpression
  ;

exclusiveOrExpression
  : exclusiveOrExpression '^' andExpression
  | andExpression
  ;

andExpression
  : andExpression '&' equalityExpression
  | equalityExpression
  ;

equalityExpression
  : equalityExpression OP6 relationalExpression
  | equalityExpression OP7 relationalExpression
  | relationalExpression
  ;

relationalExpression
  : relationalExpression '<' shiftExpression
  | relationalExpression '>' shiftExpression
  | relationalExpression OP4 shiftExpression
  | relationalExpression OP5 shiftExpression
  | relationalExpression INSTANCEOF referenceType
  | shiftExpression
  ;

referenceType
  : Name
  ;

shiftExpression
  : shiftExpression OP1 additiveExpression
  | shiftExpression OP2 additiveExpression
  | shiftExpression OP3 additiveExpression
  | additiveExpression
  ;

additiveExpression
  : additiveExpression '+' multiplecativeExpression
  | additiveExpression '-' multiplecativeExpression
  | multiplecativeExpression
  ;

multiplecativeExpression
  : multiplecativeExpression '*' unaryExpression
  | multiplecativeExpression '/' unaryExpression
  | multiplecativeExpression '%' unaryExpression
  | unaryExpression
  ;

unaryExpression
  : preIncrementExpression
  | preDecrementExpression
  | '+' unaryExpression
  | '-' unaryExpression
  | unaryExpressionNotPlusMinus
  ;

preIncrementExpression
  : INC_OP unaryExpression
  ;

preDecrementExpression
  : DEC_OP unaryExpression
  ;

unaryExpressionNotPlusMinus
  : '~' unaryExpression
  | '!' unaryExpression
  | castExpression
  | postFixExpression
  ;

castExpression
  : '(' primitiveType ')' unaryExpression
  ;

primitiveType
  : INT
  ;

postFixExpression
  : Name
  | postIncrementExpression
  | postDecrementExpression
  | atom
  ;

postIncrementExpression
  : postFixExpression INC_OP
  ;

postDecrementExpression
  : postFixExpression DEC_OP
  ;

Name
  : IDENTIFIER
  ;

atom
  : INT_LITERAL
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
