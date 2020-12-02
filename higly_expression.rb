class Expression
  def initialize(operators, opclasses, acheck)
    @operators = operators
    @opclasses = opclasses
    @acheck = acheck
  end

  def make_lex
    code = "D			[0-9]\nL			[a-zA-Z_]\n"
    code += "%%\n"
    t = @operators.sort_by do |_, v|
      v =~ /\d+/
      $&.to_i
    end.to_h
    t.each do |key, value|
      code += "\"#{key}\"  { return(#{value}); }\n"
    end

    code += "{L}({L}|{D})*  { return (IDENTIFIER);}\n"
    code += "[1-9]{D}*  { return(INT_LITERAL); }\n"
    code += "\"0\"  { return(INT_LITERAL); }\n"
    code += "{D}+\".\"{D}+  { return(FLOAT_LITERAL); }\n"
    code += "L?\\\"(\\\\.|[^\\\\\"\\n])*\\\"  { return(STRING_LITERAL); }\n"

    code
  end

  def make_yacc_definition
    code = ''
    ops = {}
    nonassoc = []
    left = []
    right = []

    @opclasses.each do |item|
      opclass = if item.child.nil?
                  item
                else
                  item.child
                end
      case opclass.assoc
      when :nonassoc
        opclass.operators.each do |operator|
          operator.operators.each do |i|
            ops[i] = :nonassoc
          end
        end
      when :left
        opclass.operators.each do |operator|
          operator.operators.each do |i|
            ops[i] = :left
          end
        end
      when :right
        opclass.operators.each do |operator|
          operator.operators.each do |i|
            ops[i] = :right
          end
        end
      end
    end

    ops.each do |op, assoc|
      case assoc
      when :nonassoc
        nonassoc.push(@operators[op])
      when :left
        left.push(@operators[op])
      when :right
        right.push(@operators[op])
      end
    end

    if nonassoc.size != 0
      code += '%nonassoc'
      nonassoc.each_with_index do |op, i|
        code += " #{op}"
        if (i+1) % 5 == 0
          code += "\n%nonassoc"
        end
      end
      code += "\n"
    end

    if left.size != 0
      code += '%left'
      left.each_with_index do |op, i|
        code += " #{op}"
        if (i+1) % 5 == 0
          code += "\n%left"
        end
      end
      code += "\n"
    end

    if right.size != 0
      code += '%right'
      right.each_with_index do |op, i|
        code += " #{op}"
        if (i+1) % 5 == 0
          code += "\n%right"
        end
      end
      code += "\n"
    end

    code += "%token IDENTIFIER INT_LITERAL FLOAT_LITERAL STRING_LITERAL\n"

    if @acheck
      code += "%{\n"
      code += "#include <string.h>\n"
      code += "#include <stdlib.h>\n"
      code += "#include <stdio.h>\n"
      code += "#define YYSTYPE Node*\n"
      code += "#define CNUM 3\n"
      code += "\n"
      code += "typedef struct node {\n"
      code += "  char* name;\n"
      code += "  struct node* child[CNUM];\n"
      code += "} Node;\n\n"
      code += "char* dcode;\n"
      code += "int dcode_size;\n"
      code += "Node* tree;\n"
      code += "\n"
      code += "Node* makeNode(char* na, Node* c1, Node* c2, Node* c3){\n"
      code += "  Node *n;\n"
      code += "  n = (Node*)malloc(sizeof(Node));\n"
      code += "  n->name = (char*)malloc(strlen(na)*sizeof(char));\n"
      code += "  strcpy(n->name, na);\n"
      code += "  n->child[0] = c1;\n"
      code += "  n->child[1] = c2;\n"
      code += "  n->child[2] = c3;\n"
      code += "  return n;\n"
      code += "}\n"
      code += "\n"
      code += "int dcode_append(char* s){\n"
      code += "  dcode_size += strlen(s);\n"
      code += "  char* tmp;\n"
      code += "  tmp = (char*)realloc(dcode, sizeof(char) * (dcode_size+1));\n"
      code += "  if (tmp == NULL){\n"
      code += "	  free(dcode);\n"
      code += "    return -1;\n"
      code += "  }\n"
      code += "  dcode = tmp;\n"
      code += "  strcat(dcode, s);\n"
      code += "  return 0;\n"
      code += "}\n"
      code += "\n"
      code += "int drawGraph(Node* t){\n"
      code += "  static int symbol_num = 0;\n"
      code += "  char *child_name[CNUM];\n"
      code += "  char* tmp;\n"
      code += "  char* ctmp[CNUM];\n"
      code += "  int self_symbol_num = 0;\n"
      code += "  int child_symbol_num[3];\n"
      code += "  int child_num = 0;\n"
      code += "  int i = 0;\n"
      code += "  \n"
      code += "  if(t == NULL) return 0;\n"
      code += "  self_symbol_num = symbol_num;\n"
      code += "\n"
      code += "  for(i=0;i<CNUM;i++){\n"
      code += "    child_symbol_num[i] = ++symbol_num;\n"
      code += "    drawGraph(t->child[i]);\n"
      code += "  }\n"
      code += "\n"
      code += "  for(i=0;i<CNUM;i++){\n"
      code += "    if(t->child[i]){\n"
      code += "      child_name[i] = t->child[i]->name;\n"
      code += "      child_num++;\n"
      code += "    }\n"
      code += "  }\n"
      code += "\n"
      code += "  tmp = (char*)malloc(15*sizeof(char));\n"
      code += "  snprintf(tmp, 15, \"symbol%d\", self_symbol_num);\n"
      code += "  for(i=0;i<child_num;i++){\n"
      code += "    ctmp[i] = (char*)malloc(15*sizeof(char));\n"
      code += "    snprintf(ctmp[i], 15, \"symbol%d\", child_symbol_num[i]);\n"
      code += "  }\n"
      code += "\n"
      code += "  dcode_append(tmp);\n"
      code += "  if(child_num != 0){\n"
      code += "    dcode_append(\" -- \");\n"
      code += "    dcode_append(ctmp[0]);\n"
      code += "    if(child_num >= 2){\n"
      code += "      for(i=1;i<child_num;i++){\n"
      code += "        dcode_append(\", \");\n"
      code += "        dcode_append(ctmp[i]);\n"
      code += "      }\n"
      code += "    }\n"
      code += "  }\n"
      code += "  dcode_append(\";\\n\");\n"
      code += "  //\"symbol1 -- symbol2, symbol3;\"\n"
      code += "\n"
      code += "  if(child_num != 0){\n"
      code += "    dcode_append(tmp);\n"
      code += "    dcode_append(\"[label = \\\"\");\n"
      code += "    dcode_append(t->name);\n"
      code += "    dcode_append(\"\\\"];\\n\");\n"
      code += "    //\"symbol1 = [label = \"+\"];\"\n"
      code += "\n"
      code += "    for(i=0;i<child_num;i++){\n"
      code += "      dcode_append(ctmp[i]);\n"
      code += "      dcode_append(\"[label = \\\"\");\n"
      code += "      dcode_append(child_name[i]);\n"
      code += "      dcode_append(\"\\\"];\\n\");\n"
      code += "      //\"symbol2 = [label = \"identifier\"];\"\n"
      code += "    }\n"
      code += "  }\n"
      code += "\n"
      code += "  return 0;\n"
      code += "}\n"
      code += "%}\n"
    end

    code += "\n%%\n\n"
    code
  end

  def make_action(op_list)
    return '' if @acheck == false

    name = ''
    i = 1
    count = 0
    op_list.each do |x|
      name += x if x.instance_of?(String)
    end
    code = "  { $$ = makeNode(\"#{name}\""
    op_list.each do |x|
      if x.instance_of?(Integer)
        j = x
        j = 3 if x > 3
        while j > 0
          code += ", $#{i}"
          i += 1
          count += 1
          j -= 1
        end
      else
        i += 1
      end
    end
    i = 3 - count
    while i > 0
      i -= 1
      code += ', NULL'
    end
    code += '); }'
  end

  def make_yacc_rule
    code = "expression\n  : #{@opclasses.first.name}  { tree = $1; }\n;\n\n"
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
        codes[n.name].code += "  | #{n.child.name}"
        codes[n.name].code += make_action([n.child.name])
        codes[n.name].code += "\n"
        nonterm = n.child
      end

      # 演算子の記述
      nonterm.operators.each do |term|
        codes[nonterm.name].code += '  |'

        case term.kind
        when :left
          i = term.operand
          codes[nonterm.name].code += " #{@operators[term.operators[0]]}"
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
          codes[nonterm.name].code += make_action([term.operators[0], term.operand])
          codes[nonterm.name].code += "\n"

        when :right
          i = term.operand
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
          codes[nonterm.name].code += " #{@operators[term.operators[0]]}"
          codes[nonterm.name].code += make_action([term.operand, term.operators[0]])
          codes[nonterm.name].code += "\n"

        when :binary
          case nonterm.assoc
          when :nonassoc
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{@operators[term.operators[0]]}"

            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
          when :left
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{@operators[term.operators[0]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
          when :right
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{@operators[term.operators[0]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
          end
          codes[nonterm.name].code += make_action([1, term.operators[0], 1])
          codes[nonterm.name].code += "\n"

        when :ternary
          case nonterm.assoc
          when :nonassoc
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{@operators[term.operators[0]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{@operators[term.operators[1]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
          when :left
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{@operators[term.operators[0]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{@operators[term.operators[1]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
          when :right
            codes[nonterm.name].code += " #{codes[nonterm.name].prename}"
            codes[nonterm.name].code += " #{@operators[term.operators[0]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
            codes[nonterm.name].code += " #{@operators[term.operators[1]]}"
            codes[nonterm.name].code += " #{codes[nonterm.name].name}"
          end
          codes[nonterm.name].code += make_action([1, term.operators[0], 1, term.operators[1], 1])
          codes[nonterm.name].code += "\n"
        end
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

    code += "primaryExpression\n"
    primary_list = ["IDENTIFIER", "INT_LITERAL", "FLOAT_LITERAL", "STRING_LITERAL"]
    primary_list.each_with_index do |x, i|
      code += "  : #{x}" if i == 0
      code += "  | #{x}" if i != 0
      code += make_action([x]);
      code += "\n"
    end
    code += "  ;\n\n%%\n"

    code
  end

  def make_yacc_footer()
    code = "#include \"lex.yy.c\"\n\n"
    code += "int main(void){\n"
    code += "  if(yyparse()==0){\n"
    code += "    printf(\"parse is sucsessfull.\\n\");\n"
    code += "  }else{\n"
    code += "    return -1;\n  }\n\n"
    if @acheck
      code += "  dcode_size = 1;\n"
      code += "  dcode = (char*)calloc(1, sizeof(char));\n"
      code += "  dcode_append(\"graph type{\\n\");\n"
      code += "  dcode_append(\"dpi=\\\"200\\\";\\n\");\n"
      code += "  dcode_append(\"node [fontname=\\\"DejaVu Serif Italic\\\"];\\n\");\n"
      code += "  if(drawGraph(tree) == 0){\n"
      code += "    printf(\"file output complete.\\n\");\n"
      code += "  }else{\n"
      code += "    printf(\"file output error.\\n\");\n"
      code += "  }\n"
      code += "  dcode_append(\"}\");\n\n"
      code += "  FILE *fp;\n"
      code += "  char *filename = \"tree.dot\";\n"
      code += "  fp = fopen(filename, \"w\");\n"
      code += "  fputs(dcode, fp);\n"
      code += "  fclose(fp);\n\n"
    end
    code += "  return 0;\n"
    code += "}\n"
    code
  end
end
