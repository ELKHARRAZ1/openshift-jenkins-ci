pipeline {
    agent any

    parameters {
        string(name: 'OC_NAMESPACE', defaultValue: 'demo', description: 'Namespace/proyecto de OpenShift')
        string(name: 'DEPLOYMENT_NAME', defaultValue: 'mi-app', description: 'Nombre del Deployment a reiniciar')
        string(name: 'OC_SERVER', defaultValue: 'https://api.crc.testing:6443', description: 'URL de la API de OpenShift')
    }

    environment {
        OC_TOKEN = credentials('ocp-jenkins-sa-token') // Secret text configurado en Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Restart Deployment') {
            steps {
                sh '''
                    chmod +x scripts/restart-deployment.sh
                    OC_SERVER="${OC_SERVER}" \
                    OC_TOKEN="${OC_TOKEN}" \
                    OC_NAMESPACE="${OC_NAMESPACE}" \
                    DEPLOYMENT_NAME="${DEPLOYMENT_NAME}" \
                    ./scripts/restart-deployment.sh
                '''
            }
        }
    }

    post {
        success {
            echo "Deployment ${params.DEPLOYMENT_NAME} reiniciado correctamente en ${params.OC_NAMESPACE}."
        }
        failure {
            echo "Fallo al reiniciar ${params.DEPLOYMENT_NAME}. Revisa los logs de oc arriba."
        }
    }
}
