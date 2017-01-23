#FROM debian:stretch
FROM nodesource/jessie
MAINTAINER Andre Vink <andre 'at' DotOne.nl>

ENV DOMOTICZ-DOCKER_UPDATE 20170122
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# install packages
RUN apt-get update && apt-get install -y \
	git \
	libssl1.0.0 libssl-dev \
	build-essential cmake \
	libboost-all-dev \
	libsqlite3-0 libsqlite3-dev \
	curl libcurl3 libcurl4-openssl-dev \
	libusb-0.1-4 libusb-dev \
	zlib1g-dev \
	libudev-dev \
	python3 \
	libpython3.4 \
        python3-dev \
    fail2ban
    # linux-headers-generic

## OpenZwave installation
# grep git version of openzwave
RUN git clone --depth 2 https://github.com/OpenZWave/open-zwave.git /src/open-zwave

# untar the files
WORKDIR /src/open-zwave

# compile
RUN make

# "install" in order to be found by domoticz
RUN ln -s /src/open-zwave /src/open-zwave-read-only

## Domoticz installation

# clone git source in src
RUN git clone --depth 2 https://github.com/domoticz/domoticz.git /src/domoticz

# Domoticz needs the full history to be able to calculate the version string
WORKDIR /src/domoticz
RUN git fetch --unshallow

# prepare makefile
RUN cmake -DCMAKE_BUILD_TYPE=Release . 

# compile
RUN make

# remove git and tmp dirs
RUN apt-get remove -y git cmake linux-headers-amd64 build-essential libssl-dev libboost-dev libboost-thread-dev libboost-system-dev libsqlite3-dev libcurl4-openssl-dev libusb-dev zlib1g-dev libudev-dev python-dev && \
   apt-get autoremove -y && \ 
   apt-get clean && \
   rm -rf /var/lib/apt/lists/*


VOLUME /config

EXPOSE 8080

ENTRYPOINT ["/src/domoticz/domoticz", "-dbase", "/config/domoticz.db", "-log", "/config/domoticz.log"]
CMD ["-www", "8080"]
