# Grammar Notes

These notes describe the small Ruby-like language parsed by this interpreter.
They are intended as a reference for the current implementation, not as a claim
of full Ruby compatibility.

```text
program = block EOF

block = statement NEWLINE block
      | statement NEWLINE
      | statement

statement = assignment
          | printstatement
          | expression

assignment = IDENTIFIER EQUALS expression

printstatement = PRINT expression

expression = level0

level0 = level0 OROR level1
       | level1

level1 = level1 ANDAND level2
       | level2

level2 = level2 EQEQ level3
       | level2 NOTEQ level3
       | level3

level3 = level3 LT level4
       | level3 LTEQ level4
       | level3 GT level4
       | level3 GTEQ level4
       | level4

level4 = level4 BITOR level5
       | level5

level5 = level5 BITXOR level6
       | level6

level6 = level6 BITAND level7
       | level7

level7 = level7 LSHIFT level8
       | level7 RSHIFT level8
       | level8

level8 = level8 + level9
       | level8 - level9
       | level9

level9 = level9 * level10
       | level9 / level10
       | level9 % level10
       | level10

level10 = level11 POWER level10
        | level11

level11 = ! level11
        | ~ level11
        | - level11
        | INTCAST ( expression )
        | FLOATCAST ( expression )
        | primary

primary = INTEGER
        | FLOATLITERAL
        | STRINGLITERAL
        | TRUE
        | FALSE
        | NULL
        | IDENTIFIER
        | ( expression )
```

The parser implementation uses iterative left-associative parsing for most
binary operator levels and recursive parsing for right-associative exponentiation.
