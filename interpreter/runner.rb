require_relative 'lexer'
require_relative 'parser'
require_relative '../model/runtime'
require_relative '../model/evaluator'
require_relative '../model/translator'

module InterpreterRunner
  class SourceError < RuntimeError
    attr_reader :kind, :source

    def initialize(kind:, message:, source:)
      @kind = kind
      @source = source
      super(message)
    end
  end

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

  def run_file_for_cli(path, show_tokens: false, show_translation: false)
    source = File.read(path)
    run_source_for_cli(
      source,
      show_tokens: show_tokens,
      show_translation: show_translation
    )
  end

  def run_source_for_cli(source, show_tokens: false, show_translation: false)
    tokens = run_cli_stage(:lexer, source) do
      Lexer.new(source).lex
    end

    if show_tokens
      puts 'Tokens:'
      tokens.each do |token|
        puts token
      end
      puts
    end

    ast = run_cli_stage(:parser, source) do
      Parser.new(tokens).parse
    end
    translator = Translator.new

    if show_translation
      puts 'Translation:'
      puts ast.visit(translator)
      puts
    end

    runtime = Runtime.new
    evaluator = Evaluator.new(runtime)
    result = run_cli_stage(:runtime, source) do
      ast.visit(evaluator)
    end

    puts "Block result: #{result.visit(translator)}"
    result
  end

  def run_cli_stage(kind, source)
    yield
  rescue RuntimeError => e
    raise SourceError.new(kind: kind, message: e.message, source: source)
  end

  def format_source_error(error)
    lines = [
      "#{error_label(error.kind)} error:",
      error.message
    ]

    line_text, column = source_line_and_column(error.source, error.message)

    if line_text
      lines << ''
      lines << line_text
      lines << "#{' ' * column}^"
    end

    lines.join("\n")
  end

  def error_label(kind)
    kind.to_s.capitalize
  end

  def source_line_and_column(source, message)
    match = message.match(/ at index (\d+)\z/)
    return nil unless match

    index = match[1].to_i
    return nil if index.negative? || index > source.length

    line_start = source.rindex("\n", index - 1) || -1
    line_end = source.index("\n", index) || source.length
    line_text = source[(line_start + 1)...line_end]

    [line_text, index - line_start - 1]
  end
end
