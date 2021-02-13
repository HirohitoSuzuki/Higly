%token ']' '[' '.' NEW OP1
%token OP2 DELETE VOID TYPEOF '+'
%token '-' '~' '!' AWAIT OP3
%token '*' '/' '%' OP4 OP5
%token OP6 '<' '>' OP7 OP8
%token INSTANCEOF IN OP9 OP10 OP11
%token OP12 '&' '^' '|' OP13
%token OP14 '?' ':' '=' OP15
%token OP16 OP17 OP18 OP19 OP20
%token OP21 OP22 OP23 OP24 OP25
%token OP26 OP27 OP28 ','
%token IDENTIFIER FLOAT_LITERAL INT_LITERAL STRING_LITERAL

%%

expression
  : commaExpression
  ;

commaExpression
  : commaExpression ',' assignmentExpression
  | assignmentExpression
  ;

assignmentExpression
  : yieldExpression_TODO
  | arrowFunction_TODO
  | asyncArrowFunction_TODO
  | leftHandSideExpression '=' assignmentExpression
  | leftHandSideExpression OP15 assignmentExpression
  | leftHandSideExpression OP16 assignmentExpression
  | leftHandSideExpression OP17 assignmentExpression
  | leftHandSideExpression OP18 assignmentExpression
  | leftHandSideExpression OP19 assignmentExpression
  | leftHandSideExpression OP20 assignmentExpression
  | leftHandSideExpression OP21 assignmentExpression
  | leftHandSideExpression OP22 assignmentExpression
  | leftHandSideExpression OP23 assignmentExpression
  | leftHandSideExpression OP24 assignmentExpression
  | leftHandSideExpression OP25 assignmentExpression
  | leftHandSideExpression OP26 assignmentExpression
  | leftHandSideExpression OP27 assignmentExpression
  | leftHandSideExpression OP28 assignmentExpression
  | conditionalExpression
  ;

conditionalExpression
  : shortCircuitExpression '?' assignmentExpression ':' assignmentExpression
  | shortCircuitExpression
  ;

shortCircuitExpression
  : coalesceExpression_TODO
  | logicalOrExpression
  ;

logicalOrExpression
  : logicalOrExpression OP14 logicalAndExpression
  | logicalAndExpression
  ;

logicalAndExpression
  : logicalAndExpression OP13 bitwiseOrExpression
  | bitwiseOrExpression
  ;

bitwiseOrExpression
  : bitwiseOrExpression '|' bitwiseXorExpression
  | bitwiseXorExpression
  ;

bitwiseXorExpression
  : bitwiseXorExpression '^' bitwiseAndExpression
  | bitwiseAndExpression
  ;

bitwiseAndExpression
  : bitwiseAndExpression '&' equalityExpression
  | equalityExpression
  ;

equalityExpression
  : equalityExpression OP9 relationalExpression
  | equalityExpression OP10 relationalExpression
  | equalityExpression OP11 relationalExpression
  | equalityExpression OP12 relationalExpression
  | relationalExpression
  ;

relationalExpression
  : relationalExpression '<' shiftExpression
  | relationalExpression '>' shiftExpression
  | relationalExpression OP7 shiftExpression
  | relationalExpression OP8 shiftExpression
  | relationalExpression INSTANCEOF shiftExpression
  | relationalExpression IN shiftExpression
  | shiftExpression
  ;

shiftExpression
  : shiftExpression OP4 additiveExpression
  | shiftExpression OP5 additiveExpression
  | shiftExpression OP6 additiveExpression
  | additiveExpression
  ;

additiveExpression
  : additiveExpression '+' multiplicativeExpression
  | additiveExpression '-' multiplicativeExpression
  | multiplicativeExpression
  ;

multiplicativeExpression
  : multiplicativeExpression '*' exponentiationExpression
  | multiplicativeExpression '/' exponentiationExpression
  | multiplicativeExpression '%' exponentiationExpression
  | exponentiationExpression
  ;

exponentiationExpression
  : updateExpression OP3 exponentiationExpression
  | unaryExpression
  ;

unaryExpression
  : DELETE unaryExpression
  | VOID unaryExpression
  | TYPEOF unaryExpression
  | '+' unaryExpression
  | '-' unaryExpression
  | '~' unaryExpression
  | '!' unaryExpression
  | AWAIT unaryExpression
  | updateExpression
  ;

updateExpression
  : leftHandSideExpression OP1
  | leftHandSideExpression OP2
  | OP1 unaryExpression
  | OP2 unaryExpression
  | leftHandSideExpression
  ;

leftHandSideExpression
  : callExpression_TODO
  | optionalExpression_TODO
  | newExpression
  ;

newExpression
  : NEW newExpression
  | memberExpression
  ;

memberExpression
  : memberExpression '[' expression ']'
  | memberExpression '.' identifierName_TODO
  | template_TODO
  | superProperty_TODO
  | metaProperty_TODO
  | newArguments_TODO
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
