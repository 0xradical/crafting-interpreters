
# typed: true

module Lox
  class Expr
    extend T::Sig
    extend T::Helpers

    abstract!
  end
  
  class Binary < Expr
    extend T::Sig

    sig { returns(Lox::Expr) }
    attr_reader :left

    sig { returns(Lox::Token) }
    attr_reader :operator

    sig { returns(Lox::Expr) }
    attr_reader :right

    sig { params(left: Lox::Expr,operator: Lox::Token,right: Lox::Expr).void }
    def initialize(left,operator,right)
      @left = left
      @operator = operator
      @right = right
    end
  end
end