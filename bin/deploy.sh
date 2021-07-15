#!/bin/bash

TMPFILE="/tmp/gitmark.$$.txt"

DEFAULT_MESSAGE="webcredits"
DEFAULT_BRANCH="gh-pages"

MESSAGE="${1:-$DEFAULT_MESSAGE}"
BRANCH="${2:-$DEFAULT_BRANCH}"

# set up btm as remote exe
BTMEXE="ssh ubuntu@157.90.144.229"

# get latest from git
git pull origin "${BRANCH}"
if [ $? -ne 0 ]
then
  echo git pull failed
  exit
fi

# commit changes
git add webcredits
git commit -m "$MESSAGE"

# check for git mark
git log -1 --pretty=%s | grep '^gitmark '
if [ $? -eq 0 ]
then
  echo git marked already
  exit
fi

# push changes to git
git push origin "${BRANCH}"

# git mark
# run twice in case new tx is not there
git mark
sleep 1
git mark > "${TMPFILE}"
# TODO check for empty tx

cat "${TMPFILE}"

TX=$( tail -1 < "${TMPFILE}" )

echo
echo "${TX}"

HASH=$(${BTMEXE} "${TX}")
echo "${HASH}" | grep '^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f].*'
if [ $? -eq 1 ]
then
  echo no hash found, something went wrong
  exit
fi
RES=$(git commit --allow-empty -m "gitmark ${HASH}")
echo "${RES}"

# add empty commit pointer
git push origin "${BRANCH}"

