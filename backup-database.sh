
cp /home/trakkor/rails_app/db/production.sqlite3 /tmp/production.sqlite3 && bzip2 --best -f /tmp/production.sqlite3 && s3cmd put /tmp/production.sqlite3.bz2 s3://better-idea-box/backups/ -v --mime-type='application/x-bzip' >> /tmp/backup-database.log 2>&1
