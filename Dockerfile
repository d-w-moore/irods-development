FROM ubuntu:18.04
RUN apt update
RUN apt install -y vim git tig sudo python curl wget nano
WORKDIR /root
RUN git clone http://github.com/d-w-moore/ubuntu_irods_installer
RUN ./ubuntu_irods_installer/install.sh --w='config-essentials create-db add-needed-runtime' 0
RUN ./ubuntu_irods_installer/install.sh -r 4
