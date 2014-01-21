#! /bin/bash

set -e

cd /home/trakkor/rails_app

#source /home/mat/.rvm/environments/ruby-1.9.3-p429
#rvm gemset use global

export RAILS_ENV=production
export SCRAPER_PATH=/home/trakkor/rails_app

bundle exec ruby /home/trakkor/rails_app/fetch-n-save.rb >> /home/trakkor/rails_app/scrape.log 2>&1

