require 'digest/md5'
require 'json'

class Tracker < ActiveRecord::Base
  R_URI = /^(http|https):\/\/.*?$/ix

  attr_accessible :uri, :xpath, :name, :web_hook

  validates_presence_of :uri, :xpath
  validates_format_of :uri, :with =>  R_URI
  validates_format_of :web_hook, :with =>  R_URI, :allow_blank => true
  validates_uniqueness_of :md5sum

  before_create :generate_md5_key
  before_create :set_name

  after_create :push_a_piece

  # order: oldest piece first, most recent last
  has_many :pieces, :order => 'created_at ASC', :dependent => :destroy

  def to_param
    "#{md5sum}"
  end

  def generate_md5_key
    self.md5sum = SecureRandom.hex(6)
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

  def current
    changes.first
  end

  def last_modified
    last_anything = current || pieces.first
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

  def changes(whether_from_cache = [])
    all_changes = pieces
    dupefree_changes = []

    prev_change = nil
    all_changes.each do |c|
      dupefree_changes << c unless c.same_content(prev_change)
      prev_change = c
    end

    # return most recent change first and on top
    dupefree_changes.reverse
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
