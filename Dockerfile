FROM ubuntu:17.10
# Making my own image based on an example of jacobalberty to know and understand what is in it.

MAINTAINER Harm

ENV PKGURL=http://dl.ubnt.com/unifi/5.6.29/unifi_sysvinit_all.deb

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install dirmngr

RUN echo "deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti" > /etc/apt/sources.list.d/ubiquiti.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50

RUN apt-get -y update
RUN apt-get -y install unifi

EXPOSE 6789/tcp 8080/tcp 8443/tcp 8880/tcp 8843/tcp 3478/udp
