# Translator is a visitor that turns an AST into Ruby code

require_relative 'nodes'

class Translator
  def visit_integer_primitive(node)
    node.value.to_s
  end

  def visit_float_primitive(node)
    node.value.to_s
  end

  def visit_boolean_primitive(node)
    node.value.to_s
  end

  def visit_string_primitive(node)
    "\"#{node.value}\""
  end

  def visit_null_primitive(_node)
    'nil'
  end

  def visit_add(node)
    "(#{node.left.visit(self)} + #{node.right.visit(self)})"
  end

  def visit_subtract(node)
    "(#{node.left.visit(self)} - #{node.right.visit(self)})"
  end

  def visit_multiply(node)
    "(#{node.left.visit(self)} * #{node.right.visit(self)})"
  end

  def visit_divide(node)
    "(#{node.left.visit(self)} / #{node.right.visit(self)})"
  end

  def visit_modulo(node)
    "(#{node.left.visit(self)} % #{node.right.visit(self)})"
  end

  def visit_exponentiate(node)
    "(#{node.left.visit(self)} ** #{node.right.visit(self)})"
  end

  def visit_negate(node)
    "(-#{node.operand.visit(self)})"
  end

  def visit_equals(node)
    "(#{node.left.visit(self)} == #{node.right.visit(self)})"
  end

  def visit_not_equals(node)
    "(#{node.left.visit(self)} != #{node.right.visit(self)})"
  end

  def visit_less_than(node)
    "(#{node.left.visit(self)} < #{node.right.visit(self)})"
  end

  def visit_less_than_or_equal(node)
    "(#{node.left.visit(self)} <= #{node.right.visit(self)})"
  end

  def visit_greater_than(node)
    "(#{node.left.visit(self)} > #{node.right.visit(self)})"
  end

  def visit_greater_than_or_equal(node)
    "(#{node.left.visit(self)} >= #{node.right.visit(self)})"
  end

  def visit_logical_and(node)
    "(#{node.left.visit(self)} && #{node.right.visit(self)})"
  end

  def visit_logical_or(node)
    "(#{node.left.visit(self)} || #{node.right.visit(self)})"
  end

  def visit_logical_not(node)
    "(!#{node.operand.visit(self)})"
  end

  def visit_bitwise_and(node)
    "(#{node.left.visit(self)} & #{node.right.visit(self)})"
  end

  def visit_bitwise_or(node)
    "(#{node.left.visit(self)} | #{node.right.visit(self)})"
  end

  def visit_bitwise_xor(node)
    "(#{node.left.visit(self)} ^ #{node.right.visit(self)})"
  end

  def visit_bitwise_not(node)
    "(~#{node.operand.visit(self)})"
  end

  def visit_left_shift(node)
    "(#{node.left.visit(self)} << #{node.right.visit(self)})"
  end

  def visit_right_shift(node)
    "(#{node.left.visit(self)} >> #{node.right.visit(self)})"
  end

  def visit_float_to_int(node)
    "((#{node.operand.visit(self)}).to_i)"
  end

  def visit_int_to_float(node)
    "((#{node.operand.visit(self)}).to_f)"
  end

  def visit_rvalue(node)
    node.name
  end

  def visit_assignment(node)
    "#{node.name} = #{node.expression.visit(self)}"
  end

  def visit_print(node)
    "puts #{node.operand.visit(self)}"
  end

  def visit_block(node)
    node.statements.map { |statement| statement.visit(self) }.join("\n")
  end
end