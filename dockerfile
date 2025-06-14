FROM ubuntu:24.04
SHELL ["/bin/bash", "-c"]
RUN apt update
WORKDIR /home/skipper/bootstrap
COPY . .
RUN source ubuntu.sh && prepRoot skipper
USER skipper
RUN source ubuntu.sh && get_ros2
CMD ["bash", "-i"]
# EXPOSE 3000
