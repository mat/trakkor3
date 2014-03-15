# encoding: utf-8

require 'test_helper'

class PieceTest < MiniTest::Unit::TestCase
  def setup
  end

  def test_fetch_with_umlaut
    uri = "http://www.better-idea.org"
    xpath = "//title"

    piece = Piece.new.fetch(uri, xpath)

    assert_nil piece.error
    assert_equal "matthias lüdtke", piece.text
  end

  def test_fetch_with_redirect
    uri = "http://better-idea.org"
    xpath = "//title"

    piece = Piece.new.fetch(uri, xpath)

    assert_nil piece.error
    assert_equal "matthias lüdtke", piece.text
  end

  def test_fetch_on_https
    uri = "https://google.com"
    xpath = "//title"

    piece = Piece.new.fetch(uri, xpath)

    assert_nil piece.error
    assert_equal "Google", piece.text
  end

  def test_fetch_with_non_existing_xpath_element
    uri = "http://google.com"
    xpath = "//INVALID"

    piece = Piece.new.fetch(uri, xpath)

    assert piece.error != nil
    assert_equal "", piece.text
  end

  #  def test_that_kitty_can_eat
  #    assert_equal "OHAI!", @meme.i_can_has_cheezburger?
  #  end

  #  def test_that_it_will_not_blend
  #    refute_match /^no/i, @meme.will_it_blend?
  #  end
end

