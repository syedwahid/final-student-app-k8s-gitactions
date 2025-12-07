#!/bin/bash
echo "🔧 Fixing Deployment Issues..."
echo "=============================="

# 1. Load images to KIND
echo "📦 Loading images to KIND..."
kind load docker-image student-backend:latest --name student-app
kind load docker-image student-frontend:latest --name student-app

# 2. Update deployments to never pull
echo "🔄 Updating deployments..."
sed -i 's/imagePullPolicy: Always/imagePullPolicy: Never/g' k8s/backend/deployment.yaml
sed -i 's/imagePullPolicy: Always/imagePullPolicy: Never/g' k8s/frontend/deployment.yaml

# 3. Restart deployments
echo "🔄 Restarting deployments..."
kubectl rollout restart deployment backend -n student-app
kubectl rollout restart deployment frontend -n student-app

# 4. Wait
echo "⏳ Waiting for pods..."
sleep 30

# 5. Check status
echo "📊 Current Status:"
kubectl get pods -n student-app

echo ""
echo "🧪 Testing..."
curl -s http://localhost:30001/api/health && echo " - ✅ Backend OK" || echo " - ❌ Backend failed"

echo ""
echo "🌐 Frontend should now be accessible at: http://localhost:31349"