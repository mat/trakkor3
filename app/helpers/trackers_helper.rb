module TrackersHelper

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    if time
      utc_timestamp = time.utc.iso8601
      content_tag(:abbr, utc_timestamp, options.merge(:title => utc_timestamp))
    end
  end

  def htidy(text)
    h(Piece.tidy_text(text))
  end
end
