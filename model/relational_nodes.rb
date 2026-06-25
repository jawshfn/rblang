# Relational node classes compare two expressions.
require_relative 'ast_node'

class Equals < BinaryNode
  def visit(visitor)
    visitor.visit_equals(self)
  end
end

class NotEquals < BinaryNode
  def visit(visitor)
    visitor.visit_not_equals(self)
  end
end

class LessThan < BinaryNode
  def visit(visitor)
    visitor.visit_less_than(self)
  end
end

class LessThanOrEqual < BinaryNode
  def visit(visitor)
    visitor.visit_less_than_or_equal(self)
  end
end

class GreaterThan < BinaryNode
  def visit(visitor)
    visitor.visit_greater_than(self)
  end
end

class GreaterThanOrEqual < BinaryNode
  def visit(visitor)
    visitor.visit_greater_than_or_equal(self)
  end
end