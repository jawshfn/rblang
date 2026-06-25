require_relative 'nodes'
require_relative 'runtime'
require_relative 'translator'
require_relative 'evaluator'

def show_expression(title, tree)
  runtime = Runtime.new
  translator = Translator.new
  evaluator = Evaluator.new(runtime)

  yield(runtime) if block_given?

  puts
  puts "--- #{title} ---"
  puts "Translation:"
  puts tree.visit(translator)
  puts "Evaluation:"
  puts tree.visit(evaluator).visit(translator)
end

# Helper for showing successful program/block demos.
def show_program(title, program)
  runtime = Runtime.new
  translator = Translator.new
  evaluator = Evaluator.new(runtime)

  puts
  puts "--- #{title} ---"
  puts "Translation:"
  puts program.visit(translator)
  puts
  puts "Evaluation:"
  result = program.visit(evaluator)
  puts "Block result: #{result.visit(translator)}"
end

# Helper for showing failing demos.
def show_error(title, tree)
  runtime = Runtime.new
  translator = Translator.new
  evaluator = Evaluator.new(runtime)

  puts
  puts "--- #{title} ---"
  puts "Translation:"
  puts tree.visit(translator)
  puts "Evaluation:"
  begin
    puts tree.visit(evaluator).visit(translator)
  rescue => e
    puts "Error: #{e.message}"
  end
end

# --------------------------------------------------
# Expression demos
# --------------------------------------------------

tree1 = Modulo.new(
  Add.new(
    Multiply.new(
      IntegerPrimitive.new(9),
      IntegerPrimitive.new(5)
    ),
    IntegerPrimitive.new(8)
  ),
  IntegerPrimitive.new(11)
)

show_expression('Arithmetic: (9 * 5 + 8) % 11', tree1)

tree2 = Multiply.new(
  Rvalue.new('a'),
  Negate.new(Rvalue.new('b'))
)

show_expression('Arithmetic negation and rvalues: a * (-b)', tree2) do |runtime|
  runtime.set('a', IntegerPrimitive.new(4))
  runtime.set('b', IntegerPrimitive.new(13))
end

tree3 = LeftShift.new(
  Rvalue.new('i'),
  IntegerPrimitive.new(2)
)

show_expression('Rvalue lookup and shift: i << 2', tree3) do |runtime|
  runtime.set('i', IntegerPrimitive.new(6))
end

tree4 = Equals.new(
  Rvalue.new('j'),
  Add.new(
    Rvalue.new('j'),
    IntegerPrimitive.new(2)
  )
)

show_expression('Rvalue lookup and comparison: j == j + 2', tree4) do |runtime|
  runtime.set('j', IntegerPrimitive.new(14))
end

tree5 = LogicalNot.new(
  GreaterThan.new(
    FloatPrimitive.new(5.4),
    FloatPrimitive.new(5.9)
  )
)

show_expression('Logic and comparison: !(5.4 > 5.9)', tree5)

tree6 = Negate.new(
  Negate.new(
    Multiply.new(
      IntegerPrimitive.new(7),
      IntegerPrimitive.new(9)
    )
  )
)

show_expression('Double negation: --(7 * 9)', tree6)

tree7 = BitwiseOr.new(
  BitwiseNot.new(IntegerPrimitive.new(10)),
  BitwiseNot.new(IntegerPrimitive.new(12))
)

show_expression('Bitwise operations: ~10 | ~12', tree7)

tree8 = Divide.new(
  IntToFloat.new(IntegerPrimitive.new(11)),
  IntegerPrimitive.new(4)
)

show_expression('Casting: int-to-float(11) / 4', tree8)

tree9 = Assignment.new(
  'mask',
  BitwiseAnd.new(
    IntegerPrimitive.new(14),
    IntegerPrimitive.new(6)
  )
)

show_expression('Assignment: mask = 14 & 6', tree9)

# --------------------------------------------------
# Program demos
# --------------------------------------------------

program1 = Block.new([
  Assignment.new('score', IntegerPrimitive.new(24)),
  Print.new(Rvalue.new('score'))
])

show_program('Assignment demo', program1)

program2 = Block.new([
  Assignment.new('value', IntegerPrimitive.new(21)),
  Print.new(
    LessThanOrEqual.new(
      Rvalue.new('value'),
      IntegerPrimitive.new(25)
    )
  ),
  Print.new(
    LogicalAnd.new(
      LessThanOrEqual.new(
        IntegerPrimitive.new(20),
        Rvalue.new('value')
      ),
      LessThanOrEqual.new(
        Rvalue.new('value'),
        IntegerPrimitive.new(34)
      )
    )
  ),
  Print.new(
    Negate.new(
      Exponentiate.new(
        Rvalue.new('value'),
        IntegerPrimitive.new(2)
      )
    )
  )
])

show_program('Logic and arithmetic demo', program2)

# --------------------------------------------------
# Type error demos
# --------------------------------------------------

bad_tree1 = LeftShift.new(
  FloatPrimitive.new(6.25),
  IntegerPrimitive.new(3)
)

show_error('Type error: 6.25 << 3', bad_tree1)

bad_tree2 = GreaterThanOrEqual.new(
  BooleanPrimitive.new(true),
  IntegerPrimitive.new(4)
)

show_error('Type error: true >= 4', bad_tree2)

bad_tree3 = Divide.new(
  StringPrimitive.new('sample'),
  IntegerPrimitive.new(5)
)

show_error('Type error: "sample" / 5', bad_tree3)
