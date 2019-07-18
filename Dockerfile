FROM openjdk:8-jdk-alpine

MAINTAINER Mojammal Hock <mojammal.hock@gmail.com>

ENV MAVEN_VERSION=3.6.1
ENV MAVEN_HOME=/usr/share/maven
ENV M2_HOME=/usr/share/maven
ENV USER_HOME_DIR=/root
ENV MAVEN_OPTS="-Xms512m -Xmx512m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"
ENV PATH=${PATH}:${MAVEN_HOME}/bin
ENV MAVEN_CONFIG="$USER_HOME_DIR/.m2"

RUN apk --update add --no-cache \
        curl procps bash wget tar git ca-certificates openssl

RUN mkdir -p /usr/share/maven /usr/share/maven/ref

RUN cd /tmp
RUN wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
   && wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512

RUN echo -e "$(cat apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512)" | sha512sum -c -  \
    && tar zxf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /usr/share/maven --strip-components=1

RUN rm -rf apache-maven-${MAVEN_VERSION}-bin.tar.gz apache-maven-${MAVEN_VERSION}-bin.tar.gz.sha512

COPY docker-settings.xml /usr/local/maven/conf/settings.xml

RUN   ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
   && ln -s /usr/share/maven/bin/mvnDebug /usr/bin/mvnDebug \
   && ln -s /usr/share/maven/bin/mvnyjp /usr/bin/mvnyjp

RUN m2Version=$(mvn -v | grep -Eo "Apache Maven [0-9]{1}\.[0-9]{1}\.[0-9]{1}" | awk '{print $3}') \
    && test $m2Version = "3.6.1" && echo "maven version is -> OK"

RUN javaVersion=$(mvn -v | grep -Eo "Java version: [0-9]{1}\.[0-9]{1}\.[0-9]{1}_[0-9]{3}" | awk '{print $3}') \
    && test $javaVersion = "1.8.0_212" && echo "java version is -> OK"

CMD [""]