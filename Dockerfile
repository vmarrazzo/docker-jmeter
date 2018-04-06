# 1
FROM alpine:3.7

# 2
LABEL maintainer="Vincenzo Marrazzo <pariamentz@gmail.com>"

# 3 
ARG JMETER_VERSION="4.0"

# 4
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN  ${JMETER_HOME}/bin
ENV MIRROR_HOST https://archive.apache.org/dist/jmeter
ENV JMETER_DOWNLOAD_URL ${MIRROR_HOST}/binaries/apache-jmeter-${JMETER_VERSION}.tgz

# 5
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk8-jre tzdata curl unzip bash \
	&& cp /usr/share/zoneinfo/Europe/Rome /etc/localtime \
	&& echo "Europe/Rome" >  /etc/timezone \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} > /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies \
	&& rm -rf /opt/apache-jmeter-${JMETER_VERSION}/docs/ \
	&& rm -rf /opt/apache-jmeter-${JMETER_VERSION}/printable_docs/ \
	&& rm -rf /opt/apache-jmeter-${JMETER_VERSION}/licenses/

# 6
ENV PATH $PATH:$JMETER_BIN

# 7
COPY launch.sh /

# 8
WORKDIR ${JMETER_HOME}

# 9
ENTRYPOINT ["/launch.sh"]
