require 'digest/md5'
require 'json'

class Tracker < ActiveRecord::Base
  R_URI = /^(http|https):\/\/.*?$/ix

  attr_accessible :uri, :xpath, :name, :web_hook

  validates_presence_of :uri, :xpath
  validates_format_of :uri, :with =>  R_URI
  validates_format_of :web_hook, :with =>  R_URI, :allow_blank => true
  validates_uniqueness_of :code

  before_create :generate_md5_key
  before_create :set_name

  after_create :push_a_piece

  has_many :pieces, :order => 'created_at DESC', :dependent => :destroy

  def to_param
    "#{code}"
  end

  def generate_md5_key
    self.code = SecureRandom.hex(6)
  end

  def validate_on_create
    @first_piece = fetch_piece
    if @first_piece.error
      errors.add("URI and XPath", "yield no content")
    end
  end

  def set_name
    self.name ||= "Tracker for #{html_title || uri}"
  end

  def before_update
    set_name
  end

  def Tracker.uri?(str)
    str =~ R_URI
  end

  def push_a_piece
    fetch_piece.save!
  end

  def current_piece
    pieces.first
  end

  def last_modified
    last_anything = current_piece
    if last_anything
      last_anything.updated_at.utc
    else
      Time.now.utc
    end
  end

  def html_title
    Piece.fetch_title(self.uri)
  end

  def fetch_piece
    p = Piece.new.fetch(uri, xpath)
    p.tracker = self
    p
  end

  def sick?
    self.error_count > 10
  end

  def pieces_count
    self.pieces.count
  end

  def self.fetch_doc_from(uri)
    unless Tracker.uri?(uri)
      err = "Please provide a proper HTTP URI like http://w3c.org"
      return nil, err
    end

    response= Piece.fetch_from_uri(uri, {})
    unless response.success?
      err =  "Could not fetch the document, " +
        "server returned: #{response.code} #{response.body}"
      return nil, err
    end

    doc = Nokogiri::HTML(response.body)
    unless doc
      err = 'URI does not point to a document that Trakkor understands.'
      return nil, err
    end

    return doc, nil
  end

  def Tracker.find_nodes_by_text(doc, str)
    nodes = []
    doc.traverse { |node|
      if(node.inner_text =~ /#{str}/i)
        nodes << node
      end
    }

    nodes
  end

  def Tracker.live_examples
    Tracker.find_all_by_id(APP_CONFIG['example_trackers'] || [])
  end

  private
  def Tracker.collect_parents(n, parents)
    return if n.class == Hpricot::Doc

    if n.parent
      parents << n.parent
      collect_parents(n.parent, parents)
    end
  end

end
