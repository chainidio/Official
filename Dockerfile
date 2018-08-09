FROM jeanblanchard/java:jre-8
LABEL MAINTAINER Xing Chain <dev@chainid.io>
LABEL version="1.11.13"

ENV NRSVersion=1.11.13

RUN \
  apk update && \
  apk add wget gpgme && \
  mkdir /bcid-boot && \
  mkdir /bcid && \
  cd /

ADD scripts /bcid-boot/scripts

VOLUME /bcid
WORKDIR /bcid-boot

ENV BCIDNET main	

COPY ./bcid-main.properties /bcid-boot/conf/
COPY ./bcid.properties /bcid-boot/conf/
COPY ./bcid-test.properties /bcid-boot/conf/
COPY ./init-bcid.sh /bcid-boot/

EXPOSE 6868 8686 6969 9696 6789 8888 9999

CMD ["/bcid-boot/init-bcid.sh", "/bin/sh"]
