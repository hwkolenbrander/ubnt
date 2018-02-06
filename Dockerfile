FROM ubuntu:17.10
# Making my own image based on an example of jacobalberty to know and understand what is in it.

MAINTAINER Harm

ENV PKGURL=http://dl.ubnt.com/unifi/5.6.29/unifi_sysvinit_all.deb

RUN apt-get -y update
RUN apt-get -y upgrade

RUN deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti
RUN apt-key -y adv --keyserver keyserver.ubuntu.com --recv C0A52C50

RUN apt-get -y update
RUN apt-get -y install unifi

