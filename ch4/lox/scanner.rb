module Lox
  class Scanner
    attr_reader :tokens

    def initialize(source)
      @source = source
    end

    def scan_tokens
      @tokens = []
    end
  end
end