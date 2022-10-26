# typed: true

module Lox
  class ASTPrinter
    extend T::Sig
    extend T::Generic
    include ExprVisitor
    include StmtVisitor

    R = type_member {{ fixed: String }}

    sig { returns(Integer) }
    attr_accessor :indent

    def initialize
      @indent = 0
    end

    sig { params(stms: T::Array[Lox::Stmt]).void }
    def print(stms)
      stms.each do |stmt|
        puts " " * self.indent + stmt.accept(self)
      end
      nil
    rescue RuntimeError => e
      Lox.runtime_error(e)
    end

    sig { override.params(stmt: Expression).returns(String).checked(:never) }
    def visit_ExpressionStmt(stmt)
      stmt.expression.accept(self)
    end

    sig { override.params(stmt: Print).returns(String).checked(:never) }
    def visit_PrintStmt(stmt)
      "print #{stmt.expression.accept(self)}"
    end

    sig { override.params(stmt: Var).returns(String).checked(:never) }
    def visit_VarStmt(stmt)
      if stmt.initializer
        parenthesize("var #{stmt.name.lexeme}", T.must(stmt.initializer))
      else
        parenthesize("var #{stmt.name.lexeme}")
      end
    end

    sig { override.params(stmt: Block).returns(String).checked(:never) }
    def visit_BlockStmt(stmt)
      inner = visit_BlockStmtRecursively(stmt, self.indent + 2)

      [
        " " * (self.indent == 0 ? self.indent : self.indent - 2) + "{",
        inner,
        " " * self.indent + "}"
      ].join("\n")
    end

    sig { override.params(stmt: If).returns(String).checked(:never) }
    def visit_IfStmt(stmt)
      if_stmt = "if (#{stmt.condition.accept(self)}) then #{stmt.then_branch.accept(self)}"
      if stmt.else_branch
        if_stmt += " else #{T.must(stmt.else_branch).accept(self)}"
      end

      if_stmt
    end

    sig { override.params(stmt: While).returns(String).checked(:never) }
    def visit_WhileStmt(stmt)
      "while (#{stmt.condition.accept(self)}) #{stmt.body.accept(self)}"
    end

    sig { params(stmt: Block, indent: Integer).returns(String) }
    def visit_BlockStmtRecursively(stmt, indent = 0)
      previous = self.indent
      self.indent = indent

      begin
        stmt.statements.map do |statement|
          " " * indent + statement.accept(self)
        end.join("\n")
      ensure
        self.indent = previous
      end
    end

    sig { override.params(stmt: Break).returns(String).checked(:never) }
    def visit_BreakStmt(stmt)
      "break"
    end

    sig { override.params(expr: Unknown).returns(String).checked(:never) }
    def visit_UnknownExpr(expr)
      "\0"
    end

    sig { override.params(expr: Assign).returns(String).checked(:never) }
    def visit_AssignExpr(expr)
      parenthesize("= #{expr.name.lexeme}", expr.value)
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

    sig { override.params(expr: Logical).returns(String).checked(:never) }
    def visit_LogicalExpr(expr)
      logical = expr.left.accept(self)

      if (expr.operator.type == :OR)
        logical += " or "
      else
        logical += " and "
      end

      logical += expr.right.accept(self)

      return "(#{logical})"
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