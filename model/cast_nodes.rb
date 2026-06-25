# Cast node classes convert between supported numeric types.
require_relative 'ast_node'

class FloatToInt < UnaryNode
  def visit(visitor)
    visitor.visit_float_to_int(self)
  end
end

class IntToFloat < UnaryNode
  def visit(visitor)
    visitor.visit_int_to_float(self)
  end
end