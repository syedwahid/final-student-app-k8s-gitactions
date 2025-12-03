#!/bin/bash
echo "🔄 Complete Redeployment"
echo "======================="

# Clean up
echo "1. Cleaning up..."
pkill -f "kubectl port-forward" 2>/dev/null || true
./scripts/teardown.sh

# Recreate KIND cluster if needed
if ! kind get clusters | grep -q "student-app"; then
    echo "2. Creating KIND cluster..."
    kind create cluster --name student-app --config kind/kind-config-fixed.yaml
else
    echo "2. KIND cluster exists, skipping creation"
fi

# Set context
kubectl config use-context kind-student-app

# Rebuild and load images
echo "3. Rebuilding images..."
cd app/backend
docker build -t student-backend:latest .
cd ../frontend
docker build -t student-frontend:latest .
cd ../..

echo "4. Loading images to KIND..."
kind load docker-image student-backend:latest --name student-app
kind load docker-image student-frontend:latest --name student-app

# Deploy
echo "5. Deploying..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/configmap.yaml

# Skip MySQL (use in-memory)
echo "6. Deploying backend and frontend..."
kubectl apply -f k8s/backend/deployment.yaml
kubectl apply -f k8s/backend/service.yaml
kubectl apply -f k8s/frontend/deployment.yaml
kubectl apply -f k8s/frontend/service.yaml

# Wait
echo "7. Waiting for pods..."
sleep 40

# Check
echo "8. Checking deployment..."
kubectl get all -n student-app

# Test with port-forward
echo "9. Testing with port-forward..."
kubectl port-forward -n student-app service/backend-service 30001:3000 &
sleep 3
kubectl port-forward -n student-app service/frontend-service 8888:80 &
sleep 3

echo "10. Testing connections..."
curl -s http://localhost:30001/api/health && echo " - Backend OK" || echo " - Backend failed"
curl -s http://localhost:8888 | head -5 && echo " - Frontend OK" || echo " - Frontend failed"

echo ""
echo "✅ Redeployment complete!"
echo "🌐 Access via:"
echo "   Frontend: http://localhost:8888"
echo "   Backend:  http://localhost:30001/api/health"
echo ""
echo "📝 To stop port-forwarding: pkill -f 'kubectl port-forward'"
