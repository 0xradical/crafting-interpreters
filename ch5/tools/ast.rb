module Tools
  module AST
    def self.run
      if ARGV.length != 1
        puts "Usage: ast <directory>"
        exit(64)
      else
        generate(ARGV[0])
      end
    end

    def self.generate(directory)
      define(directory, "Expr", {
        "Binary": [:left, :operator, :right]
      })
    end
  end
end