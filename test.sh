#!/bin/bash
# set -uo pipefail; set +e
source arch.sh; prepRoot skipper
runuser skipper -c 'source arch.sh; bootstrap'
