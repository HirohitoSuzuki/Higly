%token ++ -- ] [ )
%token ( . -> } {
%token , sizeof & * +
%token - ~ ! / %
%token << >> < > <=
%token >= == =! ^ |
%token && || : ? =
%token += -= *= /= %=
%token <<= >>= &= ^= |=
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
  | postfixExpression '.' IDENTIFIER
  | postfixExpression OP3 IDENTIFIER
  | '(' type_name ')' '{' initializerList '}'
  | '(' type_name ')' '{' initializerList ',' '}'
  | primaryExpression
  ;

unaryExpression
  : OP1 unaryExpression
  | OP2 unaryExpression
  | SIZEOF '(' type_name ')'
  | SIZEOF unaryExpression
  | '&' castExpression
  | '*' castExpression
  | '+' castExpression
  | '-' castExpression
  | '~' castExpression
  | '!' castExpression
  | postfixExpression
  ;

castExpression
  : '(' type_name ')' castExpression
  | unaryExpression
  ;

multplecativeExpression
  : multplecativeExpression '*' castExpression
  | multplecativeExpression '/' castExpression
  | multplecativeExpression '%' castExpression
  | castExpression
  ;

additiveExpression
  : additiveExpression '+' multplecativeExpression
  | additiveExpression '-' multplecativeExpression
  | multplecativeExpression
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

equaltiveExpression
  : equaltiveExpression OP8 relationalExpression
  | equaltiveExpression OP9 relationalExpression
  | relationalExpression
  ;

bitwiseAnd
  : bitwiseAnd '&' equaltiveExpression
  | equaltiveExpression
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
  : boolOr '?' expression ':' conditionExpression
  | boolOr
  ;

assignExpression
  : unaryExpression '=' assignExpression
  | unaryExpression OP12 assignExpression
  | unaryExpression OP13 assignExpression
  | unaryExpression OP14 assignExpression
  | unaryExpression OP15 assignExpression
  | unaryExpression OP16 assignExpression
  | unaryExpression OP17 assignExpression
  | unaryExpression OP18 assignExpression
  | unaryExpression OP19 assignExpression
  | unaryExpression OP20 assignExpression
  | unaryExpression OP21 assignExpression
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
