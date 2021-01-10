%token OP1 OP2 ']' '[' ')'
%token '(' '.' OP3 SIZEOF '&'
%token '*' '+' '-' '~' '!'
%token '/' '%' OP4 OP5 '<'
%token '>' OP6 OP7 OP8 OP9
%token '^' '|' OP10 OP11 '?'
%token ':' '=' OP12 OP13 OP14
%token OP15 OP16 OP17 OP18 OP19
%token OP20 OP21 ','
%token INT FLOAT DOUBLE CHAR
%token IDENTIFIER INT_LITERAL FLOAT_LITERAL STRING_LITERAL
%start expression

%%

type_name
  : INT
  | FLOAT
  | DOUBLE
  | CHAR
  ;

argumentExpressionList
	: assignExpression
	| argumentExpressionList ',' assignExpression
	;

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
