require_relative 'runner'

USAGE = <<~TEXT
  Usage: ruby interpreter/main.rb path/to/program.rbl [options]

  Options:
    --tokens      Print the token stream before evaluation
    --translate   Print translated Ruby-like/Ruby output before evaluation
    --help        Show this help message
TEXT

def print_usage
  puts USAGE
end

if ARGV.include?('--help')
  print_usage
  exit 0
end

valid_flags = ['--tokens', '--translate']
invalid_flags = ARGV.select { |arg| arg.start_with?('-') && !valid_flags.include?(arg) }

unless invalid_flags.empty?
  warn "Error: invalid option #{invalid_flags.first}"
  warn USAGE
  exit 1
end

paths = ARGV.reject { |arg| valid_flags.include?(arg) }
path = paths[0]

if path.nil?
  warn 'Error: missing source file'
  warn USAGE
  exit 1
end

if paths.length > 1
  warn "Error: unexpected argument #{paths[1]}"
  warn USAGE
  exit 1
end

unless File.file?(path)
  warn "Error: file not found: #{path}"
  exit 1
end

begin
  InterpreterRunner.run_file_for_cli(
    path,
    show_tokens: ARGV.include?('--tokens'),
    show_translation: ARGV.include?('--translate')
  )
rescue InterpreterRunner::SourceError => e
  warn InterpreterRunner.format_source_error(e)
  exit 1
rescue RuntimeError => e
  warn "Error: #{e.message}"
  exit 1
end
