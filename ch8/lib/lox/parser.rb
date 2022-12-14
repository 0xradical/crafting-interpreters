# typed: true

##
# Lox Parser
#
# Table of precedence and associativity, from lowest to highest:
#
# program         → declaration* EOF ;
# declaration     → var_decl | statement ;
# var_decl        → "var" IDENTIFIER ( "=" expression )? ";" ;
# statement       → expression_stmt | print_stmt | block ;
# block           → "{" declaration* "}" ;
# print_stmt      → "print" expression ";" ;
# expression_stmt → expression ";" ;
# expression      → assignment ;
# assignment      → IDENTIFIER "=" assignment | comma ;
# comma           → ternary ( "," ternary )* ;
# ternary         → equality ( "?" equality ":" ternary )* ;
# equality        → comparison ( ( "!=" | "==" ) comparison )* ;
# comparison      → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
# term            → factor ( ( "-" | "+" ) factor )* ;
# factor          → unary ( ( "/" | "*" ) unary )* ;
# unary           → ( "!" | "-" ) unary
#                | primary ;
# primary        → NUMBER | STRING | "true" | "false" | "nil"
#                | "(" expression ")"
#                | IDENTIFIER ;
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

    # sig { returns(T.nilable(Lox::Expr)) }
    sig { returns(T::Array[Lox::Stmt]) }
    def parse
      statements = T.let([], T::Array[Lox::Stmt])

      while !ended?
        decl = declaration

        if decl
          statements = [*statements, decl]
        end
      end

      statements
    # Syntax error recovery is the parser’s job, so we don’t want the ParseError exception
    # to escape into the rest of the interpreter.
    rescue Error => e
      []
    end

    sig { returns(T.any(NilClass, Lox::Stmt)) }
    def declaration
      if current_matches?(Lox::TokenType::VAR)
        return var_declaration
      end

      return statement
    rescue Error => e
      sync

      nil
    end

    def var_declaration
      name = T.let(
        T.must(
          consume!(
            Lox::TokenType::IDENTIFIER,
            "Expected variable name"
          )
        ),
        Lox::Token
      )

      initializer = Lox::Unknown.new

      if current_matches?(Lox::TokenType::EQUAL)
        initializer = expression
      end

      consume!(Lox::TokenType::SEMICOLON, "Expected ';' after variable declaration")

      Lox::Var.new(name, initializer)
    end

    sig { returns(Lox::Stmt) }
    def statement
      if current_matches?(Lox::TokenType::PRINT)
        return print_statement
      end

      if current_matches?(Lox::TokenType::LEFT_BRACE)
        return Lox::Block.new(block)
      end

      expression_statement
    end

    sig { returns(T::Array[Lox::Stmt]) }
    def block
      stmts = T.let([], T::Array[Lox::Stmt])

      while !check(Lox::TokenType::RIGHT_BRACE) && !ended?
        decl = declaration
        if decl
          stmts = [*stmts, decl]
        end
      end

      consume!(Lox::TokenType::RIGHT_BRACE, "Expected '}' after block")

      stmts
    end

    sig { returns(Lox::Stmt) }
    def print_statement
      value = expression
      consume!(Lox::TokenType::SEMICOLON, "Expected ';' after expression")
      Lox::Print.new(value)
    end

    sig { returns(Lox::Stmt) }
    def expression_statement
      value = expression
      consume!(Lox::TokenType::SEMICOLON, "Expected ';' after expression")
      Lox::Expression.new(value)
    end

    sig { returns(Lox::Expr) }
    def expression
      # comma
      assignment
    end

    ##
    # An l-value might be something complex, like this:
    # makeList().head.next = node;
    # But in a single-token look ahead, descent recursive parser,
    # we might not know that an l-value is a valid assignment target
    # So the trick is to parse the left-hand side as if it's an expression
    # If we bump into a "=" sign and
    # the expression evaluated is a valid assingment target
    # (currently only true if expr === Lox::Variable)
    # then we discard the whole expression and create a new node
    # that represents an assignment
    # otherwise it's an incorrect assignment
    sig { returns(Lox::Expr) }
    def assignment
      expr = comma

      # if we bump into a "=" sign, then
      # we check if the right value is a variable
      if current_matches?(Lox::TokenType::EQUAL)
        equals = previous
        # right associative , like ternary
        # so we call assignment recursively
        value = assignment

        if expr.is_a?(Lox::Variable)
          name = T.cast(expr, Lox::Variable).name
          return Lox::Assign.new(name, value)
        end

        error(equals, "Invalid assignment target")
      end

      expr
    end

    sig { returns(Lox::Expr) }
    def comma
      expr = ternary

      while current_matches?(
        Lox::TokenType::COMMA
      )
        left = expr
        operator = T.must(previous)
        right = ternary
        expr = Lox::Binary.new(left, operator, right)
      end

      expr
    end

    # https://norasandler.com/2018/02/25/Write-a-Compiler-6.html
    def ternary
      expr = equality

      while current_matches?(
        Lox::TokenType::QUESTION
      )
        left = equality
        consume!(Lox::TokenType::COLON, "Expected ':' after expression")
        right = ternary
        expr = Lox::Ternary.new(expr, left, right)
      end

      expr
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

    sig { returns(Lox::Expr) }
    def primary
      return Lox::Literal.new(true) if current_matches?(Lox::TokenType::TRUE)
      return Lox::Literal.new(false) if current_matches?(Lox::TokenType::FALSE)
      return Lox::Literal.new(nil) if current_matches?(Lox::TokenType::NIL)

      if current_matches?(
        Lox::TokenType::IDENTIFIER
      )
        return Lox::Variable.new(T.must(previous))
      end

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

      # If none of the cases in there match, it means we are sitting on a token that can’t start an expression.
      # We need to handle that error too.
      raise error(peek, "Parsing error: Expected expression")
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
      peek.type == :EOF
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

    ##
    # Synchronize the parser
    #
    # When an error happens, we don't want to stop
    # the parser immediately because some errors
    # can be dealt with in a way that the parser
    # can continue to consume the rest of the AST
    # This mechanism is called synchronization
    # We use the fact each Lox statement is finished with
    # :SEMICOLON, so the synchronization ends if one is found
    # Or if current token is any of : class, fun, var, if, while, print, return
    # we consider this the beginning of a statement
    # then we don't need to sync anymore
    def sync
      consume

      loop do
        break if previous.nil?
        break if T.must(previous).type == :SEMICOLON
        break if ended?

        case peek.type
        when :CLASS, :FUN, :VAR, :FOR, :IF, :WHILE, :PRINT, :RETURN
          break
        end

        consume
      end
    end
  end
end