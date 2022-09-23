# typed: true

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
     self.current += 1
     c
    end

    # returns something "absurd"
    # when lookahead goes out of bounds
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

    def scan_tokens!
      while !ended?
        self.start = current
        scan_token
      end

      tokens.push(Token.new(TokenType::EOF, nil, nil, line))

      tokens
    end

    def string
      while lookahead != '"' && !ended?
        self.line += 1 if lookahead == "\n"
        advance
      end

      return Lox.error(line, "Unterminated string.") if ended?

      # The closing "
      advance

      literal = source[(start + 1)...(current - 1)]
      add_token(Lox::TokenType, literal)
    end

    def digit?(c)
      c >= '0' && c <= '9'
    end

    def number
      while digit?(lookahead)
        advance
      end

      # Look for a fractional part.

      if lookahead == '.' && digit?(lookahead(2))
        advance # consume de dot

        while digit?(lookahead)
          advance
        end
      end

      literal = (source[(start)...(current)]).to_f
      add_token(TokenType::NUMBER, literal)
    end

    def alpha?(c)
      (c >= 'a' && c <= 'z') ||
      (c >= 'A' && c <= 'Z') ||
      c == '_'
    end

    def alphanum?(c)
      alpha?(c) || digit?(c)
    end

    def keyword?(text)
      !Lox.keywords[text].nil?
    end

    def identifier
      while alphanum?(lookahead)
        advance
      end

      text = source[(start)...(current)]
      if keyword?(text)
        add_token(Lox.keywords[text])
      else
        add_token(TokenType::IDENTIFIER, text)
      end
    end

    def multiline_comment?
      lookahead == "/" && lookahead(2) == "*"
    end

    def multiline_comment(depth = 0)
      advance # *

      while !(lookahead == "*" && lookahead(2) == "/") && !ended?
        if advance == "\n"
          self.line += 1
        end

        # nesting multiline_comment
        if multiline_comment?
          multiline_comment(depth + 1)
        end
      end

      if  lookahead == "*" && lookahead(2) == "/"
        advance # *
        advance # /
      else
        Lox.error(line, "Unterminated multiline comment block.")
      end
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
      when "!"
        return add_token(match('=') ? TokenType::BANG_EQUAL : TokenType::BANG)
      when '='
        return add_token(match('=') ? TokenType::EQUAL_EQUAL : TokenType::EQUAL)
      when '<'
        return add_token(match('=') ? TokenType::LESS_EQUAL : TokenType::LESS)
      when '>'
        return add_token(match('=') ? TokenType::GREATER_EQUAL : TokenType::GREATER)

      # special case because it might a comment //
      when '/'
        if match('/') # it's a comment
          while lookahead != "\n" && !ended?
            advance
          end
          # a comment goes until the end of the line
        elsif lookahead == "*" # multiline comment
          multiline_comment
        else # it's a simple division
          return add_token(TokenType::SLASH)
        end
      when " ", "\r", "\t"
        return
      when "\n"
        self.line += 1
        return
      when '"'
        string
      else
        if digit?(c)
          number
        elsif alpha?(c)
          # we begin by assuming any lexeme starting
          # with a letter or underscore is an identifier
          identifier
        else
          return Lox.error(line, "Unexpected character.")
        end
      end
    end
  end
end