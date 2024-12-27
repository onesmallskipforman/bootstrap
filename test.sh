#!/bin/bash
set -euxo pipefail # https://stackoverflow.com/questions/2870992/automatic-exit-from-bash-shell-script-on-error
# source arch.sh; prepRoot skipper
# runuser skipper -c 'source arch.sh; bootstrap'

source ubuntu.sh; prepRoot skipper
runuser skipper -s /bin/bash -c 'set -eux; source ubuntu.sh; bootstrap'
