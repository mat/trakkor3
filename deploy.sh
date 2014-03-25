#!/bin/sh

set -e

SHA="master"
BZ="stuff.i/sources.bz2"
SSH_USER="trakkor"

AWS_ACCESS_KEY_ID=AKIAJJQTR75K7IHKUO2Q
AWS_SECRET_ACCESS_KEY='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'

git archive $SHA | bzip2 > $BZ
scp $BZ $SSH_USER@better-idea.org:/home/trakkor
aws s3 cp $BZ s3://better-idea-box/trakkor/trakkor-sources.bz2
ssh $SSH_USER@better-idea.org "cd /home/trakkor && tar jxvf sources.bz2 -C rails_app"
ssh $SSH_USER@better-idea.org "cd /home/trakkor/rails_app && bundle install --deployment --without development test && RAILS_ENV=production bundle exec rake db:migrate && touch tmp/restart.txt"
git tag deployed $SHA -f


