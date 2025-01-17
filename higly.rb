#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.14
# from Racc grammer file "".
#

require 'racc/parser.rb'

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

class Parser < Racc::Parser

module_eval(<<'...end higly_racc.y/module_eval...', 'higly_racc.y', 95)
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
  t = []

  f.each do |line|
    line.strip!
    until line.empty?
      case line
      when /\A<expression>/
        @q << [:EXP, $&]
      when /\A%action/
        @q << [:ACTION, $&]
      when /\A%assoc/
        @q << [:ASSOC, $&]
      when /\A%operator/
        @q << [:OPERATOR, $&]
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
        case $&
        when '_'
          @q << ['_', '_']
        when 'tree'
          @q << [:TREE, 'tree']
        when 'left'
          @q << [:LEFT, 'left']
        when 'right'
          @q << [:RIGHT, 'right']
        when 'nonassoc'
          @q << [:NONASSOC, 'nonassoc']
        else
          @q << [:IDENTIFIER, $&]
        end
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

  prename = "atom"
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

...end higly_racc.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    35,    35,    35,    34,    34,    34,    34,    34,     2,    33,
    33,    33,    33,    33,    10,    34,    38,    11,    12,    39,
    51,    33,     3,    39,    14,    19,     5,    20,    24,    25,
    26,    24,    25,    26,    15,    16,    17,    14,    22,    28,
    37,    35,    35,    43,    28,    47,    35 ]

racc_action_check = [
    19,    39,    47,    32,    40,    19,    39,    47,     0,    32,
    40,    19,    39,    47,     4,    48,    29,     4,     4,    29,
    49,    48,     1,    49,     4,    14,     3,    14,    16,    16,
    16,    20,    20,    20,    10,    11,    12,    13,    15,    17,
    28,    31,    35,    36,    37,    43,    46 ]

racc_action_pointer = [
     6,    22,   nil,    26,    11,   nil,   nil,   nil,   nil,   nil,
    30,    31,    32,    24,    11,    33,    18,    31,   nil,    -8,
    21,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    31,     1,
   nil,    33,   -10,   nil,   nil,    34,    26,    36,   nil,    -7,
    -9,   nil,   nil,    31,   nil,   nil,    38,    -6,     2,     5,
   nil,   nil ]

racc_action_default = [
   -30,   -30,    -2,   -30,   -30,    52,    -1,    -3,    -4,    -5,
   -30,   -30,   -30,   -16,   -30,   -30,   -30,   -30,   -15,   -30,
   -30,    -6,    -7,    -8,   -12,   -13,   -14,    -9,   -11,   -30,
   -19,   -21,   -30,   -26,   -27,   -28,   -30,   -30,   -17,   -30,
   -23,   -22,   -29,   -30,   -10,   -20,   -24,   -30,   -30,   -30,
   -25,   -18 ]

racc_goto_table = [
    29,    27,    41,     6,    40,    23,     1,     4,    42,    36,
    46,     7,    18,     8,     9,    21,    45,   nil,    50,    48,
   nil,    44,   nil,   nil,   nil,   nil,   nil,   nil,    49 ]

racc_goto_check = [
    11,     9,    13,     3,    14,     8,     1,     2,    14,     8,
    13,     4,     3,     5,     6,     7,    12,   nil,    13,    14,
   nil,     9,   nil,   nil,   nil,   nil,   nil,   nil,    11 ]

racc_goto_pointer = [
   nil,     6,     5,    -1,     7,     9,    10,     0,   -11,   -16,
   nil,   -19,   -23,   -30,   -27 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
    13,   nil,    30,    31,    32 ]

racc_reduce_table = [
  0, 0, :racc_error,
  3, 21, :_reduce_1,
  0, 22, :_reduce_none,
  2, 22, :_reduce_none,
  2, 22, :_reduce_none,
  2, 22, :_reduce_none,
  3, 25, :_reduce_6,
  1, 27, :_reduce_7,
  3, 24, :_reduce_8,
  3, 26, :_reduce_9,
  3, 29, :_reduce_10,
  1, 29, :_reduce_11,
  1, 28, :_reduce_12,
  1, 28, :_reduce_13,
  1, 28, :_reduce_14,
  2, 23, :_reduce_none,
  1, 23, :_reduce_none,
  4, 30, :_reduce_17,
  7, 30, :_reduce_18,
  1, 31, :_reduce_19,
  3, 31, :_reduce_20,
  1, 32, :_reduce_21,
  2, 32, :_reduce_22,
  2, 32, :_reduce_23,
  3, 32, :_reduce_24,
  5, 32, :_reduce_25,
  1, 33, :_reduce_26,
  1, 33, :_reduce_27,
  1, 34, :_reduce_28,
  2, 34, :_reduce_29 ]

racc_reduce_n = 30

racc_shift_n = 52

racc_token_table = {
  false => 0,
  :error => 1,
  :EXP => 2,
  :ACTION => 3,
  "=" => 4,
  :TREE => 5,
  :ASSOC => 6,
  :OPERATOR => 7,
  :S_LITERAL => 8,
  "," => 9,
  :NONASSOC => 10,
  :LEFT => 11,
  :RIGHT => 12,
  :IDENTIFIER => 13,
  ":" => 14,
  ";" => 15,
  "(" => 16,
  ")" => 17,
  "|" => 18,
  "_" => 19 }

racc_nt_base = 20

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
  "ACTION",
  "\"=\"",
  "TREE",
  "ASSOC",
  "OPERATOR",
  "S_LITERAL",
  "\",\"",
  "NONASSOC",
  "LEFT",
  "RIGHT",
  "IDENTIFIER",
  "\":\"",
  "\";\"",
  "\"(\"",
  "\")\"",
  "\"|\"",
  "\"_\"",
  "$start",
  "expression",
  "options",
  "expstmts",
  "dassoc",
  "action",
  "nonterm",
  "action_names",
  "assoc",
  "nonterms",
  "expstmt",
  "op_list",
  "op_def",
  "operand",
  "operator" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

module_eval(<<'.,.,', 'higly_racc.y', 4)
  def _reduce_1(val, _values, result)
     @opgroups.reverse! 
    result
  end
.,.,

# reduce 2 omitted

# reduce 3 omitted

# reduce 4 omitted

# reduce 5 omitted

module_eval(<<'.,.,', 'higly_racc.y', 13)
  def _reduce_6(val, _values, result)
     @action = val[2] 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 16)
  def _reduce_7(val, _values, result)
     result = :tree 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 19)
  def _reduce_8(val, _values, result)
     @default_assoc = val[2] 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 24)
  def _reduce_9(val, _values, result)
        val[2].each do |v|
      @nonterms[v] = 1
    end
  
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 30)
  def _reduce_10(val, _values, result)
     result = val[2] << val[0] 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 31)
  def _reduce_11(val, _values, result)
     result = [val[0]] 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 34)
  def _reduce_12(val, _values, result)
     result = :nonassoc
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 35)
  def _reduce_13(val, _values, result)
     result = :left 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 36)
  def _reduce_14(val, _values, result)
     result = :right 
    result
  end
.,.,

# reduce 15 omitted

# reduce 16 omitted

module_eval(<<'.,.,', 'higly_racc.y', 44)
  def _reduce_17(val, _values, result)
     @opgroups << OpGroup.new(val[0], @default_assoc, val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 46)
  def _reduce_18(val, _values, result)
     @opgroups << OpGroup.new(val[0], val[2], val[5]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 49)
  def _reduce_19(val, _values, result)
     result = [val[0]] 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 50)
  def _reduce_20(val, _values, result)
     result = val[0]<<val[2] 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 53)
  def _reduce_21(val, _values, result)
     result = Op.new(:nonterm, val) 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 54)
  def _reduce_22(val, _values, result)
     result = Op.new(:lunary, val)
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 55)
  def _reduce_23(val, _values, result)
     result = Op.new(:runary, val)
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 56)
  def _reduce_24(val, _values, result)
     result = Op.new(:binary, val)
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 57)
  def _reduce_25(val, _values, result)
     result = Op.new(:ternary, val)
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 61)
  def _reduce_26(val, _values, result)
     result = 0 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 62)
  def _reduce_27(val, _values, result)
     result = val[0] 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 66)
  def _reduce_28(val, _values, result)
     result = token_store(val[0]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'higly_racc.y', 67)
  def _reduce_29(val, _values, result)
     result = token_store(val[0]) + " " + val[1] 
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

end   # class Parser


parser = Parser.new
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
