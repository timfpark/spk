#!/bin/bash

set -e

RELEASE_TYPE=$1

if [[ -z "${RELEASE_TYPE}" ]]; then
  echo "Release type is not set.  Please pass in either [major, minor or patch] or any commands supported here https://yarnpkg.com/lang/en/docs/cli/version/#toc-commands"
  return 1
fi

REMOTE=${2:-origin}

RELEASE_BRANCH=$(whoami)/release

# get the latest from master, create a release branch
git checkout master
git pull
git checkout -b ${RELEASE_BRANCH}
yarn build-cmd-docs

# Do not tag commit
yarn config set version-git-tag false

# Commit message template
yarn config set version-git-message "release: ${RELEASE_TYPE} bump to v%s"

# Bump version following the specified release type format
yarn version "--${RELEASE_TYPE}"

# copy a version of the command docs
VERSION=$(cat package.json | grep '"version"' | sed -En 's/  "version": "(.*)",/\1/p')
echo "${VERSION}" >> docs/commands/releases.txt
cp docs/commands/data.json "docs/commands/data${VERSION}.json"

git push ${REMOTE} ${RELEASE_BRANCH}
