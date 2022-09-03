module Lox
  class Token
    def initialize(type, lexeme, literal, line)
      @type, @lexeme, @literal, @line = type, lexeme, literal, line
    end

    def inspect
      @__inspect ||= [
        Lox::TokenType::IDS[@type],
        @lexeme,
        @literal ? @literal.inspect : nil
      ].compact.join(' ')
    end
  end
end