#!/bin/bash
echo "🔍 Testing Frontend-Backend Connection"
echo "======================================"

echo "1. Testing backend directly..."
curl -s http://localhost:30001/api/health && echo "✅ Backend health OK" || echo "❌ Backend health failed"
curl -s http://localhost:30001/api/students | jq '. | length' 2>/dev/null || curl -s http://localhost:30001/api/students | head -c 100

echo ""
echo "2. Checking pods..."
kubectl get pods -n student-app -o wide

echo ""
echo "3. Checking services..."
kubectl get svc -n student-app

echo ""
echo "4. Checking backend logs..."
kubectl logs -n student-app deployment/backend --tail=5

echo ""
echo "5. Checking frontend logs..."
kubectl logs -n student-app deployment/frontend --tail=5

echo ""
echo "6. Testing from frontend pod..."
FRONTEND_POD=$(kubectl get pods -n student-app -l app=frontend -o jsonpath='{.items[0].metadata.name}')
echo "Frontend pod: $FRONTEND_POD"
kubectl exec -n student-app $FRONTEND_POD -- curl -s http://backend-service:3000/api/health || echo "Frontend cannot reach backend"

echo ""
echo "7. Browser test instructions:"
echo "   Open: http://localhost:8888"
echo "   Press F12 to open Developer Tools"
echo "   Go to Console tab"
echo "   Look for errors or API_BASE_URL log"
