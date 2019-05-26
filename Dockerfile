# build docker image to run the unifi controller
#
# the unifi contoller is used to admin ubunquty wifi access points
#
#Use Ubuntu 16.4 == xenial
FROM ubuntu:bionic
MAINTAINER harm
ENV DEBIAN_FRONTEND noninteractive

RUN mkdir -p /var/log/supervisor /usr/lib/unifi/data && \
    touch /usr/lib/unifi/data/.unifidatadir

# Install MongoDB
RUN apt update; apt upgrade -y; apt dist-upgrade -y; apt autoremove -y; apt autoclean -y; apt install -y software-properties-common; apt install -y curl; apt install -y wget

RUN echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list
RUN codename=xenial; mongodb=3.4; wget -qO- https://www.mongodb.org/static/pgp/server-${mongodb}.asc | apt-key add
RUN apt update
RUN apt install -y mongodb-org

# Install Azul OpenJDK Java version 11
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
RUN apt-add-repository 'deb http://repos.azulsystems.com/ubuntu stable main'
RUN apt install zulu-11 -y
RUN echo "JAVA_HOME="/usr/lib/jvm/zulu-11"" >> /etc/environment

# RUN source /etc/environment

RUN set +e
RUN apt update
RUN apt install jsvc libcommons-daemon-java -y
RUN set -e

RUN apt install -y libcap2
# RUN wget https://dl.ubnt.com/unifi/5.8.30/unifi_sysvinit_all.deb
RUN wget https://dl.ubnt.com/unifi/5.10.24/unifi_sysvinit_all.deb
RUN dpkg -i unifi_sysvinit_all.deb
RUN rm ./unifi_sysvinit_all.deb
# RUN service unifi start

# add unifi and mongo repo
#ADD ./100-ubnt.list /etc/apt/sources.list.d/100-ubnt.list
# RUN echo "deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti" > /etc/apt/sources.list.d/100-ubnt.list

# add ubiquity + 10gen(mongo) repo + key
# update then install
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50 && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10 && \
#    apt-get update -q -y && \
#    apt-get install -q -y mongodb-server unifi

VOLUME /usr/lib/unifi/data
EXPOSE  8443 8880 8080 27117 3478/udp 10001/udp
WORKDIR /usr/lib/unifi
CMD ["java", "-Xmx256M", "-jar", "/usr/lib/unifi/lib/ace.jar", "start"]
