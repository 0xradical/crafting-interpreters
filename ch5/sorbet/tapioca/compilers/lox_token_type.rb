# typed: true
require_relative("../../../lib/lox")

module Tapioca
  module Compilers
    class LoxTokenType < ::Tapioca::Dsl::Compiler
      extend T::Sig
      ConstantType = type_member { { fixed: T.class_of(::Lox::TokenType) } }

      sig { override.void }
      def decorate
        root.create_path(constant) do |model|
          ::Lox::TokenType::IDS.each_with_index do |id, index|
            model.create_constant(id, value: "T.let(T.unsafe(nil), Integer)")
          end
        end
      end

      sig { override.returns(T::Enumerable[Module]) }
      def self.gather_constants
        [ ::Lox::TokenType ]
      end
    end
  end
end