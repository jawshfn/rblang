require_relative 'lexer'

source = "62=+color^!~<"

tokens = Lexer.new(source).lex
tokens.each do |token|
  puts token.inspect
end