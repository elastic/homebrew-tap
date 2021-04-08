#!/usr/bin/env bash

set -eou pipefail

DOWNLOAD_BASE="$1"
VERSION="$2"

# update to the new artifacts
env DOWNLOAD_BASE="$DOWNLOAD_BASE" .ci/update.sh "$VERSION"

# test the formulas
.ci/test.sh

# update to the final download urls
.ci/update-to-production-downloads.sh

# create a git patch file with the updates
git checkout -b "update-$VERSION"
git add Formula
git commit -m "Update to $VERSION" -m "Updated by homebrew-tap automation."
mkdir -p .ci/output
git format-patch -1 --output=".ci/output/update-$VERSION.patch"
git checkout -

