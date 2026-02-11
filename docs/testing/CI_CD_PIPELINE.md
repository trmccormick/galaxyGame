# CI/CD Pipeline - Galaxy Game

## Overview

Galaxy Game uses GitHub Actions for continuous integration and deployment. This document covers the complete CI/CD pipeline, deployment strategies, and operational procedures.

## Pipeline Architecture

### GitHub Actions Workflows

**Location**: `.github/workflows/`
**Purpose**: Automated testing, building, and deployment

#### Main CI Pipeline

```yaml
# .github/workflows/ci.yml
name: CI Pipeline
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  RAILS_ENV: test
  POSTGRES_HOST: localhost
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: postgres
  REDIS_URL: redis://localhost:6379/1

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2.5'
          bundler-cache: true

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'yarn'

      - name: Install system dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y libpq-dev imagemagick

      - name: Install Ruby dependencies
        run: bundle install

      - name: Install JavaScript dependencies
        run: yarn install

      - name: Setup database
        run: |
          bundle exec rails db:create
          bundle exec rails db:migrate

      - name: Run RSpec tests
        run: bundle exec rspec --format progress --out test_results.txt

      - name: Run RuboCop
        run: bundle exec rubocop --format github

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: test_results.txt

      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        if: success()
```

#### Deployment Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production
on:
  push:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'production'
        type: choice
        options:
          - production
          - staging

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    outputs:
      image-digest: ${{ steps.build.outputs.digest }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push Docker image
        id: build
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'production' }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.28.0'

      - name: Configure kubectl
        run: |
          echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > kubeconfig
          export KUBECONFIG=kubeconfig

      - name: Deploy to Kubernetes
        run: |
          # Update deployment image
          kubectl set image deployment/galaxy-game-web \
            galaxy-game-web=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}@${{ needs.build-and-push.outputs.image-digest }}

          # Wait for rollout
          kubectl rollout status deployment/galaxy-game-web

      - name: Run database migrations
        run: |
          kubectl exec -it deployment/galaxy-game-web -- bundle exec rails db:migrate

      - name: Run health checks
        run: |
          kubectl exec -it deployment/galaxy-game-web -- curl -f http://localhost:3000/health || exit 1
```

## Deployment Environments

### Development Environment

**Purpose**: Local development and testing
**Configuration**: `docker-compose.dev.yml`

```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f web

# Run tests in container
docker-compose -f docker-compose.dev.yml exec web rspec
```

### Staging Environment

**Purpose**: Pre-production testing
**Configuration**: `docker-compose.staging.yml`

```bash
# Deploy to staging
docker-compose -f docker-compose.staging.yml up -d

# Run integration tests against staging
bundle exec rspec spec/integration/
```

### Production Environment

**Purpose**: Live application
**Configuration**: `docker-compose.prod.yml`

```bash
# Deploy to production
docker-compose -f docker-compose.prod.yml up -d

# Monitor deployment
docker-compose -f docker-compose.prod.yml logs -f
```

## Docker Configuration

### Multi-Stage Dockerfile

```dockerfile
# Dockerfile
FROM ruby:3.2.5-slim as base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    imagemagick \
    nodejs \
    yarn \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Install JavaScript dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile

# Production stage
FROM base as production

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
USER app

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

### Docker Compose Configurations

#### Development

```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  web:
    build:
      context: .
      target: base
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - bundle:/usr/local/bundle
    environment:
      - RAILS_ENV=development
      - DATABASE_URL=postgres://postgres:password@db:5432/galaxy_game_dev
    depends_on:
      - db
      - redis

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: galaxy_game_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

volumes:
  bundle:
  postgres_data:
```

#### Production

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  web:
    build:
      context: .
      target: production
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    depends_on:
      - db
      - redis
    restart: unless-stopped

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: galaxy_game_prod
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ssl_certs:/etc/ssl/certs
    depends_on:
      - web
    restart: unless-stopped

volumes:
  postgres_data:
  ssl_certs:
```

## Monitoring and Observability

### Health Checks

```ruby
# config/routes.rb
get '/health', to: 'health#show'

# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def show
    checks = {
      database: database_check,
      redis: redis_check,
      sidekiq: sidekiq_check
    }

    status = checks.values.all? ? :ok : :service_unavailable
    render json: checks, status: status
  end

  private

  def database_check
    ActiveRecord::Base.connection.execute('SELECT 1')
    true
  rescue
    false
  end

  def redis_check
    Redis.current.ping == 'PONG'
  rescue
    false
  end

  def sidekiq_check
    Sidekiq::ProcessSet.new.size > 0
  rescue
    false
  end
end
```

### Logging

```ruby
# config/environments/production.rb
config.log_level = :info
config.log_formatter = ::Logger::Formatter.new

# Structured logging
Rails.application.config.lograge.enabled = true
Rails.application.config.lograge.formatter = Lograge::Formatters::Json.new
```

### Metrics Collection

```ruby
# Use prometheus-client for metrics
# config/initializers/prometheus.rb
require 'prometheus/client'

prometheus = Prometheus::Client.registry

# Custom metrics
REQUEST_COUNT = Prometheus::Client::Counter.new(
  :http_requests_total,
  docstring: 'Total number of HTTP requests',
  labels: [:method, :path, :status]
)

# Middleware for collecting metrics
class PrometheusMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    start_time = Time.now
    status, headers, response = @app.call(env)

    REQUEST_COUNT.increment(
      labels: {
        method: env['REQUEST_METHOD'],
        path: env['PATH_INFO'],
        status: status.to_s
      }
    )

    [status, headers, response]
  end
end
```

## Backup and Recovery

### Database Backups

```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
BACKUP_FILE="$BACKUP_DIR/galaxy_game_$DATE.sql"

# Create backup
docker-compose exec -T db pg_dump -U postgres galaxy_game_prod > $BACKUP_FILE

# Compress
gzip $BACKUP_FILE

# Upload to cloud storage (example with AWS S3)
aws s3 cp $BACKUP_FILE.gz s3://galaxy-game-backups/

# Clean up old backups (keep last 30 days)
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete
```

### Application Backups

```bash
# Backup uploaded files and configuration
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/app"

# Backup public/uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz -C /app/public uploads

# Backup configuration (excluding secrets)
tar -czf $BACKUP_DIR/config_$DATE.tar.gz \
  --exclude='*.key' \
  --exclude='*secret*' \
  -C /app config/
```

### Recovery Procedures

```bash
# Database recovery
docker-compose exec db psql -U postgres galaxy_game_prod < backup.sql

# Application rollback
docker-compose pull web  # Pull previous image
docker-compose up -d web

# Full environment recovery
docker-compose down
docker volume rm galaxy_game_postgres_data
docker volume create galaxy_game_postgres_data
docker-compose up -d db
# Wait for database to be ready
docker-compose exec db psql -U postgres -c "CREATE DATABASE galaxy_game_prod;"
docker-compose exec -T db psql -U postgres galaxy_game_prod < backup.sql
docker-compose up -d
```

## Security Considerations

### Container Security

```dockerfile
# Use non-root user
RUN useradd --create-home --shell /bin/bash app
USER app

# Minimize attack surface
RUN apt-get remove -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean

# No secrets in image
# Use environment variables or external secrets management
```

### Secrets Management

```yaml
# Use external secrets (example with Kubernetes)
apiVersion: v1
kind: Secret
metadata:
  name: galaxy-game-secrets
type: Opaque
data:
  database-url: <base64-encoded-url>
  redis-url: <base64-encoded-url>
  secret-key-base: <base64-encoded-key>
```

### Network Security

```yaml
# docker-compose.prod.yml (excerpt)
services:
  web:
    # Only expose necessary ports
    ports:
      - "3000:3000"
    # Use internal networks
    networks:
      - internal

  db:
    # No external ports
    networks:
      - internal

networks:
  internal:
    driver: bridge
    internal: true
```

## Troubleshooting

### Common Deployment Issues

#### 1. Container Won't Start

**Symptoms**: Container exits immediately
**Debugging**:
```bash
# Check container logs
docker-compose logs web

# Run container interactively
docker-compose run --rm web bash

# Check application logs
docker-compose exec web tail -f log/production.log
```

#### 2. Database Connection Issues

**Symptoms**: `PG::ConnectionBad` errors
**Debugging**:
```bash
# Test database connection
docker-compose exec web bundle exec rails db:version

# Check database service
docker-compose ps db

# View database logs
docker-compose logs db
```

#### 3. Asset Compilation Failures

**Symptoms**: `Sprockets::FileNotFound` errors
**Debugging**:
```bash
# Precompile assets manually
docker-compose exec web bundle exec rails assets:precompile

# Check asset paths
docker-compose exec web ls -la public/assets/
```

#### 4. Memory Issues

**Symptoms**: Container killed by OOM killer
**Solutions**:
```yaml
# Increase memory limits
services:
  web:
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
```

### Rollback Procedures

```bash
# Quick rollback to previous deployment
kubectl rollout undo deployment/galaxy-game-web

# Rollback to specific version
kubectl rollout undo deployment/galaxy-game-web --to-revision=2

# Force restart with previous image
docker-compose pull web
docker-compose up -d web
```

---

**Last Updated**: February 11, 2026
**Docker Version**: 24.0+
**Kubernetes Version**: 1.28+
**Ruby Version**: 3.2.5