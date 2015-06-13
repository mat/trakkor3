db_backup:
	heroku pg:backups delete `heroku pg:backups | grep "BLUE" | tail -n1 | cut -f 1 -d " "` --app trakkor --confirm trakkor
	heroku pg:backups capture --app trakkor
	curl -v --compressed -o db/production.dump `heroku pg:backups public-url`
	pg_restore -l db/production.dump

db_import:
	pg_restore --verbose --clean --no-acl --no-owner -h localhost -U trakkor -d trakkor_development db/production.dump

deploy:
	git push heroku master
	heroku config:set REVISION_DEPLOYED=`git describe --always`
	git tag deployed master -f

