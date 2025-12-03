#!/bin/bash
set -e

echo "🚀 SIMPLE Deploy - Student Management App"
echo "========================================="

# Clean up
echo "🧹 Cleaning up..."
kubectl delete -f k8s/ --ignore-not-found=true 2>/dev/null || true
kubectl delete namespace student-app --ignore-not-found=true 2>/dev/null || true
pkill -f "kubectl port-forward" 2>/dev/null || true

# Wait
sleep 3

# Create namespace
echo "📁 Creating namespace..."
kubectl create namespace student-app

# Apply configmap
echo "⚙️ Creating configmap..."
cat > k8s/configmap-simple.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: student-app
data:
  NODE_ENV: "production"
  PORT: "3000"
EOF
kubectl apply -f k8s/configmap-simple.yaml

# Deploy simple backend
echo "🔧 Deploying Backend (Simple)..."
cat > k8s/backend/deployment-simple.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: student-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: student-backend:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 3000
        env:
        - name: PORT
          value: "3000"
        - name: NODE_ENV
          value: "production"
        livenessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
EOF
kubectl apply -f k8s/backend/deployment-simple.yaml

# Deploy backend service
echo "🔌 Deploying Backend Service..."
cat > k8s/backend/service-simple.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: student-app
spec:
  selector:
    app: backend
  ports:
  - port: 3000
    targetPort: 3000
    nodePort: 30001
  type: NodePort
EOF
kubectl apply -f k8s/backend/service-simple.yaml

# Deploy frontend
echo "🎨 Deploying Frontend..."
kubectl apply -f k8s/frontend/deployment.yaml
kubectl apply -f k8s/frontend/service.yaml

# Wait
echo "⏳ Waiting for pods..."
sleep 30

# Check status
echo "📊 Status:"
kubectl get all -n student-app

echo ""
echo "✅ Simple deployment completed!"
echo "🌐 Run: kubectl port-forward -n student-app service/backend-service 30001:3000 &"
echo "🌐 Run: kubectl port-forward -n student-app service/frontend-service 8888:80 &"
echo "🌐 Then open: http://localhost:8888"