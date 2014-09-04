
set -ex

# Destroy oldest backup first
heroku pgbackups:destroy `heroku pgbackups | grep "^b" | head -n1 | cut -f 1 -d " "`

# Create a new one...
heroku pgbackups:capture

# ..and save it locally.
curl -v --compressed -o db/production.dump `heroku pgbackups:url`
pg_restore -l db/production.dump

