#!/bin/bash
echo "🚀 Setting up Jenkins CI/CD for Student Management App..."

# Create Jenkins namespace and resources
kubectl apply -f jenkins/namespace.yaml

# Create service account and permissions
kubectl apply -f jenkins/serviceaccount.yaml

# Create config maps
kubectl apply -f jenkins/kube-config.yaml
kubectl apply -f jenkins/jenkins-config.yaml

# Create PVC
kubectl apply -f jenkins/pvc.yaml

# Deploy Jenkins
kubectl apply -f jenkins/deployment.yaml
kubectl apply -f jenkins/service.yaml

# Wait for Jenkins to be ready
echo "⏳ Waiting for Jenkins to start..."
sleep 30
kubectl wait --for=condition=ready pod -l app=jenkins -n jenkins --timeout=300s

# Get Jenkins admin password
echo ""
echo "📋 Jenkins Admin Credentials:"
echo "Username: admin"
echo "Password: admin123"
echo ""
echo "🌐 Access Jenkins at: http://$(minikube ip):32000"
echo ""
echo "🎯 Jenkins setup completed!"