FROM jenkins/jenkins:lts-jdk17

USER root

# Instala el CLI de OpenShift (oc) dentro de la imagen de Jenkins
ARG OC_VERSION=4.15.0
RUN apt-get update && apt-get install -y --no-install-recommends curl tar ca-certificates \
    && curl -sSL "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-${OC_VERSION%%.*}.${OC_VERSION#*.}/openshift-client-linux.tar.gz" -o /tmp/oc.tar.gz \
    && tar -xzf /tmp/oc.tar.gz -C /usr/local/bin oc kubectl \
    && rm -f /tmp/oc.tar.gz \
    && chmod +x /usr/local/bin/oc /usr/local/bin/kubectl \
    && apt-get purge -y curl tar && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

USER jenkins

# Plugins minimos necesarios para pipelines desde Git
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
