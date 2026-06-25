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
    print 5 + 2
  BOX
)

run_program(
  'Arithmetic: precedence',
  <<~BOX
    print 10 * 6 - 10 % 4
  BOX
)

run_program(
  'Arithmetic: parentheses',
  <<~BOX
    print (5 + 2) * 3 % 4
  BOX
)

run_program(
  'Arithmetic: bitwise not',
  <<~BOX
    print ~6
  BOX
)

run_program(
  'Arithmetic: exponentiation',
  <<~BOX
    print 2 ** 9
  BOX
)

run_program(
  'Arithmetic: bitwise and with negation',
  <<~BOX
    print 45 & ---(1 + 3)
  BOX
)

run_program(
  'Expression result: left shift',
  <<~BOX
    9 << 1
  BOX
)

# Logic demos
run_program(
  'Logic: comparison',
  <<~BOX
    print 8 >= 7 + 1
  BOX
)

run_program(
  'Logic: repeated not',
  <<~BOX
    print !!!!false
  BOX
)

run_program(
  'Logic: or',
  <<~BOX
    print true || !false
  BOX
)

run_program(
  'Logic: and with grouping',
  <<~BOX
    print (5 > 3) && !(2 > 8)
  BOX
)

# Variable demo
run_program(
  'Variables and reassignment',
  <<~BOX
    x = 5
    print x + x * x
    x = 999
    print x
  BOX
)

# Parser, lexer, and runtime error demos
run_program(
  'Parser error: missing closing parenthesis',
  <<~BOX
    print (5 + 2
  BOX
)

run_program(
  'Parser error: incomplete expression',
  <<~BOX
    x = 7 +
  BOX
)

run_program(
  'Lexer error: unterminated string',
  "print \"unterminated\n"
)

run_program(
  'Casting demo',
<<~BOX
  print float(7) / 2
  print int(3.9)
  BOX
)

run_program(
  'Runtime error: undeclared variable',
  <<~BOX
    print slar
  BOX
)
