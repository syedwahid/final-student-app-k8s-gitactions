#!/bin/bash
echo "🔄 Complete Reset - Student Management App with KIND"
echo "==================================================="

echo "1. Cleaning up..."
./scripts/teardown.sh

echo "2. Deleting KIND cluster..."
kind delete cluster --name student-app 2>/dev/null || true

echo "3. Recreating KIND cluster..."
./scripts/kind-setup.sh

echo "4. Rebuilding and deploying..."
./scripts/deploy.sh

echo "5. Waiting for services..."
sleep 40

echo "6. Testing..."
curl -s http://localhost:30001/api/health || echo "Backend not ready yet"
curl -s http://localhost:31349 | head -5 || echo "Frontend not ready yet"

echo ""
echo "✅ Reset completed!"
echo "🌐 Access:"
echo "   Frontend: http://localhost:31349"
echo "   Backend:  http://localhost:30001/api/health"