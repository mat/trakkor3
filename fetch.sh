#! /bin/bash

set -e

cd /home/mat/apps/trakkor

source /usr/local/rvm/scripts/rvm
rvm gemset use global

export RAILS_ENV=production
export SCRAPER_PATH=/home/mat/apps/trakkor

bundle exec ruby /home/mat/apps/trakkor/fetch-n-save.rb >> /home/mat/apps/trakkor/scrape.log 2>&1

