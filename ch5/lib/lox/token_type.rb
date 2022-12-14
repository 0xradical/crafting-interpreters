# typed: true

module Lox
  module TokenType
    extend T::Sig

    IDS = T.let([
      # single-character tokens
      :LEFT_PAREN,
      :RIGHT_PAREN,
      :LEFT_BRACE,
      :RIGHT_BRACE,
      :COMMA,
      :DOT,
      :MINUS,
      :PLUS,
      :SEMICOLON,
      :SLASH,
      :STAR,

      # one or two character tokens
      :BANG,
      :BANG_EQUAL,
      :EQUAL,
      :EQUAL_EQUAL,
      :GREATER,
      :GREATER_EQUAL,
      :LESS,
      :LESS_EQUAL,

      # literals
      :IDENTIFIER,
      :STRING,
      :NUMBER,

      # keywords
      :AND,
      :CLASS,
      :ELSE,
      :FALSE,
      :FUN,
      :FOR,
      :IF,
      :NIL,
      :OR,
      :PRINT,
      :RETURN,
      :SUPER,
      :THIS,
      :TRUE,
      :VAR,
      :WHILE,


      :EOF
    ], T::Array[Symbol])

    IDS.each_with_index do |type, index|
      eval("#{type} = #{index}")
    end
  end
end