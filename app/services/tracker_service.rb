
class TrackerService

  def self.update_trackers(logger)
    trackers = Tracker.all

    trackers.each do |tracker|
      logger.info("Updating tracker %d (%s),  fetching %s..." % [tracker.id, tracker.md5sum, tracker.uri])

      old_piece = tracker.current
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
        tracker.error_count += 1
        tracker.update_attribute(:error_count, tracker.error_count)
        logger.warn("ERROR: " + err.colorize(:red))
      end

      if tracker.should_notify?(old_piece,new_piece)
        logger.info("POSTing to web hook at %s" % tracker.web_hook)
        tracker.notify_change(old_piece, new_piece)
      end
    end
  end

end
