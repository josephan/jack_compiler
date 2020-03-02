require_relative "./lib/jack_tokenizer.rb"
require_relative "./lib/compilation_engine.rb"

class JackAnalyzer
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
  end
end

file_or_directory = ARGV[0]

JackAnalyzer.new(file_or_directory).run
