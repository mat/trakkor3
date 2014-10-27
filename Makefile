db_backup:
	heroku pgbackups:destroy `heroku pgbackups | grep "^b" | head -n1 | cut -f 1 -d " "`
	heroku pgbackups:capture
	curl -v --compressed -o db/production.dump `heroku pgbackups:url`
	pg_restore -l db/production.dump

db_import:
	pg_restore --verbose --clean --no-acl --no-owner -h localhost -U trakkor -d trakkor_development db/production.dump

deploy:
	git push heroku master
	heroku config:set REVISION_DEPLOYED=`git describe --always`
	git tag deployed master -f

