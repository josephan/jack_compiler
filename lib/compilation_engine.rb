require 'cgi'
require_relative "./compilation_methods.rb"

class CompilationEngine
  include CompilationMethods

  attr_reader :tokens, :tree, :source_filepath

  def initialize(tokenizer)
    @tokens = tokenizer.tokens
    @source_filepath = tokenizer.source_filepath
    @tree = []
  end

  def run
    @tree = compile_class(@tokens)
  end
end
