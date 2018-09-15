#!/usr/bin/env bash
git config --global user.email $GH_EMAIL
git config --global user.name $GH_NAME

# This hack is needed in order to install/use multiple SSH keys for the same host.
# In this case, the host is github.com. CircleCI installs them all with the same
# "Host" (eg, github.com) and so they can't be distinguished. This script assumes
# they will be named "gh-prod" and adds the "github.com" as a HostName setting.
sed -i -e 's/Host gh-prod/Host gh-prod\n  HostName github.com/g' ~/.ssh/config
git clone git@gh-prod:$GH_ORG_PROD/sdg-data.git out

cd out
git checkout master || git checkout --orphan master
git rm -rfq .
cd ..

# The fully built site is already available at /tmp/build.
cp -a /tmp/build/_site/. out/.

mkdir -p out/.circleci && cp -a .circleci/. out/.circleci/.
cd out

git add -A
git commit -m "Automated deployment to GitHub Pages: ${CIRCLE_SHA1}" --allow-empty

git push origin master