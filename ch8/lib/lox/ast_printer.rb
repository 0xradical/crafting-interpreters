# typed: true

module Lox
  class ASTPrinter
    extend T::Sig
    extend T::Generic
    include ExprVisitor
    include StmtVisitor

    R = type_member {{ fixed: String }}

    sig { params(stms: T::Array[Lox::Stmt]).void }
    def print(stms)
      stms.each do |stmt|
        stmt.accept(self)
      end
    rescue RuntimeError => e
      Lox.runtime_error(e)
    end

    sig { override.params(stmt: Expression).returns(String).checked(:never) }
    def visit_ExpressionStmt(stmt)
      stmt.expression.accept(self)
    end

    sig { override.params(stmt: Print).returns(String).checked(:never) }
    def visit_PrintStmt(stmt)
      stmt.expression.accept(self)
    end

    sig { override.params(stmt: Var).returns(String).checked(:never) }
    def visit_VarStmt(stmt)
      if stmt.initializer
        parenthesize("var #{stmt.name}", T.must(stmt.initializer))
      else
        parenthesize("var #{stmt.name}")
      end
    end

    sig { override.params(expr: Variable).returns(String).checked(:never) }
    def visit_VariableExpr(expr)
      expr.name.lexeme || ""
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

    sig { override.params(expr: Ternary).returns(String).checked(:never) }
    def visit_TernaryExpr(expr)
      parenthesize("?:", expr.clause, expr.left, expr.right)
    end

    sig { params(name: String, exprs: Expr).returns(String).checked(:never) }
    def parenthesize(name, *exprs)
      string = "( #{name}"
      exprs.each do |expr|
        string += " "

        string += expr.accept(self)
      end

      string += " )"
      string
    end
  end
end