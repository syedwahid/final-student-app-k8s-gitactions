#!/bin/bash
echo "🎨 RESTORING ORIGINAL UI WITH CRUD"
echo "==================================="

cd ~/student-app-k8s-jenkins-cicd

echo "1. Rebuilding frontend with original UI..."
cd app/frontend

# Create the three files from above if they don't exist
# (Copy the HTML, CSS, and JS code from above into these files)

cd ../..

echo "2. Building Docker image..."
docker build -t student-frontend-original:latest app/frontend/

echo "3. Loading to KIND..."
kind load docker-image student-frontend-original:latest --name student-app

echo "4. Updating deployment..."
kubectl rollout