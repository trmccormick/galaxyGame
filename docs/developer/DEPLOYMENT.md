# Production Deployment Guide

## Overview

This guide covers deploying Galaxy Game to production environments using Docker and docker-compose.

## Prerequisites

- Docker and docker-compose installed on production server
- Domain name configured (optional but recommended)
- SSL certificate (Let's Encrypt recommended)
- Backup storage (AWS S3, local NAS, etc.)

## Production Docker Configuration

### Environment Setup

Create a production environment file:

```bash
# .env.production
RAILS_ENV=production
DATABASE_URL=postgres://postgres:secure_password@db:5432/galaxy_game_production
REDIS_URL=redis://redis:6379/1
SECRET_KEY_BASE=your_secret_key_here
RAILS_MASTER_KEY=your_master_key_here
```

### Docker Compose Production Override

The `docker-compose.prod.yml` needs these corrections for production:

```yaml
version: '3.8'
services:
  db:
    environment:
      POSTGRES_DB: galaxy_game_production  # Use production database
      POSTGRES_PASSWORD: ${DB_PASSWORD}    # Use environment variable

  web:
    environment:
      RAILS_ENV: production               # Set to production
      DATABASE_URL: ${DATABASE_URL}       # Use production DB URL
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      RAILS_MASTER_KEY: ${RAILS_MASTER_KEY}
    command: bash -c "rails assets:precompile && rails db:migrate && rails server -b '0.0.0.0' -e production"
```

## Deployment Steps

### 1. Initial Setup

```bash
# Clone repository
git clone <repository-url> galaxy-game
cd galaxy-game

# Copy production environment file
cp .env.example .env.production
# Edit .env.production with secure values
```

### 2. Database Setup

```bash
# Start only database
docker-compose -f docker-compose.prod.yml up -d db

# Wait for database to be ready
sleep 30

# Create production database
docker-compose -f docker-compose.prod.yml exec web rails db:create

# Run migrations
docker-compose -f docker-compose.prod.yml exec web rails db:migrate

# Seed initial data (if needed)
docker-compose -f docker-compose.prod.yml exec web rails db:seed
```

### 3. Asset Precompilation

```bash
# Precompile assets for production
docker-compose -f docker-compose.prod.yml exec web rails assets:precompile
```

### 4. Start Services

```bash
# Start all services
docker-compose -f docker-compose.prod.yml up -d

# Check logs
docker-compose -f docker-compose.prod.yml logs -f web
```

### 5. SSL Configuration (Recommended)

```bash
# Install certbot for Let's Encrypt
sudo apt-get install certbot

# Get SSL certificate
sudo certbot certonly --standalone -d yourdomain.com

# Update nginx configuration to use SSL
# (See nginx configuration section below)
```

## Nginx Reverse Proxy (Recommended)

Create `/etc/nginx/sites-available/galaxy-game`:

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/galaxy-game /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Backup Strategy

### Database Backups

```bash
# Create backup script
cat > /usr/local/bin/backup-galaxy-game.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/galaxy-game"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
docker-compose -f /path/to/galaxy-game/docker-compose.prod.yml exec -T db pg_dump -U postgres galaxy_game_production > $BACKUP_DIR/db_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/db_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -name "db_*.sql.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/db_$DATE.sql.gz"
EOF

chmod +x /usr/local/bin/backup-galaxy-game.sh
```

### Automated Backups

```bash
# Add to crontab for daily backups at 2 AM
0 2 * * * /usr/local/bin/backup-galaxy-game.sh
```

## Monitoring

### Health Checks

```bash
# Check if services are running
docker-compose -f docker-compose.prod.yml ps

# Check application health
curl -f http://localhost:3000/health || echo "Application unhealthy"
```

### Log Monitoring

```bash
# View application logs
docker-compose -f docker-compose.prod.yml logs -f web

# View database logs
docker-compose -f docker-compose.prod.yml logs -f db

# View Sidekiq logs
docker-compose -f docker-compose.prod.yml logs -f sidekiq
```

## Troubleshooting

### Common Issues

**Assets not loading in production:**
```bash
# Recompile assets
docker-compose -f docker-compose.prod.yml exec web rails assets:precompile
docker-compose -f docker-compose.prod.yml restart web
```

**Database connection issues:**
```bash
# Check database connectivity
docker-compose -f docker-compose.prod.yml exec web rails db:migrate:status
```

**Memory issues:**
```bash
# Check container resource usage
docker stats

# Restart services if needed
docker-compose -f docker-compose.prod.yml restart
```

## Updates and Maintenance

### Application Updates

```bash
# Pull latest changes
git pull origin main

# Rebuild containers
docker-compose -f docker-compose.prod.yml build

# Run migrations
docker-compose -f docker-compose.prod.yml exec web rails db:migrate

# Restart services
docker-compose -f docker-compose.prod.yml up -d
```

### Security Updates

```bash
# Update Docker images
docker-compose -f docker-compose.prod.yml pull

# Restart with updated images
docker-compose -f docker-compose.prod.yml up -d
```

## Performance Optimization

### Database Tuning

```sql
-- Add to PostgreSQL configuration
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
```

### Rails Performance

```ruby
# config/environments/production.rb
config.cache_classes = true
config.eager_load = true
config.consider_all_requests_local = false
config.action_controller.perform_caching = true
config.cache_store = :redis_cache_store, { url: ENV.fetch('REDIS_URL') }
```

## Scaling Considerations

For high-traffic deployments:

1. **Load Balancer**: Use nginx or HAProxy for multiple app servers
2. **Database**: Consider connection pooling (PgBouncer)
3. **Caching**: Implement Redis for session and fragment caching
4. **CDN**: Use CloudFront or similar for static assets
5. **Monitoring**: Implement proper monitoring (DataDog, New Relic)

---

**Last Updated**: February 11, 2026
**Status**: Initial production deployment guide