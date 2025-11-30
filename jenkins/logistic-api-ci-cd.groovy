pipeline {
    agent any
    
    environment {
        K8S_NAMESPACE = 'logistic'
        K8S_DEPLOYMENT = 'logistic-api'
    }

    triggers {
        githubPush()

        pollSCM('H/2 * * * *')
    }
    
    stages {
        stage('Clean Workspace') {
            steps {
                deleteDir() 
            }
        }

        stage('Checkout') {
            steps {
                script {
                    def githubUser = readFile('/var/run/secrets/github/username').trim()
                    def githubToken = readFile('/var/run/secrets/github/password').trim()
                    
                    sh """
                        git clone https://${githubUser}:${githubToken}@github.com/Tigeroff2002/LogisticAPI.git .
                        echo "✅ Repository cloned"
                    """
                }
            }
        }
        
        stage('Build Only') {
            steps {
                script {
                    sh """
                        docker build -t logistic-api:latest .
                        echo "✅ Image built locally"
                    """
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    sh """
                        # Используем kubectl annotate вместо сложного patch
                        kubectl annotate deployment ${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE} deployed-at="\$(date +%s)" --overwrite
                        kubectl rollout restart deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE}
                        kubectl rollout status deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE}
                        echo "✅ Deployment completed successfully"
                    """
                }
            }
        }
    }
}