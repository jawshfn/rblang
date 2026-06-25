require_relative 'test_helper'
require_relative '../interpreter/runner'

class EvaluatorTest < Minitest::Test
  def test_runner_evaluates_print_and_assignment_program
    output = capture_stdout do
      InterpreterRunner.run_source(<<~SOURCE)
        x = 5
        print x + x * x
      SOURCE
    end

    assert_includes output, "30\n"
    assert_includes output, 'Block result: nil'
  end

  def test_runner_can_print_diagnostics
    output = capture_stdout do
      InterpreterRunner.run_source(
        "print 5 + 2\n",
        show_tokens: true,
        show_translation: true
      )
    end

    assert_includes output, 'Tokens:'
    assert_includes output, 'Token(:print, "print"'
    assert_includes output, 'Translation:'
    assert_includes output, 'puts (5 + 2)'
    assert_includes output, "7\n"
  end
end
