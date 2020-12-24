class HiglyParser

rule
expression
  : EXP options expstmts
  {
    tmp = []
    prename = "primaryExpression"
    @opclasses.each do |_,v|
      tmp.append(v)
    end
    tmp.reverse!.each do |v|
      if v.prename == nil
        v.prename = prename
        v.op_list << Op.new(:nonterm, [prename])
        @opclasses[v.name] = v
        prename = v.name
      end
    end
    tmp = @opclasses
    @opclasses = []
    tmp.each do |_, v|
      @opclasses << v
    end
    tmp = @operators.invert
    @operators = tmp
  }
  
options
  :
  | dassoc options
  | action options
  | nonterm options 
 
action
  : ACTION '=' action_names { val[2] == :tree ? @tree_flag = true : nil }

action_names
  : TREE  { result = :tree }

dassoc
  : ASSOC '=' assoc  { @default_assoc = val[2] }

nonterm
  : NONTERM '=' nonterms
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
  : expstmt expstmts  { result = val[0] + val[1] }
  | expstmt  { result = val[0] }

expstmt
  : IDENTIFIER '.' IDENTIFIER ':' op_list ';'
  {
    if @opclasses.key?(val[0])
      @opclasses[val[0]].op_list << Op.new(:nonterm, [val[2]])
    else
      @opclasses[val[0]] = OpClass.new(val[0], @default_assoc, [Op.new(:nonterm, [val[2]])])
    end
    child = OpClass.new(val[2], @default_assoc, val[4])
    child.prename = val[0]
    child.parent = val[0]
    @opclasses[val[2]] = child
  }
  | IDENTIFIER '.' IDENTIFIER '(' assoc ')' ':' op_list ';'
  {
    if @opclasses.key?(val[0])
      @opclasses[val[0]].op_list << Op.new(:nonterm, [val[2]])
    else
      @opclasses[val[0]] = OpClass.new(val[0], val[4], [Op.new(:nonterm, [val[2]])])
    end
    child = OpClass.new(val[2], val[4], val[7])
    child.prename = val[0]
    child.parent = val[0]
    @opclasses[val[2]] = child
  }
  | IDENTIFIER ':' op_list ';'
    { @opclasses[val[0]] = OpClass.new(val[0], @default_assoc, val[2]) }
  | IDENTIFIER '(' assoc ')' ':' op_list ';'
    { @opclasses[val[0]] = OpClass.new(val[0], val[2], val[5]) }

op_list
  : op_def  { result = [val[0]] }
  | op_list '|' op_def  { result = val[0]<<val[2] }

op_def
  : operator  { result = Op.new(:nonterm, [val[0]]) }
  | operator IDENTIFIER  { result = Op.new(:lunary, [val[0]])}
  | IDENTIFIER operator  { result = Op.new(:runary, [val[1]])}
  | IDENTIFIER operator IDENTIFIER  { result = Op.new(:binary, [val[1]])}
  | IDENTIFIER operator IDENTIFIER operator IDENTIFIER  { result = Op.new(:ternary, [val[1],val[3]])}

operator
  : S_LITERAL  { result = token_register(val[0]) }
  | S_LITERAL operator  { result = token_register(val[0]) + " " + val[1] }

---- header
require './higly_expression'

class OpClass
  def initialize(name, assoc, op_list)
    @name = name
    @assoc = assoc
    @op_list = op_list
    @prename = nil
    @parent = nil
  end

  attr_reader :assoc
  attr_accessor :name, :prename, :op_list, :parent
end

class Op
  def initialize(kind, operators)
    @kind = kind
    @operators = operators
  end

  attr_reader :kind, :operators
end

class OpCode
  def initialize(name, prename, kind)
    @name = name
    @prename = prename
    @kind = kind
    @code = ""
  end

  attr_reader :name, :prename, :kind
  attr_accessor :code
end

---- inner
attr_reader :opclasses, :operators, :tree_flag, :nonterms

def parse(f)
  @q = []
  @lineno = 1
  @termno = 1
  @opclasses = Hash.new
  @operators = Hash.new
  @nonterms = Hash.new
  @default_assoc = 0

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
      when /\A%nonterm/
        @q << [:NONTERM, $&]
      when /\Aright/
        @q << [:RIGHT, $&]
      when /\Anonassoc/
        @q << [:NONASSOC, $&]
      when /\A-action/
        @q << [:ACHECK, $&]
      when /\A%\+/
        @q << [:PPLUS, $&]
      when /\A@/
        @q << [:OP, $&]
      when /\A(0|[1-9]\d*)\.\d+/
        @q << [:NUM, $&]
      when /\A(0|[1-9])\d*/
        @q << [:NUM, $&]
      when /\A"([[^"]&&\S]*)"/
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
      when /\A./
      end
      line = $'
    end
    @q << [:EOL, '']
  end
  @q << [false, '$']
  do_parse
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

def token_register(t)
  if @nonterms.key?(t)
    return t
  elsif @operators.key?(t)
    return @operators[t]
  else
    if t =~ /\A\w+/ then
      token = t.upcase
    elsif t.size == 1 then
      token = "\'#{t}\'"
    else
      token = "OP#{@termno}"
      @operators.key?(t) ? nil : @termno += 1
    end
    @operators[t] = token
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

  
  exp = Expression.new(parser.operators, parser.opclasses, parser.tree_flag)

  lex = exp.make_lex()
  yacc = exp.make_yacc_definition()
  yacc += exp.make_yacc_rule()
  yacc += exp.make_yacc_footer()

  f1.puts(lex)
  f2.puts(yacc)
  f1.close
  f2.close
else
  puts "file is nothing. input code."
end