#!/bin/bash
set -euxo pipefail # https://stackoverflow.com/questions/2870992/automatic-exit-from-bash-shell-script-on-error

DIST=$(source /etc/os-release; echo $ID)
source $DIST.sh; prepRoot skipper
runuser skipper -s /bin/bash -c "set -eux; source $DIST.sh; prep; packages"
