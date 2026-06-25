require_relative 'runner'

example_paths = Dir[File.join('examples', '*.rbl')].sort

if example_paths.empty?
  warn 'No example files found in examples/.'
  exit 1
end

example_paths.each_with_index do |path, index|
  puts unless index.zero?
  puts "--- #{File.basename(path)} ---"

  begin
    InterpreterRunner.run_file(path)
  rescue RuntimeError => e
    warn "Error in #{File.basename(path)}: #{e.message}"
    exit 1
  end
end
