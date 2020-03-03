class SymbolTable
  STATIC = "static"
  FIELD = "field"
  ARG = "argument"
  VAR = "local"

  def initialize
    @klass_table = {}
    @subroutine_table = {}
  end

  def start_subroutine
    @subroutine_table = {}
  end

  def define(name, type, kind)
    table =
      if [STATIC, FIELD].include?(kind)
        @klass_table
      elsif [ARG, VAR].include?(kind)
        @subroutine_table
      end

    table[name] = {type: type, kind: kind, index: var_count(kind)}
  end

  def exists?(name)
    row = @subroutine_table[name] || @klass_table[name]
    row != nil
  end

  def var_count(kind)
    table =
      if [STATIC, FIELD].include?(kind)
        @klass_table
      elsif [ARG, VAR].include?(kind)
        @subroutine_table
      end

    table.select { |_name, row| row[:kind] == kind }.count
  end

  def kind_of(name)
    row = @subroutine_table[name] || @klass_table[name]

    return if row.nil?

    row[:kind]
  end

  def type_of(name)
    row = @subroutine_table[name] || @klass_table[name]

    return if row.nil?

    row[:type]
  end

  def index_of(name)
    row = @subroutine_table[name] || @klass_table[name]

    return if row.nil?

    row[:index]
  end
end
