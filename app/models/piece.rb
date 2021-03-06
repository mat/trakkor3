class Piece < ActiveRecord::Base
  belongs_to :tracker

  attr_accessor :error

  def fetch(uri,xpath)
    text, error = Piece.fetch_text(uri, xpath)

    self.text = text
    self.error = error

    self
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
    text, _ = Piece.fetch_text(uri, '//title/text()')
    return text
  end

  def before_save
    self.text = Piece.tidy_text(self.text) if self.text
  end

  def same_content(other)
    !other.nil? && other.text == self.text
  end

  def Piece.tidy_text(str)
    str = tidy_tabby_lines(str)
    str = tidy_multiple_nl(str)
    str.strip[0,1_000]
  end

  private
  def self.fetch_text(uri, xpath)
    service_url = "http://getxpath.better-idea.org/get"
    service_params = {url: uri, xpath: xpath}

    begin
      response = Piece.fetch_from_uri(service_url, service_params)
    rescue => e
      error = "Error: #{e.to_s}"
      return ["", error]
    end

    if response.success?
      response_json = JSON.parse(response.body)
      text = response_json.fetch("result")
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

  def Piece.fetch_from_uri(uri_str, params)
    Typhoeus::Request.get(uri_str, followlocation: true, connecttimeout: 2_000, maxredirs:4, timeout: 10_000,  params: params)
  end

  def Piece.tidy_tabby_lines(str)
    str.gsub(/\n\t+\n/, "\n\n")
  end

  def Piece.tidy_multiple_nl(str)
    str.gsub(/\n\n+/, "\n")
  end
end
