#!/bin/sh

set -e

git push heroku master
heroku config:set REVISION_DEPLOYED=`git describe --always`
git tag deployed master -f

