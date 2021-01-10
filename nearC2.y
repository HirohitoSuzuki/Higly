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

%%

primaryExpression
  : IDENTIFIER
  | INT_LITERAL
  | FLOAT_LITERAL
  | STRING_LITERAL
  | '(' expression ')'
  ;

postfixExpression
  : postfixExpression OP1
  | postfixExpression OP2
  | postfixExpression '[' expression ']'
  | postfixExpression '(' ')'
  | postfixExpression '(' argumentExpressionList ')'
  | postfixExpression '.' primaryExpression
  | postfixExpression OP3 primaryExpression
  | '(' type_name ')' '{' initializerList '}'
  | '(' type_name ')' '{' initializerList ',' '}'
  | primaryExpression
  ;

unaryExpression
  : OP1 unaryExpression
  | OP2 unaryExpression
  | SIZEOF '(' type_name ')'
  | SIZEOF unaryExpression
  | '&' unaryExpression
  | '*' unaryExpression
  | '+' unaryExpression
  | '-' unaryExpression
  | '~' unaryExpression
  | '!' unaryExpression
  | postfixExpression
  ;

castExpression
  : '(' type_name ')' castExpression
  | unaryExpression
  ;

multiplecativeExpression
  : multiplecativeExpression '*' castExpression
  | multiplecativeExpression '/' castExpression
  | multiplecativeExpression '%' castExpression
  | castExpression
  ;

additiveExpression
  : additiveExpression '+' multiplecativeExpression
  | additiveExpression '-' multiplecativeExpression
  | multiplecativeExpression
  ;

shiftExpression
  : shiftExpression OP4 additiveExpression
  | shiftExpression OP5 additiveExpression
  | additiveExpression
  ;

relationalExpression
  : relationalExpression '<' shiftExpression
  | relationalExpression '>' shiftExpression
  | relationalExpression OP6 shiftExpression
  | relationalExpression OP7 shiftExpression
  | shiftExpression
  ;

equalityExpression
  : equalityExpression OP8 relationalExpression
  | equalityExpression OP9 relationalExpression
  | relationalExpression
  ;

bitwiseAnd
  : bitwiseAnd '&' equalityExpression
  | equalityExpression
  ;

bitwiseXor
  : bitwiseXor '^' bitwiseAnd
  | bitwiseAnd
  ;

bitwiseOr
  : bitwiseOr '|' bitwiseXor
  | bitwiseXor
  ;

boolAnd
  : boolAnd OP10 bitwiseOr
  | bitwiseOr
  ;

boolOr
  : boolOr OP11 boolAnd
  | boolAnd
  ;

conditionExpression
  : boolOr '?' conditionExpression ':' conditionExpression
  | boolOr
  ;

assignExpression
  : conditionExpression '=' assignExpression
  | conditionExpression OP12 assignExpression
  | conditionExpression OP13 assignExpression
  | conditionExpression OP14 assignExpression
  | conditionExpression OP15 assignExpression
  | conditionExpression OP16 assignExpression
  | conditionExpression OP17 assignExpression
  | conditionExpression OP18 assignExpression
  | conditionExpression OP19 assignExpression
  | conditionExpression OP20 assignExpression
  | conditionExpression OP21 assignExpression
  | conditionExpression
  ;

commaExpression
  : commaExpression ',' assignExpression
  | assignExpression
  ;

expression
  : commaExpression
  ;

%%
#include "lex.yy.c"

int main(void){
  if(yyparse()==0){
    printf("parse is sucsessfull.\n");
  }else{
    return -1;
  }

  return 0;
}
