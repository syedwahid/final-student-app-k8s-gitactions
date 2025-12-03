#!/bin/bash
echo "🧹 Cleaning up Jenkins..."

kubectl delete -f jenkins/ --ignore-not-found=true
kubectl delete namespace jenkins --ignore-not-found=true

echo "✅ Jenkins cleanup completed!"