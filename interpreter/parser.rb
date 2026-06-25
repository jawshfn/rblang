# Parser turns a list of tokens into an AST using the model classes.
# It follows the grammar one non-terminal at a time.

require_relative '../model/nodes'

class Parser
  LEVEL0_OPERATORS = {
    oror: LogicalOr
  }.freeze

  LEVEL1_OPERATORS = {
    andand: LogicalAnd
  }.freeze

  LEVEL2_OPERATORS = {
    eqeq: Equals,
    noteq: NotEquals
  }.freeze

  COMPARISON_OPERATORS = {
    lt: LessThan,
    lteq: LessThanOrEqual,
    gt: GreaterThan,
    gteq: GreaterThanOrEqual
  }.freeze

  LEVEL4_OPERATORS = {
    bitor: BitwiseOr
  }.freeze

  LEVEL5_OPERATORS = {
    bitxor: BitwiseXor
  }.freeze

  LEVEL6_OPERATORS = {
    bitand: BitwiseAnd
  }.freeze

  LEVEL7_OPERATORS = {
    lshift: LeftShift,
    rshift: RightShift
  }.freeze

  LEVEL8_OPERATORS = {
    plus: Add,
    minus: Subtract
  }.freeze

  LEVEL9_OPERATORS = {
    asterisk: Multiply,
    slash: Divide,
    percent: Modulo
  }.freeze

  def initialize(tokens)
    @tokens = tokens
    @i = 0
  end

  def has(type)
    @i < @tokens.length && @tokens[@i].type == type
  end

  def advance
    token = @tokens[@i]
    @i += 1
    token
  end

  # Parse starts at the grammar's starting non-terminal and returns the AST root
  def parse
    program
  end
  
  # Left-associative binary levels parse one lower rung, then loop while an
  # operator of that level is present, building the tree from left to right
  def parse_left_associative(lower_method_name, operator_map)
    left = send(lower_method_name)

    while operator_map.key?(current_token.type)
      operator_type = advance.type
      right = send(lower_method_name)
      node_class = operator_map[operator_type]
      left = node_class.new(left, right, left.start_index, right.end_index)
    end

    left
  end

  def program
    raise_parse_error('Expected a statement') if has(:eof)

    tree = block

    unless has(:eof)
      raise_parse_error('Expected end of input')
    end

    advance
    tree
  end

  def block
    statements = []
    statements << statement

    while has(:newline)
      advance
      break if has(:eof)
      statements << statement
    end

    Block.new(
      statements,
      statements.first.start_index,
      statements.last.end_index
    )
  end

  # Statement chooses among assignment, print, and expression statements
  def statement
    if has(:print)
      printstatement
    elsif has(:identifier) &&
          @i + 1 < @tokens.length &&
          @tokens[@i + 1].type == :equals
      assignment
    else
      expression
    end
  end

  def assignment
    name_token = advance

    unless has(:equals)
      raise_parse_error('Expected =')
    end
    advance

    value = expression

    Assignment.new(
      name_token.text,
      value,
      name_token.start_index,
      value.end_index
    )
  end

  def printstatement
    print_token = advance
    value = expression

    Print.new(
      value,
      print_token.start_index,
      value.end_index
    )
  end

  def expression
    level0
  end

  # Left-associative operators are parsed with a loop to avoid infinite recursion
  def level0
    parse_left_associative(:level1, LEVEL0_OPERATORS)
  end

  def level1
    parse_left_associative(:level2, LEVEL1_OPERATORS)
  end

  def level2
    parse_left_associative(:level3, LEVEL2_OPERATORS)
  end

  def level3
    parse_left_associative(:level4, COMPARISON_OPERATORS)
  end

  def level4
    parse_left_associative(:level5, LEVEL4_OPERATORS)
  end

  def level5
    parse_left_associative(:level6, LEVEL5_OPERATORS)
  end

  def level6
    parse_left_associative(:level7, LEVEL6_OPERATORS)
  end

  def level7
    parse_left_associative(:level8, LEVEL7_OPERATORS)
  end

  def level8
    parse_left_associative(:level9, LEVEL8_OPERATORS)
  end

  def level9
    parse_left_associative(:level10, LEVEL9_OPERATORS)
  end

  # POWER is right-associative, so this level recurses on the right
  def level10
    left = level11

    if has(:power)
      advance
      right = level10
      left = Exponentiate.new(left, right, left.start_index, right.end_index)
    end

    left
  end

  # Level11 handles unary operators and casts by recursively parsing a single operand
  def level11
    if has(:not)
      token = advance
      operand = level11
      LogicalNot.new(operand, token.start_index, operand.end_index)
    elsif has(:bitnot)
      token = advance
      operand = level11
      BitwiseNot.new(operand, token.start_index, operand.end_index)
    elsif has(:minus)
      token = advance
      operand = level11
      Negate.new(operand, token.start_index, operand.end_index)
    elsif has(:intcast)
      cast_token = advance

      unless has(:lparen)
        raise_parse_error('Expected ( after int')
      end
      advance

      operand = expression

      unless has(:rparen)
        raise_parse_error('Expected ) after int cast')
      end
      rparen = advance

      FloatToInt.new(operand, cast_token.start_index, rparen.end_index)
    elsif has(:floatcast)
      cast_token = advance

      unless has(:lparen)
        raise_parse_error('Expected ( after float')
      end
      advance

      operand = expression

      unless has(:rparen)
        raise_parse_error('Expected ) after float cast')
      end
      rparen = advance

      IntToFloat.new(operand, cast_token.start_index, rparen.end_index)
    else
      primary
    end
  end

  # Primary is the bottom rung: literals, identifiers, and parenthesized expressions
  def primary
    if has(:integer)
      token = advance
      IntegerPrimitive.new(
        token.text.to_i,
        token.start_index,
        token.end_index
      )
    elsif has(:floatliteral)
      token = advance
      FloatPrimitive.new(
        token.text.to_f,
        token.start_index,
        token.end_index
      )
    elsif has(:stringliteral)
      token = advance
      StringPrimitive.new(
        token.text,
        token.start_index,
        token.end_index
      )
    elsif has(:true)
      token = advance
      BooleanPrimitive.new(
        true,
        token.start_index,
        token.end_index
      )
    elsif has(:false)
      token = advance
      BooleanPrimitive.new(
        false,
        token.start_index,
        token.end_index
      )
    elsif has(:null)
      token = advance
      NullPrimitive.new(token.start_index, token.end_index)
    elsif has(:identifier)
      token = advance
      Rvalue.new(token.text, token.start_index, token.end_index)
    elsif has(:lparen)
      advance
      inner = expression

      unless has(:rparen)
        raise_parse_error('Expected )')
      end
      advance

      inner
    else
      raise_parse_error("Unexpected token #{current_token.text.inspect}")
    end
  end

  private

  def current_token
    @tokens[@i]
  end

  def raise_parse_error(message)
    token = current_token

    if token.nil?
      raise RuntimeError, "#{message} at end of input"
    else
      raise RuntimeError, "#{message} at index #{token.start_index}"
    end
  end
end