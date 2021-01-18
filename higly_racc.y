class HiglyParser

rule
expression
  : EXP options expstmts
  
options
  :
  | dassoc options
  | action options
  | nonterm options 
 
action
  : ACTION '=' action_names { @action = val[2] }

action_names
  : TREE  { result = :tree }

dassoc
  : ASSOC '=' assoc  { @default_assoc = val[2] }

nonterm
  : OPERATOR '=' nonterms
  {
    val[2].each do |v|
      @nonterms[v] = 1
    end
  }

nonterms
  : S_LITERAL ',' nonterms  { result = val[2] << val[0] }
  | S_LITERAL { result = [val[0]] }

assoc
  : NONASSOC  { result = :nonassoc}
  | LEFT  { result = :left }
  | RIGHT  { result = :right }

expstmts
  : expstmts expstmt
  | expstmt

expstmt
  : IDENTIFIER ':' op_list ';'
    { @opgroups << OpGroup.new(val[0], @default_assoc, val[2]) }
  | IDENTIFIER '(' assoc ')' ':' op_list ';'
    { @opgroups << OpGroup.new(val[0], val[2], val[5]) }

op_list
  : op_def  { result = [val[0]] }
  | op_list '|' op_def  { result = val[0]<<val[2] }

op_def
  : operand  { result = Op.new(:nonterm, val) }
  | operator operand  { result = Op.new(:lunary, val)}
  | operand operator  { result = Op.new(:runary, val)}
  | operand operator operand  { result = Op.new(:binary, val)}
  | operand operator operand operator operand  { result = Op.new(:ternary, val)}
  ;

operand
  : '_'  { result = 0 }
  | IDENTIFIER  { result = val[0] }
  ;

operator
  : S_LITERAL  { result = token_store(val[0]) }
  | S_LITERAL operator  { result = token_store(val[0]) + " " + val[1] }

---- header
require './higly_expression'

class OpGroup
  def initialize(name, assoc, operators)
    @name = name
    @assoc = assoc
    @operators = operators
    @prename = nil
  end

  attr_reader :assoc
  attr_accessor :name, :prename, :operators
end

class Op
  def initialize(kind, op_list)
    @kind = kind
    @op_list = op_list
  end

  attr_reader :kind, :op_list
end

---- inner
attr_reader :opgroups, :expr_tokens, :action, :nonterms

def parse(f)
  @q = []
  @lineno = 1
  @termno = 1
  @opgroups = []
  @expr_tokens = Hash.new
  @nonterms = Hash.new
  @default_assoc = :left
  @action = :true

  f.each do |line|
    line.strip!
    until line.empty?
      case line
      when /\A<expression>/
        @q << [:EXP, $&]
      when /\Aleft/
        @q << [:LEFT, $&]
      when /\Atree/
        @q << [:TREE, $&]
      when /\A%action/
        @q << [:ACTION, $&]
      when /\A%assoc/
        @q << [:ASSOC, $&]
      when /\A%operator/
        @q << [:OPERATOR, $&]
      when /\Aright/
        @q << [:RIGHT, $&]
      when /\Anonassoc/
        @q << [:NONASSOC, $&]
      when /\A_/
        @q << ['_', $&]
      when /\A@/
        @q << [:OP, $&]
      when /\A'([[^']&&\S]*)'/
        @q << [:S_LITERAL, $1]
      when /\A\(/
        @q << ['(', $&]
      when /\A\)/
        @q << [')', $&]
      when /\A\./
        @q << ['.', $&]
      when /\A,/
        @q << [',', $&]
      when /\A;/
        @q << [';', $&]
      when /\A:/
        @q << [':', $&]
      when /\A=/
        @q << ['=', $&]
      when /\A\|/
        @q << ['|', $&]
      when /\A[a-zA-Z_]\w*/
        @q << [:IDENTIFIER, $&]
      when /\A\S+/
        @q << [:OTHER, $&]
      when /\A\s+/
      end
      line = $'
    end
    @q << [:EOL, '']
  end
  @q << [false, '$']
  do_parse

  prename = "primaryExpression"
  tmp = []
  @opgroups.each do |v|
    v.prename = prename
    v.operators << Op.new(:nonterm, [prename])
    tmp << v
    prename = v.name
  end
  @opgroups = tmp.reverse

  puts "parse is successfull."
end

def next_token
  l = @q.shift
  while l[0] == :EOL do
    @lineno += 1
    l = @q.shift
  end
  return l
end

def on_error(t, v, values)
  raise Racc::ParseError, "line #{@lineno}: syntax error on #{v.inspect}."
end

def token_store(t)
  if @nonterms.key?(t)
    return t
  elsif @expr_tokens.key?(t)
    return @expr_tokens[t]
  else
    if t =~ /\A\w+/ then
      token = t.upcase
    elsif t.size == 1 then
      token = "\'#{t}\'"
    else
      token = "OP#{@termno}"
      @expr_tokens.key?(t) ? nil : @termno += 1
    end
    @expr_tokens[t] = token
    return token
  end
end

---- footer

parser = HiglyParser.new
if ARGV[0] then
  File.open(ARGV[0]) do |f|
    parser.parse f
  end

  if ARGV[1] then
    f1 = File.open("#{ARGV[1]}.l", "w")
    f2 = File.open("#{ARGV[1]}.y", "w")
  else
    f1 = File.open("higly.l", "w")
    f2 = File.open("higly.y", "w")
  end

  
  exp = Expression.new(parser.expr_tokens, parser.opgroups, parser.action)

  lex = exp.make_lex()
  yacc = exp.make_yacc_definition()
  yacc += exp.make_yacc_rule()
  yacc += exp.make_yacc_subroutine()

  f1.puts(lex)
  f2.puts(yacc)
  f1.close
  f2.close
else
  puts "file is nothing. input code."
end