# typed: true
module Lox
  class Environment
    extend T::Sig

    Values = T.type_alias { T::Hash[String, T.untyped] }

    sig { returns(Values) }
    attr_reader :values

    def initialize
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

      raise RuntimeError.new(
        name,
        "Undefined variable '#{name.lexeme}'"
      )
    end

    sig { params(name: Lox::Token).returns(T.untyped) }
    def get(name)
      return @values[T.must(name.lexeme)] if @values.key?(T.must(name.lexeme))

      raise RuntimeError.new(
        name,
        "Undefined variable '#{name.lexeme}'"
      )
    end
  end
end