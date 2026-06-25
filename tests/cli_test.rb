require_relative 'test_helper'

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
end
