# typed: true
module Lox
  class Token
    extend T::Sig
    attr_reader :lexeme, :literal, :line

    def initialize(type, lexeme = nil, literal = nil, line = nil)
      @type, @lexeme, @literal, @line = type, lexeme, literal, line
    end

    def type
      Lox::TokenType::IDS[@type]
    end

    sig { params(other: ::Lox::Token).returns(T::Boolean)}
    def ==(other)
      type == other.type &&
      @literal == other.literal &&
      @lexeme == other.lexeme
    end

    def inspect
      @__inspect ||= [
        Lox::TokenType::IDS[@type],
        @lexeme,
        @literal ? @literal.inspect : nil,
        @line ? ":#{@line}" : nil
      ].compact.join(' ')
    end
  end
end