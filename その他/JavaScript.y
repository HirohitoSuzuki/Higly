%token ']' EXPRESSION '[' '.' NEW
%token OP1 OP2 '!' '~' '+'
%token '-' TYPEOF VOID DELETE AWAIT
%token OP3 '*' '/' '%' OP4
%token OP5 OP6 '<' '>' OP7
%token OP8 IN INSTANCEOF OP9 OP10
%token OP11 OP12 '&' '^' '|'
%token OP13 OP14 ':' '?' '='
%token OP15 OP16 OP17 OP18 OP19
%token OP20 OP21 OP22 OP23 OP24
%token OP25 YIELD ','
%token IDENTIFIER INT_LITERAL FLOAT_LITERAL STRING_LITERAL

%%

primaryExpression
  : IDENTIFIER
  | INT_LITERAL
  | FLOAT_LITERAL
  | STRING_LITERAL
  | '(' expression ')'
  ;

MemberExpression
  : MemberExpression '[' EXPRESSION ']'
  | MemberExpression '.' IdentifierName(todo)
  | MemberExpression TemplateLiteral(todo)
  | SuperProperty(todo)
  | MetaProperty(todo)
  | newArguments(todo)
  | primaryExpression
  ;

NewExpression
  : NEW NewExpression
  | MemberExpression
  ;

LeftHandSideExpression
  : CallExpression(todo)
  | OptionalExpression(todo)
  | NewExpression
  ;

UpdateExpression
  : LeftHandSideExpression OP1
  | LeftHandSideExpression OP2
  | OP1 UnaryExpression
  | OP2 UnaryExpression
  | LeftHandSideExpression
  ;

UnaryExpression
  : '!' UnaryExpression
  | '~' UnaryExpression
  | '+' UnaryExpression
  | '-' UnaryExpression
  | TYPEOF UnaryExpression
  | VOID UnaryExpression
  | DELETE UnaryExpression
  | AWAIT UnaryExpression
  | UpdateExpression
  ;

ExponentiationExpression
  : UpdateExpression OP3 ExponentiationExpression
  | UnaryExpression
  ;

MultiplicativeExpression
  : MultiplicativeExpression '*' ExponentiationExpression
  | MultiplicativeExpression '/' ExponentiationExpression
  | MultiplicativeExpression '%' ExponentiationExpression
  | ExponentiationExpression
  ;

AdditiveExpression
  : AdditiveExpression '+' MultiplicativeExpression
  | AdditiveExpression '-' MultiplicativeExpression
  | MultiplicativeExpression
  ;

ShiftExpression
  : ShiftExpression OP4 AdditiveExpression
  | ShiftExpression OP5 AdditiveExpression
  | ShiftExpression OP6 AdditiveExpression
  | AdditiveExpression
  ;

RelationalExpression
  : RelationalExpression '<' ShiftExpression
  | RelationalExpression '>' ShiftExpression
  | RelationalExpression OP7 ShiftExpression
  | RelationalExpression OP8 ShiftExpression
  | RelationalExpression IN ShiftExpression
  | RelationalExpression INSTANCEOF ShiftExpression
  | ShiftExpression
  ;

EqualityExpression
  : EqualityExpression OP9 RelationalExpression
  | EqualityExpression OP10 RelationalExpression
  | EqualityExpression OP11 RelationalExpression
  | EqualityExpression OP12 RelationalExpression
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
  : ConditionalAndExpression OP13 BitwiseOrExpression
  | BitwiseOrExpression
  ;

ConditionalOrExpression
  : ConditionalOrExpression OP14 ConditionalAndExpression
  | ConditionalAndExpression
  ;

ShortCircuitExpression
  : CoalesceExpression(todo)
  | ConditionalOrExpression
  ;

ConditionalExpression
  : ConditionalExpression '?' AssignmentExpression ':' AssignmentExpression
  | ShortCircuitExpression
  ;

AssignExpression
  : ArrowFunction(todo)
  | AsyncArrowFunction(todo)
  | LeftHandSideExpression '=' AssignExpression
  | LeftHandSideExpression OP15 AssignExpression
  | LeftHandSideExpression OP16 AssignExpression
  | LeftHandSideExpression OP17 AssignExpression
  | LeftHandSideExpression OP18 AssignExpression
  | LeftHandSideExpression OP19 AssignExpression
  | LeftHandSideExpression OP20 AssignExpression
  | LeftHandSideExpression OP21 AssignExpression
  | LeftHandSideExpression OP22 AssignExpression
  | LeftHandSideExpression OP23 AssignExpression
  | LeftHandSideExpression OP24 AssignExpression
  | LeftHandSideExpression OP25 AssignExpression
  | YieldExpression
  | ConditionalExpression
  ;

YieldExpression
  : YIELD
  | YIELD AssignExpression
  | YIELD '*' AssignExpression
  ;

CommaExpression
  : CommaExpression ',' AssignExpression
  | AssignExpression
  ;

expression
  : CommaExpression
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
