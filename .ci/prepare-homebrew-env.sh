#!/usr/bin/env bash

set -eou pipefail

# the path to where an alternative install of homebrew is done to ensure we
# have access to perform 'brew install' commands.
# note that homebrew needs to be installed somewhere with a shortish
# path to avoid issues relinking dynamic libraries
# https://github.com/Homebrew/brew/issues/4979
HOMEBREW_INSTALL_PATH="/tmp/b"

# this environment variable is used by homebrew, the default is overridden
# otherwise homebrew does not allow an install in /tmp
export HOMEBREW_TEMP="/tmp/homebrew-temp"

remove_homebrew() {
  rm -rf "$HOMEBREW_INSTALL_PATH"
  rm -rf "$HOMEBREW_TEMP"
}

# do an alternative install of homebrew to ensure we have access to
# perform brew operations
# https://docs.brew.sh/Installation#untar-anywhere
install_homebrew() {
  remove_homebrew

  # https://docs.brew.sh/Installation#untar-anywhere
  git clone https://github.com/Homebrew/brew.git "$HOMEBREW_INSTALL_PATH"

  #shellcheck disable=SC2046
  eval $("$HOMEBREW_INSTALL_PATH/bin/brew" shellenv)
}

install_homebrew
