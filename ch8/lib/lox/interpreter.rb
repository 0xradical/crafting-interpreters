# typed: true

module Lox
  ##
  # Interpreter for the Lox language
  #
  # Lox type	     | Ruby representation
  # ---------------+--------------------
  # Any Lox value	 | Object
  # nil	           | nil
  # Boolean	       | Boolean
  # number	       | Float
  # string	       | String
  #
  class Interpreter
    extend T::Sig
    extend T::Generic
    include ExprVisitor
    include StmtVisitor

    R = type_member {{ fixed: Object }}

    sig { returns(Lox::Environment) }
    attr_reader :environment

    def initialize
      @environment = Environment.new
    end

    # sig { params(expr: T.nilable(Expr)).returns(Object) }
    sig { params(stms: T::Array[Lox::Stmt]).void }
    def interpret(stms)
      stms.each do |stmt|
        execute(stmt)
      end
    rescue RuntimeError => e
      Lox.runtime_error(e)
    end

    sig { params(stmt: Lox::Stmt).void }
    def execute(stmt)
      stmt.accept(self)
    end

    ##
    # Unlike expressions, statements produce no values, so the return type of the visit methods is Void,
    # not Object. We have two statement types, and we need a visit method for each. The easiest is
    # expression statements.
    sig { override.params(stmt: Expression).returns(Object).checked(:never) }
    def visit_ExpressionStmt(stmt)
      evaluate(stmt.expression)
      nil
    end

    sig { override.params(stmt: Print).returns(Object).checked(:never) }
    def visit_PrintStmt(stmt)
      value = evaluate(stmt.expression)
      puts stringify(value)
      nil
    end

    sig { override.params(stmt: Var).returns(Object).checked(:never) }
    def visit_VarStmt(stmt)
      value = nil

      if stmt.initializer
        value = evaluate(T.must(stmt.initializer))
      end

      environment.define(T.must(stmt.name.lexeme), value)
      nil
    end

    ##
    # An assignment is an expression, which evaluates to the r-value
    #
    sig { override.params(expr: Assign).returns(Object).checked(:never) }
    def visit_AssignExpr(expr)
      value = evaluate(expr.value)
      environment.assign(expr.name, value)
      value
    end

    sig { override.params(expr: Variable).returns(Object).checked(:never) }
    def visit_VariableExpr(expr)
      environment.get(expr.name)
    end

    sig { override.params(expr: Grouping).returns(Object).checked(:never) }
    def visit_GroupingExpr(expr)
      evaluate(expr.expression)
    end

    sig { override.params(expr: Literal).returns(Object).checked(:never) }
    def visit_LiteralExpr(expr)
      expr.value
    end

    sig { override.params(expr: Unary).returns(Object).checked(:never) }
    def visit_UnaryExpr(expr)
      # You can start to see how evaluation recursively traverses the tree.
      # We can’t evaluate the unary operator itself until after we evaluate its operand subexpression.
      # That means our interpreter is doing a post-order traversal—each node evaluates its children before doing its own work.
      right = evaluate(expr.right)
      type = expr.operator.type

      case type
      when :MINUS
        check_number_operand(expr.operator, right);
        return (-1) * T.cast(right, Float)
      when :BANG
        return !truthy?(right)
      end
    end

    sig { override.params(expr: Binary).returns(Object).checked(:never) }
    def visit_BinaryExpr(expr)
      left = evaluate(expr.left)
      right = evaluate(expr.right)
      type = expr.operator.type

      case type
      when :MINUS
        check_number_operands(expr.operator, left, right)
        return T.cast(left, Float) - T.cast(right, Float)
      when :SLASH
        check_number_operands(expr.operator, left, right)
        return T.cast(left, Float) / T.cast(right, Float)
      when :STAR
        check_number_operands(expr.operator, left, right)
        return T.cast(left, Float) * T.cast(right, Float)
      when :PLUS
        case [ left, right ]
        in [ String, String ]
          return T.cast(left, String) + T.cast(right, String)
        in [ Float, Float ]
          return T.cast(left, Float) + T.cast(right, Float)
        else
          raise RuntimeError.new(expr.operator, "Operands must be two numbers or two strings.")
        end
      when :GREATER
        check_number_operands(expr.operator, left, right)
        return T.cast(left, Float) > T.cast(right, Float)
      when :GREATER_EQUAL
        check_number_operands(expr.operator, left, right)
        return T.cast(left, Float) >= T.cast(right, Float)
      when :LESS
        check_number_operands(expr.operator, left, right)
        return T.cast(left, Float) < T.cast(right, Float)
      when :LESS_EQUAL
        check_number_operands(expr.operator, left, right)
        return T.cast(left, Float) <= T.cast(right, Float)
      when :BANG_EQUAL
        return !equal?(left, right)
      when :EQUAL
        return equal?(left, right)
      end
    end

    sig { override.params(expr: Ternary).returns(Object).checked(:never) }
    def visit_TernaryExpr(expr)
    end

    sig { params(expr: Expr).returns(Object) }
    def evaluate(expr)
      expr.accept(self)
    end

    ##
    # Lox follows Ruby’s simple rule: false and nil are falsey, and everything else is truthy.
    #
    sig { params(value: Object).returns(T::Boolean) }
    def truthy?(value)
      return false if value.nil?
      return false if value == false

      true
    end

    ##
    # Checks for value equality
    # Use Ruby's == method to check for that
    sig { params(val: Object, other_val: Object).returns(T::Boolean) }
    def equal?(val, other_val)
      return true if val.nil? && other_val.nil?

      val == other_val
    end

    ##
    # Check if operand is a number
    #
    sig { params(operator: Lox::Token, value: Object).void }
    def check_number_operand(operator, value)
      return if value.is_a?(Float)

      raise RuntimeError.new(operator, "Operand must be a number.")
    end

    ##
    # Check if operands are both numbers
    #
    sig { params(operator: Lox::Token, left: Object, right: Object).void }
    def check_number_operands(operator, left, right)
      return if left.is_a?(Float) && right.is_a?(Float)

      raise RuntimeError.new(operator, "Operands must be numbers.")
    end

    ##
    # Returns a string representation of any value
    # produced by the interpreter's evaluation of an expression
    #
    sig { params(value: Object).returns(String) }
    def stringify(value)
      return "nil" if value.nil?

      if value.is_a?(Float)
        text = value.to_s

        # 2.0 => 2
        if text.end_with?(".0")
          text = T.must(text[0...-2])
        end

        return text
      end

      value.to_s
    end
  end
end
