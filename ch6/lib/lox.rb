# typed: true
require 'sorbet-runtime'
require_relative "./lox/token_type"
require_relative "./lox/token"
require_relative "./lox/scanner"
require_relative "./lox/expr"
require_relative "./lox/ast_printer"
require_relative "./lox/parser"

module Lox
  extend T::Sig
  @@error = false

  def self.error=(bool)
    @@error = bool
  end

  def self.error?
    @@error
  end

  # For exit codes, I’m using the conventions defined in the UNIX “sysexits.h” header.
  # It’s the closest thing to a standard I could find.
  def self.boot
    if ARGV.length > 1
      puts "Usage: lox [script]"
      exit(64)
    elsif ARGV.length == 1
      self.run_file(ARGV[0])
    else
      puts "Running in REPL mode"
      self.run_prompt
    end
  end

  sig { params(line: T.any(String, Lox::Token), message: String).void }
  def self.error(line, message)
    case line
    when String
      report(line, "", message)
    when Lox::Token
      if line.type == Lox::TokenType::IDS[Lox::TokenType::EOF]
        report(line.line," at end", message)
      else
        report(line.line," at '#{line.lexeme}'", message)
      end
    else
      T.absurd(line)
    end
  end

  def self.report(line, where, message)
    STDERR.puts "[line #{line}] Error#{where}: #{message}"
    self.error = true
  end

  def self.run_file(path)
    self.run(File.read(path))
    exit(65) if self.error?
  end

  def self.run_prompt
    loop do
      print "> "
      line = gets.chomp
      # ctrl-d exists repl
      break if line == ?\C-d || line == "exit" || line == ?\C-c

      self.run(line.chomp)
      self.error = false
    end
  end

  def self.run(source)
    scanner = Lox::Scanner.new(source)
    scanner.scan_tokens!

    parser = Lox::Parser.new(scanner.tokens)
    expression = parser.parse

    return if self.error?

    puts Lox::ASTPrinter.new.print(expression)
  end

  # keywords
  def self.keywords
    @@keywords ||= [
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
      :WHILE
    ].reduce(Hash.new) do |acc, kw|
      { **acc, kw.downcase.to_s => Lox::TokenType.const_get(kw) }
    end
  end
end