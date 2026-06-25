require_relative 'test_helper'
require 'tempfile'

class CliTest < Minitest::Test
  def test_cli_runs_arithmetic_example
    stdout, stderr, status = run_ruby_script(
      project_path('interpreter', 'main.rb'),
      project_path('examples', 'arithmetic.rbl')
    )

    assert status.success?, stderr
    assert_empty stderr

    ['16', '41', '4', '243', '48', 'Block result: nil'].each do |expected|
      assert_includes stdout, expected
    end
  end

  def test_cli_help_prints_usage_and_options
    stdout, stderr, status = run_ruby_script(
      project_path('interpreter', 'main.rb'),
      '--help'
    )

    assert status.success?, stderr
    assert_empty stderr
    assert_includes stdout, 'Usage:'
    assert_includes stdout, 'Options:'
    assert_includes stdout, '--tokens'
    assert_includes stdout, '--translate'
  end

  def test_cli_invalid_flag_exits_nonzero
    stdout, stderr, status = run_ruby_script(
      project_path('interpreter', 'main.rb'),
      '--bogus'
    )

    refute status.success?
    assert_empty stdout
    assert_includes stderr, 'invalid option'
    assert_includes stderr, 'Usage:'
  end

  def test_cli_missing_file_argument_exits_nonzero
    stdout, stderr, status = run_ruby_script(project_path('interpreter', 'main.rb'))

    refute status.success?
    assert_empty stdout
    assert_includes stderr, 'missing source file'
    assert_includes stderr, 'Usage:'
  end

  def test_cli_file_not_found_exits_nonzero
    stdout, stderr, status = run_ruby_script(
      project_path('interpreter', 'main.rb'),
      project_path('examples', 'missing.rbl')
    )

    refute status.success?
    assert_empty stdout
    assert_includes stderr, 'file not found'
  end

  def test_cli_can_print_tokens_and_translation
    stdout, stderr, status = run_ruby_script(
      project_path('interpreter', 'main.rb'),
      project_path('examples', 'arithmetic.rbl'),
      '--tokens',
      '--translate'
    )

    assert status.success?, stderr
    assert_empty stderr
    assert_includes stdout, 'Tokens:'
    assert_includes stdout, 'Token(:print, "print"'
    assert_includes stdout, 'Translation:'
    assert_includes stdout, 'puts (12 + 4)'
    assert_includes stdout, 'Block result: nil'
  end

  def test_cli_runs_program_with_comments
    Tempfile.create(['rblang-comments', '.rbl']) do |file|
      file.write(<<~SOURCE)
        # calculate a score
        score = 12 + 4
        print score # inline comment
      SOURCE
      file.close

      stdout, stderr, status = run_ruby_script(
        project_path('interpreter', 'main.rb'),
        file.path
      )

      assert status.success?, stderr
      assert_empty stderr
      assert_includes stdout, "16\n"
      assert_includes stdout, 'Block result: nil'
    end
  end

  def test_cli_formats_parser_errors_with_caret
    stdout, stderr, status = run_temp_source("print (12 + 4\n")

    refute status.success?
    assert_empty stdout
    assert_includes stderr, "Parser error:\nExpected ) at index 13"
    assert_includes stderr, "print (12 + 4\n             ^"
  end

  def test_cli_formats_lexer_errors_with_caret
    stdout, stderr, status = run_temp_source("print \"unterminated\n")

    refute status.success?
    assert_empty stdout
    assert_includes stderr, "Lexer error:\nunclosed string literal at index 6"
    assert_includes stderr, "print \"unterminated\n      ^"
  end

  def test_cli_formats_runtime_errors_with_caret
    stdout, stderr, status = run_temp_source("print missing_value\n")

    refute status.success?
    assert_empty stdout
    assert_includes stderr, "Runtime error:\nundeclared variable \"missing_value\" at index 6"
    assert_includes stderr, "print missing_value\n      ^"
  end

  private

  def run_temp_source(source)
    Tempfile.create(['rblang-error', '.rbl']) do |file|
      file.write(source)
      file.close

      return run_ruby_script(
        project_path('interpreter', 'main.rb'),
        file.path
      )
    end
  end
end
