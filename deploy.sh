#!/bin/sh

set -e

SHA="master"
BZ="stuff.i/sources.bz2"

git archive $SHA | bzip2 > $BZ
scp $BZ better-idea.org:/home/trakkor
aws s3 cp $BZ s3://better-idea-box/trakkor/trakkor-sources.bz2
ssh better-idea.org "cd /home/trakkor && tar jxvf sources.bz2 -C rails_app"
ssh better-idea.org "cd /home/trakkor/rails_app && bundle install --deployment --without development test && RAILS_ENV=production bundle exec rake db:migrate && touch tmp/restart.txt"
git tag deployed $SHA -f


