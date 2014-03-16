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
require "#{SCRAPER_PATH}/app/services/tracker_service.rb"

dbconfig = YAML::load(File.open('config/database.yml')).fetch(RAILS_ENV)
ActiveRecord::Base.establish_connection(dbconfig)  

logger = Logger.new($stderr)
Rails.logger = logger

logger.info("Using #{RAILS_ENV} environment.")

runtime_ms = Benchmark.realtime do
  TrackerService.update_trackers(logger)
end

logger.info("Finished in %.2fs" % runtime_ms)

