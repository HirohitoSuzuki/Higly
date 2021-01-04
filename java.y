%token ++ -- ~ ! +
%token - * / % <<
%token >> >>> < > <=
%token >= instanceof == =! &
%token ^ | && || :
%token ? = += -= *=
%token /= %= <<= >>= >>>=
%token &= ^= |=
%token IDENTIFIER INT_LITERAL FLOAT_LITERAL STRING_LITERAL

%%

primaryExpression
  : IDENTIFIER
  | INT_LITERAL
  | FLOAT_LITERAL
  | STRING_LITERAL
  | '(' expression ')'
  ;

PostFixExpression
  : Name
  | PostIncrementExpression
  | PostDecrementExpression
  | primaryExpression
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
  | CastExpression(後で書く)
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

MultiplecativeExpression
  : MultiplecativeExpression '*' UnaryExpression
  | MultiplecativeExpression '/' UnaryExpression
  | MultiplecativeExpression '%' UnaryExpression
  | UnaryExpression
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
  : LeftHandSide '=' AssignExpression
  | LeftHandSide OP12 AssignExpression
  | LeftHandSide OP13 AssignExpression
  | LeftHandSide OP14 AssignExpression
  | LeftHandSide OP15 AssignExpression
  | LeftHandSide OP16 AssignExpression
  | LeftHandSide OP17 AssignExpression
  | LeftHandSide OP18 AssignExpression
  | LeftHandSide OP19 AssignExpression
  | LeftHandSide OP20 AssignExpression
  | LeftHandSide OP21 AssignExpression
  | LeftHandSide OP22 AssignExpression
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
