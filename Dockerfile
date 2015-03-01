FROM podbox/tomcat8

RUN apt-get update \
 && apt-get install -yq git \
 && apt-get clean

RUN useradd -m teamcity \
 && mkdir /logs \
 && chown -R teamcity:teamcity /apache-tomcat /logs

USER teamcity

ENV CATALINA_OPTS \
 -Xmx512m \
 -Xss256k \
 -XX:+UseCompressedOops \
 -Dfile.encoding=UTF-8 \
 -Duser.timezone=Europe/Paris

RUN sed -i 's/<Connector port="8080"/<Connector port="8080" useBodyEncodingForURI="true"/' /apache-tomcat/conf/server.xml \
 && sed -i 's/connectionTimeout="20000"/connectionTimeout="60000"/'                        /apache-tomcat/conf/server.xml

EXPOSE 8080
WORKDIR /apache-tomcat
CMD ["./bin/catalina.sh", "run"]

# --------------------------------------------------------------------- teamcity
ENV TEAMCITY_VERSION 9.0.2

RUN curl -LO http://download.jetbrains.com/teamcity/TeamCity-$TEAMCITY_VERSION.war \
 && unzip -qq TeamCity-$TEAMCITY_VERSION.war -d /apache-tomcat/webapps/teamcity \
 && rm -f TeamCity-$TEAMCITY_VERSION.war \
 && rm -f /apache-tomcat/webapps/teamcity/WEB-INF/lib/tomcat-*.jar \

 && rm -f  /apache-tomcat/webapps/teamcity/WEB-INF/plugins/clearcase.zip     \
 && rm -f  /apache-tomcat/webapps/teamcity/WEB-INF/plugins/mercurial.zip     \
 && rm -f  /apache-tomcat/webapps/teamcity/WEB-INF/plugins/*-distributor.zip \
 && rm -Rf /apache-tomcat/webapps/teamcity/WEB-INF/plugins/dot*              \

 && echo '<meta name="mobile-web-app-capable" content="yes">' >> /apache-tomcat/webapps/teamcity/WEB-INF/tags/pageMeta.tag
