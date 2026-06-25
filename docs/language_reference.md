# RBLang Language Reference

## Overview

RBLang is a small Ruby-like language implemented by the interpreter in this
repository. It is useful for simple expression-oriented programs with variables,
printing, arithmetic, comparisons, logical expressions, bitwise operations, and
numeric casts.

RBLang is inspired by Ruby syntax, but it is not Ruby and does not aim for full
Ruby compatibility.

## Running Programs

Write RBLang source in a `.rbl` file and run it with the CLI:

```bash
ruby interpreter/main.rb examples/variables.rbl
```

The bundled examples can be run together:

```bash
ruby interpreter/run_examples.rb
```

The CLI also supports diagnostic output:

```bash
ruby interpreter/main.rb examples/arithmetic.rbl --tokens --translate
```

## Comments

Comments begin with `#` and continue to the end of the line.

```ruby
# calculate a total
total = 8
print total
```

Comments can also appear after code:

```ruby
print 12 + 4 # prints 16
```

## Print Statements

Use `print` to write the value of an expression.

```ruby
print 12 + 4
print true
print "hello"
```

Each printed value appears on its own line.

## Literals

RBLang supports integer, float, boolean, string, and null literals.

```ruby
print 12
print 2.75
print true
print false
print "hello"
print null
```

String literals use double quotes.

## Variables and Assignment

Assign values with `=`, then read them by name in later expressions.

```ruby
total = 8
print total + total * 3
total = 41
print total
```

Variables must be assigned before they are read.

## Arithmetic Operators

RBLang supports these arithmetic operators:

- `+` addition
- `-` subtraction
- `*` multiplication
- `/` division
- `%` modulo
- `**` exponentiation

```ruby
print 12 + 4
print 14 * 3 - 16 % 5
print (8 + 4) * 5 % 7
print 3 ** 5
```

Parentheses can be used to group expressions.

## Unary Operators

RBLang supports unary numeric negation with `-`, logical not with `!`, and
bitwise not with `~`.

```ruby
print -12
print !!!!!true
print ~11
```

Unary operators can be repeated:

```ruby
print ---(2 + 5)
```

## Comparison Operators

Comparison operators return boolean values.

- `<`
- `<=`
- `>`
- `>=`
- `==`
- `!=`

```ruby
print 14 >= 9 + 5
print 8 == 8
print 12 != 4
```

## Logical Operators

Logical operators work with boolean expressions.

- `!` logical not
- `&&` logical and
- `||` logical or

```ruby
print false || !false
print (9 > 4) && !(3 > 12)
```

## Bitwise Operators

Bitwise operators work with integer values.

- `~` bitwise not
- `&` bitwise and
- `|` bitwise or
- `^` bitwise xor
- `<<` left shift
- `>>` right shift

```ruby
print 52 & ---(2 + 5)
print 6 << 2
print ~11
```

## Type Casting

RBLang supports numeric casts with `int(...)` and `float(...)`.

```ruby
print float(11) / 4
print int(8.6)
```

`float(...)` converts an integer expression to a float. `int(...)` converts a
float expression to an integer.

## Expression Results / Block Result

Every program is evaluated as a block of statements. After execution, the CLI
prints the final block result.

For programs that end with a `print` statement, the block result is `nil`:

```ruby
print 12 + 4
```

Output:

```text
16
Block result: nil
```

For programs that end with a plain expression, the expression value becomes the
block result:

```ruby
6 << 2
```

Output:

```text
Block result: 24
```

## Error Messages

When a file has a lexer, parser, or runtime error, the CLI prints the error type,
the original message, the source line, and a caret when an index is available.

Parser error example:

```text
Parser error:
Expected ) at index 13

print (12 + 4
             ^
```

Lexer error example:

```text
Lexer error:
unclosed string literal at index 6

print "unterminated
      ^
```

Runtime error example:

```text
Runtime error:
undeclared variable "missing_value" at index 6

print missing_value
      ^
```

## Known Limitations

RBLang intentionally supports a small language surface.

It does not currently implement Ruby classes, methods, modules, arrays, hashes,
blocks, loops, exceptions, or the Ruby standard library. It also does not
provide a REPL or package system.

The interpreter is intended as an educational and portfolio project, not a
production-ready Ruby implementation.
