# Microservices Architecture for AWS EKS

A complete microservices architecture with 4 services designed to run on AWS EKS infrastructure.

## 📋 Overview

### Services

1. **API Gateway** (Port 3000)
   - Entry point for all client requests
   - Routes requests to appropriate microservices
   - Handles CORS and logging

2. **User Service** (Port 3001)
   - Manages user data
   - CRUD operations for users
   - MySQL backend

3. **Product Service** (Port 3002)
   - Manages product catalog
   - CRUD operations for products
   - MySQL backend

4. **Order Service** (Port 3003)
   - Manages orders
   - CRUD operations for orders
   - MySQL backend

### Technology Stack

- **Runtime:** Node.js 18 (Alpine)
- **Framework:** Express.js
- **Database:** MySQL 8.0
- **Container:** Docker
- **Orchestration:** Kubernetes (EKS)
- **Cloud Provider:** AWS

## 🚀 Quick Start

### Local Development with Docker Compose

```bash
# Navigate to microservices directory
cd microservices

# Make scripts executable
chmod +x scripts/*.sh

# Start local development environment
./scripts/local-dev-setup.sh

# Test the API
curl http://localhost:3000/api/users

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Deploy to EKS

```bash
# Set your AWS Account ID
export AWS_ACCOUNT_ID=205474062795
export AWS_REGION=eu-west-1

# Build and push Docker images to ECR
./scripts/build-and-push.sh $AWS_ACCOUNT_ID $AWS_REGION

# Deploy to EKS
./scripts/deploy.sh $AWS_ACCOUNT_ID dev microservices

# Check deployment status
./scripts/status.sh microservices

# Undeploy (if needed)
./scripts/undeploy.sh microservices
```

## 📁 Project Structure

```
microservices/
├── api-gateway/          # API Gateway service
│   ├── package.json
│   ├── index.js
│   └── Dockerfile
├── user-service/         # User management service
│   ├── package.json
│   ├── index.js
│   └── Dockerfile
├── product-service/      # Product catalog service
│   ├── package.json
│   ├── index.js
│   └── Dockerfile
├── order-service/        # Order management service
│   ├── package.json
│   ├── index.js
│   └── Dockerfile
├── k8s/                  # Kubernetes manifests
│   ├── 01-mysql.yaml     # MySQL deployment
│   ├── 02-services.yaml  # Microservices deployments
│   └── 03-ingress-hpa.yaml  # Ingress and HPA config
├── scripts/              # Helper scripts
│   ├── build-and-push.sh
│   ├── deploy.sh
│   ├── undeploy.sh
│   ├── status.sh
│   └── local-dev-setup.sh
├── docker-compose.yml    # Local development
└── README.md            # This file
```

## 🔌 API Endpoints

### API Gateway (http://localhost:3000)

#### Users
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

#### Products
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

#### Orders
- `GET /api/orders` - Get all orders
- `GET /api/orders/:id` - Get order by ID
- `POST /api/orders` - Create new order
- `PUT /api/orders/:id` - Update order status
- `DELETE /api/orders/:id` - Delete order

#### Health Check
- `GET /health` - Service health status (all services)

## 📝 Example Requests

### Create a User
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

### Create a Product
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","description":"High-performance laptop","price":999.99,"stock":50}'
```

### Create an Order
```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id":1,"product_id":1,"quantity":2,"total_price":1999.98}'
```

## 🐳 Docker Commands

### Build all services
```bash
docker-compose build
```

### Run services in background
```bash
docker-compose up -d
```

### View logs
```bash
docker-compose logs -f [service-name]
```

### Stop services
```bash
docker-compose down
```

### Remove volumes
```bash
docker-compose down -v
```

## ☸️ Kubernetes Deployment

### Prerequisites
- EKS cluster running
- kubectl configured
- AWS CLI configured
- ECR repositories created or auto-created by script

### Deployment Steps

1. **Build and push images to ECR:**
   ```bash
   ./scripts/build-and-push.sh 205474062795 eu-west-1 v1.0.0
   ```

2. **Deploy to EKS:**
   ```bash
   ./scripts/deploy.sh 205474062795 dev
   ```

3. **Verify deployment:**
   ```bash
   ./scripts/status.sh
   ```

### Kubernetes Resources Created

- **Namespace:** microservices
- **Deployments:** api-gateway, user-service, product-service, order-service, mysql
- **Services:** LoadBalancer for API Gateway, ClusterIP for others
- **Ingress:** ALB-based ingress for external access
- **HPA:** Auto-scaling policies for all services
- **PVC:** Persistent storage for MySQL
- **Secret:** MySQL credentials
- **NetworkPolicy:** Microservices network isolation

## 🔐 Security Considerations

### Implemented
- Health checks (liveness & readiness probes)
- Resource limits and requests
- Persistent volume for database
- Network policies
- Container security scanning (recommended)

### Recommended
- Implement service mesh (Istio) for advanced networking
- Add authentication/authorization (OAuth2/JWT)
- Use AWS Secrets Manager for sensitive data
- Enable Pod Security Policies
- Implement logging and monitoring (CloudWatch/ELK)
- Use HTTPS/TLS for all communications

## 📊 Monitoring & Logging

### Local Logs
```bash
# View all logs
docker-compose logs

# Follow specific service logs
docker-compose logs -f api-gateway
```

### Kubernetes Logs
```bash
# Get pod logs
kubectl logs -f <pod-name> -n microservices

# Get all pod logs for a service
kubectl logs -f -l app=api-gateway -n microservices

# Get previous logs (if pod crashed)
kubectl logs <pod-name> --previous -n microservices
```

## 🔄 Scaling

### Manual Scaling
```bash
# Scale a deployment
kubectl scale deployment api-gateway --replicas=3 -n microservices
```

### Auto-scaling
Auto-scaling is configured via HPA with:
- Min replicas: 2
- Max replicas: 5
- CPU threshold: 70%
- Memory threshold: 80%

### View HPA Status
```bash
kubectl get hpa -n microservices
kubectl describe hpa api-gateway-hpa -n microservices
```

## 🔧 Configuration

### Environment Variables

**API Gateway:**
- `PORT` - Service port (default: 3000)
- `USER_SERVICE_URL` - User service URL
- `PRODUCT_SERVICE_URL` - Product service URL
- `ORDER_SERVICE_URL` - Order service URL

**Microservices (User, Product, Order):**
- `PORT` - Service port
- `DB_HOST` - MySQL host
- `DB_USER` - MySQL user
- `DB_PASSWORD` - MySQL password
- `DB_NAME` - Database name

### Updating Configuration

1. Edit `docker-compose.yml` for local development
2. Edit `k8s/02-services.yaml` for Kubernetes deployment
3. Rebuild and redeploy services

## 🛠️ Development Workflow

```bash
# 1. Clone the repository
git clone <repository-url>
cd microservices

# 2. Install dependencies (optional - Docker handles it)
cd api-gateway && npm install
cd ../user-service && npm install
# ... for other services

# 3. Start local development
./scripts/local-dev-setup.sh

# 4. Make changes to services
# Edit files in respective service directories

# 5. Rebuild services
docker-compose down
docker-compose build
docker-compose up -d

# 6. Test changes
curl http://localhost:3000/api/users

# 7. Commit and push changes
git add .
git commit -m "Feature: description"
git push

# 8. Build and push to ECR
./scripts/build-and-push.sh 205474062795 eu-west-1

# 9. Deploy to EKS
./scripts/deploy.sh 205474062795 dev
```

## 🐛 Troubleshooting

### Services not starting
```bash
# Check logs
docker-compose logs

# Ensure ports are not in use
lsof -i :3000
```

### MySQL connection errors
```bash
# Check MySQL container status
docker-compose ps mysql

# Verify connection
mysql -h 127.0.0.1 -u root -p
```

### Kubernetes deployment issues
```bash
# Check pod status
kubectl get pods -n microservices

# Describe pod for events
kubectl describe pod <pod-name> -n microservices

# Check events
kubectl get events -n microservices

# View logs
kubectl logs <pod-name> -n microservices
```

## 📚 Additional Resources

- [Express.js Documentation](https://expressjs.com/)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Docker Documentation](https://docs.docker.com/)

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review logs and events
3. Check Kubernetes resources status
4. Consult the documentation

## 📄 License

This project is part of the AWS-PROJECT infrastructure.
