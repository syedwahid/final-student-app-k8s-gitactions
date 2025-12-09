#!/bin/bash
echo "🎓 Student Management App - Access Guide"
echo "========================================"
echo "Using KIND Kubernetes Cluster"
echo "============================="

# Check if KIND cluster exists
if ! kind get clusters | grep -q "student-app"; then
    echo "❌ KIND cluster 'student-app' not found!"
    echo "   Run: ./scripts/kind-setup.sh"
    exit 1
fi

# Set kubectl context
kubectl config use-context kind-student-app

# Kill any existing port-forwards (not needed with KIND port mappings, but just in case)
pkill -f "kubectl port-forward" 2>/dev/null || true

echo ""
echo "✅ Application is accessible via KIND port mappings!"
echo ""
echo "🌐 ACCESS URLs:"
echo "   Frontend (UI):    http://localhost:31349"
echo "   Backend (API):    http://localhost:30001/api"
echo ""
echo "🔍 TEST ENDPOINTS:"
echo "   Health Check:     curl http://localhost:30001/api/health"
echo "   List Students:    curl http://localhost:30001/api/students"
echo ""
echo "📊 DEMO DATA:"
echo "   The app comes with 5 sample students"
echo "   You can add, edit, and delete students"
echo ""
echo "🔄 If you need to restart:"
echo "   ./scripts/teardown.sh"
echo "   ./scripts/deploy.sh"
echo ""
echo "🔧 Troubleshooting:"
echo "   Check pod status: kubectl get pods -n student-app"
echo "   View logs: kubectl logs -n student-app deployment/backend"
echo ""
echo "🎯 Happy Learning with KIND Kubernetes!"