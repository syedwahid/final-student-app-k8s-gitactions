#!/bin/bash
echo "🧪 Testing Student Management Application"
echo "========================================="

echo "1. Checking pods..."
kubectl get pods -n student-app

echo ""
echo "2. Testing Backend API..."
echo "Health Check:"
curl -s http://localhost:30001/api/health || echo "❌ Backend not accessible"

echo ""
echo "Students API:"
curl -s http://localhost:30001/api/students || echo "❌ Students endpoint not working"

echo ""
echo "3. Testing Frontend..."
echo "Frontend HTML (first 5 lines):"
curl -s http://localhost:31349 | head -5 || echo "❌ Frontend not accessible"

echo ""
echo "4. Checking logs..."
echo "Backend logs (last 5 lines):"
kubectl logs -n student-app deployment/backend --tail=5 2>/dev/null || echo "Cannot get logs"

echo ""
echo "✅ Test completed!"
echo "🌐 Open browser to: http://localhost:31349"
