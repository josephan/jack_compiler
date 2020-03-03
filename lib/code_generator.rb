require_relative "./vm_writer.rb"
require_relative "./symbol_table.rb"

class CodeGenerator
  def initialize(compilation_engine)
    @compilation_engine = compilation_engine
    @tree = compilation_engine.tree
    @symbol_table = SymbolTable.new
    @vm_writer = VMWriter.new(compilation_engine.source_filepath)
    @klass_name = nil
    @label_counter = 0
  end

  def run
    # set class name
    @klass_name = tree[0][:type] == "class" && tree[0][:body][1][:body]

    # generate symbol table
    class_body = tree[0][:body]
    define_class_symbol_table(class_body)

    # generate code - subroutines
    compile_subroutines(class_body)
  end

  def compile_subroutines(class_body)
    subroutine_decs = class_body
      .select { |child| child[:type] == "subroutineDec" }
      .map { |child| child[:body] }

    subroutine_decs.each do |subroutine_dec|
      # create symbol table
      symbol_table.start_subroutine
      define_subroutine_symbol_table_for_arguments(subroutine_dec)
      subroutine_type = subroutine_dec[0][:body]
      body = subroutine_dec.find { |child| child[:type] == "subroutineBody" }[:body]
      define_subroutine_symbol_table_for_locals(subroutine_type, body)

      # write function
      compile_subroutine(subroutine_dec)
    end
  end

  def compile_subroutine(subroutine_dec)
    subroutine_type = subroutine_dec[0][:body]
    subroutine_name = subroutine_dec[2][:body]
    n_locals = symbol_table.var_count("local")

    vm_writer.write_function("#{klass_name}.#{subroutine_name}", n_locals)

    if subroutine_type == "constructor"
      block_count = symbol_table.var_count(field)
      vm_writer.write_push('constant', block_count)
      vm_writer.write_call('Memory.alloc', 1)
      vm_writer.write_pop('pointer', 0)
    end

    statements = subroutine_dec
      .find { |child| child[:type] == "subroutineBody" }[:body]
      .find { |child| child[:type] == "statements" }

    compile_statements(statements)
  end

  def compile_statements(statements)
    statements[:body].each do |statement|
      compile_statement(statement)
    end
  end

  def compile_statement(statement)
    case statement[:type]
    when "letStatement"
      compile_let(statement)
    when "ifStatement"
      compile_if(statement)
    when "whileStatement"
      compile_while(statement)
    when "doStatement"
      compile_do(statement)
    when "returnStatement"
      compile_return(statement)
    end
  end

  def compile_let(statement)
    name = statement[:body][1][:body]
    # compile expression
    compile_expression(statement[:body][3])
    # pop expression to variable
    kind = symbol_table.kind_of(name)
    index = symbol_table.index_of(name)
    vm_writer.write_pop(kind, index)
  end

  def compile_if(statement)
    expression = statement[:body][2]
    statements = statement[:body][5]
    else_statements = statement[:body][9]
    label_1 = generate_label
    label_2 = generate_label

    compile_expression(expression)
    vm_writer.write_arithmetic('not')
    vm_writer.write_if(label_1)
    compile_statements(statements)
    vm_writer.write_goto(label_2)
    vm_writer.write_label(label_1)
    compile_statements(else_statements) if else_statements
    vm_writer.write_label(label_2)
  end

  def generate_label
    @label_counter += 1
    return "#{@klass_name}-label-#{@label_counter}"
  end

  def compile_while(statement)
    expression = statement[:body][2]
    statements = statement[:body][5]
    label_1 = generate_label
    label_2 = generate_label
    vm_writer.write_label(label_1)
    compile_expression(expression)
    vm_writer.write_arithmetic('not')
    vm_writer.write_if(label_2)
    compile_statements(statements)
    vm_writer.write_goto(label_1)
    vm_writer.write_label(label_2)
  end

  def compile_do(statement)
    tokens = statement[:body][1..-2]
    compile_subroutine_call(tokens)
    vm_writer.write_pop("temp", 0)
  end

  def compile_return(statement)
    if statement[:body].length == 2
      vm_writer.write_push('constant', 0)
      vm_writer.write_return
    else
      compile_expression(statement[:body][1])
      vm_writer.write_return
    end
  end

  def compile_expression(expression)
    if expression[:body].count == 1
      term = expression[:body][0]
      compile_term(term)
    elsif expression[:body].count > 2
      compile_term(expression[:body][0])
      compile_term(expression[:body][2])
      compile_op(expression[:body][1])

      if expression[:body].count > 3
        expression[3..-1].each_slice(2) do |op, term|
          compile_term(term)
          compile_op(op)
        end
      end
    end
  end

  def compile_term(term)
    if term[:body].length == 1
      if term[:body][0][:type] == "integerConstant"
        vm_writer.write_push("constant", term[:body][0][:body])
      elsif term[:body][0][:type] == "keyword"
        compile_keyword_constant(term[:body][0][:body])
      elsif term[:body][0][:type] == "identifier"
        name = term[:body][0][:body]
        segment = symbol_table.kind_of(name)
        index = symbol_table.index_of(name)
        vm_writer.write_push(segment, index)
      elsif term[:body][0][:type] == "stringConstant"
        compile_string_constant(term[:body][0][:body])
      end
    end

    if term[:body].length == 2
      compile_term(term[:body][1])
      compile_unary(term[:body][0])
    end

    # expression in parens
    if term[:body].length == 3
      compile_expression(term[:body][1])
    end

    if term[:body].length > 3
      compile_subroutine_call(term[:body])
    end
  end

  def compile_subroutine_call(tokens)
    if tokens.length == 4
      method = tokens[0][:body]
      expression_list = tokens[2][:body]
      n_args = expression_list.select { |child| child[:type] == "expression" }.count + 1
      vm_writer.write_push('pointer', 0)
      compile_expression_list(expression_list)
      vm_writer.write_call("#{@klass_name}.#{method}", n_args)
    end

    # subroutine call
    if tokens.length == 6
      name = tokens[0][:body]
      method = tokens[2][:body]
      expression_list = tokens[4][:body]
      n_args = expression_list.select { |child| child[:type] == "expression" }.count
      if symbol_table.exists?(name)
        # method call
        kind = symbol_table.kind_of(name)
        type = symbol_table.type_of(name)
        index = symbol_table.index_of(name)
        vm_writer.write_push(kind, index)
        compile_expression_list(expression_list)
        vm_writer.write_call("#{type}.#{method}", n_args + 1)
      else
        # constructor or function
        compile_expression_list(expression_list)
        vm_writer.write_call("#{name}.#{method}", n_args)
      end
    end
  end

  def compile_expression_list(expression_list)
    expressions = expression_list.select { |child| child[:type] == "expression" }
    expressions.each do |exp|
      compile_expression(exp)
    end
  end

  def compile_keyword_constant(keyword)
    case keyword
    when 'true'
      vm_writer.write_push('constant', 1)
      vm_writer.write_arithmetic('neg')
    when 'false'
      vm_writer.write_push('constant', 0)
    when 'null'
      vm_writer.write_push('constant', 0)
    when 'this'
      vm_writer.write_push('pointer', '0')
    end
  end

  def compile_string_constant(string)
    vm_writer.write_push('constant', string.length)
    vm_writer.write_call('String.new', 1)
    string.chars.each do |c|
      vm_writer.write_push('constant', c.ord)
      vm_writer.write_call('String.appendChar', 2)
    end
  end

  def compile_op(op)
    case op[:body]
    when '+'
      vm_writer.write_arithmetic('add')
    when '-'
      vm_writer.write_arithmetic('sub')
    when '*'
      vm_writer.write_call('Math.multiply', 2)
    when '/'
      vm_writer.write_call('Math.divide', 2)
    when '&'
      vm_writer.write_arithmetic('and')
    when '|'
      vm_writer.write_arithmetic('or')
    when '<'
      vm_writer.write_arithmetic('lt')
    when '>'
      vm_writer.write_arithmetic('gt')
    when '='
      vm_writer.write_arithmetic('eq')
    end
  end

  def compile_unary(unary)
    case unary[:body]
    when '-'
      vm_writer.write_arithmetic('neg')
    when '~'
      vm_writer.write_arithmetic('not')
    end
  end

  def define_subroutine_symbol_table_for_arguments(subroutine_dec)
    param_list = subroutine_dec.find { |child| child[:type] == "parameterList" }[:body]
    param_list.each_with_index do |token, i|
      next if token[:type] != "keyword"
      kind = "argument"
      type = param_list[i][:body]
      name = param_list[i+1][:body]

      symbol_table.define(name, type, kind)
    end
  end

  def define_subroutine_symbol_table_for_locals(subroutine_type, body)
    if subroutine_type == "method"
      symbol_table.define("this", klass_name, "argument")
    end

    var_decs = body
      .select { |child| child[:type] == "varDec" }
      .map { |child| child[:body] }

    var_decs.each do |var_dec|
      kind = "local"
      type = var_dec[1][:body]
      names = var_dec[2..-1]
               .select { |token| token[:type] == "identifier" }
               .map { |token| token[:body] }

      names.each do |name|
        symbol_table.define(name, type, kind)
      end
    end
  end

  def define_class_symbol_table(class_body)
    class_var_decs = class_body
      .select { |child| child[:type] == "classVarDec" }
      .map { |child| child[:body] }

    class_var_decs.each do |class_var_dec|
      kind = class_var_dec[0][:body]
      type = class_var_dec[1][:body]
      names = class_var_dec[2..-1]
               .select { |token| token[:type] == "identifier" }
               .map { |token| token[:body] }

      names.each do |name|
        symbol_table.define(name, type, kind)
      end
    end
  end

  private

  attr_reader :symbol_table, :vm_writer, :tree, :klass_name
end
