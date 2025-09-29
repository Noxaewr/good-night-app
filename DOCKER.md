# Docker Multi-Environment Setup

This project supports Docker containers for development, test, and production environments.

## Building Images

### Development
```bash
docker build --build-arg RAILS_ENV=development -t good_night_app:dev .
```

### Test
```bash
docker build --build-arg RAILS_ENV=test -t good_night_app:test .
```

### Production
```bash
docker build --build-arg RAILS_ENV=production -t good_night_app:prod .
```

## Using Docker Compose

### Development Environment
```bash
# Start development environment with live code reloading
docker-compose up app-dev

# Access the app at http://localhost:3000
```

### Test Environment
```bash
# Run tests
docker-compose up app-test

# Run specific test files
docker-compose run --rm app-test bundle exec rails test test/models/user_test.rb
```

### Production Environment
```bash
# Start production environment
docker-compose up app-prod

# Access the app at http://localhost:80
```

## Environment Differences

### Development
- Includes development and test gems
- Code is mounted as volume for live reloading
- Runs on port 3000
- Includes development tools (vim, nano, less)

### Test
- Includes test gems but excludes development gems
- Optimized for running test suites
- Default command runs the full test suite

### Production
- Excludes development and test gems
- Assets are precompiled
- Runs with Thruster on port 80
- Optimized for performance and security

## Database

All environments use a shared PostgreSQL database with separate databases:
- `good_night_app_development`
- `good_night_app_test`
- `good_night_app_production`

## Secrets

For production, make sure you have a `config/master.key` file with your Rails master key.

## Useful Commands

```bash
# Build all environments
docker-compose build

# Start only the database
docker-compose up db

# Run rails console in development
docker-compose run --rm app-dev bundle exec rails console

# Run database migrations
docker-compose run --rm app-dev bundle exec rails db:migrate

# Clean up
docker-compose down
docker system prune -f
```
