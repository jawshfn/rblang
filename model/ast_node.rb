# AstNode is the base class for all AST nodes and may track a source span.
# Each node accepts a visitor through its visit method.

class AstNode
  attr_reader :start_index, :end_index

  def initialize(start_index = nil, end_index = nil)
    @start_index = start_index
    @end_index = end_index
  end
end

# BinaryNode stores two child nodes.
class BinaryNode < AstNode
  attr_reader :left, :right

  def initialize(left, right, start_index = nil, end_index = nil)
    super(start_index, end_index)
    @left = left
    @right = right
  end
end

# UnaryNode stores one child node.
class UnaryNode < AstNode
  attr_reader :operand

  def initialize(operand, start_index = nil, end_index = nil)
    super(start_index, end_index)
    @operand = operand
  end
end