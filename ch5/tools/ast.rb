# typed: true

# Metaprogramming the trees

# Instead of tediously handwriting each AST Node class definition, field declaration,
# constructor, and initializer, we’ll hack together a script that does it for us.
# It has a description of each tree type—its name and fields—and it prints out the Ruby code
# needed to define a class with that name and state.
require "sorbet-runtime"

module Tools
  module AST
    extend T::Sig

    ASTFields = T.type_alias { T::Hash[Symbol, T.class_of(Object)] }
    Directory = T.type_alias { T.any(String, Pathname) }

    class ASTNode < T::Struct
      prop :basename, String
      prop :fields, ASTFields
    end

    sig { void }
    def self.run
      if ARGV.length != 1
        puts "Usage: ast <directory>"
        exit(64)
      else
        generate(ARGV[0])
      end
    end

    ##
    # Generates all AST Node classes in directory <directory>
    sig { params(directory: Directory).void }
    def self.generate(directory)
      define_AST(directory, "Expr", {
        Binary: {
          left: Lox::Expr,
          operator: Lox::Token,
          right: Lox::Expr
        }
      })
    end

    sig {
      params(
        directory: Directory,
        base_name: String,
        types: T::Hash[Symbol, ASTFields]
      ).void
    }
    def self.define_AST(directory, base_name, types)
      File.open(directory, "w+") do |f|
        f.write(%Q{
# typed: true

module Lox
  class Expr
    extend T::Sig
    extend T::Helpers

    abstract!
  end
  #{types.map{|type, fields| self.define_type(type, fields) }.join("\n")}
end})
      end
    end

  sig { params(type: Symbol, fields: ASTFields).returns(String) }
  def self.define_type(type, fields)
    %Q{
  class #{type} < Expr
    extend T::Sig

#{fields.each_pair.map{|name, t| ['    ', "sig { returns(#{t}) }\n", '    ', 'attr_reader :',name].join}.join("\n\n")}

    sig { params(#{fields.map{|name, t| [name, ':', ' ', t].join }.join(",")}).void }
    def initialize(#{fields.map{|name, _| name}.join(",")})
#{fields.each_pair.map{|name, _| ['      ', '@',name,' = ',name].join}.join("\n")}
    end
  end}
    end
  end
end