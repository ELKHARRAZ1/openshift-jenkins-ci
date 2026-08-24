#!/bin/sh
# Reinicia un Deployment en OpenShift (rollout restart) y espera a que termine.
#
# Variables de entorno requeridas:
#   OC_SERVER       URL de la API de OpenShift, p.ej. https://api.crc.testing:6443
#   OC_TOKEN        Token del service account con permisos sobre el Deployment
#   OC_NAMESPACE    Namespace/proyecto donde vive el Deployment
#   DEPLOYMENT_NAME Nombre del Deployment (o DeploymentConfig) a reiniciar
#
# Uso local de prueba:
#   OC_SERVER=https://api.crc.testing:6443 OC_TOKEN=xxx OC_NAMESPACE=demo \
#   DEPLOYMENT_NAME=mi-app ./scripts/restart-deployment.sh

set -eu

: "${OC_SERVER:?Falta OC_SERVER}"
: "${OC_TOKEN:?Falta OC_TOKEN}"
: "${OC_NAMESPACE:?Falta OC_NAMESPACE}"
: "${DEPLOYMENT_NAME:?Falta DEPLOYMENT_NAME}"

oc login "$OC_SERVER" --token="$OC_TOKEN" --insecure-skip-tls-verify=true
oc project "$OC_NAMESPACE"

echo "Reiniciando deployment/$DEPLOYMENT_NAME en $OC_NAMESPACE..."
oc rollout restart deployment/"$DEPLOYMENT_NAME"
oc rollout status deployment/"$DEPLOYMENT_NAME" --timeout=180s

echo "Reinicio completado."
