# Developer Setup Guide

## Prerequisites

- Ruby 3.2.5 (use rbenv or rvm)
- PostgreSQL 16
- Docker and docker-compose
- Git

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd galaxyGame
   ```

2. **Set up Ruby environment**
   ```bash
   rbenv install 3.2.5
   rbenv local 3.2.5
   gem install bundler
   ```

3. **Install dependencies**
   ```bash
   bundle install
   ```

4. **Set up the database**
   ```bash
   # Using Docker (recommended)
   docker-compose up -d db

   # Or using local PostgreSQL
   createdb galaxy_game_development
   createdb galaxy_game_test

   # Run migrations
   bin/rails db:create db:migrate db:seed
   ```

5. **Start the development server**
   ```bash
   bin/rails server
   ```

## Development Workflow

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Code Quality
```bash
# Run RuboCop
bundle exec rubocop

# Run Brakeman (security)
bundle exec brakeman

# Run all quality checks
bundle exec rake quality
```

### Working with Docker

The project includes docker-compose configuration for development:

```bash
# Start all services
docker-compose up

# Start only database
docker-compose up db

# Run tests in container
docker-compose exec web bundle exec rspec

# Access Rails console
docker-compose exec web bin/rails console
```

## Project Structure

```
galaxy_game/
├── app/                    # Rails application code
│   ├── controllers/        # Web controllers
│   ├── models/            # Data models
│   ├── services/          # Business logic
│   ├── views/             # Templates
│   └── assets/            # Static assets
├── config/                # Rails configuration
├── db/                    # Database schema and seeds
├── lib/                   # Shared libraries
├── spec/                  # Test suite
└── docs/                  # Documentation
```

## Key Development Areas

### Adding New Equipment
1. Create blueprint JSON in `app/data/blueprints/`
2. Add operational data in `app/data/operational_data/`
3. Update relevant services and models
4. Add tests in `spec/`

### Modifying Planetary Systems
1. Update sphere models in `app/models/celestial_bodies/spheres/`
2. Modify terraforming logic in services
3. Update simulation parameters
4. Test with integration scenarios

### AI Manager Changes
1. Modify pattern recognition in `app/services/ai_manager/`
2. Update mission profiles
3. Test with various scenarios
4. Validate economic impact

## Troubleshooting

### Common Issues

**Ruby version conflicts**
```bash
rbenv versions
rbenv local 3.2.5
```

**Database connection issues**
```bash
# Check if PostgreSQL is running
pg_isready

# Reset database
RAILS_ENV=test bin/rails db:drop db:create db:migrate
```

**Asset compilation errors**
```bash
# Clear asset cache
bin/rails assets:clean
bin/rails assets:precompile
```

## Getting Help

- Check existing documentation in `docs/`
- Review test files for usage examples
- Check GitHub issues for known problems
- Ask in development discussions

## Contributing

See [Contributing Guide](contributing.md) for detailed contribution guidelines.