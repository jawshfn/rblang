# Logical node classes represent boolean operations.
require_relative 'ast_node'

class LogicalAnd < BinaryNode
  def visit(visitor)
    visitor.visit_logical_and(self)
  end
end

class LogicalOr < BinaryNode
  def visit(visitor)
    visitor.visit_logical_or(self)
  end
end

class LogicalNot < UnaryNode
  def visit(visitor)
    visitor.visit_logical_not(self)
  end
end