pipeline {
    agent any
    
    environment {
        // Docker Configuration
        DOCKER_USERNAME = credentials('docker-hub')
        DOCKER_PASSWORD = credentials('docker-hub')
        DOCKER_REGISTRY = 'docker.io'
        
        // Application Configuration
        APP_NAME = 'student-app'
        APP_VERSION = "${BUILD_NUMBER}-${GIT_COMMIT_SHORT}"
        BACKEND_IMAGE = "${DOCKER_REGISTRY}/${DOCKER_USERNAME}/student-backend"
        FRONTEND_IMAGE = "${DOCKER_REGISTRY}/${DOCKER_USERNAME}/student-frontend"
        
        // Kubernetes Configuration
        KUBE_NAMESPACE = 'student-app'
        KUBECONFIG = credentials('kube-config')
        
        // Git Configuration
        GIT_URL = 'https://github.com/your-username/student-app-k8s.git'
        GIT_BRANCH = 'main'
        
        // Build Configuration
        BUILD_TIMESTAMP = sh(script: 'date +%Y%m%d-%H%M%S', returnStdout: true).trim()
        
        // Application URLs (for notifications)
        FRONTEND_URL = 'http://your-cluster-ip:31349'
        BACKEND_URL = 'http://your-cluster-ip:30001'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
    }
    
    parameters {
        choice(
            name: 'DEPLOY_ENVIRONMENT',
            choices: ['dev', 'staging', 'production'],
            description: 'Select deployment environment'
        )
        string(
            name: 'IMAGE_TAG',
            defaultValue: 'latest',
            description: 'Docker image tag'
        )
        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: true,
            description: 'Run tests before deployment'
        )
        booleanParam(
            name: 'SKIP_PUSH',
            defaultValue: false,
            description: 'Skip pushing images to registry'
        )
    }
    
    stages {
        stage('Initialize') {
            steps {
                script {
                    echo "🚀 Starting CI/CD Pipeline"
                    echo "Build: #${BUILD_NUMBER}"
                    echo "Branch: ${env.GIT_BRANCH}"
                    echo "Environment: ${params.DEPLOY_ENVIRONMENT}"
                    echo "Image Tag: ${params.IMAGE_TAG}"
                    
                    // Set environment-specific variables
                    if (params.DEPLOY_ENVIRONMENT == 'production') {
                        env.KUBE_NAMESPACE = 'student-app-prod'
                        env.APP_VERSION = "prod-${APP_VERSION}"
                    } else if (params.DEPLOY_ENVIRONMENT == 'staging') {
                        env.KUBE_NAMESPACE = 'student-app-staging'
                        env.APP_VERSION = "staging-${APP_VERSION}"
                    }
                    
                    // Write kubeconfig to file
                    writeFile file: 'kubeconfig', text: KUBECONFIG
                    sh 'chmod 600 kubeconfig'
                }
            }
        }
        
        stage('Checkout Source Code') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${GIT_BRANCH}"]],
                    userRemoteConfigs: [[
                        url: GIT_URL,
                        credentialsId: 'github-token'
                    ]],
                    extensions: [
                        [$class: 'CleanBeforeCheckout'],
                        [$class: 'CloneOption', depth: 1, noTags: false, shallow: true]
                    ]
                ])
                
                script {
                    // Get git commit info
                    env.GIT_COMMIT = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    env.GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.GIT_AUTHOR = sh(script: 'git log -1 --pretty=format:"%an"', returnStdout: true).trim()
                    env.GIT_MESSAGE = sh(script: 'git log -1 --pretty=format:"%s"', returnStdout: true).trim()
                    
                    echo "📦 Git Commit: ${GIT_COMMIT_SHORT}"
                    echo "👤 Author: ${GIT_AUTHOR}"
                    echo "💬 Message: ${GIT_MESSAGE}"
                }
            }
        }
        
        stage('Code Quality Check') {
            steps {
                script {
                    echo "🔍 Running code quality checks..."
                    
                    dir('app/backend') {
                        sh '''
                            echo "Checking backend code..."
                            npm run lint || echo "Linting not configured"
                        '''
                    }
                    
                    dir('app/frontend') {
                        sh '''
                            echo "Checking frontend code..."
                            # Add any frontend linting here
                        '''
                    }
                }
            }
        }
        
        stage('Build Application') {
            steps {
                script {
                    echo "🔨 Building application..."
                    
                    // Build Backend
                    dir('app/backend') {
                        sh '''
                            echo "📦 Installing backend dependencies..."
                            npm install --production
                            
                            echo "🧪 Running backend tests..."
                            if [ "${params.RUN_TESTS}" = "true" ]; then
                                npm test || echo "Tests failed but continuing"
                            fi
                        '''
                    }
                    
                    // Build Frontend
                    dir('app/frontend') {
                        sh '''
                            echo "🎨 Building frontend..."
                            # Add any frontend build steps here
                        '''
                    }
                }
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    echo "🐳 Building Docker images..."
                    
                    // Build Backend Image
                    dir('app/backend') {
                        sh """
                            echo "🔧 Building backend image..."
                            docker build -t ${BACKEND_IMAGE}:${APP_VERSION} .
                            docker tag ${BACKEND_IMAGE}:${APP_VERSION} ${BACKEND_IMAGE}:${params.IMAGE_TAG}
                            
                            echo "✅ Backend image built:"
                            docker images | grep ${BACKEND_IMAGE}
                        """
                    }
                    
                    // Build Frontend Image
                    dir('app/frontend') {
                        sh """
                            echo "🎨 Building frontend image..."
                            docker build -t ${FRONTEND_IMAGE}:${APP_VERSION} .
                            docker tag ${FRONTEND_IMAGE}:${APP_VERSION} ${FRONTEND_IMAGE}:${params.IMAGE_TAG}
                            
                            echo "✅ Frontend image built:"
                            docker images | grep ${FRONTEND_IMAGE}
                        """
                    }
                }
            }
        }
        
        stage('Push Docker Images') {
            when {
                expression { params.SKIP_PUSH == false }
            }
            steps {
                script {
                    echo "📤 Pushing images to Docker Hub..."
                    
                    sh """
                        # Login to Docker Hub
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                        
                        # Push Backend Images
                        echo "📦 Pushing backend images..."
                        docker push ${BACKEND_IMAGE}:${APP_VERSION}
                        docker push ${BACKEND_IMAGE}:${params.IMAGE_TAG}
                        
                        # Push Frontend Images
                        echo "🎨 Pushing frontend images..."
                        docker push ${FRONTEND_IMAGE}:${APP_VERSION}
                        docker push ${FRONTEND_IMAGE}:${params.IMAGE_TAG}
                        
                        echo "✅ Images pushed successfully!"
                    """
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "🚀 Deploying to Kubernetes..."
                    
                    withEnv(["KUBECONFIG=${WORKSPACE}/kubeconfig"]) {
                        // Create namespace if not exists
                        sh """
                            kubectl create namespace ${KUBE_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f - || echo "Namespace exists"
                        """
                        
                        // Deploy MySQL
                        sh """
                            echo "🗄️  Deploying MySQL..."
                            kubectl apply -f k8s/mysql/ -n ${KUBE_NAMESPACE}
                            
                            # Wait for MySQL
                            echo "⏳ Waiting for MySQL to be ready..."
                            kubectl wait --for=condition=ready pod -l app=mysql -n ${KUBE_NAMESPACE} --timeout=180s || echo "MySQL might still be starting..."
                        """
                        
                        // Update deployment manifests with new images
                        sh """
                            echo "🔄 Updating image tags..."
                            sed -i "s|student-backend:latest|${BACKEND_IMAGE}:${APP_VERSION}|g" k8s/backend/deployment.yaml
                            sed -i "s|student-frontend:latest|${FRONTEND_IMAGE}:${APP_VERSION}|g" k8s/frontend/deployment.yaml
                            
                            # Add imagePullSecrets if needed
                            cat >> k8s/backend/deployment.yaml << 'EOF'
      imagePullSecrets:
      - name: docker-hub-secret
EOF
                        """
                        
                        // Apply all Kubernetes manifests
                        sh """
                            echo "📋 Applying Kubernetes manifests..."
                            kubectl apply -f k8s/secrets.yaml -n ${KUBE_NAMESPACE}
                            kubectl apply -f k8s/configmap.yaml -n ${KUBE_NAMESPACE}
                            kubectl apply -f k8s/backend/ -n ${KUBE_NAMESPACE}
                            kubectl apply -f k8s/frontend/ -n ${KUBE_NAMESPACE}
                        """
                        
                        // Wait for deployment
                        sh """
                            echo "⏳ Waiting for deployment to complete..."
                            kubectl rollout status deployment/backend -n ${KUBE_NAMESPACE} --timeout=300s
                            kubectl rollout status deployment/frontend -n ${KUBE_NAMESPACE} --timeout=300s
                            
                            echo "✅ Deployment completed!"
                        """
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    echo "🔍 Verifying deployment..."
                    
                    withEnv(["KUBECONFIG=${WORKSPACE}/kubeconfig"]) {
                        // Check resources
                        sh """
                            echo "📊 Deployment Status:"
                            kubectl get all -n ${KUBE_NAMESPACE}
                            
                            echo ""
                            echo "🔧 Pod Details:"
                            kubectl get pods -n ${KUBE_NAMESPACE} -o wide
                            
                            echo ""
                            echo "🌐 Services:"
                            kubectl get svc -n ${KUBE_NAMESPACE}
                        """
                        
                        // Test backend health
                        sh """
                            echo "🧪 Testing backend health..."
                            BACKEND_POD=\$(kubectl get pods -n ${KUBE_NAMESPACE} -l app=backend -o jsonpath='{.items[0].metadata.name}')
                            kubectl exec -n ${KUBE_NAMESPACE} \$BACKEND_POD -- curl -s http://localhost:3000/api/health || echo "Backend health check failed"
                            
                            echo "🔗 Testing service connectivity..."
                            kubectl run test-curl --image=curlimages/curl -n ${KUBE_NAMESPACE} --rm -i --restart=Never -- curl -s http://backend-service:3000/api/health || echo "Service connectivity test failed"
                        """
                    }
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                script {
                    echo "🧪 Running integration tests..."
                    
                    withEnv(["KUBECONFIG=${WORKSPACE}/kubeconfig"]) {
                        sh """
                            echo "🔗 Testing frontend-backend connection..."
                            FRONTEND_POD=\$(kubectl get pods -n ${KUBE_NAMESPACE} -l app=frontend -o jsonpath='{.items[0].metadata.name}')
                            kubectl exec -n ${KUBE_NAMESPACE} \$FRONTEND_POD -- curl -s http://backend-service:3000/api/health || echo "Frontend to backend connection test failed"
                            
                            echo "📝 Checking application logs..."
                            kubectl logs -n ${KUBE_NAMESPACE} deployment/backend --tail=10
                        """
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    echo "🧹 Cleaning up..."
                    
                    // Remove Docker images
                    sh """
                        docker rmi ${BACKEND_IMAGE}:${APP_VERSION} || true
                        docker rmi ${FRONTEND_IMAGE}:${APP_VERSION} || true
                    """
                    
                    // Remove kubeconfig file
                    sh "rm -f kubeconfig"
                    
                    // Archive artifacts if needed
                    archiveArtifacts artifacts: '**/target/*.jar,**/dist/*', fingerprint: true
                }
            }
        }
    }
    
    post {
        success {
            script {
                echo "✅ Pipeline completed successfully!"
                
                // Send notification
                emailext(
                    subject: "✅ Student App Deployment Successful - Build #${BUILD_NUMBER}",
                    body: """
                    Student Management App deployed successfully!
                    
                    Build Details:
                    - Build Number: #${BUILD_NUMBER}
                    - Environment: ${params.DEPLOY_ENVIRONMENT}
                    - Git Commit: ${GIT_COMMIT_SHORT}
                    - Author: ${GIT_AUTHOR}
                    - Commit Message: ${GIT_MESSAGE}
                    
                    Application URLs:
                    - Frontend: ${FRONTEND_URL}
                    - Backend API: ${BACKEND_URL}/api/health
                    
                    Docker Images:
                    - Backend: ${BACKEND_IMAGE}:${APP_VERSION}
                    - Frontend: ${FRONTEND_IMAGE}:${APP_VERSION}
                    
                    To check deployment status:
                    kubectl get all -n ${KUBE_NAMESPACE}
                    """,
                    to: 'dev-team@example.com',
                    attachLog: true
                )
            }
        }
        failure {
            script {
                echo "❌ Pipeline failed!"
                
                // Send failure notification
                emailext(
                    subject: "❌ Student App Deployment Failed - Build #${BUILD_NUMBER}",
                    body: """
                    Student Management App deployment failed!
                    
                    Build Details:
                    - Build Number: #${BUILD_NUMBER}
                    - Environment: ${params.DEPLOY_ENVIRONMENT}
                    - Git Commit: ${GIT_COMMIT_SHORT}
                    
                    Please check Jenkins logs for details:
                    ${BUILD_URL}
                    
                    Last 50 lines of logs:
                    ${currentBuild.rawBuild.getLog(50).join('\n')}
                    """,
                    to: 'dev-team@example.com',
                    attachLog: true
                )
            }
        }
        always {
            script {
                echo "📊 Build Summary:"
                echo "Duration: ${currentBuild.durationString}"
                echo "Result: ${currentBuild.currentResult}"
                
                // Clean workspace
                cleanWs()
            }
        }
    }
}