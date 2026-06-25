require_relative 'lexer'
require_relative 'parser'
require_relative '../model/runtime'
require_relative '../model/evaluator'
require_relative '../model/translator'

module InterpreterRunner
  module_function

  def run_source(source)
    tokens = Lexer.new(source).lex
    ast = Parser.new(tokens).parse
    runtime = Runtime.new
    evaluator = Evaluator.new(runtime)
    result = ast.visit(evaluator)

    puts "Block result: #{result.visit(Translator.new)}"
    result
  end

  def run_file(path)
    run_source(File.read(path))
  end
end
