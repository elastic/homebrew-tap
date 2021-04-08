#!/usr/bin/env bash

set -eou pipefail

DOWNLOAD_BASE="$1"
VERSION="$2"

install_homebrew() {
  # do an alternative install of homebrew to ensure we have access to
  # perform brew operations
  # https://docs.brew.sh/Installation#untar-anywhere
  # note that homebrew needs to be installed somewhere with a shortish
  # path to avoid issues relinking dynamic libraries
  # https://github.com/Homebrew/brew/issues/4979
  rm -rf "/tmp/b"
  git clone https://github.com/Homebrew/brew.git "/tmp/b"
  #shellcheck disable=SC2046
  eval $("/tmp/b/bin/brew" shellenv)
  # override the default temp directory, by default homebrew does not
  # allow an install in /tmp otherwise
  export HOMEBREW_TEMP=/tmp/homebrew-temp
}

remove_homebrew() {
  rm -rf "/tmp/b"
}

install_homebrew

# update to the new artifacts
env DOWNLOAD_BASE="$DOWNLOAD_BASE" .ci/update.sh "$VERSION"

# test the formulas
.ci/test.sh

# update to the final download urls
.ci/update-to-production-downloads.sh

# create a git patch file with the updates
UPDATE_BRANCH_NAME="update-$VERSION-$(date -u +%Y%m%d%H%M)"
git checkout -b "$UPDATE_BRANCH_NAME"
git add Formula
git commit -m "Update to $VERSION" -m "Updated by homebrew-tap automation."
mkdir -p .ci/output
git format-patch -1 --stdout > ".ci/output/update-$VERSION.patch"
git checkout -

remove_homebrew

