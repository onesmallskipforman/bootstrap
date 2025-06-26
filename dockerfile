ARG BASE
FROM $BASE
# OS arg must go after FROM statement
# https://stackoverflow.com/a/56748289
ARG OS
SHELL ["/bin/bash", "-c"]
WORKDIR /home/skipper/Projects/bootstrap
COPY ./ ./
RUN set -e && source ${OS}.sh && prepRoot skipper
# exit is needed to allow for logout before switching users
# https://stackoverflow.com/a/72596120
RUN exit
USER skipper
RUN set -e && source $OS.sh && syncDots
RUN set -e && source $OS.sh && packages
CMD ["bash", "-li"]
