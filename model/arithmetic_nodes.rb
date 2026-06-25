# Arithmetic node classes represent arithmetic expressions.
require_relative 'ast_node'

class Add < BinaryNode
  def visit(visitor)
    visitor.visit_add(self)
  end
end

class Subtract < BinaryNode
  def visit(visitor)
    visitor.visit_subtract(self)
  end
end

class Multiply < BinaryNode
  def visit(visitor)
    visitor.visit_multiply(self)
  end
end

class Divide < BinaryNode
  def visit(visitor)
    visitor.visit_divide(self)
  end
end

class Modulo < BinaryNode
  def visit(visitor)
    visitor.visit_modulo(self)
  end
end

class Exponentiate < BinaryNode
  def visit(visitor)
    visitor.visit_exponentiate(self)
  end
end

class Negate < UnaryNode
  def visit(visitor)
    visitor.visit_negate(self)
  end
end