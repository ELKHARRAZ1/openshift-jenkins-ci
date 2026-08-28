FROM jenkins/jenkins:lts-jdk21

USER root

# Instala el CLI de OpenShift (oc) dentro de la imagen de Jenkins.
# OC_VERSION es la MINOR del cluster (crc version), no la patch.
ARG OC_VERSION=4.22
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSL "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-${OC_VERSION}/openshift-client-linux.tar.gz" -o /tmp/oc.tar.gz \
    && tar -xzf /tmp/oc.tar.gz -C /usr/local/bin oc kubectl \
    && chmod +x /usr/local/bin/oc /usr/local/bin/kubectl \
    && rm -f /tmp/oc.tar.gz \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Falla el build aqui mismo si oc no quedo instalado
RUN oc version --client

USER jenkins

# Plugins minimos necesarios para pipelines desde Git
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt