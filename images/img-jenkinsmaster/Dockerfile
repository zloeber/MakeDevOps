FROM jenkinsci/blueocean:latest
ENV container docker

ARG JENKINS_HTTP_PORT_default=8080
ARG JENKINS_HTTPS_PORT_default=4443
ARG JENKINS_AGENT_PORT_default=50000
ARG JENKINS_ADMIN_PASS_default=admin
ARG JENKINS_USER_default=jenkins
ARG TIME_ZONE_default="US/Central"
ARG APP_COST_CENTER_default=5501922

ENV JENKINS_HTTP_PORT ${JENKINS_HTTP_PORT_default}
ENV JENKINS_HTTPS_PORT ${JENKINS_HTTPS_PORT_default}
ENV JENKINS_SLAVE_AGENT_PORT ${JENKINS_AGENT_PORT_default}
ENV JENKINS_AGENT_PORT ${JENKINS_AGENT_PORT_default}
ENV JENKINS_ADMIN_USER ${JENKINS_ADMIN_USER_default}
ENV JENKINS_USER ${JENKINS_USER_default}
ENV JENKINS_PASS ${JENKINS_ADMIN_PASS_default}
ENV APP_COST_CENTER ${APP_COST_CENTER_default}
ENV APP_TEAM ${APP_TEAM_default}
ENV TIME_ZONE ${TIME_ZONE_default}

USER root

# Fix timezone issues (sets to US/Central)
RUN apk add --no-cache tini tzdata && cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime && echo ${TIME_ZONE} > /etc/timezone && apk del tzdata

# Other jenkins environmental variables
ENV JAVA_OPTS "-Xmx8192m -Djenkins.install.runSetupWizard=false"
ENV JENKINS_OPTS "--handlerCountMax=300 --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war"

# Install Jenkins plugins
COPY ./config/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
COPY ./config/executors.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY ./config/default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
# also logs dump locally for now :(
RUN chown -R jenkins:jenkins /var/jenkins_home && mkdir -p /var/log/jenkins

# Copy in local config files
COPY ./config/init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy
COPY ./config/jenkins-support /usr/local/bin/jenkins-support
#COPY jenkins.sh /usr/local/bin/jenkins.sh

RUN chmod +x /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy \
    && chmod +x /usr/local/bin/jenkins-support \
    && chmod +x /usr/local/bin/jenkins.sh

# Switch to the jenkins user
USER ${JENKINS_USER}

### Run our app
##CMD ["/usr/local/bin/jenkins.sh"]

LABEL description="Jenkins Master"
LABEL vendor=Nielsen
LABEL maintainer="zachary.loeber.consultant@nielsen.com"
LABEL CostCenter=${APP_COST_CENTER}
LABEL Application=${APP_TEAM}