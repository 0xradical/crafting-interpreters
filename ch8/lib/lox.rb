# typed: true
require 'sorbet-runtime'
require "pry"
require_relative "./lox/token_type"
require_relative "./lox/token"
require_relative "./lox/scanner"
require_relative "./lox/expr"
require_relative "./lox/stmt"
require_relative "./lox/ast_printer"
require_relative "./lox/parser"
require_relative "./lox/environment"
require_relative "./lox/interpreter"

module Lox
  class RuntimeError < StandardError
    extend T::Sig

    sig { returns(Lox::Token) }
    attr_reader :token

    sig { params(token: Lox::Token, message: String).void }
    def initialize(token, message)
      @token, @message = token, message
      super(message)
    end
  end

  extend T::Sig
  @@error = false
  @@runtime_error = false
  @@interpreter = Lox::Interpreter.new

  def self.error=(bool)
    @@error = bool
  end

  def self.error?
    @@error
  end

  def self.runtime_error=(bool)
    @@runtime_error = bool
  end

  def self.runtime_error?
    @@runtime_error
  end

  sig { returns(Lox::Interpreter) }
  def self.interpreter
    @@interpreter
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

  sig { params(error: Lox::RuntimeError).void }
  def self.runtime_error(error)
    STDERR.puts "#{error.message}\n[line #{error.token.line} ]"
    self.runtime_error = true
  end

  def self.report(line, where, message)
    STDERR.puts "[line #{line}] Error#{where}: #{message}"
    self.error = true
  end

  ##
  # sysexists.h
  #
  # EX_DATAERR (65)	   The input data was incorrect in some way.  This
  # should only be used for user's data and not system
  # files.
  #
  # EX_SOFTWARE (70)	   An internal software error has been detected.  This
  # should be limited to non-operating system related
  # errors as possible.
  #
  # @param path TODO
  # @return TODO
  def self.run_file(path)
    self.run(File.read(path))
    exit(65) if self.error?
    exit(70) if self.runtime_error?
  end

  def self.run_prompt
    loop do
      print "> "
      line = gets.chomp
      # ctrl-d exists repl
      break if line == ?\C-d || line == "exit" || line == ?\C-c

      self.run(line.chomp)
      self.error = false
      self.runtime_error = false
    end
  end

  def self.run(source)
    scanner = Lox::Scanner.new(source)
    scanner.scan_tokens!

    parser = Lox::Parser.new(scanner.tokens)
    statements = parser.parse

    return if self.error?

    Lox::ASTPrinter.new.print(statements)
    self.interpreter.interpret(statements)
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