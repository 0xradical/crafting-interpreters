# typed: true
# frozen_string_literal: true

require "sorbet-runtime"
require "tapioca/dsl"
require "pathname"
$LOAD_PATH.unshift(Pathname.new(__dir__) / ".." / ".." / "lib")
require "lox"