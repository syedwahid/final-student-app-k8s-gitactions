#!/bin/bash
echo "🔧 Fixing Access Now!"
echo "===================="

# Clean up
pkill -f "kubectl port-forward" 2>/dev/null

# Use simple port-forward
kubectl port-forward -n student-app service/backend-service 30001:3000 &
sleep 2
kubectl port-forward -n student-app service/frontend-service 8888:80 &
sleep 2

# Test
echo "Testing backend..."
if curl -s http://localhost:30001/api/health > /dev/null; then
    echo "✅ Backend is working!"
    echo "Backend response:"
    curl -s http://localhost:30001/api/health | python3 -m json.tool 2>/dev/null || curl -s http://localhost:30001/api/health
else
    echo "❌ Backend not responding"
    echo "Checking pods..."
    kubectl get pods -n student-app
    echo "Checking logs..."
    kubectl logs -n student-app deployment/backend --tail=10
fi

echo ""
echo "🌐 Access URLs:"
echo "Frontend: http://localhost:8888"
echo "Backend API: http://localhost:30001/api/health"
echo ""
echo "⏹️  To stop: Ctrl+C or run: pkill -f 'kubectl port-forward'"
