#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.14
# from Racc grammer file "".
#

require 'racc/parser.rb'

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

class HiglyParser < Racc::Parser

module_eval(<<'...end higly_racc.y/module_eval...', 'higly_racc.y', 138)
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

...end higly_racc.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    13,    26,    27,    28,    22,    31,    11,    12,    25,    21,
    30,    22,    22,    22,    22,    22,    21,    21,    21,    21,
    21,    15,    16,    17,    15,    16,    17,    15,    16,    17,
    41,    28,    50,    28,    52,    28,     3,     4,     7,     8,
     9,     7,    18,    24,    29,    32,    36,    37,    39,    40,
    42,    39,    44,    45,    48,    49 ]

racc_action_check = [
     7,    18,    19,    19,    12,    22,     7,     7,    18,    12,
    22,    25,    28,    39,    40,    48,    25,    28,    39,    40,
    48,     8,     8,     8,    13,    13,    13,    26,    26,    26,
    33,    33,    47,    47,    51,    51,     0,     1,     2,     3,
     4,     5,    11,    14,    21,    23,    29,    30,    31,    32,
    34,    36,    37,    38,    42,    44 ]

racc_action_pointer = [
    34,    37,    30,    36,    40,    33,   nil,    -3,    16,   nil,
   nil,    34,    -4,    19,    39,   nil,   nil,   nil,    -2,    -9,
   nil,    36,    -3,    41,   nil,     3,    22,   nil,     4,    38,
    39,    40,    39,    19,    46,   nil,    43,    39,    40,     5,
     6,   nil,    44,   nil,    47,   nil,   nil,    21,     7,   nil,
   nil,    23,   nil ]

racc_action_default = [
   -22,   -22,   -22,   -22,   -22,    -1,    -7,   -22,   -22,    53,
    -6,   -22,   -22,   -22,   -22,    -3,    -4,    -5,   -22,   -22,
   -12,   -22,   -22,   -22,    -2,   -22,   -22,   -10,   -22,   -14,
   -16,   -20,   -22,   -22,   -22,   -13,   -20,   -18,   -22,   -22,
   -22,    -8,   -22,   -15,   -22,   -17,   -21,   -22,   -22,   -19,
   -11,   -22,    -9 ]

racc_goto_table = [
    19,    14,    38,    35,     1,     6,    23,    43,    10,     2,
     5,   nil,   nil,    33,    46,   nil,   nil,   nil,   nil,    34,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    47,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,    51 ]

racc_goto_check = [
     6,     4,     8,     7,     1,     5,     4,     8,     5,     2,
     3,   nil,   nil,     6,     7,   nil,   nil,   nil,   nil,     4,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,     6,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,     6 ]

racc_goto_pointer = [
   nil,     4,     9,     8,    -7,     3,   -12,   -25,   -29 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    20,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  2, 15, :_reduce_1,
  4, 16, :_reduce_2,
  1, 18, :_reduce_3,
  1, 18, :_reduce_4,
  1, 18, :_reduce_5,
  2, 17, :_reduce_6,
  1, 17, :_reduce_7,
  6, 19, :_reduce_8,
  9, 19, :_reduce_9,
  4, 19, :_reduce_10,
  7, 19, :_reduce_11,
  1, 20, :_reduce_12,
  3, 20, :_reduce_13,
  2, 21, :_reduce_14,
  4, 21, :_reduce_15,
  2, 21, :_reduce_16,
  4, 21, :_reduce_17,
  3, 21, :_reduce_18,
  5, 21, :_reduce_19,
  0, 22, :_reduce_20,
  2, 22, :_reduce_21 ]

racc_reduce_n = 22

racc_shift_n = 53

racc_token_table = {
  false => 0,
  :error => 1,
  :EXP => 2,
  "(" => 3,
  ")" => 4,
  :NONASSOC => 5,
  :LEFT => 6,
  :RIGHT => 7,
  :IDENTIFIER => 8,
  "." => 9,
  ":" => 10,
  ";" => 11,
  "|" => 12,
  :S_LITERAL => 13 }

racc_nt_base = 14

racc_use_result_var = true

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "EXP",
  "\"(\"",
  "\")\"",
  "NONASSOC",
  "LEFT",
  "RIGHT",
  "IDENTIFIER",
  "\".\"",
  "\":\"",
  "\";\"",
  "\"|\"",
  "S_LITERAL",
  "$start",
  "expression",
  "exp_head",
  "expstmts",
  "assoc",
  "expstmt",
  "expfig",
  "operators",
  "operands" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

module_eval(<<'.,.,', 'higly_racc.y', 5)
  def _reduce_1(val, _values, result)
          val[1].last.prename = "primaryExpression"
      @opclasses = val[1]
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 10)
  def _reduce_2(val, _values, result)
     @default_assoc = val[2] 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 13)
  def _reduce_3(val, _values, result)
     result = :nonassoc 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 14)
  def _reduce_4(val, _values, result)
     result = :left 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 15)
  def _reduce_5(val, _values, result)
     result = :right 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 20)
  def _reduce_6(val, _values, result)
          val[0].last.prename = val[1].name
      result = val[0].push(val[1])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 25)
  def _reduce_7(val, _values, result)
          result = Array.new
      result.push(val[0])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 32)
  def _reduce_8(val, _values, result)
          result = OpClassRegistry.new(val[0], 0, [OpRegistry.new(1, [1])])
      result.child = OpClassRegistry.new(val[2], @default_assoc, val[4])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 37)
  def _reduce_9(val, _values, result)
          result = OpClassRegistry.new(val[0], 0, [OpRegistry.new(1, [1])])
      result.child = OpClassRegistry.new(val[2], val[4], val[7])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 42)
  def _reduce_10(val, _values, result)
          result = OpClassRegistry.new(val[0], @default_assoc, val[2])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 46)
  def _reduce_11(val, _values, result)
          result = OpClassRegistry.new(val[0], val[2], val[5])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 52)
  def _reduce_12(val, _values, result)
          result = Array.new
      result.push(val[0])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 57)
  def _reduce_13(val, _values, result)
          result = val[0].push(val[2])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 63)
  def _reduce_14(val, _values, result)
          token_register(val[0])
      result = OpRegistry.new(1, [@operators[val[0]], 1])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 68)
  def _reduce_15(val, _values, result)
          token_register(val[0])
      result = OpRegistry.new(1, [@operators[val[0]],2+val[3]])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 73)
  def _reduce_16(val, _values, result)
          token_register(val[1])
      result = OpRegistry.new(1, [1, @operators[val[1]]])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 78)
  def _reduce_17(val, _values, result)
          token_register(val[3])
      result = OpRegistry.new(1, [2+val[2], @operators[val[3]]])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 83)
  def _reduce_18(val, _values, result)
          token_register(val[1])
      result = OpRegistry.new(2, [1, @operators[val[1]], 1])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 88)
  def _reduce_19(val, _values, result)
          token_register(val[1])
      token_register(val[3])
      result = OpRegistry.new(3, [1, @operators[val[1]], 1, @operators[val[3]], 1])
    
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 94)
  def _reduce_20(val, _values, result)
    result = 0
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 95)
  def _reduce_21(val, _values, result)
    result = 1 + val[1]
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

end   # class HiglyParser


parser = HiglyParser.new
exp = Expression.new
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

  lex = exp.make_lex(parser.operators)
  yacc = exp.make_yacc_header(parser.opclasses)
  yacc += exp.make_yacc_inner(parser.opclasses)

  f1.puts(lex)
  f2.puts(yacc)
  f1.close
  f2.close
else
  puts "file is nothing. input code."
end
