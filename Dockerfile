FROM dockerfile/java:oracle-java8
MAINTAINER Oded Lazar oded@senexx.com

ENV DEBIAN_FRONTEND noninteractive
ENV LOGSTASH_PKG_NAME logstash-1.4.2

RUN echo $LOGSTASH_PKG_NAME
RUN 	\
	cd /tmp && \
	wget https://download.elasticsearch.org/logstash/logstash/$LOGSTASH_PKG_NAME.tar.gz && \
	tar zxvf $LOGSTASH_PKG_NAME.tar.gz && \
	rm -rf $LOGSTASH_PKG_NAME.tar.gz && \
	mv $LOGSTASH_PKG_NAME /opt/logstash && \
	mkdir -p /opt/logstash/conf.d

WORKDIR /opt/logstash

ADD config/logstash.conf conf.d/

ADD bootstrap.sh ./
RUN chmod u+x bootstrap.sh

#Install contrib plugins
#RUN bin/plugin install contrib

RUN mkdir -p /etc/pki/tls
VOLUME ["/opt/logstash/conf.d", "/etc/pki/tls"]

# lumberjack
EXPOSE 5000
# tcp connections
EXPOSE 8200

ENTRYPOINT exec bash bootstrap.sh
