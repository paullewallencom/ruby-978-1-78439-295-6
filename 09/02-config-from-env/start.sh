#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DIR="$(cd "$(dirname "$0")" && pwd)"
export $($DIR/config/env-echo.sh | xargs)

# app-specific startup, in this case a Rack web app
rackup