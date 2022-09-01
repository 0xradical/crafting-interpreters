module Lox
  class Token
    def initialize(type, lexeme, literal, line)
      @type, @lexeme, @literal, @line = type, lexeme, literal, line
    end

    def to_s
      "#{type} #{lexeme} #{literal}"
    end
  end
end