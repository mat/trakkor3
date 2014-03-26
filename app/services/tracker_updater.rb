
class TrackerUpdater
  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def update_trackers
    trackers = Tracker.all

    trackers.each do |tracker|
      logger.info("Updating tracker %d (%s),  fetching %s..." % [tracker.id, tracker.code, tracker.uri])
      update_tracker(tracker)
    end
  end

  def update_tracker(tracker)
    old_piece = tracker.current_piece
    new_piece = tracker.fetch_piece
    if(!old_piece && new_piece.text.present?)
      logger.info("Content available for the first time: %s" % [new_piece.text.colorize(:green)])
      new_piece.save!
    elsif new_piece.text.present? && !old_piece.same_content(new_piece)
      logger.info("Content changed from %s to %s" % [old_piece.text, new_piece.text.colorize(:green)])
      new_piece.save!
    else
      logger.info("Content unchanged at %s" % [old_piece.text.colorize(:yellow)])
    end

    err = new_piece.error
    if err
      record_error(tracker, err)
      logger.warn("ERROR: " + err.colorize(:red))
    else
      record_success(tracker)
    end

    if should_notify?(tracker, old_piece, new_piece)
      logger.info("POSTing to web hook at %s" % tracker.web_hook)
      notify_change(tracker, old_piece, new_piece)
    end
  end

  private
  def should_notify?(tracker, old_piece, new_piece)
    tracker.web_hook.present? && !new_piece.error && !old_piece.same_content(new_piece)
  end

  def notify_change(tracker, old_piece, new_piece)
    t = {:name => tracker.name, :uri => tracker.uri, :xpath => tracker.xpath }
    n = {:timestamp => new_piece.created_at.iso8601, :text => new_piece.text}
    o = {:timestamp => old_piece.created_at.iso8601, :text => old_piece.text}
    payload = {:change => {:tracker => t, :new => n, :old => o}}

    Typhoeus::Request.post(tracker.web_hook, {'payload' => payload.to_json}, :timeout => 4_000)
  end

  def record_error(tracker, error_message)
    tracker.error_count += 1
    tracker.update_attribute(:error_count, tracker.error_count)
    tracker.last_error = error_message
    tracker.update_attribute(:last_error, tracker.last_error)
  end

  def record_success(tracker)
    tracker.error_count = 0
    tracker.update_attribute(:error_count, tracker.error_count)
    tracker.last_error = ""
    tracker.update_attribute(:last_error, tracker.last_error)
  end

end

