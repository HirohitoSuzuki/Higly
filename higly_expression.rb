class Expression
  def initialize(expr_tokens, opgroups, action)
    @expr_tokens = expr_tokens
    @opgroups = opgroups
    @action = action
  end

  def make_lex
    code = "%%\n"
    t = @expr_tokens.sort_by do |_, v|
      v =~ /\AOP(\d+)/
      $1.to_i
    end.to_h
    t.each do |key, value|
      code += "\"#{key}\"  { return(#{value}); }\n"
    end

    code += "[a-zA-Z_]([a-zA-Z_]|[0-9])*  { return (IDENTIFIER);}\n"
    code += "0                            { return(INT_LITERAL); }\n"
    code += "[1-9][0-9]*                  { return(INT_LITERAL); }\n"
    code += "[0-9]+\".\"[0-9]+              { return(FLOAT_LITERAL); }\n"
    code += "\\\"[^\\\"\\n]*\\\"                 { return(STRING_LITERAL); }\n"

    code
  end

  def make_yacc_definition
    code = '%token'
    i = 0

    @expr_tokens.each do |_, v|
      if i >= 5
        code += "\n%token"
        i = 0
      end
      code += " #{v}"
      i += 1
    end
    code += "\n"

    code += "%token IDENTIFIER FLOAT_LITERAL INT_LITERAL STRING_LITERAL\n"

    if @action == :tree
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
      code += "int codeAppend(char** s1, char* s2){\n"
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
      code += "  codeAppend(&dcode, tmp);\n"
      code += "  if(child_num != 0){\n"
      code += "    codeAppend(&dcode, \" -- \");\n"
      code += "    codeAppend(&dcode, ctmp[0]);\n"
      code += "    if(child_num >= 2){\n"
      code += "      for(i=1;i<child_num;i++){\n"
      code += "        codeAppend(&dcode, \", \");\n"
      code += "        codeAppend(&dcode, ctmp[i]);\n"
      code += "      }\n"
      code += "    }\n"
      code += "  }\n"
      code += "  codeAppend(&dcode, \";\\n\");\n"
      code += "  //\"symbol1 -- symbol2, symbol3;\"\n"
      code += "\n"
      code += "  if(child_num != 0){\n"
      code += "    codeAppend(&dcode, tmp);\n"
      code += "    codeAppend(&dcode, \"[label = \\\"\");\n"
      code += "    codeAppend(&dcode, t->name);\n"
      code += "    codeAppend(&dcode, \"\\\"];\\n\");\n"
      code += "    //\"symbol1 = [label = \"+\"];\"\n"
      code += "\n"
      code += "    for(i=0;i<child_num;i++){\n"
      code += "      codeAppend(&dcode, ctmp[i]);\n"
      code += "      codeAppend(&dcode, \"[label = \\\"\");\n"
      code += "      codeAppend(&dcode, child_name[i]);\n"
      code += "      codeAppend(&dcode, \"\\\"];\\n\");\n"
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

  def make_yacc_action(op_list)
    return '' if @action != :tree

    name = ''
    i = 1
    count = 0
    op_list.each do |x|
      if x.instance_of?(String)
        if @expr_tokens.key?(x)
          name += @expr_tokens[x]
        else
          name += x
        end
      end
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

    code = "expression\n  : #{@opgroups.first.name}"
    code += "{ tree = $1; }" if @action == :tree
    code += "\n  ;\n\n"

    @opgroups.each do |opgroup|
      code += "#{opgroup.name}\n"
      name = opgroup.name

      # 演算子の記述
      opgroup.operators.each_with_index do |op, i|
        i == 0 ? code += "  :" : code += '  |'

        case op.kind
        when :nonterm
          code += " #{op.op_list[0]}"

        when :lunary
          code += " #{op.op_list[0]}"
          if op.op_list[1].instance_of?(Integer)
            case opgroup.assoc
            when :nonassoc
              code += " #{opgroup.prename}"
            else
              code += " #{name}"
            end
          else
            code += " #{op.op_list[1]}"
          end
          code += make_yacc_action([op.op_list[0], 1])

        when :runary
          if op.op_list[0].instance_of?(Integer)
            case opgroup.assoc
            when :nonassoc
              code += " #{opgroup.prename}"
            else
              code += " #{name}"
            end
          else
            code += " #{op.op_list[0]}"
          end
          code += " #{op.op_list[1]}"
          code += make_yacc_action([1, op.op_list[1]])

        when :binary
          case opgroup.assoc
          when :nonassoc
            op1 = opgroup.prename
            op2 = opgroup.prename
          when :left
            op1 = name
            op2 = opgroup.prename
          when :right
            op1 = opgroup.prename
            op2 = name
          end

          code += op.op_list[0].instance_of?(Integer) ? " #{op1}" : " #{op.op_list[0]}"
          code += " #{op.op_list[1]}"
          code += op.op_list[2].instance_of?(Integer) ? " #{op2}" : " #{op.op_list[2]}"
          code += make_yacc_action([1, op.op_list[1], 1])

        when :ternary
          case opgroup.assoc
          when :nonassoc
            op1 = opgroup.prename
            op2 = opgroup.prename
            op3 = opgroup.prename
          when :left
            op1 = name
            op2 = name
            op3 = opgroup.prename
          when :right
            op1 = opgroup.prename
            op2 = name
            op3 = name
          end

          code += op.op_list[0].instance_of?(Integer) ? " #{op1}" : " #{op.op_list[0]}"
          code += " #{op.op_list[1]}"
          code += op.op_list[2].instance_of?(Integer) ? " #{op2}" : " #{op.op_list[2]}"
          code += " #{op.op_list[3]}"
          code += op.op_list[4].instance_of?(Integer) ? " #{op3}" : " #{op.op_list[4]}"
          code += make_yacc_action([1, op.op_list[1], 1, op.op_list[3], 1])
        end
        code += "\n"
      end
      code += "  ;\n\n"
    end
    
    code += "atom\n"
    atom_list = ["IDENTIFIER", "INT_LITERAL", "FLOAT_LITERAL", "STRING_LITERAL"]
    atom_list.each_with_index do |x, i|
      if i == 0
        code += "  : #{x}"
      else
        code += "  | #{x}" if i != 0
      end
      code += make_yacc_action([x]);
      code += "\n"
    end
    code += "  | '(' expression ')'"
    code += make_yacc_action(["(", 1, ")"])
    code += "\n  ;\n\n"
    
  end

  def make_yacc_subroutine()
    code = "%%\n#include \"lex.yy.c\"\n\n"
    code += "int main(void){\n"
    code += "  if(yyparse()==0){\n"
    code += "    printf(\"parse is successfull.\\n\");\n"
    code += "  }else{\n"
    code += "    return -1;\n  }\n\n"
    if @action == :tree
      code += "  dcode = (char*)calloc(1, sizeof(char));\n"
      code += "  codeAppend(&dcode, \"graph type{\\n\");\n"
      code += "  if(drawGraph(tree) == 0){\n"
      code += "    printf(\"file output complete.\\n\");\n"
      code += "  }else{\n"
      code += "    printf(\"file output error.\\n\");\n"
      code += "  }\n"
      code += "  codeAppend(&dcode, \"}\");\n\n"
      code += "  FILE *fp;\n"
      code += "  fp = fopen(\"tree.dot\", \"w\");\n"
      code += "  fputs(dcode, fp);\n"
      code += "  fclose(fp);\n\n"
    end
    code += "  return 0;\n"
    code += "}\n"
    code
  end
end
