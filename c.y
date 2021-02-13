%token ']' '[' ')' '(' '.'
%token OP1 OP2 OP3 '&' '*'
%token '+' '-' '~' '!' SIZEOF
%token '/' '%' OP4 OP5 '<'
%token '>' OP6 OP7 OP8 OP9
%token '^' '|' OP10 OP11 '?'
%token ':' '=' OP12 OP13 OP14
%token OP15 OP16 OP17 OP18 OP19
%token OP20 OP21 ','
%token IDENTIFIER FLOAT_LITERAL INT_LITERAL STRING_LITERAL
%token INT

%%

expression
  : comma_expression
  ;

comma_expression
  : comma_expression ',' assignment_expression
  | assignment_expression
  ;

assignment_expression
  : unary_expression '=' assignment_expression
  | unary_expression OP12 assignment_expression
  | unary_expression OP13 assignment_expression
  | unary_expression OP14 assignment_expression
  | unary_expression OP15 assignment_expression
  | unary_expression OP16 assignment_expression
  | unary_expression OP17 assignment_expression
  | unary_expression OP18 assignment_expression
  | unary_expression OP19 assignment_expression
  | unary_expression OP20 assignment_expression
  | unary_expression OP21 assignment_expression
  | conditional_expression
  ;

conditional_expression
  : logical_or_expression '?' expression ':' conditional_expression
  | logical_or_expression
  ;

logical_or_expression
  : logical_or_expression OP11 logical_and_expression
  | logical_and_expression
  ;

logical_and_expression
  : logical_and_expression OP10 inclusive_or_expression
  | inclusive_or_expression
  ;

inclusive_or_expression
  : inclusive_or_expression '|' exclusive_or_expression
  | exclusive_or_expression
  ;

exclusive_or_expression
  : exclusive_or_expression '^' and_expression
  | and_expression
  ;

and_expression
  : and_expression '&' equality_expression
  | equality_expression
  ;

equality_expression
  : equality_expression OP8 relational_expression
  | equality_expression OP9 relational_expression
  | relational_expression
  ;

relational_expression
  : relational_expression '<' shift_expression
  | relational_expression '>' shift_expression
  | relational_expression OP6 shift_expression
  | relational_expression OP7 shift_expression
  | shift_expression
  ;

shift_expression
  : shift_expression OP4 additive_expression
  | shift_expression OP5 additive_expression
  | additive_expression
  ;

additive_expression
  : additive_expression '+' multiplecative_expression
  | additive_expression '-' multiplecative_expression
  | multiplecative_expression
  ;

multiplecative_expression
  : multiplecative_expression '*' cast_expression
  | multiplecative_expression '/' cast_expression
  | multiplecative_expression '%' cast_expression
  | cast_expression
  ;

cast_expression
  : '(' type_name ')' cast_expression
  | unary_expression
  ;

type_name
  : INT
  ;

unary_expression
  : OP2 unary_expression
  | OP3 unary_expression
  | '&' cast_expression
  | '*' cast_expression
  | '+' cast_expression
  | '-' cast_expression
  | '~' cast_expression
  | '!' cast_expression
  | SIZEOF unary_expression
  | SIZEOF '(' type_name ')'
  | postfix_expression
  ;

postfix_expression
  : postfix_expression '[' expression ']'
  | postfix_expression '(' ')'
  | postfix_expression '(' argument_expression_list ')'
  | postfix_expression '.' IDENTIFIER
  | postfix_expression OP1 IDENTIFIER
  | postfix_expression OP2
  | postfix_expression OP3
  | atom
  ;

argument_expression_list
  : assignment_expression
  | argument_expression_list ',' assignment_expression
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
