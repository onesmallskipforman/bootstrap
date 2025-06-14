#!/bin/bash
# TODO: make this script only executable as root
set -euxo pipefail # https://stackoverflow.com/questions/2870992/automatic-exit-from-bash-shell-script-on-error

LIB=$(. /etc/os-release; echo $ID).sh
. $LIB; prepRoot skipper

DIR=/home/skipper/Projects/bootstrap

mkdir -p $(dirname $DIR)
cp -r . $DIR
chown -R skipper:skipper $DIR

runuser skipper -s /bin/bash -c "set -eux; cd $DIR; source $LIB; prep"
runuser skipper -s /bin/bash -c "set -eux; cd $DIR; source $LIB; syncDots"
runuser skipper -s /bin/bash -c "set -eux; cd $DIR; source $LIB; packages"
