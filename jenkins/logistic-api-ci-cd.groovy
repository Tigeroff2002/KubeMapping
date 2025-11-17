pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'tigeroff/logistic-api'
        K8S_NAMESPACE = 'logistic'
        K8S_DEPLOYMENT = 'logistic-api'
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    // Читаем GitHub credentials из mounted secrets
                    def githubUser = readFile('/var/run/secrets/github/username').trim()
                    def githubToken = readFile('/var/run/secrets/github/password').trim()
                    
                    sh """
                        git clone https://${githubUser}:${githubToken}@github.com/your-username/your-private-repo.git .
                    """
                }
            }
        }
        
        stage('Docker Build and Push') {
            steps {
                script {
                    // Читаем Docker Hub credentials из mounted secrets
                    def dockerUser = readFile('/var/run/secrets/docker-hub/username').trim()
                    def dockerPass = readFile('/var/run/secrets/docker-hub/password').trim()
                    
                    sh """
                        echo '${dockerPass}' | docker login -u '${dockerUser}' --password-stdin
                        docker build -t ${DOCKER_IMAGE}:latest .
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh """
                    kubectl rollout restart deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE}
                    kubectl rollout status deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE}
                """
            }
        }
    }
}