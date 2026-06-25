# Statement nodes represent variable access, assignment, printing, and blocks.
require_relative 'ast_node'

class Rvalue < AstNode
  attr_reader :name

  def initialize(name, start_index = nil, end_index = nil)
    super(start_index, end_index)
    @name = name
  end

  def visit(visitor)
    visitor.visit_rvalue(self)
  end
end

class Assignment < AstNode
  attr_reader :name, :expression

  def initialize(name, expression, start_index = nil, end_index = nil)
    super(start_index, end_index)
    @name = name
    @expression = expression
  end

  def visit(visitor)
    visitor.visit_assignment(self)
  end
end

class Print < UnaryNode
  def visit(visitor)
    visitor.visit_print(self)
  end
end

class Block < AstNode
  attr_reader :statements

  def initialize(statements, start_index = nil, end_index = nil)
    super(start_index, end_index)
    @statements = statements
  end

  def visit(visitor)
    visitor.visit_block(self)
  end
end