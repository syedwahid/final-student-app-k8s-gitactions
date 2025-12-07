#!/bin/bash
echo "💥 NUKE EVERYTHING - Complete Cleanup"
echo "======================================"
echo "This will destroy ALL Docker, Kubernetes, and KIND resources"
echo "Continue? (y/N)"
read -r response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "❌ Aborted."
    exit 1
fi

echo ""
echo "🚀 Starting complete cleanup..."
echo ""

# 1. Stop all port-forwards
echo "1. 🛑 Stopping all port-forward processes..."
pkill -f "kubectl port-forward" 2>/dev/null || true
pkill -f "kubectl proxy" 2>/dev/null || true
echo "   ✅ Port-forwards stopped"

# 2. Stop all running containers
echo "2. 🛑 Stopping all Docker containers..."
docker stop $(docker ps -q) 2>/dev/null || true
echo "   ✅ Containers stopped"

# 3. Delete KIND clusters
echo "3. 🗑️  Deleting KIND clusters..."
kind delete cluster --name student-app 2>/dev/null || true
kind delete cluster --name kind 2>/dev/null || true
kind delete cluster --name jenkins 2>/dev/null || true
kind delete cluster --all 2>/dev/null || true
echo "   ✅ KIND clusters deleted"

# 4. Delete all Kubernetes namespaces (except default, kube-system)
echo "4. 🗑️  Deleting Kubernetes namespaces..."
kubectl delete namespace student-app --ignore-not-found=true
kubectl delete namespace jenkins --ignore-not-found=true
kubectl delete namespace default --ignore-not-found=true --grace-period=0 --force 2>/dev/null || true

# Delete all custom namespaces
for ns in $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
    if [[ "$ns" != "kube-system" && "$ns" != "kube-public" && "$ns" != "kube-node-lease" ]]; then
        kubectl delete namespace "$ns" --ignore-not-found=true --grace-period=0 --force 2>/dev/null || true
    fi
done
echo "   ✅ Namespaces deleted"

# 5. Remove all Docker resources
echo "5. 🗑️  Removing Docker resources..."

# Remove all containers
echo "   Removing containers..."
docker rm -f $(docker ps -aq) 2>/dev/null || true

# Remove all student app images
echo "   Removing student app images..."
docker rmi -f $(docker images | grep "student-" | awk '{print $3}') 2>/dev/null || true
docker rmi -f student-backend:latest student-frontend:latest 2>/dev/null || true
docker rmi -f student-backend-local:latest student-frontend-local:latest 2>/dev/null || true
docker rmi -f student-backend-crud:latest student-frontend-original:latest 2>/dev/null || true

# Remove all Docker images (optional - uncomment if you want to remove ALL images)
# echo "   Removing all Docker images..."
# docker rmi -f $(docker images -q) 2>/dev/null || true

# Remove all volumes
echo "   Removing volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null || true

# Remove all networks (except default)
echo "   Removing networks..."
docker network rm $(docker network ls -q | grep -v "bridge\|host\|none") 2>/dev/null || true

# Prune everything
echo "   Pruning Docker system..."
docker system prune -a -f --volumes 2>/dev/null || true
echo "   ✅ Docker resources cleaned"

# 6. Clean Kubernetes config
echo "6. 🧹 Cleaning Kubernetes configuration..."
kubectl config delete-context kind-student-app 2>/dev/null || true
kubectl config delete-cluster kind-student-app 2>/dev/null || true
kubectl config delete-user kind-student-app 2>/dev/null || true
kubectl config unset contexts.kind-student-app 2>/dev/null || true

# Remove KIND entries from kubeconfig
if [ -f ~/.kube/config ]; then
    cp ~/.kube/config ~/.kube/config.backup.$(date +%Y%m%d_%H%M%S)
    KUBECONFIG=~/.kube/config kubectl config get-contexts -o name | grep -E "kind-|minikube-" | xargs -I {} kubectl config delete-context {} 2>/dev/null || true
fi
echo "   ✅ Kubernetes config cleaned"

# 7. Clean temporary files
echo "7. 🧹 Cleaning temporary files..."
rm -rf /tmp/kube-* /tmp/kind-* /tmp/docker-* 2>/dev/null || true
rm -rf ~/.kube/cache ~/.kube/http-cache 2>/dev/null || true
echo "   ✅ Temporary files cleaned"

# 8. Stop Docker service (optional)
echo "8. ⏸️  Stopping Docker service..."
sudo systemctl stop docker 2>/dev/null || true
sudo systemctl stop docker.socket 2>/dev/null || true
echo "   ✅ Docker service stopped"

# 9. Reset Docker (nuclear option - uncomment if needed)
# echo "9. 🔄 Resetting Docker..."
# sudo systemctl stop docker
# sudo rm -rf /var/lib/docker
# sudo systemctl start docker
# echo "   ✅ Docker reset"

# 10. Verify cleanup
echo "10. 🔍 Verifying cleanup..."
echo ""
echo "📊 FINAL STATUS:"
echo "----------------"

echo "Docker containers:"
docker ps -a 2>/dev/null || echo "   Docker not running or no containers"

echo ""
echo "Docker images:"
docker images 2>/dev/null | head -10 || echo "   Docker not running or no images"

echo ""
echo "KIND clusters:"
kind get clusters 2>/dev/null || echo "   No KIND clusters found"

echo ""
echo "Kubernetes contexts:"
kubectl config get-contexts 2>/dev/null || echo "   No kubectl contexts"

echo ""
echo "Disk space freed:"
df -h /var/lib/docker 2>/dev/null || echo "   Could not check disk space"

echo ""
echo "✅ NUKE COMPLETE!"
echo "✨ Everything has been destroyed and cleaned."
echo ""
echo "To start fresh:"
echo "1. Start Docker: sudo systemctl start docker"
echo "2. Create KIND: kind create cluster --name student-app --config kind/kind-config-fixed.yaml"
echo "3. Run pipeline: Go to Jenkins and run your CI/CD pipeline"