#!/bin/bash
echo "🧹 Cleaning up Student Management App from KIND cluster..."

# Set kubectl context
kubectl config use-context kind-student-app 2>/dev/null || true

# Delete all resources
kubectl delete -f k8s/frontend/ --ignore-not-found=true
kubectl delete -f k8s/backend/ --ignore-not-found=true
kubectl delete -f k8s/mysql/ --ignore-not-found=true
kubectl delete -f k8s/configmap.yaml --ignore-not-found=true
kubectl delete -f k8s/secrets.yaml --ignore-not-found=true
kubectl delete -f k8s/namespace.yaml --ignore-not-found=true

# Kill any port-forward processes
pkill -f "kubectl port-forward" 2>/dev/null || true

echo "✅ Cleanup completed!"
echo ""
echo "To delete the entire KIND cluster:"
echo "   kind delete cluster --name student-app"
echo ""
echo "To recreate cluster:"
echo "   ./scripts/kind-setup.sh"