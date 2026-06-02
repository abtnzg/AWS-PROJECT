# Development Notes

## Services Overview

### API Gateway
- **Port:** 3000
- **Purpose:** Entry point for all requests
- **Routes:** Forwards requests to other microservices
- **Dependencies:** user-service, product-service, order-service

### User Service
- **Port:** 3001
- **Purpose:** User management
- **Database:** users_db
- **Tables:** users
- **Dependencies:** MySQL

### Product Service
- **Port:** 3002
- **Purpose:** Product catalog management
- **Database:** products_db
- **Tables:** products
- **Dependencies:** MySQL

### Order Service
- **Port:** 3003
- **Purpose:** Order management
- **Database:** orders_db
- **Tables:** orders
- **Dependencies:** MySQL

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Products Table
```sql
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  stock INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Orders Table
```sql
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  total_price DECIMAL(10, 2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Local Development

### Starting Services
```bash
cd microservices
docker-compose up -d
```

### Accessing Services
- API Gateway: http://localhost:3000
- User Service: http://localhost:3001
- Product Service: http://localhost:3002
- Order Service: http://localhost:3003
- MySQL: localhost:3306

### MySQL Access
```bash
mysql -h 127.0.0.1 -u root -p
# Password: rootpassword
```

## Kubernetes Deployment

### Before Deployment
1. Ensure EKS cluster is running
2. Update AWS Account ID in scripts
3. Configure kubectl to connect to your cluster
4. Build and push images to ECR

### Deployment Process
```bash
# Build and push images
./scripts/build-and-push.sh 205474062795 eu-west-1

# Deploy to Kubernetes
./scripts/deploy.sh 205474062795 dev

# Verify deployment
./scripts/status.sh microservices
```

### Accessing Deployed Services
- API Gateway: http://api.205474062795.realhandsonlabs.net
- Services communicate via DNS within the cluster

## CI/CD Integration

To integrate with your GitHub Actions pipeline:

1. Add ECR build step to your workflow
2. Push images with a specific tag (e.g., git commit SHA)
3. Update Kubernetes manifests with new image tags
4. Deploy to EKS

Example workflow step:
```yaml
- name: Build and push microservices
  run: |
    ./microservices/scripts/build-and-push.sh $AWS_ACCOUNT_ID $AWS_REGION ${{ github.sha }}
```

## Next Steps

1. **Add Authentication:** Implement JWT token validation
2. **Add Message Queue:** Integrate RabbitMQ or SQS for async operations
3. **Add Service Mesh:** Implement Istio for advanced networking
4. **Add Monitoring:** Set up CloudWatch or Prometheus/Grafana
5. **Add Logging:** Implement ELK or CloudWatch Logs
6. **Add Tracing:** Implement distributed tracing with X-Ray
7. **Add CI/CD:** Integrate with GitHub Actions
8. **Add Tests:** Add unit and integration tests
9. **Add Documentation:** Generate API documentation with Swagger
10. **Add Security:** Add container scanning and RBAC policies
