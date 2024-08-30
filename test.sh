#!/bin/bash
# set -uo pipefail; set +e
source arch.sh; prepRoot
addUser skipper
chown skipper /home/skipper; chmod ug+w /home/skipper
runuser skipper -c 'source arch.sh; bootstrap'
