# encoding: utf-8

require 'test_helper'

class PieceTest < MiniTest::Unit::TestCase
  def setup
  end

  def test_fetch_a_title
    uri = "http://www.better-idea.org"
    assert_equal "matthias lüdtke", Piece.fetch_title(uri)
  end

  def test_fetch_with_redirect
    uri = "http://better-idea.org"
    xpath = "//title"

    assert_equal "matthias lüdtke", Piece.new.fetch(uri, xpath).text
  end

  def test_fetch_on_https
    uri = "https://google.com"
    xpath = "//title"

    result = Piece.new.fetch(uri, xpath)
    assert_equal "Google", result.text
  end

#  def test_that_kitty_can_eat
#    assert_equal "OHAI!", @meme.i_can_has_cheezburger?
#  end

#  def test_that_it_will_not_blend
#    refute_match /^no/i, @meme.will_it_blend?
#  end
end

