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
      IntegerPrimitive.new(7),
      IntegerPrimitive.new(4)
    ),
    IntegerPrimitive.new(3)
  ),
  IntegerPrimitive.new(12)
)

show_expression('Arithmetic: (7 * 4 + 3) % 12', tree1)

tree2 = Multiply.new(
  Rvalue.new('a'),
  Negate.new(Rvalue.new('b'))
)

show_expression('Arithmetic negation and rvalues: a * (-b)', tree2) do |runtime|
  runtime.set('a', IntegerPrimitive.new(6))
  runtime.set('b', IntegerPrimitive.new(7))
end

tree3 = LeftShift.new(
  Rvalue.new('i'),
  IntegerPrimitive.new(3)
)

show_expression('Rvalue lookup and shift: i << 3', tree3) do |runtime|
  runtime.set('i', IntegerPrimitive.new(5))
end

tree4 = Equals.new(
  Rvalue.new('j'),
  Add.new(
    Rvalue.new('j'),
    IntegerPrimitive.new(0)
  )
)

show_expression('Rvalue lookup and comparison: j == j + 0', tree4) do |runtime|
  runtime.set('j', IntegerPrimitive.new(11))
end

tree5 = LogicalNot.new(
  GreaterThan.new(
    FloatPrimitive.new(3.3),
    FloatPrimitive.new(3.2)
  )
)

show_expression('Logic and comparison: !(3.3 > 3.2)', tree5)

tree6 = Negate.new(
  Negate.new(
    Multiply.new(
      IntegerPrimitive.new(6),
      IntegerPrimitive.new(8)
    )
  )
)

show_expression('Double negation: --(6 * 8)', tree6)

tree7 = BitwiseOr.new(
  BitwiseNot.new(IntegerPrimitive.new(5)),
  BitwiseNot.new(IntegerPrimitive.new(8))
)

show_expression('Bitwise operations: ~5 | ~8', tree7)

tree8 = Divide.new(
  IntToFloat.new(IntegerPrimitive.new(7)),
  IntegerPrimitive.new(2)
)

show_expression('Casting: int-to-float(7) / 2', tree8)

tree9 = Assignment.new(
  'n',
  BitwiseAnd.new(
    IntegerPrimitive.new(9),
    IntegerPrimitive.new(3)
  )
)

show_expression('Assignment: n = 9 & 3', tree9)

# --------------------------------------------------
# Program demos
# --------------------------------------------------

program1 = Block.new([
  Assignment.new('x', IntegerPrimitive.new(17)),
  Print.new(Rvalue.new('x'))
])

show_program('Assignment demo', program1)

program2 = Block.new([
  Assignment.new('n', IntegerPrimitive.new(18)),
  Print.new(
    LessThanOrEqual.new(
      Rvalue.new('n'),
      IntegerPrimitive.new(18)
    )
  ),
  Print.new(
    LogicalAnd.new(
      LessThanOrEqual.new(
        IntegerPrimitive.new(13),
        Rvalue.new('n')
      ),
      LessThanOrEqual.new(
        Rvalue.new('n'),
        IntegerPrimitive.new(16)
      )
    )
  ),
  Print.new(
    Negate.new(
      Exponentiate.new(
        Rvalue.new('n'),
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
  FloatPrimitive.new(7.5),
  IntegerPrimitive.new(2)
)

show_error('Type error: 7.5 << 2', bad_tree1)

bad_tree2 = GreaterThanOrEqual.new(
  BooleanPrimitive.new(true),
  IntegerPrimitive.new(10)
)

show_error('Type error: true >= 10', bad_tree2)

bad_tree3 = Divide.new(
  StringPrimitive.new('fooo'),
  IntegerPrimitive.new(3)
)

show_error('Type error: "fooo" / 3', bad_tree3)
