#!/bin/bash
echo "🔍 Testing Kubernetes Connections..."
echo "==================================="

echo "1. Checking pods..."
kubectl get pods -n student-app

echo ""
echo "2. Checking services..."
kubectl get services -n student-app

echo ""
echo "3. Testing backend internally..."
kubectl exec -n student-app deployment/backend -- curl -s http://localhost:3000/api/health || echo "Backend internal check failed"

echo ""
echo "4. Testing backend via service..."
kubectl run -n student-app test-curl --image=curlimages/curl --rm -it --restart=Never -- curl -s http://backend-service:3000/api/health || echo "Service check failed"

echo ""
echo "5. Testing frontend-backend connection..."
kubectl exec -n student-app deployment/frontend -- curl -s http://backend-service:3000/api/health || echo "Frontend to backend check failed"

echo ""
echo "✅ Tests completed!"