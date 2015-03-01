FROM podbox/tomcat8

RUN apt-get update \
 && apt-get install -yq git \
 && apt-get clean

# --------------------------------------------------------------------- teamcity
ENV TEAMCITY_VERSION 9.0.2

RUN curl -LO http://download.jetbrains.com/teamcity/TeamCity-$TEAMCITY_VERSION.war \
 && unzip -qq TeamCity-$TEAMCITY_VERSION.war -d /apache-tomcat/webapps/teamcity \
 && rm -f TeamCity-$TEAMCITY_VERSION.war \
 && rm -f /apache-tomcat/webapps/teamcity/WEB-INF/lib/tomcat-*.jar \

 && echo '<meta name="mobile-web-app-capable" content="yes">' >> /apache-tomcat/webapps/teamcity/WEB-INF/tags/pageMeta.tag \

 && sed -i 's/<Connector port="8080"/<Connector port="8080" useBodyEncodingForURI="true"/' /apache-tomcat/conf/server.xml \
 && sed -i 's/connectionTimeout="20000"/connectionTimeout="60000"/'                        /apache-tomcat/conf/server.xml

RUN useradd -m teamcity \
 && mkdir /logs \
 && chown -R teamcity:teamcity /apache-tomcat /logs

ENV CATALINA_OPTS \
 -Xmx512m \
 -Xss256k \
 -XX:+UseCompressedOops \
 -Dfile.encoding=UTF-8 \
 -Duser.timezone=Europe/Paris

EXPOSE 8080

USER teamcity
CMD ["/apache-tomcat/bin/catalina.sh", "run"]
