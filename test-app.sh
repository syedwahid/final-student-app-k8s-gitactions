#!/bin/bash
echo "🧪 Testing Student Management App..."
echo "===================================="

cd ~/student-app-k8s-jenkins-cicd

echo "1. Testing backend..."
cd app/backend
node -c app.js && echo "✅ Backend app.js syntax OK" || echo "❌ Backend app.js syntax error"
cd ../..

echo "2. Testing frontend..."
cd app/frontend
if [ -f "index.html" ]; then
    echo "✅ index.html exists"
else
    echo "❌ index.html missing"
fi
if [ -f "app.js" ]; then
    echo "✅ app.js exists"
else
    echo "❌ app.js missing"
fi
if [ -f "styles.css" ]; then
    echo "✅ styles.css exists"
else
    echo "❌ styles.css missing"
fi
cd ../..

echo "3. Testing Docker builds..."
echo "Building backend..."
docker build -t student-backend-test app/backend/ && echo "✅ Backend Docker build OK" || echo "❌ Backend Docker build failed"

echo "Building frontend..."
docker build -t student-frontend-test app/frontend/ && echo "✅ Frontend Docker build OK" || echo "❌ Frontend Docker build failed"

echo ""
echo "✅ Testing complete!"
echo "Run ./scripts/deploy.sh to deploy to KIND"