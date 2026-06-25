# RBLang

[![RBLang CI](https://github.com/jawshfn/rblang/actions/workflows/ruby.yml/badge.svg)](https://github.com/jawshfn/rblang/actions/workflows/ruby.yml)

RBLang is a small Ruby-like interpreter written in Ruby. It implements an
expression-oriented language with a lexer, recursive-descent parser, AST/model
nodes, runtime environment, evaluator, and translator.

This project is designed as an educational interpreter and portfolio project. It
is inspired by Ruby syntax, but it is not a full Ruby interpreter.

## Features

- Lexical analysis with token positions for error reporting
- Recursive-descent parser with operator precedence
- AST node model for primitives, expressions, statements, and operations
- Runtime environment for variable assignment and lookup
- Evaluator for running parsed programs
- Translator for inspecting Ruby-like output from parsed AST nodes
- File-based program execution from `.rbl` source files
- Example runner for bundled sample programs
- Error messages for malformed syntax, undeclared variables, and invalid operand types

## Example

Example source:

```ruby
# calculate a total
total = 8
print total + total * 3
total = 41
print total
```

Run it with:

```bash
ruby interpreter/main.rb examples/variables.rbl
```

Output:

```text
32
41
Block result: nil
```

`Block result: nil` is the final value of the evaluated program block.

## Run Locally

Requirements:

- Ruby installed
- No external dependencies

Run one source file:

```bash
ruby interpreter/main.rb examples/arithmetic.rbl
ruby interpreter/main.rb examples/variables.rbl
ruby interpreter/main.rb examples/logic_and_casts.rbl
```

Print diagnostic output from the interpreter pipeline:

```bash
ruby interpreter/main.rb examples/arithmetic.rbl --tokens --translate
```

Available CLI options:

- `--tokens`: print the token stream before evaluation
- `--translate`: print translated Ruby-like/Ruby output before evaluation
- `--help`: print usage and available options

If no file is provided, the CLI prints a usage message:

```bash
ruby interpreter/main.rb
```

## Run Example Programs

Run all bundled examples:

```bash
ruby interpreter/run_examples.rb
```

The example runner prints each filename before executing it.

## Documentation

- [docs/language_reference.md](docs/language_reference.md): practical guide to writing RBLang programs
- [docs/grammar_notes.md](docs/grammar_notes.md): grammar-oriented notes for parser/syntax structure

## Run Tests

Run the automated test suite:

```bash
ruby tests/run_all_tests.rb
```

The GitHub Actions workflow runs the same Minitest suite on push and pull request.

## Project Structure

```text
examples/
  Public-facing .rbl example programs

docs/
  Language reference (docs/language_reference.md) and grammar notes

interpreter/
  Lexer, parser, token model, CLI entry point, and example runner

model/
  AST/model nodes, runtime environment, evaluator, translator, and AST demos

tests/
  Minitest coverage for the CLI, lexer, and evaluator pipeline
```

## Language Support

The current language supports literals, variables, assignment, `print`
statements, comments, arithmetic, comparison, logical and bitwise operators,
numeric casts, grouped expressions, and multi-statement programs.

For syntax details and runnable examples, see
[docs/language_reference.md](docs/language_reference.md).

## Limitations

- This is a Ruby-like educational interpreter, not a full Ruby implementation.
- It supports a deliberately small syntax and runtime model.
- It does not currently implement Ruby classes, methods, modules, arrays, hashes,
  blocks, loops, exceptions, or the Ruby standard library.
- Error reporting includes source positions, but remains intentionally lightweight.
- The project is not intended to be production-ready.

## Development Notes

The core execution path is:

```text
source file -> lexer -> parser -> AST/model nodes -> evaluator/runtime
```

The translator visitor is useful for inspecting how parsed AST nodes map back to
Ruby-like/Ruby expressions and statements.
