require "minitest/test"
require "minitest/autorun"
require_relative "../lib/compilation_methods.rb"

class DummyClass
  include CompilationMethods
end

class CompilationMethodsTest < Minitest::Test
  def test_compile_terms_for_integer_constant
    tokens = [{type: 'integerConstant', body: '12345'}]

    expected_tree = {
      type: 'term',
      body: [
        {type: 'integerConstant', body: '12345'}
      ]
    }

    actual_tree = DummyClass.new.compile_term(tokens)

    assert_equal expected_tree, actual_tree
  end

  def test_compile_terms_for_string_constant
    tokens = [{type: 'stringConstant', body: 'hello world'}]

    expected_tree = {
      type: 'term',
      body: [
        {type: 'stringConstant', body: 'hello world'}
      ]
    }

    actual_tree = DummyClass.new.compile_term(tokens)

    assert_equal expected_tree, actual_tree
  end

  def test_compile_terms_for_keyword_constant
    tokens = [{type: 'keyword', body: 'return'}]

    expected_tree = {
      type: 'term',
      body: [
        {type: 'keyword', body: 'return'}
      ]
    }

    actual_tree = DummyClass.new.compile_term(tokens)

    assert_equal expected_tree, actual_tree
  end

  def test_compile_terms_for_identifier_constant
    tokens = [{type: 'identifier', body: 'foo'}]

    expected_tree = {
      type: 'term',
      body: [
        {type: 'identifier', body: 'foo'}
      ]
    }

    actual_tree = DummyClass.new.compile_term(tokens)

    assert_equal expected_tree, actual_tree
  end

  def test_compile_terms_for_array_element_access_with_int
    tokens = [
      {type: 'identifier', body: 'shoppingList'},
      {type: 'symbol', body: '['},
      {type: 'integerConstant', body: '10'},
      {type: 'symbol', body: ']'},
    ]

    expected_tree = {
      type: 'term',
      body: [
        {type: 'identifier', body: 'shoppingList'},
        {type: 'symbol', body: '['},
        {type: 'expression', body: [
          {type: 'term', body: [
            {type: 'integerConstant', body: '10'},
          ]}
        ]},
        {type: 'symbol', body: ']'},
      ]
    }

    actual_tree = DummyClass.new.compile_term(tokens)

    assert_equal expected_tree, actual_tree
  end

  def test_compile_terms_for_array_element_access_with_expression
    tokens = [
      {type: 'identifier', body: 'shoppingList'},
      {type: 'symbol', body: '['},
      {type: 'integerConstant', body: '1'},
      {type: 'symbol', body: '+'},
      {type: 'integerConstant', body: '1'},
      {type: 'symbol', body: ']'},
    ]

    expected_tree = {
      type: 'term',
      body: [
        {type: 'identifier', body: 'shoppingList'},
        {type: 'symbol', body: '['},
        {type: 'expression', body: [
          {type: 'term', body: [
            {type: 'integerConstant', body: '1'},
          ]},
          {type: 'symbol', body: '+'},
          {type: 'term', body: [
            {type: 'integerConstant', body: '1'},
          ]}
        ]},
        {type: 'symbol', body: ']'},
      ]
    }

    actual_tree = DummyClass.new.compile_term(tokens)

    assert_equal expected_tree, actual_tree
  end

  def test_compile_terms_for_subroutine_call
    tokens = [
      {type: 'identifier', body: 'sayHello'},
      {type: 'symbol', body: '('},
      {type: 'stringConstant', body: 'hello world'},
      {type: 'symbol', body: ')'},
    ]

    expected_tree = {
      type: 'term',
      body: [
        {type: 'identifier', body: 'sayHello'},
        {type: 'symbol', body: '('},
        {type: 'expressionList', body: [
          {type: 'expression', body: [
            {type: 'term', body: [
              {type: 'stringConstant', body: 'hello world'},
            ]}
          ]}
        ]},
        {type: 'symbol', body: ')'},
      ]
    }

    actual_tree = DummyClass.new.compile_term(tokens)

    assert_equal expected_tree, actual_tree
  end

  def test_compile_terms_for_class_subroutine_call
    tokens = [
      {type: 'identifier', body: 'Person'},
      {type: 'symbol', body: '.'},
      {type: 'identifier', body: 'sayHello'},
      {type: 'symbol', body: '('},
      {type: 'stringConstant', body: 'hello world'},
      {type: 'symbol', body: ')'},
    ]

    expected_tree = {
      type: 'term',
      body: [
        {type: 'identifier', body: 'Person'},
        {type: 'symbol', body: '.'},
        {type: 'identifier', body: 'sayHello'},
        {type: 'symbol', body: '('},
        {type: 'expressionList', body: [
          {type: 'expression', body: [
            {type: 'term', body: [
              {type: 'stringConstant', body: 'hello world'},
            ]}
          ]}
        ]},
        {type: 'symbol', body: ')'},
      ]
    }

    actual_tree = DummyClass.new.compile_term(tokens)

    assert_equal expected_tree, actual_tree
  end

  def test_compile_terms_for_expression
    tokens = [
      {type: 'symbol', body: '('},
      {type: 'integerConstant', body: '2'},
      {type: 'symbol', body: '+'},
      {type: 'integerConstant', body: '2'},
      {type: 'symbol', body: ')'},
    ]

    expected_tree = {
      type: 'term',
      body: [
        {type: 'symbol', body: '('},
        {type: 'expression', body: [
          {type: 'term', body: [
            {type: 'integerConstant', body: '2'},
          ]},
          {type: 'symbol', body: '+'},
          {type: 'term', body: [
            {type: 'integerConstant', body: '2'},
          ]}
        ]},
        {type: 'symbol', body: ')'},
      ]
    }

    actual_tree = DummyClass.new.compile_term(tokens)

    assert_equal expected_tree, actual_tree
  end

  def test_compile_terms_for_unary_op
    tokens = [
      {type: 'symbol', body: '~'},
      {type: 'keyword', body: 'true'}
    ]

    expected_tree = {
      type: 'term',
      body: [
        {type: 'symbol', body: '~'},
        {type: 'term', body: [
          {type: 'keyword', body: 'true'}
        ]}
      ]
    }

    actual_tree = DummyClass.new.compile_term(tokens)

    assert_equal expected_tree, actual_tree
  end
end
