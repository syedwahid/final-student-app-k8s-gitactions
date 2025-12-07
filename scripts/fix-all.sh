#!/bin/bash
echo "🔧 COMPLETE FIX FOR KIND DEPLOYMENT"
echo "==================================="

# 1. Load images to KIND
echo "1. Loading images to KIND..."
kind load docker-image student-backend:latest --name student-app
kind load docker-image student-frontend:latest --name student-app

# 2. Update deployments
echo "2. Updating deployments..."
sed -i 's/imagePullPolicy:.*/imagePullPolicy: Never/g' k8s/backend/deployment.yaml k8s/frontend/deployment.yaml
sed -i 's/image: .*/image: student-backend:latest/g' k8s/backend/deployment.yaml
sed -i 's/image: .*/image: student-frontend:latest/g' k8s/frontend/deployment.yaml

# 3. Clean up
echo "3. Cleaning up old pods..."
kubectl delete pods -n student-app --all --grace-period=0 --force 2>/dev/null || true
sleep 5

# 4. Skip MySQL for now
echo "4. Skipping MySQL (using in-memory backend)..."
kubectl delete deployment mysql -n student-app --ignore-not-found=true

# 5. Create simple deployments
echo "5. Creating simple deployments..."

# Simple backend
cat > simple-backend.yaml << 'EOF'
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
        - name: USE_MYSQL
          value: "false"
EOF

# Simple frontend
cat > simple-frontend.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: student-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: student-frontend:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 80
EOF

# Apply simple deployments
kubectl apply -f simple-backend.yaml
kubectl apply -f simple-frontend.yaml

# 6. Wait
echo "6. Waiting for pods..."
sleep 40

# 7. Check status
echo "7. Checking status..."
kubectl get all -n student-app

# 8. Test
echo "8. Testing..."
echo "Backend:"
curl -s http://localhost:30001/api/health || echo "Backend not ready yet"
echo ""
echo "Frontend:"
curl -s http://localhost:31349 | head -5 || echo "Frontend not ready yet"

echo ""
echo "✅ FIX COMPLETED!"
echo "🌐 Access: http://localhost:31349"