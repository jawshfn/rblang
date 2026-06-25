require_relative 'runner'

path = ARGV[0]

if path.nil?
  warn 'Usage: ruby interpreter/main.rb path/to/program.rbl'
  exit 1
end

unless File.file?(path)
  warn "Error: file not found: #{path}"
  exit 1
end

begin
  InterpreterRunner.run_file(path)
rescue RuntimeError => e
  warn "Error: #{e.message}"
  exit 1
end
