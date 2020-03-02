require_relative "./jack_tokenizer.rb"

module CompilationMethods
  # Program structure
  CLASS_TYPE = "class"
  CLASS_VAR_DEC_TYPE = "classVarDec"
  SUBROUTINE_DEC_TYPE = "subroutineDec"
  PARAMETER_LIST_TYPE = "parameterList"
  SUBROUTINE_BODY_TYPE = "subroutineBody"
  VAR_DEC_TYPE = "varDec"

  # Statements
  STATEMENTS_TYPE = "statements"
  LET_STATEMENT_TYPE = "letStatement"
  IF_STATEMENT_TYPE = "ifStatement"
  WHILE_STATEMENT_TYPE = "whileStatement"
  DO_STATEMENT_TYPE = "doStatement"
  RETURN_STATEMENT_TYPE = "returnStatement"

  # Expressions
  EXPRESSION_TYPE = "expression"
  TERM_TYPE = "term"
  SUBROUTINE_CALL_TYPE = "subroutineCall"
  EXPRESSION_LIST_TYPE = "expressionList"

  # Lexical elements
  KEYWORD_TYPE = JackTokenizer::KEYWORD_TYPE
  SYMBOL_TYPE = JackTokenizer::SYMBOL_TYPE
  IDENTIFIER_TYPE = JackTokenizer::IDENTIFIER_TYPE
  INT_CONST_TYPE = JackTokenizer::INT_CONST_TYPE
  STRING_CONST_TYPE = JackTokenizer::STRING_CONST_TYPE


  CLASS_VAR_DECS = %w(static field)
  SUBROUTINES_DECS = %w(constructor function method)
  OP_SYMBOLS = %w(+ - * / & | < > =)
  UNARY_OP_SYMBOLS = %w(- ~)

  def compile_class(tokens)
    class_keyword = tokens.shift
    class_name = tokens.shift
    open_curly = tokens.shift
    class_vars = compile_class_var_dec(tokens)
    subroutines = compile_subroutine(tokens)
    close_curly = tokens.shift

    [
      {
        type: CLASS_TYPE,
        body: [
          class_keyword,
          class_name,
          open_curly,
          *class_vars,
          *subroutines,
          close_curly
        ]
      }
    ]
  end

  def compile_class_var_dec(tokens)
    class_vars = []

    while tokens[0][:type] == KEYWORD_TYPE && CLASS_VAR_DECS.include?(tokens[0][:body]) do
      class_var = {type: CLASS_VAR_DEC_TYPE, body: []}

      until class_var[:body][-1] &&
            class_var[:body][-1][:type] == SYMBOL_TYPE &&
            class_var[:body][-1][:body] == ';' do
        class_var[:body] << tokens.shift
      end

      class_vars << class_var
    end

    return class_vars
  end

  def compile_subroutine(tokens)
    subroutines = []

    while tokens[0] && tokens[0][:type] == KEYWORD_TYPE && SUBROUTINES_DECS.include?(tokens[0][:body]) do
      subroutine = {type: SUBROUTINE_DEC_TYPE, body: []}

      subroutine[:body] << tokens.shift # method
      subroutine[:body] << tokens.shift # type
      subroutine[:body] << tokens.shift # name
      subroutine[:body] << tokens.shift # open paren
      subroutine[:body] << compile_parameter_list(tokens) # parameterList
      subroutine[:body] << tokens.shift # close paren
      subroutine[:body] << compile_subroutine_body(tokens)

      subroutines << subroutine
    end

    return subroutines
  end

  def compile_subroutine_body(tokens)
    subroutine_body = {type: SUBROUTINE_BODY_TYPE, body: []}

    subroutine_body[:body] << tokens.shift # open curly
    subroutine_body[:body].append(*compile_var_dec(tokens)) # var declarations
    subroutine_body[:body] << compile_statements(tokens) # statements
    subroutine_body[:body] << tokens.shift # close curly

    return subroutine_body
  end

  def compile_parameter_list(tokens)
    parameterList = {type: PARAMETER_LIST_TYPE, body: []}

    while tokens[0][:body] != ')' do
      parameterList[:body] << tokens.shift
    end

    return parameterList
  end

  def compile_var_dec(tokens)
    var_decs = []

    while tokens[0][:type] == KEYWORD_TYPE && tokens[0][:body] == 'var' do
      var_dec = {type: VAR_DEC_TYPE, body: []}

      until var_dec[:body][-1] &&
            var_dec[:body][-1][:type] == SYMBOL_TYPE &&
            var_dec[:body][-1][:body] == ';' do
        var_dec[:body] << tokens.shift
      end

      var_decs << var_dec
    end

    return var_decs
  end

  def compile_statements(tokens)
    statements = {type: STATEMENTS_TYPE, body: []}

    while tokens[0] &&
          tokens[0][:type] != SYMBOL_TYPE &&
          tokens[0][:body] != '}' do
      case tokens[0][:body]
      when 'let'
        statements[:body] << compile_let(tokens)
      when 'if'
        statements[:body] << compile_if(tokens)
      when 'while'
        statements[:body] << compile_while(tokens)
      when 'do'
        statements[:body] << compile_do(tokens)
      when 'return'
        statements[:body] << compile_return(tokens)
      end
    end

    return statements
  end

  def compile_let(tokens)
    let = {type: LET_STATEMENT_TYPE, body: []}

    let[:body] << tokens.shift # let
    let[:body] << tokens.shift # varName
    if tokens[0][:type] == SYMBOL_TYPE && tokens[0][:body] == '['
      let[:body] << tokens.shift # [
      let[:body] << compile_expression(tokens) # expression
      let[:body] << tokens.shift # ]
    end

    let[:body] << tokens.shift # =
    let[:body] << compile_expression(tokens) # expression
    let[:body] << tokens.shift # ;

    return let
  end

  def compile_if(tokens)
    if_statement = {type: IF_STATEMENT_TYPE, body: []}

    if_statement[:body] << tokens.shift # if
    if_statement[:body] << tokens.shift # (
    if_statement[:body] << compile_expression(tokens) # expression
    if_statement[:body] << tokens.shift # )

    if_statement[:body] << tokens.shift # {
    if_statement[:body] << compile_statements(tokens) # expression
    if_statement[:body] << tokens.shift # }

    if tokens[0][:type] == KEYWORD_TYPE && tokens[0][:body] == "else"
      if_statement[:body] << tokens.shift # else
      if_statement[:body] << tokens.shift # {
      if_statement[:body] << compile_statements(tokens) # expression
      if_statement[:body] << tokens.shift # }
    end

    return if_statement
  end

  def compile_while(tokens)
    while_statement = {type: WHILE_STATEMENT_TYPE, body: []}

    while_statement[:body] << tokens.shift # while
    while_statement[:body] << tokens.shift # (
    while_statement[:body] << compile_expression(tokens) # expression
    while_statement[:body] << tokens.shift # )

    while_statement[:body] << tokens.shift # {
    while_statement[:body] << compile_statements(tokens) # expression
    while_statement[:body] << tokens.shift # }

    return while_statement
  end

  def compile_do(tokens)
    do_statement = {type: DO_STATEMENT_TYPE, body: []}

    do_statement[:body] << tokens.shift # do

    if tokens[1] && tokens[1][:body] == "(" # subroutine call
      do_statement[:body] << tokens.shift # subroutine name
      do_statement[:body] << tokens.shift # (
      do_statement[:body] << compile_expression_list(tokens)
      do_statement[:body] << tokens.shift # )
    elsif tokens[1] && tokens[1][:body] == "." # subroutine call
      do_statement[:body] << tokens.shift # var or class name
      do_statement[:body] << tokens.shift # .
      do_statement[:body] << tokens.shift # subroutine name
      do_statement[:body] << tokens.shift # (
      do_statement[:body] << compile_expression_list(tokens)
      do_statement[:body] << tokens.shift # )
    end

    do_statement[:body] << tokens.shift # ;

    return do_statement
  end

  def compile_return(tokens)
    return_statement = {type: RETURN_STATEMENT_TYPE, body: []}

    return_statement[:body] << tokens.shift # return

    if tokens[0][:body] != ';'
      return_statement[:body] << compile_expression(tokens)
    end

    return_statement[:body] << tokens.shift # ;

    return return_statement
  end

  def compile_expression(tokens)
    expression = {type: EXPRESSION_TYPE, body: []}

    expression[:body] << compile_term(tokens) if tokens != []

    if tokens[0] && tokens[0][:type] == SYMBOL_TYPE && OP_SYMBOLS.include?(tokens[0][:body])
      expression[:body] << tokens.shift # operation
      expression[:body] << compile_term(tokens)
    end

    return expression
  end

  def compile_term(tokens)
    term = {type: TERM_TYPE, body: []}

    if tokens[0] && tokens[0][:body] == "("
      term[:body] << tokens.shift # (
      term[:body] << compile_expression(tokens)
      term[:body] << tokens.shift # )
    elsif tokens[0] && UNARY_OP_SYMBOLS.include?(tokens[0][:body])
      term[:body] << tokens.shift # unary operation
      term[:body] << compile_term(tokens)
    elsif tokens[1] && tokens[1][:body] == "["
      term[:body] << tokens.shift # var name
      term[:body] << tokens.shift # [
      term[:body] << compile_expression(tokens)
      term[:body] << tokens.shift # ]
    elsif tokens[1] && tokens[1][:body] == "(" # subroutine call
      term[:body] << tokens.shift # subroutine name
      term[:body] << tokens.shift # (
      term[:body] << compile_expression_list(tokens)
      term[:body] << tokens.shift # )
    elsif tokens[1] && tokens[1][:body] == "." # subroutine call
      term[:body] << tokens.shift # var or class name
      term[:body] << tokens.shift # .
      term[:body] << tokens.shift # subroutine name
      term[:body] << tokens.shift # (
      term[:body] << compile_expression_list(tokens)
      term[:body] << tokens.shift # )
    elsif tokens[0] && [KEYWORD_TYPE, SYMBOL_TYPE, IDENTIFIER_TYPE, INT_CONST_TYPE, STRING_CONST_TYPE].include?(tokens[0][:type])
      term[:body] << tokens.shift # constant or var
    end

    return term
  end

  def compile_expression_list(tokens)
    expression_list = {type: EXPRESSION_LIST_TYPE, body: []}

    while tokens[0] && tokens[0][:body] != ')' do
      expression_list[:body] << compile_expression(tokens)
      expression_list[:body] << tokens.shift if tokens[0] && tokens[0][:body] == ','
    end

    return expression_list
  end
end
