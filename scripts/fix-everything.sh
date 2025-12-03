#!/bin/bash
echo "🔧 Fixing Everything - Student Management System"
echo "================================================"

# Stop everything
echo "🛑 Stopping everything..."
pkill -f "kubectl port-forward" 2>/dev/null || true

# Delete current deployment
echo "🗑️  Deleting current deployment..."
kubectl delete -f k8s/ --ignore-not-found=true
kubectl delete namespace student-app --ignore-not-found=true
sleep 5

# Rebuild images
echo "🔨 Rebuilding Docker images..."
cd app/backend
docker build -t student-backend:latest .
cd ../frontend
docker build -t student-frontend:latest .
cd ../..

# Create fresh deployment
echo "🚀 Creating fresh deployment..."

# Create namespace
kubectl create namespace student-app

# Apply in correct order
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/configmap.yaml

# Wait a bit
sleep 2

# Deploy MySQL first
echo "🗄️ Deploying MySQL..."
kubectl apply -f k8s/mysql/

# Wait for MySQL
echo "⏳ Waiting for MySQL..."
sleep 30

# Deploy Backend with MySQL disabled (will use in-memory)
echo "🔧 Deploying Backend (with in-memory storage)..."
kubectl apply -f k8s/backend/

# Wait for backend
echo "⏳ Waiting for Backend..."
sleep 20

# Deploy Frontend
echo "🎨 Deploying Frontend..."
kubectl apply -f k8s/frontend/

# Wait for everything
echo "⏳ Waiting for all pods..."
sleep 30

# Check status
echo "📊 Deployment Status:"
kubectl get all -n student-app

echo ""
echo "🔍 Checking pod status..."
kubectl get pods -n student-app

echo ""
echo "📝 Pod details:"
kubectl describe pods -n student-app

echo ""
echo "✅ Fix completed!"
echo ""
echo "🌐 To access the application:"
echo "1. Run: kubectl port-forward -n student-app service/backend-service 30001:3000 &"
echo "2. Run: kubectl port-forward -n student-app service/frontend-service 8888:80 &"
echo "3. Open: http://localhost:8888"
echo ""
echo "🐛 If issues persist, check logs:"
echo "   kubectl logs -n student-app deployment/backend"
echo "   kubectl logs -n student-app deployment/frontend"