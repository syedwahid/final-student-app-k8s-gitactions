#!/bin/bash
echo "=== Final Setup - Student Management System ==="

# 1. Delete old cluster if exists
echo "1. Deleting old Kind cluster..."
kind delete cluster --name student-cluster 2>/dev/null || true
sleep 2

# 2. Build Docker image
echo "2. Building Docker image..."
docker build -t student-app:1.0.0 . --no-cache

# 3. Create new cluster
echo "3. Creating Kind cluster..."
kind create cluster --name student-cluster --config kind-config.yaml

# 4. Load image into Kind
echo "4. Loading image into Kind..."
kind load docker-image student-app:1.0.0 --name student-cluster

# 5. Deploy to Kubernetes
echo "5. Deploying to Kubernetes..."
kubectl apply -f ./k8s/deployment.yaml
kubectl apply -f ./k8s/service.yaml

# 6. Wait and check status
echo "6. Waiting for pods to be ready..."
sleep 10
kubectl get pods -o wide
kubectl get svc

# 7. Test the application
echo "7. Testing the application..."
echo "Access the app at: http://localhost:7373"
echo "Test health endpoint: curl http://localhost:7373/api/health"

echo -e "\n=== Setup Complete ==="