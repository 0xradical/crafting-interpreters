require "minitest/autorun"
require "pry"

class ScannerTest < Minitest::Test
  def test_simple_multiline_comment
    scanner = Lox::Scanner.new(%Q{/* test */})

    scanner.scan_tokens!

    assert_equal(scanner.line, 1)
    assert_equal(scanner.tokens, [
      Lox::Token.new(Lox::TokenType::EOF)
    ])
  end

  def test_complex_multiline_comment
    scanner = Lox::Scanner.new(%Q{/*
test if this
still doesn't emit
anything
*/})

    scanner.scan_tokens!

    assert_equal(scanner.line, 5)
    assert_equal(scanner.tokens, [
      Lox::Token.new(Lox::TokenType::EOF)
    ])
  end

  def test_nested_multiline_comment
    scanner = Lox::Scanner.new(%Q{/*
test if this
still doesn't emit
anything, even if
 /* there's a nested comment */
*/})

    scanner.scan_tokens!

    assert_equal(scanner.line, 6)
    assert_equal(scanner.tokens, [
      Lox::Token.new(Lox::TokenType::EOF)
    ])
  end
end
