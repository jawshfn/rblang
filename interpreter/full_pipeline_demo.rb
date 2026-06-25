require_relative 'lexer'
require_relative 'parser'
require_relative '../model/translator'
require_relative '../model/runtime'
require_relative '../model/evaluator'

# Shows the complete lexer -> parser -> translator -> evaluator pipeline.
def run_program(title, source)
  puts
  puts "--- #{title} ---"
  puts 'Source:'
  puts source
  puts

  begin
    tokens = Lexer.new(source).lex

    puts 'Tokens:'
    tokens.each do |token|
      puts token
    end
    puts

    ast = Parser.new(tokens).parse

    puts 'Translation:'
    puts ast.visit(Translator.new)
    puts

    puts 'Evaluation:'
    runtime = Runtime.new
    evaluator = Evaluator.new(runtime)
    result = ast.visit(evaluator)
    puts "Block result: #{result.visit(Translator.new)}"
  rescue RuntimeError => e
    puts 'Error:'
    puts e.message
  end
end

# Arithmetic demos
run_program(
  'Arithmetic: addition',
  <<~BOX
    print 12 + 4
  BOX
)

run_program(
  'Arithmetic: precedence',
  <<~BOX
    print 14 * 3 - 16 % 5
  BOX
)

run_program(
  'Arithmetic: parentheses',
  <<~BOX
    print (8 + 4) * 5 % 7
  BOX
)

run_program(
  'Arithmetic: bitwise not',
  <<~BOX
    print ~11
  BOX
)

run_program(
  'Arithmetic: exponentiation',
  <<~BOX
    print 3 ** 5
  BOX
)

run_program(
  'Arithmetic: bitwise and with negation',
  <<~BOX
    print 52 & ---(2 + 5)
  BOX
)

run_program(
  'Expression result: left shift',
  <<~BOX
    6 << 2
  BOX
)

# Logic demos
run_program(
  'Logic: comparison',
  <<~BOX
    print 14 >= 9 + 5
  BOX
)

run_program(
  'Logic: repeated not',
  <<~BOX
    print !!!!!true
  BOX
)

run_program(
  'Logic: or',
  <<~BOX
    print false || !false
  BOX
)

run_program(
  'Logic: and with grouping',
  <<~BOX
    print (9 > 4) && !(3 > 12)
  BOX
)

# Variable demo
run_program(
  'Variables and reassignment',
  <<~BOX
    total = 8
    print total + total * 3
    total = 41
    print total
  BOX
)

# Parser, lexer, and runtime error demos
run_program(
  'Parser error: missing closing parenthesis',
  <<~BOX
    print (12 + 4
  BOX
)

run_program(
  'Parser error: incomplete expression',
  <<~BOX
    score = 10 *
  BOX
)

run_program(
  'Lexer error: unterminated string',
  "print \"open string\n"
)

run_program(
  'Casting demo',
<<~BOX
  print float(11) / 4
  print int(8.6)
  BOX
)

run_program(
  'Runtime error: undeclared variable',
  <<~BOX
    print missing_value
  BOX
)
