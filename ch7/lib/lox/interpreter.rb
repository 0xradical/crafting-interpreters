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
    include Visitor

    R = type_member {{ fixed: Object }}

    sig { params(expr: T.nilable(Expr)).returns(Object) }
    def interpret(expr)
      if expr
        evaluate(expr)
      else
        nil
      end
    end

    sig { override.params(expr: Grouping).returns(Object).checked(:never) }
    def visit_GroupingExpr(expr)
      evaluate(expr)
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
        return T.cast(left, Float) - T.cast(right, Float)
      when :SLASH
        return T.cast(left, Float) / T.cast(right, Float)
      when :STAR
        return T.cast(left, Float) * T.cast(right, Float)
      when :PLUS
        case [ left, right ]
        in [ String, String ]
          return T.cast(left, String) + T.cast(right, String)
        in [ Float, Float ]
          return T.cast(left, Float) + T.cast(right, Float)
        end
      when :GREATER
        return T.cast(left, Float) > T.cast(right, Float)
      when :GREATER_EQUAL
        return T.cast(left, Float) >= T.cast(right, Float)
      when :LESS
        return T.cast(left, Float) < T.cast(right, Float)
      when :LESS_EQUAL
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

    sig { params(val: Object, other_val: Object).returns(T::Boolean) }
    def equal?(val, other_val)
      return true if val.nil? && other_val.nil?

      val == other_val
    end
  end
end
