
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

    sig { abstract.params(stmt: If).returns(R) }
    def visit_IfStmt(stmt); end

    sig { abstract.params(stmt: While).returns(R) }
    def visit_WhileStmt(stmt); end
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

    sig { returns(T.nilable(Lox::Expr)) }
    attr_reader :initializer

    sig { params(name: Lox::Token,initializer: T.nilable(Lox::Expr)).void }
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
      

  class If < Stmt
    extend T::Sig

    sig { returns(Lox::Expr) }
    attr_reader :condition

    sig { returns(Lox::Stmt) }
    attr_reader :then_branch

    sig { returns(T.nilable(Lox::Stmt)) }
    attr_reader :else_branch

    sig { params(condition: Lox::Expr,then_branch: Lox::Stmt,else_branch: T.nilable(Lox::Stmt)).void }
    def initialize(condition,then_branch,else_branch)
      @condition = condition
      @then_branch = then_branch
      @else_branch = else_branch
    end

    sig { override.type_parameters(:R).params(visitor: StmtVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_IfStmt(self)
    end
  end
      

  class While < Stmt
    extend T::Sig

    sig { returns(Lox::Expr) }
    attr_reader :condition

    sig { returns(Lox::Stmt) }
    attr_reader :body

    sig { params(condition: Lox::Expr,body: Lox::Stmt).void }
    def initialize(condition,body)
      @condition = condition
      @body = body
    end

    sig { override.type_parameters(:R).params(visitor: StmtVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_WhileStmt(self)
    end
  end
      
end