#!/usr/bin/env bash

set -euo pipefail

# example: 7.2.0
VERSION=$1
# override to test staging like so:
#   https://staging.elastic.co/7.2.0-abcd1234/downloads
DOWNLOAD_BASE=${DOWNLOAD_BASE:=https://artifacts.elastic.co/downloads}

DOWNLOAD_ARGS="tap=elastic/homebrew-tap"

log() {
  echo "[homebrew-updater] $1"
}

get_sha256() {
  echo $(curl $1 | shasum -a 256 | cut -d ' ' -f 1)
}

update() {
  FORMULA_FILE=$1
  ARTIFACT_PATH=$2

  NEW_URL="$DOWNLOAD_BASE/$ARTIFACT_PATH?$DOWNLOAD_ARGS"

  log "Replacing the url, version, and emptying the sha256 of the formula '${FORMULA_FILE}'."
  /usr/bin/sed -i '' \
    -e "s~^  url \".*\"$~  url \"$NEW_URL\"~" \
    -e "s~^  version \".*\"$~  version \"$VERSION\"~" \
    -e "s~^  sha256 \".*\"$~  sha256 \"\"~" \
    "$FORMULA_FILE"

  log "Installing '${FORMULA_FILE}'."
  if BREW_INSTALL_OUTPUT=$(brew install --formula "$FORMULA_FILE" 2>&1)
  then
    echo "$BREW_INSTALL_OUTPUT"
    log "Install successful."
  else
    echo "$BREW_INSTALL_OUTPUT"
    log "The install was unsuccessful, aborting."
    exit 1
  fi

  log "Picking up the reported new sha256."
  NEW_SHA256=$(echo "$BREW_INSTALL_OUTPUT" | awk '/sha256 / { gsub("\"","");print $2 }')

  if test -z "$NEW_SHA256"
  then
    log 'No new sha256 detected. Aborting.'
    exit 1
  fi

  log "Putting the new sha256 in place."
  /usr/bin/sed -i '' \
    -e "s~^  sha256 \".*\"$~  sha256 \"$NEW_SHA256\"~" \
    "$FORMULA_FILE"

  brew uninstall --formula "$FORMULA_FILE"
}

update_multiarch() {
  FORMULA_FILE=$1
  X86_64_ARTIFACT_PATH=$2
  AARCH64_ARTIFACT_PATH=$3

  X86_64_NEW_URL="$DOWNLOAD_BASE/$X86_64_ARTIFACT_PATH?$DOWNLOAD_ARGS"
  AARCH64_NEW_URL="$DOWNLOAD_BASE/$AARCH64_ARTIFACT_PATH?$DOWNLOAD_ARGS"

  X86_64_SHASUM=$(get_sha256 $X86_64_NEW_URL)
  AARCH64_SHASUM=$(get_sha256 $AARCH64_NEW_URL)

  log "Replacing the url, version, and setting the sha256 of the formula '${FORMULA_FILE}'."
  /usr/bin/sed -i '' \
    -e "s~^  url \".*aarch.*\"$~  url \"$AARCH64_NEW_URL\"~" \
    -e "s~^  url \".*x86_64.*\"$~  url \"$X86_64_NEW_URL\"~" \
    -e "s~^  version \".*\"$~  version \"$VERSION\"~" \
    -e "s~^  sha256_x86_64 = \".*\"$~  sha256_x86_64 = \"$X86_64_SHASUM\"~" \
    -e "s~^  sha256_aarch64 = \".*\"$~  sha256_aarch64 = \"$AARCH64_SHASUM\"~" \
    "$FORMULA_FILE"

  log "Installing '${FORMULA_FILE}'."
  if BREW_INSTALL_OUTPUT=$(brew install --formula "$FORMULA_FILE" 2>&1)
  then
    echo "$BREW_INSTALL_OUTPUT"
    log "Install successful."
  else
    echo "$BREW_INSTALL_OUTPUT"
    log "The install was unsuccessful, aborting."
    exit 1
  fi

  brew uninstall --formula "$FORMULA_FILE"
}

log "Using brew: '$(which brew)'."

update "./Formula/apm-server-full.rb" "apm-server/apm-server-$VERSION-darwin-x86_64.tar.gz"

if [[ $VERSION =~ ^7\.* ]]
then
  update "./Formula/apm-server-oss.rb" "apm-server/apm-server-oss-$VERSION-darwin-x86_64.tar.gz"
fi

update "./Formula/auditbeat-full.rb" "beats/auditbeat/auditbeat-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/auditbeat-oss.rb" "beats/auditbeat/auditbeat-oss-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/filebeat-full.rb" "beats/filebeat/filebeat-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/filebeat-oss.rb" "beats/filebeat/filebeat-oss-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/heartbeat-full.rb" "beats/heartbeat/heartbeat-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/heartbeat-oss.rb" "beats/heartbeat/heartbeat-oss-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/logstash-full.rb" "logstash/logstash-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/logstash-oss.rb" "logstash/logstash-oss-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/metricbeat-full.rb" "beats/metricbeat/metricbeat-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/metricbeat-oss.rb" "beats/metricbeat/metricbeat-oss-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/packetbeat-full.rb" "beats/packetbeat/packetbeat-$VERSION-darwin-x86_64.tar.gz"
update "./Formula/packetbeat-oss.rb" "beats/packetbeat/packetbeat-oss-$VERSION-darwin-x86_64.tar.gz"

update_multiarch "./Formula/elasticsearch-full.rb" \
  "elasticsearch/elasticsearch-$VERSION-darwin-x86_64.tar.gz" \
  "elasticsearch/elasticsearch-$VERSION-darwin-aarch64.tar.gz"

update_multiarch "./Formula/kibana-full.rb" \
  "kibana/kibana-$VERSION-darwin-x86_64.tar.gz" \
  "kibana/kibana-$VERSION-darwin-aarch64.tar.gz"
