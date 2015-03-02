FROM podbox/tomcat8

RUN apt-get update \
 && apt-get install -yq git \
 && apt-get clean

RUN useradd -m teamcity \
 && mkdir /logs \
 && chown -R teamcity:teamcity /apache-tomcat /logs

USER teamcity
WORKDIR /apache-tomcat

ENV CATALINA_OPTS \
 -Xmx512m \
 -Xss256k \
 -XX:+UseCompressedOops \
 -Dfile.encoding=UTF-8 \
 -Duser.timezone=Europe/Paris

RUN sed -i 's/<Connector port="8080"/<Connector port="8080" useBodyEncodingForURI="true"/'                            conf/server.xml \
 && sed -i 's/connectionTimeout="20000"/connectionTimeout="60000"/'                                                   conf/server.xml \
 && sed -i 's/<\/Context>/<Loader loaderClass="org.apache.catalina.loader.ParallelWebappClassLoader" \/><\/Context>/' conf/context.xml

EXPOSE 8080
CMD ["./bin/catalina.sh", "run"]

# --------------------------------------------------------------------- teamcity
ENV TEAMCITY_VERSION 9.0.2

RUN curl -LO http://download.jetbrains.com/teamcity/TeamCity-$TEAMCITY_VERSION.war \
 && unzip -qq TeamCity-$TEAMCITY_VERSION.war -d webapps/teamcity \
 && rm -f TeamCity-$TEAMCITY_VERSION.war \
 && rm -f webapps/teamcity/WEB-INF/lib/tomcat-*.jar \

 && rm -f  webapps/teamcity/WEB-INF/plugins/clearcase.zip     \
 && rm -f  webapps/teamcity/WEB-INF/plugins/mercurial.zip     \
 && rm -f  webapps/teamcity/WEB-INF/plugins/*-distributor.zip \
 && rm -Rf webapps/teamcity/WEB-INF/plugins/dot*              \

 && echo '<meta name="mobile-web-app-capable" content="yes">' >> webapps/teamcity/WEB-INF/tags/pageMeta.tag
