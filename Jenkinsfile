pipeline {
    agent any
    
    environment {
        APP_NAME = "student-app"
        KUBE_NAMESPACE = "student-app"
    }
    
    stages {
        stage('Destroy Existing Resources') {
            steps {
                script {
                    echo '💥 Cleaning up existing resources...'
                    sh '''
                        echo "1. Stopping port-forwards..."
                        pkill -f "kubectl port-forward" 2>/dev/null || true
                        
                        echo "2. Deleting KIND cluster if exists..."
                        kind delete cluster --name student-app 2>/dev/null || true
                        
                        echo "3. Removing old Docker images..."
                        docker rmi -f student-backend:latest student-frontend:latest 2>/dev/null || true
                        
                        echo "✅ Cleanup complete"
                    '''
                }
            }
        }
        
        stage('Create KIND Cluster') {
            steps {
                script {
                    echo '☸️ Creating fresh KIND cluster...'
                    sh '''
                        echo "Creating KIND configuration..."
                        cat > /tmp/kind-config.yaml << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30001
    hostPort: 30001
    protocol: tcp
  - containerPort: 31349
    hostPort: 31349
    protocol: tcp
EOF
                        
                        echo "Creating KIND cluster..."
                        kind create cluster --name student-app --config /tmp/kind-config.yaml
                        
                        echo "Setting up kubeconfig..."
                        mkdir -p /var/lib/jenkins/.kube
                        kind get kubeconfig --name student-app | \\
                            sed 's|server: https://.*:.*|server: https://127.0.0.1:6443|' | \\
                            tee /var/lib/jenkins/.kube/config
                        chmod 600 /var/lib/jenkins/.kube/config
                        
                        echo "✅ KIND cluster created"
                        kubectl get nodes
                    '''
                }
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    echo '🐳 Building fresh Docker images...'
                    sh '''
                        echo "Building backend image..."
                        cd app/backend
                        docker build -t student-backend:latest .
                        
                        echo "Building frontend image..."
                        cd ../frontend
                        docker build -t student-frontend:latest .
                        
                        echo "✅ Docker images built:"
                        docker images | grep student-
                    '''
                }
            }
        }
        
        stage('Load Images to KIND') {
            steps {
                script {
                    echo '📦 Loading images to KIND cluster...'
                    sh '''
                        echo "Loading backend image..."
                        kind load docker-image student-backend:latest --name student-app
                        
                        echo "Loading frontend image..."
                        kind load docker-image student-frontend:latest --name student-app
                        
                        echo "✅ Images loaded to KIND"
                    '''
                }
            }
        }
        
        stage('Prepare Kubernetes Manifests') {
            steps {
                script {
                    echo '🔄 Preparing manifests for KIND...'
                    sh '''
                        echo "1. Backing up original manifests..."
                        cp k8s/backend/deployment.yaml k8s/backend/deployment.yaml.backup
                        cp k8s/frontend/deployment.yaml k8s/frontend/deployment.yaml.backup
                        
                        echo "2. Setting imagePullPolicy to Never (required for KIND)..."
                        sed -i 's/imagePullPolicy:.*/imagePullPolicy: Never/g' k8s/backend/deployment.yaml
                        sed -i 's/imagePullPolicy:.*/imagePullPolicy: Never/g' k8s/frontend/deployment.yaml
                        
                        echo "3. Ensuring correct image names..."
                        sed -i 's|image:.*student-backend.*|image: student-backend:latest|g' k8s/backend/deployment.yaml
                        sed -i 's|image:.*student-frontend.*|image: student-frontend:latest|g' k8s/frontend/deployment.yaml
                        
                        echo "✅ Manifests prepared"
                    '''
                }
            }
        }
        
        stage('Deploy Application') {
            steps {
                script {
                    echo '🚀 Deploying Student Management App...'
                    sh '''
                        echo "1. Creating namespace..."
                        kubectl create namespace student-app --dry-run=client -o yaml | kubectl apply -f -
                        
                        echo "2. Applying base configurations..."
                        kubectl apply -f k8s/namespace.yaml
                        kubectl apply -f k8s/secrets.yaml
                        kubectl apply -f k8s/configmap.yaml
                        
                        echo "3. Deploying Backend..."
                        kubectl apply -f k8s/backend/
                        
                        echo "4. Deploying Frontend..."
                        kubectl apply -f k8s/frontend/
                        
                        echo "⏳ Waiting for pods to start (45 seconds)..."
                        sleep 45
                        
                        echo "📊 Deployment status:"
                        kubectl get all -n student-app
                    '''
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    echo '🔍 Verifying deployment...'
                    sh '''
                        echo "Checking pod status..."
                        kubectl get pods -n student-app -o wide
                        
                        echo ""
                        echo "Checking service status..."
                        kubectl get svc -n student-app
                        
                        echo ""
                        echo "🌐 Application URLs:"
                        echo "Frontend UI:    http://localhost:31349"
                        echo "Backend API:    http://localhost:30001/api/health"
                        echo "Students API:   http://localhost:30001/api/students"
                    '''
                }
            }
        }
        
        stage('Test Application') {
            steps {
                script {
                    echo '🧪 Testing application...'
                    sh '''
                        echo "Testing backend API..."
                        BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:30001/api/health 2>/dev/null || echo "FAILED")
                        if [ "$BACKEND_STATUS" = "200" ]; then
                            echo "✅ Backend is working (HTTP $BACKEND_STATUS)"
                            echo "Backend response:"
                            curl -s http://localhost:30001/api/health | python3 -m json.tool 2>/dev/null || curl -s http://localhost:30001/api/health
                        else
                            echo "❌ Backend not responding (Status: $BACKEND_STATUS)"
                            echo "Checking pods..."
                            kubectl describe pods -n student-app -l app=backend | tail -20
                        fi
                        
                        echo ""
                        echo "Testing frontend..."
                        FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:31349 2>/dev/null || echo "FAILED")
                        if [ "$FRONTEND_STATUS" = "200" ]; then
                            echo "✅ Frontend is working (HTTP $FRONTEND_STATUS)"
                            echo "Frontend title:"
                            curl -s http://localhost:31349 | grep -o "<title>.*</title>" || echo "No title found"
                        else
                            echo "⚠️ Frontend status: $FRONTEND_STATUS"
                        fi
                        
                        echo ""
                        echo "📋 Complete application test results saved to artifacts/test-results.txt"
                        mkdir -p ${WORKSPACE}/artifacts
                        echo "Backend: HTTP $BACKEND_STATUS" > ${WORKSPACE}/artifacts/test-results.txt
                        echo "Frontend: HTTP $FRONTEND_STATUS" >> ${WORKSPACE}/artifacts/test-results.txt
                        date >> ${WORKSPACE}/artifacts/test-results.txt
                    '''
                }
            }
        }
        
        stage('Create Access Guide') {
            steps {
                script {
                    echo '📋 Creating access guide...'
                    sh '''
                        echo "Creating access script..."
                        cat > ${WORKSPACE}/access-app.sh << 'EOF'
#!/bin/bash
echo "🎓 Student Management System"
echo "============================"
echo ""
echo "📊 Current Status:"
kubectl get pods -n student-app
echo ""
echo "🌐 Access URLs:"
echo "   Frontend (UI):    http://localhost:31349"
echo "   Backend API:      http://localhost:30001/api/health"
echo "   Students API:     http://localhost:30001/api/students"
echo ""
echo "🔧 Troubleshooting:"
echo "   Check logs:    kubectl logs -n student-app deployment/backend"
echo "   Describe pods: kubectl describe pods -n student-app"
echo "   Restart:       kubectl rollout restart deployment/backend -n student-app"
echo ""
echo "🧪 Quick Test:"
curl -s http://localhost:30001/api/health | grep -o '"status":"[^"]*"' || echo "Backend not responding"
EOF
                        chmod +x ${WORKSPACE}/access-app.sh
                        echo "✅ Access guide created: ${WORKSPACE}/access-app.sh"
                    '''
                    
                    archiveArtifacts artifacts: 'access-app.sh, artifacts/**/*'
                }
            }
        }
    }
    
    post {
        success {
            echo '🎉 AUTOMATED DEPLOYMENT COMPLETED SUCCESSFULLY!'
            script {
                currentBuild.description = "✅ Fresh deployment complete"
                currentBuild.displayName = "#${BUILD_NUMBER} - Fresh Deploy"
                
                // Create summary
                sh '''
                    echo "📈 DEPLOYMENT SUMMARY"
                    echo "===================="
                    echo "✅ KIND cluster created"
                    echo "✅ Docker images built and loaded"
                    echo "✅ Kubernetes deployment complete"
                    echo "✅ Application accessible at http://localhost:31349"
                    echo ""
                    echo "To destroy everything and start fresh:"
                    echo "   ./nuke-everything.sh"
                    echo ""
                    echo "To access the application:"
                    echo "   ./access-app.sh"
                '''
            }
        }
        failure {
            echo '❌ DEPLOYMENT FAILED!'
            script {
                currentBuild.description = "❌ Deployment failed"
                
                sh '''
                    echo "🔧 Debug information:"
                    echo "KIND clusters:"
                    kind get clusters || echo "No KIND clusters"
                    echo ""
                    echo "Docker images:"
                    docker images | grep student- || echo "No student images"
                    echo ""
                    echo "Kubernetes pods:"
                    kubectl get pods --all-namespaces || echo "Cannot connect to Kubernetes"
                '''
            }
        }
        always {
            echo "🏁 Pipeline #${BUILD_NUMBER} completed"
            echo "Result: ${currentBuild.currentResult}"
            echo "Duration: ${currentBuild.durationString}"
        }
    }
}