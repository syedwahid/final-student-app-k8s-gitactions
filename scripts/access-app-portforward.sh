#!/bin/bash
echo "🎓 Student Management App - Port Forward Access"
echo "================================================"

# Kill existing port-forwards
pkill -f "kubectl port-forward" 2>/dev/null || true

echo "🚀 Starting port forwarding..."

# Start backend port forward
echo "🔧 Forwarding backend to port 30001..."
kubectl port-forward -n student-app service/backend-service 30001:3000 > /dev/null 2>&1 &
BACKEND_PID=$!

# Start frontend port forward
echo "🎨 Forwarding frontend to port 8888..."
kubectl port-forward -n student-app service/frontend-service 8888:80 > /dev/null 2>&1 &
FRONTEND_PID=$!

# Wait for port forwarding to establish
sleep 5

echo ""
echo "🧪 Testing connections..."
echo "Backend API:"
curl -s http://localhost:30001/api/health | python3 -m json.tool 2>/dev/null || curl -s http://localhost:30001/api/health || echo "Backend not ready yet"

echo ""
echo "Frontend:"
curl -s -I http://localhost:8888 | head -1 || echo "Frontend not ready yet"

echo ""
echo "✅ Application is now running via port-forward!"
echo ""
echo "🌐 ACCESS URLs:"
echo "   Frontend (UI):    http://localhost:8888"
echo "   Backend (API):    http://localhost:30001/api"
echo ""
echo "🔍 TEST ENDPOINTS:"
echo "   Health Check:     curl http://localhost:30001/api/health"
echo "   List Students:    curl http://localhost:30001/api/students"
echo ""
echo "⏹️  To stop: Press Ctrl+C"
echo ""
echo "📝 Note: This uses kubectl port-forward instead of KIND port mapping"
echo "   For direct KIND ports, check if ports 30001 and 31349 are open"

# Keep script running and handle cleanup
trap "echo 'Stopping port forwarding...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit 0" INT TERM

echo "Press Ctrl+C to stop..."
wait
