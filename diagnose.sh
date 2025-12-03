#!/bin/bash
echo "🔍 DIAGNOSTIC - Why No Data?"
echo "============================="

echo "1. Are pods running?"
kubectl get pods -n student-app -o wide

echo ""
echo "2. Is backend responding?"
curl -v http://localhost:30001/api/health 2>&1 | head -20

echo ""
echo "3. Backend logs:"
kubectl logs -n student-app deployment/backend --tail=10

echo ""
echo "4. Frontend logs:"
kubectl logs -n student-app deployment/frontend --tail=10

echo ""
echo "5. Check browser console:"
echo "   - Open http://localhost:8888"
echo "   - Press F12"
echo "   - Go to Console tab"
echo "   - Look for errors or 'API_URL' log"

echo ""
echo "6. Direct API test:"
echo "   curl http://localhost:30001/api/students"

echo ""
echo "✅ Diagnostic complete"
