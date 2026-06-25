# Runtime stores variable bindings during evaluation.

class Runtime
  def initialize
    @variables = {}
  end

  def set(name, value)
    @variables[name] = value
  end

  def get(name)
    @variables[name]
  end

  def has?(name)
    @variables.key?(name)
  end
end