# Token represents one lexeme from the source program.
# It stores the token's type, the exact source text, and
# the starting and ending indices in the source.

class Token
  attr_reader :type, :text, :start_index, :end_index

  def initialize(type, text, start_index, end_index)
    @type = type
    @text = text
    @start_index = start_index
    @end_index = end_index
  end

  def to_s
    "Token(#{@type.inspect}, #{@text.inspect}, #{@start_index}, #{@end_index})"
  end

  def inspect
    to_s
  end
end