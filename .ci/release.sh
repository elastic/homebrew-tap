#!/usr/bin/env bash

set -eou pipefail

DOWNLOAD_BASE="$1"
VERSION="$2"

source .ci/prepare-homebrew-env.sh

# update to the new artifacts
env DOWNLOAD_BASE="$DOWNLOAD_BASE" .ci/update.sh "$VERSION"

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

