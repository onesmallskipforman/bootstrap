ARG BASE=archlinux:base # default arg is required to prevent complaint
FROM $BASE
ARG OS # must go after FROM statement, https://stackoverflow.com/a/56748289
SHELL ["/bin/bash", "-c"]

COPY ${OS}/get-sudo ./${OS}/
RUN set -euxo pipefail && ./${OS}/get-sudo

COPY library.sh ./
RUN set -euxo pipefail && source ./library.sh && createUser skipper
# COPY common/create-user ./common/
# RUN set -euxo pipefail && ./common/create-user skipper

# need to create workdir after creating user for correct ownership
USER skipper
WORKDIR /home/skipper/Projects/bootstrap
COPY --chown=skipper:skipper library.sh ./
COPY --chown=skipper:skipper flake      ./flake

# exit needed to allow logout+login, https://stackoverflow.com/a/72596120
COPY --chown=skipper:skipper ${OS}/prep ./${OS}/
RUN ./${OS}/prep && exit

COPY --chown=skipper:skipper dotfiles ./dotfiles
RUN set -euxo pipefail && source ./library.sh && syncDots

COPY --chown=skipper:skipper ${OS}/packages ./${OS}/
RUN ./${OS}/packages

CMD ["bash", "-li"]


# USER root
# CMD ["/sbin/init"]
