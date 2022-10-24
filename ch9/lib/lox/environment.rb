# typed: true
module Lox
  class Environment
    extend T::Sig

    Values = T.type_alias { T::Hash[String, T.untyped] }

    sig { returns(Values) }
    attr_reader :values

    ##
    # Allows for tree-like structure for variables
    # Each branch is a new scope
    sig { returns(T.nilable(Lox::Environment)) }
    attr_reader :enclosing

    sig { params(enclosing: T.nilable(Lox::Environment)).void }
    def initialize(enclosing = nil)
      @enclosing = enclosing
      @values = T.let({}, Values)
    end

    sig { params(name: String, value: T.untyped).void }
    def define(name, value)
      @values[name] = value
    end

    sig { params(name: Lox::Token, value: T.untyped).void }
    def assign(name, value)
      if @values.key?(T.must(name.lexeme))
        @values[T.must(name.lexeme)] = value
        return
      end

      # if didn't find, try the enclosing branch up the tree
      if enclosing
        T.must(enclosing).assign(name, value)
        return
      end

      raise RuntimeError.new(
        name,
        "Undefined variable '#{name.lexeme}'"
      )
    end

    sig { params(name: Lox::Token).returns(T.untyped) }
    def get(name)
      if @values.key?(T.must(name.lexeme))
        val = @values[T.must(name.lexeme)]

        case val
        when Lox::Unknown
          raise RuntimeError.new(
            name,
            "Accessing unitialized variable '#{name.lexeme}'"
          )
        end

        return val
      end

      # if didn't find, look up the enclosing branch up the tree
      if enclosing
        return T.must(enclosing).get(name)
      end

      raise RuntimeError.new(
        name,
        "Undefined variable '#{name.lexeme}'"
      )
    end
  end
end