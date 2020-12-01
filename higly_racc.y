class HiglyParser
rule
  expression
    : exp_head expstmts
    {
      val[1].last.prename = "primaryExpression"
      @opclasses = val[1]
    }
  
  exp_head
    : EXP '(' assoc ')' { @default_assoc = val[2] }

  assoc
    : NONASSOC { result = :nonassoc }
    | LEFT { result = :left }
    | RIGHT { result = :right }

  expstmts
    : expstmts expstmt
    {
      val[0].last.prename = val[1].name
      result = val[0].push(val[1])
    }
    | expstmt
    {
      result = Array.new
      result.push(val[0])
    }

  expstmt
    : IDENTIFIER '.' IDENTIFIER ':' expfig ';'
    {
      result = OpClassRegistry.new(val[0], 0, [OpRegistry.new(1, [1])])
      result.child = OpClassRegistry.new(val[2], @default_assoc, val[4])
    }
    | IDENTIFIER '.' IDENTIFIER '(' assoc ')' ':' expfig ';'
    {
      result = OpClassRegistry.new(val[0], 0, [OpRegistry.new(1, [1])])
      result.child = OpClassRegistry.new(val[2], val[4], val[7])
    }
    | IDENTIFIER ':' expfig ';'
    {
      result = OpClassRegistry.new(val[0], @default_assoc, val[2])
    }
    | IDENTIFIER '(' assoc ')' ':' expfig ';'
    {
      result = OpClassRegistry.new(val[0], val[2], val[5])
    }

  expfig
    : operators
    {
      result = Array.new
      result.push(val[0])
    }
    | expfig '|' operators
    {
      result = val[0].push(val[2])
    }

  operators
    : S_LITERAL IDENTIFIER
    {
      token_register(val[0])
      result = OpRegistry.new(1, [val[0], 1])
    }
    | S_LITERAL IDENTIFIER IDENTIFIER operands
    {
      token_register(val[0])
      result = OpRegistry.new(1, [val[0],2+val[3]])
    }
    | IDENTIFIER S_LITERAL
    {
      token_register(val[1])
      result = OpRegistry.new(1, [1, val[1]])
    }
    | IDENTIFIER IDENTIFIER operands S_LITERAL
    {
      token_register(val[3])
      result = OpRegistry.new(1, [2+val[2], val[3]])
    }
    | IDENTIFIER S_LITERAL IDENTIFIER
    {
      token_register(val[1])
      result = OpRegistry.new(2, [1, val[1], 1])
    }
    | IDENTIFIER S_LITERAL IDENTIFIER S_LITERAL IDENTIFIER
    {
      token_register(val[1])
      token_register(val[3])
      result = OpRegistry.new(3, [1, val[1], 1, val[3], 1])
    }

  operands
    : {result = 0}
    | IDENTIFIER operators {result = 1 + val[1]}

end

---- header
require './higly_expression'

class OpClassRegistry
  def initialize(name, assoc, operators)
    @name = name
    @assoc = assoc
    @operators = operators
    @prename = nil
    @child = nil
  end

  attr_reader :assoc, :operators
  attr_accessor :name, :prename, :child
end

class OpRegistry
  def initialize(kind, op_list)
    @kind = kind
    @op_list = op_list
  end

  attr_reader :kind, :op_list
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
attr_reader :opclasses, :operators

def parse(f)
  @q = []
  @lineno = 1
  @termno = 1
  @operators = Hash.new
  @default_assoc = 0

  f.each do |line|
    line.strip!
    until line.empty?
      case line
      when /\A%expression/
        @q << [:EXP, $&]
      when /\Aleft/
        @q << [:LEFT, $&]
      when /\Aright/
        @q << [:RIGHT, $&]
      when /\Anonassoc/
        @q << [:NONASSOC, $&]
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
      when /\A;/
        @q << [';', $&]
      when /\A:/
        @q << [':', $&]
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
  if t =~ /\A\w+/ then
    @operators[t] = t.upcase
  elsif t.size == 1 then
    @operators[t] = "\'#{t}\'"
  else
    @operators[t] = "OP#{@termno}"
    @termno += 1
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

  
  exp = Expression.new(parser.operators, parser.opclasses)

  lex = exp.make_lex()
  yacc = exp.make_yacc_definition()
  yacc += exp.make_yacc_rule()

  f1.puts(lex)
  f2.puts(yacc)
  f1.close
  f2.close
else
  puts "file is nothing. input code."
end

