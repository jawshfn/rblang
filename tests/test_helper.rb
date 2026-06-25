require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'stringio'

PROJECT_ROOT = File.expand_path('..', __dir__)
RUBY = RbConfig.ruby

def project_path(*parts)
  File.join(PROJECT_ROOT, *parts)
end

def run_ruby_script(*args)
  Open3.capture3(RUBY, *args, chdir: PROJECT_ROOT)
end

def capture_stdout
  original_stdout = $stdout
  output = StringIO.new
  $stdout = output
  yield
  output.string
ensure
  $stdout = original_stdout
end
