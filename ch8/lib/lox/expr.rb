
# typed: true

module Lox
  module ExprVisitor
    extend T::Sig
    extend T::Generic
    abstract!

    R = type_member(:out) {{ upper: T.untyped }}

    sig { abstract.params(expr: Binary).returns(R) }
    def visit_BinaryExpr(expr); end

    sig { abstract.params(expr: Grouping).returns(R) }
    def visit_GroupingExpr(expr); end

    sig { abstract.params(expr: Literal).returns(R) }
    def visit_LiteralExpr(expr); end

    sig { abstract.params(expr: Unary).returns(R) }
    def visit_UnaryExpr(expr); end

    sig { abstract.params(expr: Ternary).returns(R) }
    def visit_TernaryExpr(expr); end

    sig { abstract.params(expr: Variable).returns(R) }
    def visit_VariableExpr(expr); end

    sig { abstract.params(expr: Assign).returns(R) }
    def visit_AssignExpr(expr); end

    sig { abstract.params(expr: Unknown).returns(R) }
    def visit_UnknownExpr(expr); end
  end
      
  class Expr
    extend T::Sig
    extend T::Helpers

    abstract!
    sig { abstract.type_parameters(:R).params(visitor: ExprVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor); end
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

    sig { override.type_parameters(:R).params(visitor: ExprVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_BinaryExpr(self)
    end
  end
      

  class Grouping < Expr
    extend T::Sig

    sig { returns(Lox::Expr) }
    attr_reader :expression

    sig { params(expression: Lox::Expr).void }
    def initialize(expression)
      @expression = expression
    end

    sig { override.type_parameters(:R).params(visitor: ExprVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_GroupingExpr(self)
    end
  end
      

  class Literal < Expr
    extend T::Sig

    sig { returns(T.untyped) }
    attr_reader :value

    sig { params(value: T.untyped).void }
    def initialize(value)
      @value = value
    end

    sig { override.type_parameters(:R).params(visitor: ExprVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_LiteralExpr(self)
    end
  end
      

  class Unary < Expr
    extend T::Sig

    sig { returns(Lox::Token) }
    attr_reader :operator

    sig { returns(Lox::Expr) }
    attr_reader :right

    sig { params(operator: Lox::Token,right: Lox::Expr).void }
    def initialize(operator,right)
      @operator = operator
      @right = right
    end

    sig { override.type_parameters(:R).params(visitor: ExprVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_UnaryExpr(self)
    end
  end
      

  class Ternary < Expr
    extend T::Sig

    sig { returns(Lox::Expr) }
    attr_reader :clause

    sig { returns(Lox::Expr) }
    attr_reader :left

    sig { returns(Lox::Expr) }
    attr_reader :right

    sig { params(clause: Lox::Expr,left: Lox::Expr,right: Lox::Expr).void }
    def initialize(clause,left,right)
      @clause = clause
      @left = left
      @right = right
    end

    sig { override.type_parameters(:R).params(visitor: ExprVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_TernaryExpr(self)
    end
  end
      

  class Variable < Expr
    extend T::Sig

    sig { returns(Lox::Token) }
    attr_reader :name

    sig { params(name: Lox::Token).void }
    def initialize(name)
      @name = name
    end

    sig { override.type_parameters(:R).params(visitor: ExprVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_VariableExpr(self)
    end
  end
      

  class Assign < Expr
    extend T::Sig

    sig { returns(Lox::Token) }
    attr_reader :name

    sig { returns(Lox::Expr) }
    attr_reader :value

    sig { params(name: Lox::Token,value: Lox::Expr).void }
    def initialize(name,value)
      @name = name
      @value = value
    end

    sig { override.type_parameters(:R).params(visitor: ExprVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_AssignExpr(self)
    end
  end
      

  class Unknown < Expr
    extend T::Sig

    sig { override.type_parameters(:R).params(visitor: ExprVisitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_UnknownExpr(self)
    end
  end
      
end