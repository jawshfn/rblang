require_relative 'lexer'
require_relative 'parser'
require_relative '../model/runtime'
require_relative '../model/evaluator'
require_relative '../model/translator'

module InterpreterRunner
  module_function

  def run_source(source, show_tokens: false, show_translation: false)
    tokens = Lexer.new(source).lex

    if show_tokens
      puts 'Tokens:'
      tokens.each do |token|
        puts token
      end
      puts
    end

    ast = Parser.new(tokens).parse
    translator = Translator.new

    if show_translation
      puts 'Translation:'
      puts ast.visit(translator)
      puts
    end

    runtime = Runtime.new
    evaluator = Evaluator.new(runtime)
    result = ast.visit(evaluator)

    puts "Block result: #{result.visit(translator)}"
    result
  end

  def run_file(path, show_tokens: false, show_translation: false)
    run_source(
      File.read(path),
      show_tokens: show_tokens,
      show_translation: show_translation
    )
  end
end
