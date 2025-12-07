#!/bin/bash
echo "🔄 FULL RESET & DEPLOY"
echo "======================"

echo "1. Stopping everything..."
pkill -f "kubectl port-forward" 2>/dev/null || true

echo "2. Deleting KIND cluster..."
kind delete cluster --name student-app 2>/dev/null || true

echo "3. Removing Docker images..."
docker rmi student-backend:latest student-frontend:latest 2>/dev/null || true

echo "4. Recreating KIND cluster..."
kind create cluster --name student-app --config kind/kind-config-fixed.yaml

echo "5. Building fresh images..."
docker build -t student-backend:latest app/backend/
docker build -t student-frontend:latest app/frontend/

echo "6. Loading images to KIND..."
kind load docker-image student-backend:latest --name student-app
kind load docker-image student-frontend:latest --name student-app

echo "7. Deploying to Kubernetes..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/mysql/
sleep 20
kubectl apply -f k8s/backend/
kubectl apply -f k8s/frontend/

echo "8. Waiting for deployment..."
sleep 40

echo "9. Checking status..."
kubectl get all -n student-app

echo ""
echo "✅ RESET COMPLETE!"
echo "🌐 Access URLs:"
echo "   Frontend: http://localhost:31349"
echo "   Backend:  http://localhost:30001/api/health"
echo ""
echo "🧪 Testing..."
curl -s http://localhost:30001/api/health && echo "✅ Backend is working!" || echo "❌ Backend not ready yet"