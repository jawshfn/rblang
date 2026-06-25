# Evaluator is a visitor that executes an AST and returns model primitive nodes.
# It uses the runtime to read and write variable bindings.

require_relative 'nodes'
require_relative 'runtime'
require_relative 'translator'

class Evaluator
  def initialize(runtime)
    @runtime = runtime
    @translator = Translator.new
  end

  def visit_integer_primitive(node)
    node
  end

  def visit_float_primitive(node)
    node
  end

  def visit_boolean_primitive(node)
    node
  end

  def visit_string_primitive(node)
    node
  end

  def visit_null_primitive(node)
    node
  end

  def visit_add(node)
    evaluate_arithmetic(node, 'addition requires numeric operands') do |left, right|
      left + right
    end
  end

  def visit_subtract(node)
    evaluate_arithmetic(node, 'subtraction requires numeric operands') do |left, right|
      left - right
    end
  end

  def visit_multiply(node)
    evaluate_arithmetic(node, 'multiplication requires numeric operands') do |left, right|
      left * right
    end
  end

  def visit_divide(node)
    evaluate_arithmetic(
      node,
      'division requires numeric operands',
      force_float: true
    ) do |left, right|
      left.to_f / right.to_f
    end
  end

  def visit_modulo(node)
    evaluate_arithmetic(
      node,
      'modulo requires integer operands',
      integers_only: true
    ) do |left, right|
      left % right
    end
  end

  def visit_exponentiate(node)
    evaluate_arithmetic(node, 'exponentiation requires numeric operands') do |left, right|
      left**right
    end
  end

  def visit_negate(node)
    value = node.operand.visit(self)
    ensure_numeric!(value, 'negation requires a numeric operand')
    wrap_numeric_value(-value.value, integer_node?(value))
  end

  def visit_equals(node)
    left = node.left.visit(self)
    right = node.right.visit(self)

    if numeric_node?(left) && numeric_node?(right)
      BooleanPrimitive.new(left.value == right.value)
    elsif left.class == right.class
      if left.is_a?(NullPrimitive)
        BooleanPrimitive.new(true)
      else
        BooleanPrimitive.new(left.value == right.value)
      end
    else
      BooleanPrimitive.new(false)
    end
  end

  def visit_not_equals(node)
    value = visit_equals(node)
    BooleanPrimitive.new(!value.value)
  end

  def visit_less_than(node)
    evaluate_numeric_comparison(node, 'less-than requires numeric operands') do |left, right|
      left < right
    end
  end

  def visit_less_than_or_equal(node)
    evaluate_numeric_comparison(
      node,
      'less-than-or-equal requires numeric operands'
    ) do |left, right|
      left <= right
    end
  end

  def visit_greater_than(node)
    evaluate_numeric_comparison(node, 'greater-than requires numeric operands') do |left, right|
      left > right
    end
  end

  def visit_greater_than_or_equal(node)
    evaluate_numeric_comparison(
      node,
      'greater-than-or-equal requires numeric operands'
    ) do |left, right|
      left >= right
    end
  end

  def visit_logical_and(node)
    left = node.left.visit(self)

    unless boolean_node?(left)
      raise RuntimeError, 'logical and requires boolean operands'
    end

    return BooleanPrimitive.new(false) unless left.value

    right = node.right.visit(self)

    unless boolean_node?(right)
      raise RuntimeError, 'logical and requires boolean operands'
    end

    BooleanPrimitive.new(right.value)
  end

  def visit_logical_or(node)
    left = node.left.visit(self)

    unless boolean_node?(left)
      raise RuntimeError, 'logical or requires boolean operands'
    end

    return BooleanPrimitive.new(true) if left.value

    right = node.right.visit(self)

    unless boolean_node?(right)
      raise RuntimeError, 'logical or requires boolean operands'
    end

    BooleanPrimitive.new(right.value)
  end

  def visit_logical_not(node)
    value = node.operand.visit(self)

    unless boolean_node?(value)
      raise RuntimeError, 'logical not requires a boolean operand'
    end

    BooleanPrimitive.new(!value.value)
  end

  def visit_bitwise_and(node)
    evaluate_integer_binary(node, 'bitwise and requires integer operands') do |left, right|
      left & right
    end
  end

  def visit_bitwise_or(node)
    evaluate_integer_binary(node, 'bitwise or requires integer operands') do |left, right|
      left | right
    end
  end

  def visit_bitwise_xor(node)
    evaluate_integer_binary(node, 'bitwise xor requires integer operands') do |left, right|
      left ^ right
    end
  end

  def visit_bitwise_not(node)
    value = node.operand.visit(self)

    unless integer_node?(value)
      raise RuntimeError, 'bitwise not requires an integer operand'
    end

    IntegerPrimitive.new(~value.value)
  end

  def visit_left_shift(node)
    evaluate_integer_binary(node, 'left shift requires integer operands') do |left, right|
      left << right
    end
  end

  def visit_right_shift(node)
    evaluate_integer_binary(node, 'right shift requires integer operands') do |left, right|
      left >> right
    end
  end

  def visit_float_to_int(node)
    value = node.operand.visit(self)

    unless value.is_a?(FloatPrimitive)
      raise RuntimeError, 'float-to-int requires a float operand'
    end

    IntegerPrimitive.new(value.value.to_i)
  end

  def visit_int_to_float(node)
    value = node.operand.visit(self)

    unless integer_node?(value)
      raise RuntimeError, 'int-to-float requires an integer operand'
    end

    FloatPrimitive.new(value.value.to_f)
  end

  # Rvalue lookup raises an indexed error if the variable was never assigned
  def visit_rvalue(node)
    unless @runtime.has?(node.name)
      raise RuntimeError,
          "undeclared variable #{node.name.inspect} at index #{node.start_index}"
    end

    @runtime.get(node.name)
  end

  def visit_assignment(node)
    value = node.expression.visit(self)
    @runtime.set(node.name, value)
    value
  end

  def visit_print(node)
    value = node.operand.visit(self)
    puts value.visit(@translator)
    NullPrimitive.new
  end

  def visit_block(node)
    result = NullPrimitive.new

    node.statements.each do |statement|
      result = statement.visit(self)
    end

    result
  end

  private

  def evaluate_arithmetic(node, error_message, integers_only: false, force_float: false)
    left = node.left.visit(self)
    right = node.right.visit(self)

    if integers_only
      ensure_integers!(left, right, error_message)
    else
      ensure_numeric!(left, error_message)
      ensure_numeric!(right, error_message)
    end

    result = yield(left.value, right.value)
    integer_result = integer_node?(left) && integer_node?(right) && !force_float
    wrap_numeric_value(result, integer_result)
  end

  def evaluate_numeric_comparison(node, error_message)
    left = node.left.visit(self)
    right = node.right.visit(self)

    ensure_numeric!(left, error_message)
    ensure_numeric!(right, error_message)

    BooleanPrimitive.new(yield(left.value, right.value))
  end

  def evaluate_integer_binary(node, error_message)
    left = node.left.visit(self)
    right = node.right.visit(self)

    ensure_integers!(left, right, error_message)
    IntegerPrimitive.new(yield(left.value, right.value))
  end

  def wrap_numeric_value(value, integer_result)
    if integer_result
      IntegerPrimitive.new(value)
    else
      FloatPrimitive.new(value)
    end
  end

  def ensure_numeric!(node, error_message)
    raise RuntimeError, error_message unless numeric_node?(node)
  end

  def ensure_integers!(left, right, error_message)
    unless integer_node?(left) && integer_node?(right)
      raise RuntimeError, error_message
    end
  end

  def numeric_node?(node)
    integer_node?(node) || node.is_a?(FloatPrimitive)
  end

  def boolean_node?(node)
    node.is_a?(BooleanPrimitive)
  end

  def integer_node?(node)
    node.is_a?(IntegerPrimitive)
  end
end