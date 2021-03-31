#!/usr/bin/env bash

set -euo pipefail

TEST_FAILURE=""

log() {
  # the output from homebrew commands can be a bit much, space out our logs with some newlines
  echo
  echo "[homebrew-updater] $1"
  echo
}

brew_test() {
  FORMULA_FILE=$1

  # ensure this formula is not already installed
  if brew uninstall --formula "$FORMULA_FILE" > /dev/null
  then
    log "The formula from '${FORMULA_FILE}' appears to have already been installed, it has been uninstalled, continuing."
  fi

  log "Installing '${FORMULA_FILE}'."
  brew install --formula "$FORMULA_FILE"

  log "Testing '${FORMULA_FILE}'."

  if brew test "$FORMULA_FILE"
  then
    log "The tests were successful."
  else
    log "The tests for '${FORMULA_FILE}' failed, try running 'brew test ${FORMULA_FILE} --debug --verbose' for more information."
    TEST_FAILURE="true"
  fi

  brew uninstall --formula "$FORMULA_FILE"
}

brew_test "./Formula/apm-server-full.rb"
brew_test "./Formula/apm-server-oss.rb"
brew_test "./Formula/auditbeat-full.rb"
brew_test "./Formula/auditbeat-oss.rb"
brew_test "./Formula/elasticsearch-full.rb"
brew_test "./Formula/filebeat-full.rb"
brew_test "./Formula/filebeat-oss.rb"
brew_test "./Formula/heartbeat-full.rb"
brew_test "./Formula/heartbeat-oss.rb"
brew_test "./Formula/kibana-full.rb"
brew_test "./Formula/logstash-full.rb"
brew_test "./Formula/logstash-oss.rb"
brew_test "./Formula/metricbeat-full.rb"
brew_test "./Formula/metricbeat-oss.rb"
brew_test "./Formula/packetbeat-full.rb"
brew_test "./Formula/packetbeat-oss.rb"

if [[ $TEST_FAILURE == "true" ]]
then
  echo 'Some tests failed, exiting with error.'
  exit 1
fi
