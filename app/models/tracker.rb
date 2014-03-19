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

  scope :web_hooked, :conditions => 'web_hook IS NOT NULL'

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

  def errs
    pieces.errs
  end

  def changes(whether_from_cache = [])
    changes_impl
  end

  def changes_impl
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

  def last_change
    changes.first
  end
  alias :current :last_change

  def first
    changes.last
  end

  def last_modified
    last_anything = last_change || pieces.first
    return last_anything.updated_at.utc if last_anything

    Time.now.utc
  end

  def html_title
    Piece.fetch_title(self.uri)
  end

  def fetch_piece
    p = Piece.new.fetch(uri, xpath)
    p.tracker = self
    p
  end

  def notify_change(old_piece, new_piece)
    t = {:name => self.name, :uri => self.uri, :xpath => self.xpath }
    n = {:timestamp => new_piece.created_at.xmlschema, :text => new_piece.text}
    o = {:timestamp => old_piece.created_at.xmlschema, :text => old_piece.text}
    payload = {:change => {:tracker => t, :new => n, :old => o}}

    Typhoeus::Request.post(self.web_hook, {'payload' => payload.to_json}, :timeout => 4_000)
  end

  def should_notify?(old_piece, new_piece)
    self.web_hook.present? && !new_piece.error && !old_piece.same_content(new_piece)
  end

  def sick?
    self.error_count > 10
  end

  def pieces_count
    self.pieces.count
  end

  def Tracker.find_nodes_by_text(doc, str)
    nodes = []
    doc.traverse {|node| 
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
