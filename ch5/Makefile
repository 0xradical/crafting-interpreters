.PHONY: test pry

test:
	@ bundle exec ruby -Ilib -rlox test/**/*_test.rb

pry:
	@ bundle exec pry -Ilib -rlox

lox:
	@ ./bin/lox

dsl:
	@ ./bin/tapioca dsl
	@ ./bin/tapioca todo

tc:
	@ bundle exec srb tc

ast:
	@ bundle exec ruby -Itools -Ilib -rast -rlox -e 'Tools::AST.run' $(PWD)/lib/lox/expr.rb