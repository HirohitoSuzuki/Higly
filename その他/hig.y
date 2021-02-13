%token ++ -- ~ ! +
%token - ) ( * /
%token % << >> >>> <
%token > <= >= instanceof ==
%token =! & ^ | &&
%token || : ? = LeftHandSide
%token += -= *= /= %=
%token <<= >>= >>>= &= ^=
%token |=
%token IDENTIFIER INT_LITERAL FLOAT_LITERAL STRING_LITERAL

%%

primaryExpression
  : IDENTIFIER
  | INT_LITERAL
  | FLOAT_LITERAL
  | STRING_LITERAL
  | '(' expression ')'
  ;

PostfixExpression
  : Name
  | primaryExpression
  ;

PostFixExpression
  : PostIncrementExpression
  | PostDecrementExpression
  | PostfixExpression
  ;

PostIncrementExpression
  : PostFixExpression OP1
  ;

PostDecrementExpression
  : PostFixExpression OP2
  ;

UnaryExpressionNotPlusMinus
  : '~' UnaryExpression
  | '!' UnaryExpression
  | CastExpression
  | PostFixExpression
  ;

UnaryExpression
  : '+' UnaryExpression
  | '-' UnaryExpression
  | PreIncrementExpression
  | PreDecrementExpression
  | UnaryExpressionNotPlusMinus
  ;

PreIncrementExpression
  : OP1 UnaryExpression
  ;

PreDecrementExpression
  : OP2 UnaryExpression
  ;

CastExpression
  : '(' PrimitiveType DimsOpt ')' CastExpression
  | '(' expression ')' UnaryExpressionNotPlusMinus
  | '(' Name Dims ')' UnaryExpressionNotPlusMinus
  | UnaryExpression
  ;

MultiplecativeExpression
  : MultiplecativeExpression '*' CastExpression
  | MultiplecativeExpression '/' CastExpression
  | MultiplecativeExpression '%' CastExpression
  | CastExpression
  ;

AdditiveExpression
  : AdditiveExpression '+' MultiplecativeExpression
  | AdditiveExpression '-' MultiplecativeExpression
  | MultiplecativeExpression
  ;

ShiftExpression
  : ShiftExpression OP3 AdditiveExpression
  | ShiftExpression OP4 AdditiveExpression
  | ShiftExpression OP5 AdditiveExpression
  | AdditiveExpression
  ;

RelationalExpression
  : RelationalExpression '<' ShiftExpression
  | RelationalExpression '>' ShiftExpression
  | RelationalExpression OP6 ShiftExpression
  | RelationalExpression OP7 ShiftExpression
  | RelationalExpression INSTANCEOF ReferenceType
  | ShiftExpression
  ;

EqualityExpression
  : EqualityExpression OP8 RelationalExpression
  | EqualityExpression OP9 RelationalExpression
  | RelationalExpression
  ;

BitwiseAndExpression
  : BitwiseAndExpression '&' EqualityExpression
  | EqualityExpression
  ;

BitwiseXorExpression
  : BitwiseXorExpression '^' BitwiseAndExpression
  | BitwiseAndExpression
  ;

BitwiseOrExpression
  : BitwiseOrExpression '|' BitwiseXorExpression
  | BitwiseXorExpression
  ;

ConditionalAndExpression
  : ConditionalAndExpression OP10 BitwiseOrExpression
  | BitwiseOrExpression
  ;

ConditionalOrExpression
  : ConditionalOrExpression OP11 ConditionalAndExpression
  | ConditionalAndExpression
  ;

ConditionalExpression
  : ConditionalOrExpression '?' expression ':' ConditionalExpression
  | ConditionalOrExpression
  ;

AssignExpression
  : LEFTHANDSIDE '=' AssignExpression
  | LEFTHANDSIDE OP12 AssignExpression
  | LEFTHANDSIDE OP13 AssignExpression
  | LEFTHANDSIDE OP14 AssignExpression
  | LEFTHANDSIDE OP15 AssignExpression
  | LEFTHANDSIDE OP16 AssignExpression
  | LEFTHANDSIDE OP17 AssignExpression
  | LEFTHANDSIDE OP18 AssignExpression
  | LEFTHANDSIDE OP19 AssignExpression
  | LEFTHANDSIDE OP20 AssignExpression
  | LEFTHANDSIDE OP21 AssignExpression
  | LEFTHANDSIDE OP22 AssignExpression
  | ConditionalExpression
  ;

expression
  : AssignExpression
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
