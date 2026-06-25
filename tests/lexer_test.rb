require_relative 'test_helper'
require_relative '../interpreter/lexer'

class LexerTest < Minitest::Test
  def test_lexes_simple_print_expression
    tokens = Lexer.new("print 12 + 4\n").lex

    assert_equal(
      [:print, :integer, :plus, :integer, :newline, :eof],
      tokens.map(&:type)
    )

    assert_equal ['print', '12', '+', '4', "\n", ''], tokens.map(&:text)
    assert_equal [0, 6, 9, 11, 12, 13], tokens.map(&:start_index)
  end
end
