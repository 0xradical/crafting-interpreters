# typed: true
module Lox
  class Token
    extend T::Sig

    sig { returns(T.nilable(String)) }
    attr_reader :lexeme

    sig { returns(T.nilable(String))}
    attr_reader :literal

    sig { returns(Integer) }
    attr_reader :line

    ##
    # Lexeme is nilable for EOF token
    #
    sig { params(type_value: Lox::TokenType::Value, lexeme: T.nilable(String), literal: T.nilable(String), line: Integer).void }
    def initialize(type_value, lexeme, literal = nil, line = -1)
      @type_value, @lexeme, @literal, @line = type_value, lexeme, literal, line
    end

    sig { returns(T.nilable(Symbol)) }
    def type
      Lox::TokenType::IDS[T.let(@type_value, Lox::TokenType::Value)]
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