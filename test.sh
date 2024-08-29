#!/bin/bash
# set -uo pipefail; set +e
source arch.sh && prep

chown skipper /home/skipper
chmod u+w /home/skipper
chmod g+w /home/skipper

runuser skipper -c 'source arch.sh && packages'
