module TrackersHelper

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    utc_timestamp = time.utc.iso8601
    content_tag(:abbr, utc_timestamp, options.merge(:title => utc_timestamp)) if time
  end

  def htidy(text)
    h(Piece.tidy_text(text))
  end
end
