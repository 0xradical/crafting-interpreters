
# typed: true

module Lox
  module StmtVisitor
    extend T::Sig
    extend T::Generic
    abstract!

    R = type_member(:out) {{ upper: T.untyped }}

    sig { abstract.params(stmt: Expression).returns(R) }
    def visit_ExpressionStmt(stmt); end

    sig { abstract.params(stmt: Print).returns(R) }
    def visit_PrintStmt(stmt); end

    sig { abstract.params(stmt: Var).returns(R) }
    def visit_VarStmt(stmt); end

    sig { abstract.params(stmt: Block).returns(R) }
    def visit_BlockStmt(stmt); end
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
      

  class Var < Stmt
    extend T::Sig

    sig { returns(Lox::Token) }
    attr_reader :name

    sig { returns(Lox::Expr) }
    attr_reader :initializer

    sig { params(name: Lox::Token,initializer: Lox::Expr).void }
    def initialize(name,initializer)
      @name = name
      @initializer = initializer
    end

    sig { override.type_parameters(:R).params(visitor: StmtVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_VarStmt(self)
    end
  end
      

  class Block < Stmt
    extend T::Sig

    sig { returns(T::Array[Lox::Stmt]) }
    attr_reader :statements

    sig { params(statements: T::Array[Lox::Stmt]).void }
    def initialize(statements)
      @statements = statements
    end

    sig { override.type_parameters(:R).params(visitor: StmtVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_BlockStmt(self)
    end
  end
      
end