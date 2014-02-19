#! /usr/bin/env ruby

require "logger"
require "benchmark"
   
require "rubygems"
require "typhoeus"
require "rails"
require "active_record"
require "colorize"

RAILS_ENV = ENV.fetch('RAILS_ENV')
SCRAPER_PATH = ENV.fetch('SCRAPER_PATH')

raise "SCRAPER_PATH (#{SCRAPER_PATH}) does not exist." unless File.exist? SCRAPER_PATH

require "#{SCRAPER_PATH}/app/models/tracker.rb"
require "#{SCRAPER_PATH}/app/models/piece.rb"

dbconfig = YAML::load(File.open('config/database.yml')).fetch(RAILS_ENV)
ActiveRecord::Base.establish_connection(dbconfig)  

logger = Logger.new($stderr)
Rails.logger = logger

runtime_ms = Benchmark.realtime do
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

   if tracker.should_notify?(old_piece,new_piece)
     logger.info("POSTing to web hook at %s" % tracker.web_hook)
     tracker.notify_change(old_piece, new_piece)
   end
  end
end

logger.info("Finished in %.2fs" % runtime_ms)

