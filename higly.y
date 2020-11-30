%nonassoc '<' '>' OP15 OP16
%left ',' '?' ':' OP11 OP12 '|' '^' '&' OP13 OP14 '+' '-' '*' '/' '%' OP17 OP18 OP19 SIZEOF '~' '!' OP20 OP21 AWAIT
%right '=' OP1 OP2 OP3 OP4 OP5 OP6 OP7 OP8 OP9 OP10
%token IDENTIFIER

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
  | OP18 unaryExpression
  | OP19 unaryExpression
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

primaryExpression
  : IDENTIFIER
  ;

%%
#include "lex.yy.c"
int main(void){
	//yydebug = 1;
	int a = yyparse();
	if(a==0) printf("yyparse ok.\n");
	return 0;
}