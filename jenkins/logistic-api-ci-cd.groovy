pipeline {
    agent any
    
    environment {
        K8S_NAMESPACE = 'logistic'
        K8S_DEPLOYMENT = 'logistic-api'
        // Добавляем переменную с путем к Dockerfile
        DOCKERFILE_PATH = 'LogisticAPI'  // Папка, где лежит Dockerfile
        IMAGE_NAME = 'logistic-api'
        DOCKER_REGISTRY = 'tigeroff'  // Ваш Docker Hub username
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
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Собираем только образ с latest тегом
                    sh """
                        cd ${DOCKERFILE_PATH}
                        docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest .
                        echo "✅ Image built and tagged: ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                    """
                }
            }
        }
        
        stage('Push to Docker Registry') {
            steps {
                script {
                    // Читаем credentials из secret (аналогично github)
                    def dockerUsername = readFile('/var/run/secrets/docker-hub/username').trim()
                    def dockerPassword = readFile('/var/run/secrets/docker-hub/password').trim()
                    
                    sh """
                        echo "Logging to Docker Hub as ${dockerUsername}..."
                        echo ${dockerPassword} | docker login -u ${dockerUsername} --password-stdin
                        
                        echo "Pushing image..."
                        docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                        
                        docker logout
                        echo "✅ Image pushed to Docker Hub successfully"
                    """
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                        # Добавляем аннотацию с временем деплоя
                        kubectl annotate deployment ${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE} \
                            deployed-at="\$(date +%s)" \
                            --overwrite
                        
                        # Перезапускаем deployment чтобы подтянуть последний образ
                        kubectl rollout restart deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE}
                        
                        # Ожидаем успешного развертывания
                        kubectl rollout status deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE}
                        
                        echo "✅ Deployment completed successfully with image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}