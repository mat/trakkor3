updated = @tracker.last_modified

if @tracker.sick?
  sick_note = '<br> This tracker may be <strong>SICK</strong>, inspect errors on Trakkor page above.'
else
  sick_note = ''
end

atom_feed(:root_url => url_for(:only_path => false)) do |feed|
  if @tracker.sick?
    feed.title("Trakkor (sick!) - #{@tracker.name}", :type => 'text')
  else
    feed.title("Trakkor - #{@tracker.name}", :type => 'text')
  end
  feed.updated(updated)
  feed.subtitle("This tracker observes <a href='#{@tracker.uri}'>#{@tracker.uri}</a>.<br /> View and change tracker settings at <a href='#{url_for :only_path => false}'>#{@tracker.name}</a>" + sick_note, :type => 'html')
  feed.link(:href => url_for(:only_path => false, :format => 'atom'), :rel =>'self')

  for piece in @tracker.pieces
    feed.entry(piece, :url => @tracker.uri) do |entry|
      entry.title(piece.text, :type => 'text')
      entry.content(piece.text, :type => 'text')

      entry.author do |author|
        author.name("via Trakkor")
      end
    end
  end
end

