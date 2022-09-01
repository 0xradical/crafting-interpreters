module Lox
  class Scanner
    attr_reader :tokens, :length, :source
    attr_accessor :start, :current, :line

    def initialize(source)
      @source = source
      @length = source.length
      @start = 0
      @current = 0
      @line = 1
      @tokens = []
    end

    def ended?
      current >= length
    end

    # everytime we call advance
    # the pointer "current" points
    # to the next first character
    # that wasn't tokenized yet
    def advance
     c = source[current]
     current += 1
     c
    end

    def lookahead(n = 1)
      return "\0" if ended?
      source[current + n - 1]
    end

    def match(expected)
      return false if ended?
      return false if source[current] != expected

      advance

      return true
    end

    def add_token(token_type, literal = nil)
      text = source[start..current]
      @tokens.push(Token.new(token_type, text, literal, line))
    end

    def scan_tokens
      while !ended?
        start = current
        scan_token
      end

      tokens.push(Token.new(TokenType::EOF, "", nil, line))

      tokens
    end

    def scan_token
      c = advance

      case c
      when "("
        return add_token(TokenType::LEFT_PAREN)
      when ")"
        return add_token(TokenType::RIGHT_PAREN)
      when "{"
        return add_token(TokenType::LEFT_BRACE)
      when "}"
        return add_token(TokenType::RIGHT_BRACE)
      when ","
        return add_token(TokenType::COMMA)
      when "."
        return add_token(TokenType::DOT)
      when "-"
        return add_token(TokenType::MINUS)
      when "+"
        return add_token(TokenType::PLUS)
      when ";"
        return add_token(TokenType::SEMICOLON)
      when "*"
        return add_token(TokenType::STAR)
      when "!":
        return add_token(match('=') ? TokenType::BANG_EQUAL : TokenType::BANG)
      when '=':
        return add_token(match('=') ? TokenType::EQUAL_EQUAL : TokenType::EQUAL)
      when '<'
        return add_token(match('=') ? TokenType::LESS_EQUAL : TokenType::LESS)
      when '>'
        return add_token(match('=') ? TokenType::GREATER_EQUAL : TokenType::GREATER)

      # special case because it might a comment //
      when '/':
        if match('/') # it's a comment
          advance while lookahead != "\n" && !ended?
          # a comment goes until the end of the line
        else # it's a simple division
          return add_token(TokenType::SLASH)
        end
      when " ", "\r", "\t"
        return
      when "\n"
        self.line += 1
        return
      else
        return Lox.error(line, "Unexpected character.")
      end
    end
  end
end