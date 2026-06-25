# Lexer turns source code into a list of tokens.
# It does not build AST nodes or check grammar rules.

require_relative 'token'

class Lexer
  KEYWORDS = {
    'print' => :print,
    'true' => :true,
    'false' => :false,
    'null' => :null,
    'int' => :intcast,
    'float' => :floatcast
  }.freeze

  OPERATORS = {
    '||' => :oror,
    '&&' => :andand,
    '==' => :eqeq,
    '!=' => :noteq,
    '<=' => :lteq,
    '>=' => :gteq,
    '<<' => :lshift,
    '>>' => :rshift,
    '**' => :power,
    '='  => :equals,
    '<'  => :lt,
    '>'  => :gt,
    '|'  => :bitor,
    '^'  => :bitxor,
    '&'  => :bitand,
    '+'  => :plus,
    '-'  => :minus,
    '*'  => :asterisk,
    '/'  => :slash,
    '%'  => :percent,
    '!'  => :not,
    '~'  => :bitnot,
    '('  => :lparen,
    ')'  => :rparen
  }.freeze

  ORDERED_OPERATORS = OPERATORS.keys.sort_by { |text| -text.length }.freeze

  def initialize(source)
    @source = source
    @i = 0
    @token_text = ''
    @token_start = 0
    @tokens = []
  end

  # Lex scans the source left to right and emits tokens until EOF
  def lex
    while !done?
      if has(" ") || has("\t") || has("\r")
        skip
      elsif has("\n")
        start_token
        capture
        emit_token(:newline)
      elsif has_alpha || has("_")
        lex_identifier_or_keyword
      elsif has_digit
        lex_number
      elsif has('"')
        lex_string
      else
        lex_operator_or_punctuation
      end
    end

    @tokens << Token.new(:eof, '', @source.length, @source.length)
    @tokens
  end

  private

  def done?
    @i >= @source.length
  end

  def current
    return nil if done?
    @source[@i]
  end

  def peek(offset = 1)
    j = @i + offset
    return nil if j >= @source.length
    @source[j]
  end

  def has(text)
    return false if done?
    @source[@i, text.length] == text
  end

  def has_digit
    !done? && current >= '0' && current <= '9'
  end

  def has_alpha
    !done? && ((current >= 'a' && current <= 'z') ||
               (current >= 'A' && current <= 'Z'))
  end

  def has_alphanumeric
    has_alpha || has_digit || has("_")
  end

  def start_token
    @token_text = ''
    @token_start = @i
  end

  def capture
    @token_text << current
    @i += 1
  end

  def skip
    @i += 1
  end

  def emit_token(type)
    @tokens << Token.new(type, @token_text, @token_start, @i - 1)
  end

  # Identifiers are lexed greedily, then checked against known keywords
  def lex_identifier_or_keyword
    start_token
    capture

    while has_alphanumeric
      capture
    end

    emit_token(KEYWORDS.fetch(@token_text, :identifier))
  end

  # Numbers may be integers or floats, depending on whether a decimal point appears
  def lex_number
    start_token

    while has_digit
      capture
    end

    if has('.') && peek && peek >= '0' && peek <= '9'
      capture

      while has_digit
        capture
      end

      emit_token(:floatliteral)
    else
      emit_token(:integer)
    end
  end

  # String literals keep their contents as token text and report an error if unclosed
  def lex_string
    start_token
    quote_index = @i
    skip

    while !done? && !has('"')
      if has('\\')
        capture
        if done?
          raise "unclosed string literal at index #{quote_index}"
        end
        capture
      elsif has("\n")
        raise "unclosed string literal at index #{quote_index}"
      else
        capture
      end
    end

    unless has('"')
      raise "unclosed string literal at index #{quote_index}"
    end

    skip
    emit_token(:stringliteral)
  end

  # Multi-character operators are matched before single-character operators
  def lex_operator_or_punctuation
    start_token

    operator_text = ORDERED_OPERATORS.find { |text| has(text) }

    if operator_text.nil?
      raise "unexpected character #{current.inspect} at index #{@i}"
    end

    operator_text.length.times do
      capture
    end

    emit_token(OPERATORS[operator_text])
  end
end