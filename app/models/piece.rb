require 'rubygems'
require 'hpricot'

class Piece < ActiveRecord::Base
  belongs_to :tracker

  scope :errs, :conditions => 'NOT error IS NULL', :order => 'created_at ASC' 
  scope :old,  :conditions => ['created_at < ?', 6.months.ago]

  def fetch(uri,xpath)
    begin
      response = Piece.fetch_from_uri(uri)

      if response.success?
        _, self.text, self.error = Piece.extract_piece(response.body, xpath)
      elsif response.code.to_i == 0
        self.error = "Error: #{response.code} #{response.options.fetch(:return_code)}"
      else
        raise "Code not handled: #{response.code}"
      end
    rescue => e
      self.error = "Error: #{e.to_s}"
    end

    self
  end

  def Piece.create(source)
    p = Piece.new

    if Hpricot::Elem === source then
      p.text = source.inner_text
    end

    p
  end


  def Piece.fetch_from_uri(uri_str)
    Typhoeus::Request.get(uri_str, followlocation: true, connecttimeout: 2_000, maxredirs:4, timeout: 10_000)
  end

  def Piece.extract_piece(data, xpath)

    begin
      html, text = Piece.extract_text(data, xpath)
      raise "No DOM node found for given XPath." if html.nil?
    rescue => e
      return [nil, nil, e.to_s]
    end
 
    [html, text, nil]
  end


  def Piece.extract_elem(data,xpath)
    if Hpricot::Doc === data
      doc = data
    else
      doc = Hpricot.parse(data.to_s)
    end

    doc.at(xpath)
  end

  def Piece.extract_text(data, xpath)
    elem = Piece.extract_elem(data, xpath)
    return nil unless elem
    [elem.to_original_html, elem.inner_text]
  end


  def Piece.extract_with_parents(doc, xpath)
    piece = e = doc.at(xpath)
    parents = []
    while e.parent.class != Hpricot::Doc do
      parents << e.parent
      e = e.parent
    end
    [piece,parents[0..2]]
  end

  def Piece.fetch_title(uri)
    p = Piece.new.fetch(uri, '//head/title/text()')
    return nil if p.error
    p.text
  end

  def before_save
    self.text = Piece.tidy_text(self.text) if self.text
  end

  def same_content(other)
     !other.nil? && other.text == self.text
  end


  def Piece.html_to_text(html)
    Hpricot(html).inner_text
  end


  def Piece.tidy_text(str)
   str = tidy_tabby_lines(str)
   str = tidy_multiple_nl(str)
   str.strip[0,1_000]
  end

  def Piece.delete_old_pieces
    Piece.delete_all(['created_at < ?', 6.months.ago])
  end

  private
  def Piece.tidy_tabby_lines(str)
    str.gsub(/\n\t+\n/, "\n\n")
  end

  def Piece.tidy_multiple_nl(str)
    str.gsub(/\n\n+/, "\n")
  end
end
