#!/bin/bash
set -e

echo "🚀 Deploying Student Management App to KIND Kubernetes..."
echo "========================================================"

# Check if KIND cluster exists
if ! kind get clusters | grep -q "student-app"; then
    echo "❌ KIND cluster 'student-app' not found!"
    echo "   Run: ./scripts/kind-setup.sh"
    exit 1
fi

# Set kubectl context
kubectl config use-context kind-student-app

echo "📦 Building Docker images locally..."

# Build backend image
echo "🔨 Building backend image..."
cd app/backend
docker build -t student-backend:latest .
cd ../..

# Build frontend image
echo "🎨 Building frontend image..."
cd app/frontend
docker build -t student-frontend:latest .
cd ../..

echo "📤 Loading images into KIND cluster..."
# Load images into KIND cluster
kind load docker-image student-backend:latest --name student-app
kind load docker-image student-frontend:latest --name student-app

echo "✅ Images loaded into KIND cluster"

echo "📁 Creating namespace..."
kubectl apply -f k8s/namespace.yaml

echo "🔐 Creating secrets..."
kubectl apply -f k8s/secrets.yaml

echo "⚙️ Creating configmaps..."
kubectl apply -f k8s/configmap.yaml

# Deploy MySQL
echo "🗄️ Deploying MySQL..."
kubectl apply -f k8s/mysql/

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n student-app --timeout=180s 2>/dev/null || echo "MySQL might still be starting..."

# Deploy Backend
echo "🔧 Deploying Backend..."
kubectl apply -f k8s/backend/

# Deploy Frontend
echo "🎨 Deploying Frontend..."
kubectl apply -f k8s/frontend/

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Display deployment status
echo "📊 Deployment Status:"
kubectl get all -n student-app

echo ""
echo "✅ Deployment completed!"
echo ""
echo "🌐 Access URLs:"
echo "   Frontend:      http://localhost:31349"
echo "   Backend API:   http://localhost:30001/api/health"
echo "   Backend Students: http://localhost:30001/api/students"
echo ""
echo "🔧 For detailed access:"
echo "   ./scripts/access-app.sh"
echo ""
echo "📈 To monitor:"
echo "   kubectl get pods -n student-app -w"