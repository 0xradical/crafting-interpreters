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

    ASTFields = T.type_alias { T::Hash[Symbol, String] }
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
          left: "Lox::Expr",
          operator: "Lox::Token",
          right: "Lox::Expr"
        },
        Grouping: {
          expression: "Lox::Expr"
        },
        Literal: {
          value: "T.untyped"
        },
        Unary: {
          operator: "Lox::Token",
          right: "Lox::Expr"
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
        f.write(
          %Q{
# typed: true

module Lox
#{self.define_visitor(base_name, types)}
  class #{base_name}
    extend T::Sig
    extend T::Helpers

    abstract!
    sig { abstract.type_parameters(:R).params(visitor: Visitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor); end
  end
  #{types.map{|type, fields| self.define_type(base_name, type, fields) }.join("\n")}
end}
        )
      end
    end

    sig { params(base_name: String, types: T::Hash[Symbol, ASTFields]).returns(String) }
    def self.define_visitor(base_name, types)
      clean(%Q{
  module Visitor
    extend T::Sig
    extend T::Generic
    abstract!

    R = type_member

#{types.each_pair.map{|name, _| ["    sig { abstract.params(expr: #{name}).returns(R) }\n", "    def visit_#{name}#{base_name}(expr); end"].join}.join("\n\n")}
  end
      })
    end

    sig { params(base_name: String, type: Symbol, fields: ASTFields).returns(String) }
    def self.define_type(base_name, type, fields)
      %Q{
  class #{type} < #{base_name}
    extend T::Sig

#{fields.each_pair.map{|name, t| ["    sig { returns(#{t}) }\n", '    attr_reader :',name].join}.join("\n\n")}

    sig { params(#{fields.map{|name, t| [name, ':', ' ', t].join }.join(",")}).void }
    def initialize(#{fields.map{|name, _| name}.join(",")})
#{fields.each_pair.map{|name, _| ['      @',name,' = ',name].join}.join("\n")}
    end

    sig { override.type_parameters(:R).params(visitor: Visitor[T.type_parameter(:R)]).returns(T.type_parameter(:R))}
    def accept(visitor)
      visitor.visit_#{type}#{base_name}(self)
    end
  end
      }
    end

    ##
    # Transforms any string into its snakecased equivalent,
    # ignoring the first capitalized letter, if present.
    # Ex.:
    #   firstName => first_name
    #   ClassName => class_name
    sig { params(value: String).returns(String) }
    def self.snake_case(value)
      value.gsub(/[A-Z]/) {|c| "_#{c.downcase}"}.sub(/\A_/,'')
    end

    ##
    # Removes newlines
    #
    sig { params(value: String).returns(String) }
    def self.clean(value)
      value.gsub(/\A\n+/, "")
    end
  end
end