
set -e

git archive master | bzip2 > sources.bz2
scp sources.bz2 better-idea.org:/home/trakkor
aws s3 cp sources.bz2 s3://better-idea-box/trakkor/trakkor-sources.bz2
ssh better-idea.org "cd /home/trakkor && tar jxvf sources.bz2 -C rails_app"
ssh better-idea.org "cd /home/trakkor/rails_app && bundle install --deployment --without development test && RAILS_ENV=production bundle exec rake db:migrate && touch tmp/restart.txt"
