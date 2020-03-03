require_relative "./lib/jack_tokenizer.rb"
require_relative "./lib/compilation_engine.rb"
require_relative "./lib/code_generator.rb"

class JackCompiler
  def initialize(file_or_directory)
    @file_or_directory = file_or_directory
  end

  def run
    if File.directory?(@file_or_directory)
      Dir.glob("#{@file_or_directory}/*.jack").each do |file|
        analyze_file(file)
      end
    else
      analyze_file(@file_or_directory)
    end
  end

  private

  def analyze_file(filepath)
    tokenizer = JackTokenizer.new(filepath)
    tokenizer.run

    compilation_engine = CompilationEngine.new(tokenizer)
    compilation_engine.run

    code_generator = CodeGenerator.new(compilation_engine)
    code_generator.run
  end
end

file_or_directory = ARGV[0]

JackCompiler.new(file_or_directory).run
