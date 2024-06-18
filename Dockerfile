FROM --platform=linux/amd64 ubuntu:22.04
RUN apt update && apt upgrade -y && apt upgrade -y

# create user "user" with password "pass"
RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo user
RUN sh -c 'echo "user:pass" | chpasswd'

# dependencies for buildroot build
RUN apt install -y --no-install-recommends --allow-unauthenticated \
    sudo build-essential g++ git file \
    wget cpio unzip rsync bc \
    cmake libncurses5-dev libssl-dev openssh-client device-tree-compiler ca-certificates

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user

RUN mkdir -p /home/user/images

RUN git config --global --add safe.directory /home/user/br-rpizero2