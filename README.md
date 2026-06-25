# RBLang

RBLang is a small Ruby-like interpreter written in Ruby. It implements an
expression-oriented language with a lexer, recursive-descent parser, AST/model
nodes, runtime environment, evaluator, and translator.

This project is designed as an educational interpreter and portfolio project. It
is inspired by Ruby syntax, but it is not a full Ruby interpreter.

## Features

- Lexical analysis with source-indexed tokens
- Recursive-descent parser with operator precedence
- AST/model nodes for primitives, expressions, statements, and operations
- Runtime environment for variable assignment and lookup
- Visitor-based evaluator for executing parsed programs
- Translator visitor that renders AST nodes as Ruby-like/Ruby code
- File-based program execution from `.rbl` source files
- Example runner for bundled sample programs
- Error messages for malformed syntax, undeclared variables, and invalid operand types

## Example

Example source:

```ruby
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
  Language reference and grammar notes

interpreter/
  Lexer, parser, token model, CLI entry point, and example runner

model/
  AST/model nodes, runtime environment, evaluator, translator, and AST demos

tests/
  Minitest coverage for the CLI, lexer, and evaluator pipeline
```

## Language Support

The current language supports:

- Integer, float, boolean, string, and null literals
- Variables and assignment
- `print` statements
- Multi-statement programs separated by newlines
- Parenthesized expressions
- Arithmetic operators: `+`, `-`, `*`, `/`, `%`, `**`
- Unary numeric negation: `-`
- Relational operators: `<`, `<=`, `>`, `>=`
- Equality operators: `==`, `!=`
- Logical operators: `!`, `&&`, `||`
- Bitwise operators: `~`, `&`, `|`, `^`, `<<`, `>>`
- Numeric casts: `int(...)`, `float(...)`

## Limitations

- This is a Ruby-like educational interpreter, not a full Ruby implementation.
- It supports a deliberately small syntax and runtime model.
- It does not currently implement Ruby classes, methods, modules, arrays, hashes,
  blocks, loops, exceptions, or the Ruby standard library.
- Error reporting is source-indexed, but intentionally lightweight.
- The project is not intended to be production-ready.

## Development Notes

This project is a standalone educational interpreter inspired by Ruby syntax. It
focuses on the interpreter pipeline rather than full Ruby compatibility.

The core execution path is:

```text
source file -> lexer -> parser -> AST/model nodes -> evaluator/runtime
```

The translator visitor is useful for inspecting how parsed AST nodes map back to
Ruby-like/Ruby expressions and statements.
