#!/usr/bin/env bash

set -euo pipefail

/usr/bin/sed -i '' \
  -e 's~^  url "https://staging.elastic.co/.*/downloads~  url "https://artifacts.elastic.co/downloads~' \
  Formula/*.rb
