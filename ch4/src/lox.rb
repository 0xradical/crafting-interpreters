require_relative "./lox/token_type"
require_relative "./lox/scanner"

module Lox
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

  def self.error(line, message)
    report(line, "", message)
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
      line = gets
      # ctrl-d exists repl
      break if line.nil?

      self.run(line.chomp)
      self.error = false
    end
  end

  def self.run(source)
    scanner = Lox::Scanner.new(source)
    scanner.scan_tokens

    scanner.tokens.each do |token|
      puts(token)
    end
  end
end