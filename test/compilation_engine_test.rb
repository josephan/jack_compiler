require "minitest/autorun"
require "minitest/test"
require_relative "../lib/compilation_engine.rb"

class CompilationEngineTest < Minitest::Test

  [
    # Array Test
    ["ArrayTest/Main.jack", "ArrayTest/expected_Main.xml", "ArrayTest/Main.xml"],

    # ExpressionLessSquare Test
    ["ExpressionLessSquare/Main.jack", "ExpressionLessSquare/expected_Main.xml", "ExpressionLessSquare/Main.xml"],
    ["ExpressionLessSquare/Square.jack", "ExpressionLessSquare/expected_Square.xml", "ExpressionLessSquare/Square.xml"],
    ["ExpressionLessSquare/SquareGame.jack", "ExpressionLessSquare/expected_SquareGame.xml", "ExpressionLessSquare/SquareGame.xml"],

    # Square Test
    ["Square/Main.jack", "Square/expected_Main.xml", "Square/Main.xml"],
    ["Square/Square.jack", "Square/expected_Square.xml", "Square/Square.xml"],
    ["Square/SquareGame.jack", "Square/expected_SquareGame.xml", "Square/SquareGame.xml"]
  ].each do |source, expected, actual|
    define_method "test_#{source.tr("/.", "_")}" do
      expected_tree = File.readlines("./test/fixtures/#{expected}").map(&:strip)

      tokenizer = JackTokenizer.new("./test/fixtures/#{source}")
      tokenizer.run
      CompilationEngine.new(tokenizer).run

      actual_tree = File.readlines("./test/fixtures/#{actual}").map(&:strip)

      assert_equal expected_tree, actual_tree, highlight: true
    end
  end

  def test_format_to_xml
     structure = [
      {
        type: 'class', body: [
          {type: 'keyword', body: 'class'},
          {type: 'identifier', body: 'Main'},
          {type: 'symbol', body: '{'},
          {type: 'subroutineDec', body: [{type: 'keyword', body: 'function'}]},
          {type: 'symbol', body: '}'}
        ]
      }
    ]

    expected_xml =
      <<~XML
      <class>
        <keyword> class </keyword>
        <identifier> Main </identifier>
        <symbol> { </symbol>
        <subroutineDec>
          <keyword> function </keyword>
        </subroutineDec>
        <symbol> } </symbol>
      </class>
      XML

    actual_xml = CompilationEngine.format_to_xml(structure)

    assert_equal expected_xml, actual_xml, highlight: true
  end
end
