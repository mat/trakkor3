
class Piece < ActiveRecord::Base
  belongs_to :tracker

  attr_accessor :error

  def fetch(uri,xpath)
    text, error = Piece.fetch_text(uri, xpath)

    self.text = text
    self.error = error

    self
  end

  def self.fetch_text(uri, xpath)
    service_url = "http://xpfetcher.herokuapp.com"
    service_params = {url: uri, xpath: xpath}

    begin
      response = Piece.fetch_from_uri(service_url, service_params)
    rescue => e
      error = "Error: #{e.to_s}"
      return ["", error]
    end

    if response.success?
      response_json = JSON.parse(response.body)
      text = response_json.fetch("content")
      error = response_json.fetch("error")
      return [text, error]
    elsif response.code.to_i == 0
      error = "Error: #{response.code} #{response.options.fetch(:return_code)}"
      return ["", error]
    else
      error = "Error #{response.code}"
      return ["", error]
    end
  end

  def Piece.create(source)
    p = Piece.new
    p.text = source.inner_text
    p
  end


  def Piece.fetch_from_uri(uri_str, params)
    Typhoeus::Request.get(uri_str, followlocation: true, connecttimeout: 2_000, maxredirs:4, timeout: 10_000,  params: params)
  end

  def Piece.extract_piece(data, xpath)
    html, text = Piece.extract_text(data, xpath)
    raise "No DOM node found for given XPath." if html.nil?

    [html, text, nil]
  end


  def Piece.extract_elem(data,xpath)
    puts data.class
    # puts "XPATH: %s" % xpath
    res = data.at(xpath)
    puts "RES: %s" % res
    res
  end

  def Piece.extract_text(data, xpath)
    elem = Piece.extract_elem(data, xpath)
    return nil unless elem
    [elem.to_original_html, elem.inner_text]
  end


  def Piece.extract_with_parents(doc, xpath)
    piece = e = doc.at(xpath)
    parents = []
    while e.parent.class != Nokogiri::HTML::Document do
      parents << e.parent
      e = e.parent
    end
    [piece,parents[0..2]]
  end

  def Piece.fetch_title(uri)
    p = Piece.new.fetch(uri, '//title/text()')
    if p.error
      nil 
    else
      p.text
    end
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

  private
  def Piece.tidy_tabby_lines(str)
    str.gsub(/\n\t+\n/, "\n\n")
  end

  def Piece.tidy_multiple_nl(str)
    str.gsub(/\n\n+/, "\n")
  end
end
