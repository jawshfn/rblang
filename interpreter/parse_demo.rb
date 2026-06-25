require_relative 'lexer'
require_relative 'parser'
require_relative '../model/translator'
require_relative '../model/runtime'
require_relative '../model/evaluator'

source = <<~BOX
  print (4 < 9) && !(12 < 6)
BOX

tokens = Lexer.new(source).lex
ast = Parser.new(tokens).parse

puts 'Translation:'
puts ast.visit(Translator.new)
puts
puts 'Evaluation:'
result = ast.visit(Evaluator.new(Runtime.new))
puts "Block result: #{result.visit(Translator.new)}"
