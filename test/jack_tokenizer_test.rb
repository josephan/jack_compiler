require "minitest/autorun"
require "minitest/test"
require_relative "../lib/jack_tokenizer.rb"

class JackTokenizerTest < Minitest::Test

  [
    # Array Test
    ["ArrayTest/Main.jack", "ArrayTest/expected_MainT.xml", "ArrayTest/MainT.xml"],

    # ExpressionLessSquare Test
    ["ExpressionLessSquare/Main.jack", "ExpressionLessSquare/expected_MainT.xml", "ExpressionLessSquare/MainT.xml"],
    ["ExpressionLessSquare/Square.jack", "ExpressionLessSquare/expected_SquareT.xml", "ExpressionLessSquare/SquareT.xml"],
    ["ExpressionLessSquare/SquareGame.jack", "ExpressionLessSquare/expected_SquareGameT.xml", "ExpressionLessSquare/SquareGameT.xml"],

    # Square Test
    ["Square/Main.jack", "Square/expected_MainT.xml", "Square/MainT.xml"],
    ["Square/Square.jack", "Square/expected_SquareT.xml", "Square/SquareT.xml"],
    ["Square/SquareGame.jack", "Square/expected_SquareGameT.xml", "Square/SquareGameT.xml"]
  ].each do |source, expected, actual|
    define_method "test_#{source.tr("/.", "_")}" do
      expected_tokens = File.readlines("./test/fixtures/#{expected}").map(&:strip)
      JackTokenizer.new("./test/fixtures/#{source}").run
      actual_tokens = File.readlines("./test/fixtures/#{actual}").map(&:strip)

      assert_equal expected_tokens, actual_tokens
    end
  end
end
