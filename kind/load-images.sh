#!/bin/bash
echo "📤 Loading Docker images into KIND cluster..."

if ! kind get clusters | grep -q "student-app"; then
    echo "❌ KIND cluster 'student-app' not found!"
    exit 1
fi

# Load backend image
if docker images | grep -q "student-backend"; then
    echo "📦 Loading student-backend:latest..."
    kind load docker-image student-backend:latest --name student-app
else
    echo "⚠️  student-backend:latest not found locally"
fi

# Load frontend image
if docker images | grep -q "student-frontend"; then
    echo "🎨 Loading student-frontend:latest..."
    kind load docker-image student-frontend:latest --name student-app
else
    echo "⚠️  student-frontend:latest not found locally"
fi

echo "✅ Images loaded into KIND cluster"