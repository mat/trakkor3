require "logger"
require "benchmark"
   
require "rubygems"
require "typhoeus"
require "rails"
require "active_record"

SCRAPER_PATH = ENV.fetch('SCRAPER_PATH')

raise "SCRAPER_PATH (#{SCRAPER_PATH}) does not exist." unless File.exist? SCRAPER_PATH

require "#{SCRAPER_PATH}/app/models/tracker.rb"
require "#{SCRAPER_PATH}/app/models/piece.rb"

dbconfig = YAML::load(File.open('config/database.yml')).fetch("development")
ActiveRecord::Base.establish_connection(dbconfig)  

logger = Logger.new($stderr)
Rails.logger = logger

runtime_ms = Benchmark.realtime do
  trackers = Tracker.all

  trackers.each do |tracker|
   logger.info("Updating tracker %d. Fetching %s..." % [tracker.id, tracker.uri])

   old_piece = tracker.current
   new_piece = tracker.fetch_piece
   new_piece.save!

   if tracker.should_notify?(old_piece,new_piece)
     logger.info("POSTing to web hook at %s" % tracker.web_hook)
     tracker.notify_change(old_piece, new_piece)
   end
  end
end

logger.info("Finished in %.2fs" % runtime_ms)

