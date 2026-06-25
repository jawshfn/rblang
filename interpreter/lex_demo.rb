require_relative 'lexer'

source = "84=+shade^!~>"

tokens = Lexer.new(source).lex
tokens.each do |token|
  puts token.inspect
end
