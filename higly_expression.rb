class Expression
  def make_lex(operators)
    code = "%%\n"
    t = operators.sort_by do |_, v|
      v =~ /\d+/
      $&.to_i
    end.to_h
    t.each do |key, value|
      code += "\"#{key}\"  { return(#{value}); }\n"
    end
    code
  end

  def make_yacc_header(opclasses)
    code = ''
    ops = {}
    nonassoc = []
    left = []
    right = []

    opclasses.each do |item|
      opclass = if item.child.nil?
                  item
                else
                  item.child
                end
      case opclass.assoc
      when :nonassoc
        opclass.operators.each do |operator|
          operator.op_list.each do |i|
            ops[i] = :nonassoc if i.instance_of?(String)
          end
        end
      when :left
        opclass.operators.each do |operator|
          operator.op_list.each do |i|
            ops[i] = :left if i.instance_of?(String)
          end
        end
      when :right
        opclass.operators.each do |operator|
          operator.op_list.each do |i|
            ops[i] = :right if i.instance_of?(String)
          end
        end
      end
    end

    ops.each do |op, assoc|
      case assoc
      when :nonassoc
        nonassoc.push(op)
      when :left
        left.push(op)
      when :right
        right.push(op)
      end
    end

    if nonassoc.size != 0
      code += '%nonassoc'
      nonassoc.each do |op|
        code += " #{op}"
      end
      code += "\n"
    end

    if left.size != 0
      code += '%left'
      left.each do |op|
        code += " #{op}"
      end
      code += "\n"
    end

    if right.size != 0
      code += '%right'
      right.each do |op|
        code += " #{op}"
      end
      code += "\n"
    end
    code += "\n%%\n\n"
    code
  end

  def make_yacc_inner(opclasses)
    code = ''
    codes = {}

    opclasses.each do |n|
      if n.child.nil?
        codes[n.name] = OpCode.new(n.name, n.prename, :parent)
      else
        codes[n.name] = OpCode.new(n.name, n.prename, :parent)
        codes[n.child.name] = OpCode.new(n.name, n.prename, :child)
      end
    end

    opclasses.each do |n|
      if n.child.nil?
        nonterm = n
      else
        codes[n.name].code += "  | #{n.child.name}\n"
        nonterm = n.child
      end

      # 演算子の記述
      nonterm.operators.each do |term|
        codes[nonterm.name].code += '  |'

        case term.kind
        when 1
          term.op_list.each do |op|
            if op.instance_of?(Integer)
              i = op
              if nonterm.assoc == :nonassoc
                while i > 0
                  codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
                  i -= 1
                end
              else
                while i > 0
                  codes[nonterm.name].code += " #{codes[nonterm.name].name}"
                  i -= 1
                end
              end
            else
              codes[nonterm.name].code += " #{op}"
            end
          end

        when 2
          case nonterm.assoc
          when :nonassoc
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{term.op_list[1]}"

            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
          when :left
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{term.op_list[1]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
          when :right
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{term.op_list[1]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
          end

        when 3
          case nonterm.assoc
          when :nonassoc
            term.op_list.each do |op|
              codes[nonterm.name].code += if op.instance_of?(Integer)
                                            " #{codes[nonterm.name].prename}"
                                          else
                                            " #{op}"
                                          end
            end
          when :left
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{term.op_list[1]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{term.op_list[3]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
          when :right
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{term.op_list[1]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{term.op_list[3]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
          end
        end
        codes[nonterm.name].code += "\n"
      end
    end

    codes.each do |name, i|
      if i.kind == :child
        code += "#{name}\n  : "
        code += i.code.delete_prefix('  | ')
      else
        code += "#{name}\n  : #{i.prename}\n"
        code += i.code
      end
      code += "  ;\n\n"
    end

    code
  end
end
