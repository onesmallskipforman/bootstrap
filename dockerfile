ARG BASE=archlinux:base # default arg is required to prevent complaint
FROM $BASE
ARG OS # must go after FROM statement, https://stackoverflow.com/a/56748289
SHELL ["/bin/bash", "-c"]

# set up working directory
WORKDIR /home/skipper/Projects/bootstrap
COPY --chown=skipper:skipper ${OS}.sh   ./
COPY --chown=skipper:skipper library.sh ./
COPY --chown=skipper:skipper flake      ./flake
COPY --chown=skipper:skipper dotfiles   ./dotfiles

# exit needed to allow logout+login, https://stackoverflow.com/a/72596120
RUN set -euxo pipefail && source ${OS}.sh && prepRoot skipper && exit
USER skipper
RUN set -euxo pipefail && source ${OS}.sh && syncDots
RUN set -euxo pipefail && source ${OS}.sh && packages
CMD ["bash", "-li"]
