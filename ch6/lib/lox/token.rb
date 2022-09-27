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
    sig { params(type: Integer, lexeme: T.nilable(String), literal: T.nilable(String), line: Integer).void }
    def initialize(type, lexeme, literal = nil, line = -1)
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