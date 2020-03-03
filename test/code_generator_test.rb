require "minitest/autorun"
require "minitest/test"
require_relative "../lib/jack_tokenizer.rb"
require_relative "../lib/compilation_engine.rb"
require_relative "../lib/code_generator.rb"

class CodeGeneratorTest < Minitest::Test

  [
    "Seven/Main.jack",

    "ConvertToBin/Main.jack",

    "Square/Main.jack",
    "Square/Square.jack",
    "Square/SquareGame.jack",

    "Average/Main.jack",

    "Pong/Main.jack",
    "Pong/Bat.jack",
    "Pong/Ball.jack",
    "Pong/PongGame.jack",

    "ComplexArrays/Main.jack",
  ].each do |source|
    define_method "test_#{source.tr("/.", "_")}" do
      tokenizer = JackTokenizer.new("./test/fixtures/#{source}")
      tokenizer.run

      compilation_engine = CompilationEngine.new(tokenizer)
      compilation_engine.run

      code_generator = CodeGenerator.new(compilation_engine)
      code_generator.run

      assert true
    end
  end
end
