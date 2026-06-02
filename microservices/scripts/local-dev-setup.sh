#!/bin/bash

# Local development setup
# Usage: ./local-dev-setup.sh

set -e

echo "=========================================="
echo "Local Development Setup"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker ps &> /dev/null; then
  echo "❌ Docker is not running. Please start Docker and try again."
  exit 1
fi

echo "✅ Docker is running"
echo ""

# Build and start Docker Compose
echo "Building services..."
docker-compose build

echo ""
echo "Starting services..."
docker-compose up -d

echo ""
echo "Waiting for services to be ready..."
sleep 10

echo ""
echo "=========================================="
echo "✅ Local development environment started!"
echo "=========================================="
echo ""

echo "Services are running at:"
echo "  - API Gateway:    http://localhost:3000"
echo "  - User Service:   http://localhost:3001"
echo "  - Product Service: http://localhost:3002"
echo "  - Order Service:  http://localhost:3003"
echo "  - MySQL:          localhost:3306"
echo ""

echo "Test the API:"
echo "  curl http://localhost:3000/api/users"
echo ""

echo "View logs:"
echo "  docker-compose logs -f"
echo ""

echo "Stop services:"
echo "  docker-compose down"
