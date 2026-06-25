# Bitwise node classes represent integer bit operations.
require_relative 'ast_node'

class BitwiseAnd < BinaryNode
  def visit(visitor)
    visitor.visit_bitwise_and(self)
  end
end

class BitwiseOr < BinaryNode
  def visit(visitor)
    visitor.visit_bitwise_or(self)
  end
end

class BitwiseXor < BinaryNode
  def visit(visitor)
    visitor.visit_bitwise_xor(self)
  end
end

class BitwiseNot < UnaryNode
  def visit(visitor)
    visitor.visit_bitwise_not(self)
  end
end

class LeftShift < BinaryNode
  def visit(visitor)
    visitor.visit_left_shift(self)
  end
end

class RightShift < BinaryNode
  def visit(visitor)
    visitor.visit_right_shift(self)
  end
end