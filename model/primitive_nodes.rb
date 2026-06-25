# Primitive nodes represent the literal values of the language.
require_relative 'ast_node'

class PrimitiveNode < AstNode
  attr_reader :value
  
  def initialize(value, start_index = nil, end_index = nil)
    super(start_index, end_index)
    @value = value
  end
end

class IntegerPrimitive < PrimitiveNode
  def visit(visitor)
    visitor.visit_integer_primitive(self)
  end
end

class FloatPrimitive < PrimitiveNode
  def visit(visitor)
    visitor.visit_float_primitive(self)
  end
end

class BooleanPrimitive < PrimitiveNode
  def visit(visitor)
    visitor.visit_boolean_primitive(self)
  end
end

class StringPrimitive < PrimitiveNode
  def visit(visitor)
    visitor.visit_string_primitive(self)
  end
end

class NullPrimitive < AstNode
  def initialize(start_index = nil, end_index = nil)
    super(start_index, end_index)
  end

  def visit(visitor)
    visitor.visit_null_primitive(self)
  end
end