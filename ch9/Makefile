.PHONY: test pry help

default: help

help:	## Show this help.
	@grep -hE '^[A-Za-z0-9_ \-]*?:.*##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test: ## Run tests
	@ bundle exec ruby -Ilib -rlox test/**/*_test.rb

pry: ## Run Lox in a Pry session
	@ bundle exec pry -Ilib -rlox

lox: ## Run Lox REPL
	@ ./bin/lox

dsl: ## Generate custom DSLs for Sorbet
	@ ./bin/tapioca dsl
	@ ./bin/tapioca todo

tc: ## Type check
	@ bundle exec srb tc

ast: ## Generate Lox::Expr subclasses
	@ bundle exec ruby -Itools -Ilib -rast -rlox -e 'Tools::AST.run' $(PWD)/lib/lox/
