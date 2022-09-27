# typed: true

module Lox
  class ASTPrinter
    extend T::Sig
    extend T::Generic
    include Visitor

    R = type_member {{ fixed: String }}

    sig { params(expr: Expr).returns(String) }
    def print(expr)
      expr.accept(self)
    end

    sig { override.params(expr: Binary).returns(String).checked(:never) }
    def visit_BinaryExpr(expr)
      if expr.operator.lexeme
        parenthesize(T.must(expr.operator.lexeme), expr.left, expr.right)
      else
        ""
      end
    end

    sig { override.params(expr: Grouping).returns(String).checked(:never) }
    def visit_GroupingExpr(expr)
      parenthesize("group", expr.expression)
    end

    sig { override.params(expr: Literal).returns(String).checked(:never) }
    def visit_LiteralExpr(expr)
      return "nil" if expr.value.nil?

      expr.value.to_s
    end

    sig { override.params(expr: Unary).returns(String).checked(:never) }
    def visit_UnaryExpr(expr)
      if expr.operator.lexeme
        parenthesize(T.must(expr.operator.lexeme), expr.right)
      else
        ""
      end
    end

    sig { params(name: String, exprs: Expr).returns(String).checked(:never) }
    def parenthesize(name, *exprs)
      string = "( #{name}"
      exprs.each do |expr|
        string += " "

        string += expr.accept(self)
      end

      string += ")"
      string
    end
  end
end