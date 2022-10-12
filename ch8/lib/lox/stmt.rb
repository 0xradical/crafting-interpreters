
# typed: true

module Lox
  module StmtVisitor
    extend T::Sig
    extend T::Generic
    abstract!

    R = type_member(:out) {{ upper: T.untyped }}

    sig { abstract.params(expr: Expression).returns(R) }
    def visit_ExpressionStmt(expr); end

    sig { abstract.params(expr: Print).returns(R) }
    def visit_PrintStmt(expr); end
  end
      
  class Stmt
    extend T::Sig
    extend T::Helpers

    abstract!
    sig { abstract.type_parameters(:R).params(visitor: StmtVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor); end
  end
  
  class Expression < Stmt
    extend T::Sig

    sig { returns(Lox::Expr) }
    attr_reader :expression

    sig { params(expression: Lox::Expr).void }
    def initialize(expression)
      @expression = expression
    end

    sig { override.type_parameters(:R).params(visitor: StmtVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_ExpressionStmt(self)
    end
  end
      

  class Print < Stmt
    extend T::Sig

    sig { returns(Lox::Expr) }
    attr_reader :expression

    sig { params(expression: Lox::Expr).void }
    def initialize(expression)
      @expression = expression
    end

    sig { override.type_parameters(:R).params(visitor: StmtVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_PrintStmt(self)
    end
  end
      
end