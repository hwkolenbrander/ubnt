FROM ubuntu:17.10
# Making my own image based on an example of jacobalberty to know and understand what is in it.

MAINTAINER Harm

ENV PKGURL=https://dl.ubnt.com/unifi/5.6.30/unifi_sysvinit_all.deb

ENV BASEDIR=/usr/lib/unifi \
    DATADIR=/unifi/data \
    LOGDIR=/unifi/log \
    CERTDIR=/unifi/cert \
    RUNDIR=/var/run/unifi \
    ODATADIR=/var/lib/unifi \
    OLOGDIR=/var/log/unifi \
    CERTNAME=cert.pem \
    CERT_IS_CHAIN=false \
    GOSU_VERSION=1.10 \
    BIND_PRIV=true \
    RUNAS_UID0=true \
    UNIFI_GID=999 \
    UNIFI_UID=999

RUN mkdir -p /usr/share/man/man1/ \
 && groupadd -r unifi -g $UNIFI_GID \
 && useradd --no-log-init -r -u $UNIFI_UID -g $UNIFI_GID unifi \
 && apt-get update \
 && apt-get install -qy --no-install-recommends \
    curl \
    dirmngr \
    gnupg \
    procps \
    libcap2-bin \
 && echo "deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti" > /etc/apt/sources.list.d/20ubiquiti.list \
 && curl -L -o ./unifi.deb "${PKGURL}" \
 && apt -qy install ./unifi.deb \
 && apt-get -qy purge --auto-remove \
    dirmngr \
    gnupg \
 && rm -f ./unifi.deb \
 && chown -R unifi:unifi /usr/lib/unifi \
 && rm -rf /var/lib/apt/lists/*


RUN rm -rf ${ODATADIR} ${OLOGDIR} \
 && mkdir -p ${DATADIR} ${LOGDIR} \
 && ln -s ${DATADIR} ${BASEDIR}/data \
 && ln -s ${RUNDIR} ${BASEDIR}/run \
 && ln -s ${LOGDIR} ${BASEDIR}/logs \
 && rm -rf {$ODATADIR} ${OLOGDIR} \
 && ln -s ${DATADIR} ${ODATADIR} \
 && ln -s ${LOGDIR} ${OLOGDIR} \
 && mkdir -p /var/cert ${CERTDIR} \
 && ln -s ${CERTDIR} /var/cert/unifi

VOLUME ["/unifi", "${RUNDIR}"]

EXPOSE 6789/tcp 8080/tcp 8443/tcp 8880/tcp 8843/tcp 3478/udp

RUN mkdir -p /usr/unifi \
     /usr/local/unifi/init.d \
     /usr/unifi/init.d
COPY docker-entrypoint.sh /usr/local/bin/
COPY docker-healthcheck.sh /usr/local/bin/
COPY functions /usr/unifi/functions
COPY import_cert /usr/unifi/init.d/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
 && chmod +x /usr/unifi/init.d/import_cert \
 && chmod +x /usr/local/bin/docker-healthcheck.sh

WORKDIR /unifi

HEALTHCHECK CMD /usr/local/bin/docker-healthcheck.sh || exit 1

# execute controller using JSVC like original debian package does
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["unifi"]

# execute the controller directly without using the service
#ENTRYPOINT ["/usr/bin/java", "-Xmx${JVM_MAX_HEAP_SIZE}", "-jar", "/usr/lib/unifi/lib/ace.jar"]
  # See issue #12 on github: probably want to consider how JSVC handled creating multiple processes, issuing the -stop instraction, etc. Not sure if the above ace.jar class gracefully handles TERM signals.
#CMD ["start"]
