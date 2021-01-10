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
    code = '%token'
    i = 0

    @operators.each do |_, v|
      if i >= 5
        code += "\n%token"
        i = 0
      end
      code += " #{v}"
      i += 1
    end
    code += "\n"

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
      code += "int code_append(char** s1, char* s2){\n"
      code += "  int size = strlen(*s1) + strlen(s2);\n"
      code += "  char* tmp;\n"
      code += "  tmp = (char*)realloc(*s1, sizeof(char) * (size+1));\n"
      code += "  if (tmp == NULL){\n"
      code += "	  free(*s1);\n"
      code += "    return -1;\n"
      code += "  }\n"
      code += "  *s1 = tmp;\n"
      code += "  strcat(*s1, s2);\n"
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
      code += "  code_append(&dcode, tmp);\n"
      code += "  if(child_num != 0){\n"
      code += "    code_append(&dcode, \" -- \");\n"
      code += "    code_append(&dcode, ctmp[0]);\n"
      code += "    if(child_num >= 2){\n"
      code += "      for(i=1;i<child_num;i++){\n"
      code += "        code_append(&dcode, \", \");\n"
      code += "        code_append(&dcode, ctmp[i]);\n"
      code += "      }\n"
      code += "    }\n"
      code += "  }\n"
      code += "  code_append(&dcode, \";\\n\");\n"
      code += "  //\"symbol1 -- symbol2, symbol3;\"\n"
      code += "\n"
      code += "  if(child_num != 0){\n"
      code += "    code_append(&dcode, tmp);\n"
      code += "    code_append(&dcode, \"[label = \\\"\");\n"
      code += "    code_append(&dcode, t->name);\n"
      code += "    code_append(&dcode, \"\\\"];\\n\");\n"
      code += "    //\"symbol1 = [label = \"+\"];\"\n"
      code += "\n"
      code += "    for(i=0;i<child_num;i++){\n"
      code += "      code_append(&dcode, ctmp[i]);\n"
      code += "      code_append(&dcode, \"[label = \\\"\");\n"
      code += "      code_append(&dcode, child_name[i]);\n"
      code += "      code_append(&dcode, \"\\\"];\\n\");\n"
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

    code = "primaryExpression\n"
    primary_list = ["IDENTIFIER", "INT_LITERAL", "FLOAT_LITERAL", "STRING_LITERAL"]
    primary_list.each_with_index do |x, i|
      if i == 0
        code += "  : #{x}"
      else
        code += "  | #{x}" if i != 0
      end
      code += make_action([x]);
      code += "\n"
    end
    code += "  | '(' expression ')'"
    code += make_action(["(", 1, ")"])
    code += "\n  ;\n\n"

    @opclasses.each do |opclass|
      code += "#{opclass.name}\n"
      if opclass.parent == nil
        name = opclass.name
      else
        name = opclass.parent
      end

      # 演算子の記述
      opclass.operators.each_with_index do |op, i|
        i == 0 ? code += "  :" : code += '  |'

        case op.kind
        when :nonterm
          code += " #{op.op_list[0]}"

        when :lunary
          code += " #{op.op_list[0]}"
          if op.op_list[1].instance_of?(Integer)
            case opclass.assoc
            when :nonassoc
              code += " #{opclass.prename}"
            else
              code += " #{name}"
            end
          else
            code += " #{op.op_list[1]}"
          end
          code += make_action([op.op_list[0], 1])

        when :runary
          if op.op_list[0].instance_of?(Integer)
            case opclass.assoc
            when :nonassoc
              code += " #{opclass.prename}"
            else
              code += " #{name}"
            end
          else
            code += " #{op.op_list[0]}"
          end
          code += " #{op.op_list[1]}"
          code += make_action([1, op.op_list[1]])

        when :binary
          case opclass.assoc
          when :nonassoc
            op1 = opclass.prename
            op2 = opclass.prename
          when :left
            op1 = name
            op2 = opclass.prename
          when :right
            op1 = opclass.prename
            op2 = name
          end

          code += op.op_list[0].instance_of?(Integer) ? " #{op1}" : " #{op.op_list[0]}"
          code += " #{op.op_list[1]}"
          code += op.op_list[2].instance_of?(Integer) ? " #{op2}" : " #{op.op_list[2]}"
          code += make_action([1, op.op_list[0], 1])

        when :ternary
          case opclass.assoc
          when :nonassoc
            op1 = opclass.prename
            op2 = opclass.prename
            op3 = opclass.prename
          when :left
            op1 = name
            op2 = name
            op3 = opclass.prename
          when :right
            op1 = opclass.prename
            op2 = name
            op3 = name
          end

          code += op.op_list[0].instance_of?(Integer) ? " #{op1}" : " #{op.op_list[0]}"
          code += " #{op.op_list[1]}"
          code += op.op_list[2].instance_of?(Integer) ? " #{op2}" : " #{op.op_list[2]}"
          code += " #{op.op_list[3]}"
          code += op.op_list[4].instance_of?(Integer) ? " #{op3}" : " #{op.op_list[4]}"
          code += make_action([1, op.op_list[0], 1, op.op_list[1], 1])
        end
        code += "\n"
      end
      code += "  ;\n\n"
    end
    
    code += "expression\n  : #{@opclasses.last.name}"
    code += "{ tree = $1; }" if @acheck
    code += "\n  ;\n\n%%\n"
  end

  def make_yacc_footer()
    code = "#include \"lex.yy.c\"\n\n"
    code += "int main(void){\n"
    code += "  if(yyparse()==0){\n"
    code += "    printf(\"parse is sucsessfull.\\n\");\n"
    code += "  }else{\n"
    code += "    return -1;\n  }\n\n"
    if @acheck
      code += "  dcode = (char*)calloc(1, sizeof(char));\n"
      code += "  code_append(&dcode, \"graph type{\\n\");\n"
      code += "  code_append(&dcode, \"dpi=\\\"200\\\";\\n\");\n"
      code += "  code_append(&dcode, \"node [fontname=\\\"DejaVu Serif Italic\\\"];\\n\");\n"
      code += "  if(drawGraph(tree) == 0){\n"
      code += "    printf(\"file output complete.\\n\");\n"
      code += "  }else{\n"
      code += "    printf(\"file output error.\\n\");\n"
      code += "  }\n"
      code += "  code_append(&dcode, \"}\");\n\n"
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
