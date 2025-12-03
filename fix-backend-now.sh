#!/bin/bash
echo "🛠️ Fixing Backend Now!"
echo "======================"

cd ~/student-app-k8s-jenkins-cicd

# Kill port-forwards
pkill -f "kubectl port-forward" 2>/dev/null || true

# Delete old backend
kubectl delete deployment backend -n student-app --ignore-not-found=true

# Create fixed backend
mkdir -p /tmp/fixed-backend
cd /tmp/fixed-backend

echo "Creating fixed backend..."
cat > index.js << 'EOL'
const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());

const students = [
    {id:1,name:"Fixed Student 1",age:20,grade:"A",email:"fixed1@school.com"},
    {id:2,name:"Fixed Student 2",age:21,grade:"B",email:"fixed2@school.com"},
    {id:3,name:"Fixed Student 3",age:22,grade:"A",email:"fixed3@school.com"}
];

app.get('/api/health', (req,res) => {
    res.json({status:"FIXED",message:"This backend works!"});
});

app.get('/api/students', (req,res) => {
    res.json(students);
});

app.listen(3000, '0.0.0.0', () => console.log('✅ Fixed backend on 3000'));
EOL

cat > package.json << 'EOL'
{
  "name": "fixed-backend",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  }
}
EOL

cat > Dockerfile << 'EOL'
FROM node:18-alpine
WORKDIR /app
COPY package.json ./
RUN npm install
COPY index.js .
EXPOSE 3000
CMD ["node", "index.js"]
EOL

# Build
docker build -t fixed-backend:latest .

# Deploy
cd ~/student-app-k8s-jenkins-cicd
cat > fixed-deploy.yaml << 'EOL'
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
        image: fixed-backend:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 3000
EOL

kubectl apply -f fixed-deploy.yaml
kubectl apply -f k8s/backend/service.yaml

echo "Waiting 20 seconds..."
sleep 20

echo "Checking status..."
kubectl get pods -n student-app

echo "Testing..."
kubectl port-forward -n student-app service/backend-service 30001:3000 &
sleep 3
curl -s http://localhost:30001/api/health | head -c 100
echo ""
curl -s http://localhost:30001/api/students | head -c 100
echo ""

echo "Starting frontend..."
kubectl port-forward -n student-app service/frontend-service 8888:80 &
echo "✅ Open: http://localhost:8888"
