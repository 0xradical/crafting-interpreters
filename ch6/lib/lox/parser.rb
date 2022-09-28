# typed: true

##
# Lox Parser
#
# Table of precedence and associativity, from lowest to highest:
#
# expression     → equality ;
# equality       → comparison ( ( "!=" | "==" ) comparison )* ;
# comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
# term           → factor ( ( "-" | "+" ) factor )* ;
# factor         → unary ( ( "/" | "*" ) unary )* ;
# unary          → ( "!" | "-" ) unary
#                | primary ;
# primary        → NUMBER | STRING | "true" | "false" | "nil"
#                | "(" expression ")" ;
#
module Lox
  class Parser
    extend T::Sig

    Error = Class.new(StandardError)

    sig { returns(Integer) }
    attr_accessor :current

    ##
    # @current points to the next token eagerly waiting to be parsed.
    #
    sig { params(tokens: T::Array[Lox::Token]).void }
    def initialize(tokens = [])
      @tokens = tokens
      @current = T.let(0, Integer)
    end

    sig { returns(Lox::Expr) }
    def expression
      equality
    end

    sig { returns(Lox::Expr) }
    def equality
      expr = comparison

      while current_matches?(
        Lox::TokenType::EQUAL_EQUAL,
        Lox::TokenType::BANG_EQUAL
      ) && previous
        operator = T.must(previous)
        right = comparison
        expr = Lox::Binary.new(expr, operator, right)
      end

      expr
    end

    sig { returns(Lox::Expr) }
    def comparison
      expr = term

      while current_matches?(
        Lox::TokenType::GREATER,
        Lox::TokenType::GREATER_EQUAL,
        Lox::TokenType::LESS,
        Lox::TokenType::LESS_EQUAL
      ) && previous
        operator = T.must(previous)
        right = term
        expr = Lox::Binary.new(expr, operator, right)
      end

      expr
    end

    sig { returns(Lox::Expr) }
    def term
      expr = factor

      while current_matches?(
        Lox::TokenType::PLUS,
        Lox::TokenType::MINUS
      ) && previous
        operator = T.must(previous)
        right = factor
        expr = Lox::Binary.new(expr, operator, right)
      end

      expr
    end

    sig { returns(Lox::Expr) }
    def factor
      expr = unary

      while current_matches?(
        Lox::TokenType::STAR,
        Lox::TokenType::SLASH
      ) && previous
        operator = T.must(previous)
        right = unary
        expr = Lox::Binary.new(expr, operator, right)
      end

      expr
    end

    sig { returns(Lox::Expr) }
    def unary
      if current_matches?(
        Lox::TokenType::BANG,
        Lox::TokenType::MINUS
      )
        return Lox::Unary.new(T.must(previous), unary)
      else
        return primary
      end
    end

    sig { returns(T.nilable(Lox::Expr)) }
    def primary
      return Lox::Literal.new(true) if current_matches?(Lox::TokenType::TRUE)
      return Lox::Literal.new(false) if current_matches?(Lox::TokenType::FALSE)
      return Lox::Literal.new(nil) if current_matches?(Lox::TokenType::NIL)

      if current_matches?(
        Lox::TokenType::STRING,
        Lox::TokenType::NUMBER
      )
        return Lox::Literal.new(T.must(previous).literal)
      end

      if current_matches?(
        Lox::TokenType::LEFT_PAREN
      )
        expr = expression
        consume!(Lox::TokenType::RIGHT_PAREN, "Expected ')' after expression")
        return Lox::Grouping.new(expr)
      end
    end

    ##
    # Checks iteratively if any of the types match
    # the current type. If it does, then consume
    #
    # @param types TODO
    # @return TODO
    sig { params(types: Lox::TokenType::Value).returns(T::Boolean) }
    def current_matches?(*types)
      types.each do |type|
        if check(type)
          consume
          return true
        end
      end

      return false
    end

    ##
    # Checks if current token is of type `type`
    #
    sig { params(type: Lox::TokenType::Value).returns(T::Boolean) }
    def check(type)
      if ended?
        false
      else
        peek.type == Lox::TokenType::IDS[type]
      end
    end


    ##
    # Consume token (move current pointer) and return it
    #
    sig { returns(T.nilable(Lox::Token)) }
    def consume
      self.current = self.current + 1 unless ended?

      return previous
    end

    ##
    # Consume given `type` or error with `message`
    #
    sig { params(type: Lox::TokenType::Value, message: String).returns(T.nilable(Lox::Token)) }
    def consume!(type, message)
      if check(type)
        return consume
      else
        raise error(peek, message)
      end
    end

    ##
    # Reports error using `Lox.error`
    # and returns an `Error` instance
    def error(token, message)
      Lox.error(token, message)

      return Error.new
    end

    sig { returns(T::Boolean) }
    def ended?
      peek.type == Lox::TokenType::EOF
    end

    ##
    # Returns current token without consuming
    # The current token is the token that is next
    # in line to be consumed.
    # This could be named "current", but "current"
    # is already being used to refer to the index of
    # the current token
    #
    sig { returns(Lox::Token) }
    def peek
      T.must(@tokens[current])
    end

    ##
    # Returns previous token
    #
    sig { returns(T.nilable(Lox::Token)) }
    def previous
      current == 0 ? nil : @tokens[current - 1]
    end
  end
end