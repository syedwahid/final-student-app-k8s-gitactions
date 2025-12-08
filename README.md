# Student Management System - Kubernetes & Jenkins CI/CD

## Overview
A full-stack student management application with CI/CD pipeline using Jenkins and Kubernetes.

## Architecture
- **Frontend**: Nginx serving static files
- **Backend**: Node.js/Express API
- **Database**: MySQL (with in-memory fallback)
- **Infrastructure**: Kubernetes (KIND cluster)
- **CI/CD**: Jenkins pipeline with automated builds and deployments

## Quick Start

### 1. Prerequisites
- Docker & Docker Compose
- kubectl
- KIND (Kubernetes in Docker)
- Jenkins (or use included Jenkins setup)

### 2. Local Development
```bash
# Clone repository
git clone <repo-url>
cd student-app-k8s

# Start local cluster
./scripts/deploy.sh

# Access application
./scripts/access-app.sh# final-student-app-k8s-cicd
# final-student-app-k8s-cicd
