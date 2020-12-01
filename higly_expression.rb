class Expression

  def initialize(operators, opclasses)
    @operators = operators
    @opclasses = opclasses
  end

  def make_lex()
    code = "%%\n"
    t = @operators.sort_by do |_, v|
      v =~ /\d+/
      $&.to_i
    end.to_h
    t.each do |key, value|
      code += "\"#{key}\"  { return(#{value}); }\n"
    end
    code
  end

  def make_yacc_definition()
    code = ''
    ops = {}
    nonassoc = []
    left = []
    right = []

    code += "#include <string.h>\n"
    code += "#include <stdlib.h>\n"
    code += "#include <stdio.h>\n\n"
    code += "typedef struct node {\n"
    code += "  char* name;\n"
    code += "  struct node* left;"
    code += "  struct node* right;"
    code += "} Node;\n\n"
    code += "Node* tree;\n"
    code += "char* code;\n"
    code += "int code_size = 0;\n\n"
    code += "Node* makeNode(char* na, Node* l, Node* r){\n"
    code += "  Node *n;\n"
    code += "  n = (Node*)malloc(sizeof(Node));\n"
    code += "  n->name = (char*)malloc(strlen(na)*sizeof(char));\n"
    code += "  strcpy(n->name, na);\n"
    code += "  n->left = l;\n"
    code += "  n->right = r;\n"
    code += "  return n\n;"
    code += "}\n\n"
    code += "int code_append(char* s){\n"
    code += "  code_size += strlen(s);\n"
    code += "  char* tmp;\n"
    code += "  tmp = (char*)realloc(code, sizeof(char) * code_size+1);\n"
    code += "  if (tmp == NULL){\n"
    code += "	  free(code);\n"
    code += "    return -1;\n"
    code += "  }\n"
    code += "  code = tmp;\n"
    code += "  strcat(code, s);\n"
    code += "  return 0;\n"
    code += "}\n\n"
    code += "int drawGraph(Node* t){\n"
    code += "  static int symbol_num = 0;\n"
    code += "  char *lname;\n"
    code += "  char *rname;\n"
    code += "  int self_num = symbol_num;\n"
    code += "  int left_num = ++symbol_num;\n"
    code += "  int right_num = ++symbol_num;\n"
    code += "  int children_num;\n"
    code += "  if(t == NULL) return 0;\n"
    code += "  drawGraph(t->left);\n"
    code += "  drawGraph(t->right);\n\n"
    code += "  if(t->left == NULL){\n"
    code += "    children_num = 0;\n"
    code += "  }else{\n"
    code += "    lname = t->left->name;\n"
    code += "    if(t->right == NULL){\n"
    code += "      children_num = 1;\n"
    code += "   }else{\n"
    code += "      rname = t->right->name;\n"
    code += "      children_num = 2;\n"
    code += "    }\n"
    code += "  }\n\n"
    code += "  char tmp1[15], tmp2[15], tmp3[15];\n\n"
    code += "  snprintf(tmp1, 15, \"symbol%d\", self_num);\n"
    code += "  if(children_num != 0){\n"
    code += "    snprintf(tmp2, 15, \"symbol%d\", left_num);\n"
    code += "    if(children_num == 2){\n"
    code += "      snprintf(tmp3, 15, \"symbol%d\", right_num);\n"
    code += "    }\n"
    code += "  }\n\n"
    code += "  code_append(tmp1);\n"
    code += "  if(children_num != 0){\n"
    code += "    code_append(\" -- \");\n"
    code += "    code_append(tmp2);\n"
    code += "    if(children_num == 2){\n"
    code += "      code_append(\", \");\n"
    code += "      code_append(tmp3);\n"
    code += "    }\n"
    code += "  }\n"
    code += "  code_append(\";\n\");\n"
    code += "  //\"symbol1 -- symbol2, symbol3;\"\n\n"
    code += "  if(children_num != 0){\n"
    code += "    code_append(tmp1);\n"
    code += "    code_append(\"[label = \\\"\");\n"
    code += "    code_append(t->name);\n"
    code += "    code_append(\"\\\"];\\n\");\n"
    code += "    //\"symbol1 = [label = \"+\"];\"\n\n"
    code += "    code_append(tmp2);\n"
    code += "    code_append(\"[label = \\\"\");\n"
    code += "    code_append(lname);\n"
    code += "    code_append(\"\\\"];\\n\");\n"
    code += "    //\"symbol2 = [label = \"identifier\"];\"\n\n"
    code += "    if(children_num == 2){\n"
    code += "      code_append(tmp3);\n"
    code += "      code_append(\"[label = \\\"\");\n"
    code += "      code_append(rname);\n"
    code += "      code_append(\"\\\"];\\n\");\n"
    code += "      //\"symbol3 = [label = \"intliteral\"];\"\n"
    code += "    }\n"
    code += "  }\n\n"
    code += "  return 0;\n"
    code += "}\n"

    @opclasses.each do |item|
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

  def make_yacc_rule()
    code = ''
    codes = {}

    @opclasses.each do |n|
      if n.child.nil?
        codes[n.name] = OpCode.new(n.name, n.prename, :parent)
      else
        codes[n.name] = OpCode.new(n.name, n.prename, :parent)
        codes[n.child.name] = OpCode.new(n.name, n.prename, :child)
      end
    end

    @opclasses.each do |n|
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
              codes[nonterm.name].code += " #{@operators[op]}"
            end
          end

        when 2
          case nonterm.assoc
          when :nonassoc
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{@operators[term.op_list[1]]}"

            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
          when :left
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{@operators[term.op_list[1]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
          when :right
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{@operators[term.op_list[1]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
          end

        when 3
          case nonterm.assoc
          when :nonassoc
            term.op_list.each do |op|
              codes[nonterm.name].code += if op.instance_of?(Integer)
                                            " #{codes[nonterm.name].prename}"
                                          else
                                            " #{@operators[op]}"
                                          end
            end
          when :left
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{@operators[term.op_list[1]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{@operators[term.op_list[3]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
          when :right
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{@operators[term.op_list[1]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{@operators[term.op_list[3]]}"
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
