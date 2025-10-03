# Good Night App 🌙

A RESTful API application for tracking sleep records and managing user relationships. Users can clock in/out their sleep times, follow other users, and view their friends' sleep patterns from the previous week.

## Features

- **Sleep Tracking**: Record bedtime and wake time with automatic duration calculation
- **Social Features**: Follow/unfollow other users
- **Sleep Analytics**: View sleep records from followed users in the previous week, sorted by duration
- **API Documentation**: Interactive Swagger UI for API exploration
- **Comprehensive Testing**: Full RSpec test suite with 81+ examples

## Tech Stack

- **Ruby**: 3.2.2
- **Rails**: 8.0.2+
- **Database**: PostgreSQL
- **Testing**: RSpec, FactoryBot, Shoulda Matchers
- **API Documentation**: Rswag (Swagger/OpenAPI)
- **Serialization**: JSONAPI Serializer
- **Pagination**: Kaminari
- **Validation**: Dry-validation

## Prerequisites

Before you begin, ensure you have the following installed:

- Ruby 3.2.2 or higher
- PostgreSQL (9.3+)
- Bundler gem

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/Noxaewr/good-night-app.git
cd good-night-app
```

### 2. Install dependencies

```bash
bundle install
```

If you encounter any gem installation issues:

```bash
# For PostgreSQL gem issues on macOS with Homebrew
gem install pg -- --with-pg-config=/usr/local/bin/pg_config

# Or if using Apple Silicon
gem install pg -- --with-pg-config=/opt/homebrew/bin/pg_config
```

### 3. Database setup

Make sure PostgreSQL is running, then:

```bash
# Create databases
rails db:create

# Run migrations
rails db:migrate

# (Optional) Seed the database with sample data
rails db:seed
```

### 4. Start the server

```bash
# Using Rails default server
rails server

# Or using Puma directly
bundle exec puma -C config/puma.rb
```

The application will be available at `http://localhost:3000`

## Running the Application

### Development Mode

```bash
rails server
# Server runs on http://localhost:3000
```

### Production Mode

```bash
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails server
```

## API Documentation

Once the server is running, access the interactive API documentation:

**Swagger UI**: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)

## API Endpoints

### Users

- `GET /v1/users` - List all users
- `GET /v1/users/:id` - Get user details
- `POST /v1/users` - Create a new user
- `POST /v1/users/:id/follow` - Follow a user
- `DELETE /v1/users/:id/unfollow` - Unfollow a user
- `GET /v1/users/:id/following` - Get users that this user follows
- `GET /v1/users/:id/followers` - Get users following this user

### Sleep Records

- `GET /v1/users/:user_id/sleep_records` - Get user's sleep records
- `POST /v1/users/:user_id/sleep_records` - Clock in/out (create sleep record)
- `GET /v1/users/:user_id/following_sleep_records` - Get sleep records from followed users (previous week, sorted by duration)

## Running Tests

### Run the entire test suite

```bash
bundle exec rspec
```

### Run specific test files

```bash
# Model tests
bundle exec rspec spec/models/

# Request/API tests
bundle exec rspec spec/requests/

# Specific file
bundle exec rspec spec/models/user_spec.rb
```

### Run tests with coverage report

```bash
bundle exec rspec
# Coverage report will be generated in coverage/index.html
```

### Test Statistics

- **Total Examples**: 81
- **Coverage**: ~68% line coverage
- **Test Types**: Models, Requests, Services, Factories

## Database Schema

### Users
- `id`: Primary key
- `name`: User's name (required)
- `created_at`, `updated_at`: Timestamps

### Sleep Records
- `id`: Primary key
- `user_id`: Foreign key to users
- `bedtime`: DateTime when user went to bed
- `wake_time`: DateTime when user woke up
- `duration_minutes`: Calculated sleep duration in minutes
- `created_at`, `updated_at`: Timestamps

### Users Follows (Join Table)
- `id`: Primary key
- `follower_id`: User who follows
- `followed_user_id`: User being followed
- `created_at`, `updated_at`: Timestamps

## Development Tools

### Code Quality

```bash
# Run Rubocop for code style checking
bundle exec rubocop

# Run Brakeman for security analysis
bundle exec brakeman
```

### Database Console

```bash
rails dbconsole
```

### Rails Console

```bash
rails console
```

## Configuration

### Database Configuration

Edit `config/database.yml` to configure database connections for different environments.

### Environment Variables

For production, set the following environment variables:

- `GOOD_NIGHT_APP_DATABASE_PASSWORD`: PostgreSQL password
- `RAILS_ENV`: Set to `production`
- `RAILS_MAX_THREADS`: Number of threads for Puma (default: 5)

## Deployment

### Docker Deployment (Local/Development)

#### Prerequisites
- Docker Desktop installed and running
- Docker Compose v3.8+

#### Quick Start with Docker Compose

```bash
# Build and start all services (web + PostgreSQL)
docker-compose up --build

# Or run in detached mode
docker-compose up -d --build

# View logs
docker-compose logs -f web

# Stop services
docker-compose down

# Stop and remove volumes (WARNING: deletes database data)
docker-compose down -v
```

The application will be available at `http://localhost:3000`

#### Run Tests in Docker

```bash
# Run tests using the test profile
docker-compose --profile test run --rm test

# Or run tests in the web container
docker-compose exec web bundle exec rspec
```

#### Docker Commands

```bash
# Access Rails console in Docker
docker-compose exec web rails console

# Access database console
docker-compose exec web rails dbconsole

# Run migrations
docker-compose exec web rails db:migrate

# Access container shell
docker-compose exec web bash

# Rebuild specific service
docker-compose build web

# View running containers
docker-compose ps
```

### Production Docker Deployment

```bash
# Set required environment variables
export POSTGRES_PASSWORD=your_secure_password
export RAILS_MASTER_KEY=your_rails_master_key

# Build and start production services
docker-compose -f docker-compose.prod.yml up -d --build

# View production logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop production services
docker-compose -f docker-compose.prod.yml down
```

### Kamal Deployment (Remote Servers)

For deploying to remote servers using Kamal:

#### 1. Configure Kamal

Edit `config/deploy.yml`:

```yaml
# Update these values:
image: your-dockerhub-username/good_night_app
servers:
  web:
    - your-server-ip-address
registry:
  username: your-dockerhub-username
proxy:
  host: your-domain.com
```

#### 2. Set up secrets

Create `.kamal/secrets` file:

```bash
# Create secrets file
mkdir -p .kamal
cat > .kamal/secrets << 'EOF'
KAMAL_REGISTRY_PASSWORD=$DOCKER_HUB_PASSWORD
RAILS_MASTER_KEY=$RAILS_MASTER_KEY
EOF
```

#### 3. Deploy

```bash
# First time setup
kamal setup

# Deploy updates
kamal deploy

# View logs
kamal app logs -f

# Access console
kamal app exec -i "bin/rails console"

# Rollback
kamal rollback
```

### Building Docker Image Manually

```bash
# Development build
docker build -t good_night_app:dev .

# Production build
docker build --build-arg RAILS_ENV=production -t good_night_app:prod .

# Run the built image
docker run -p 3000:3000 \
  -e DATABASE_URL=postgresql://user:pass@host:5432/dbname \
  good_night_app:dev
```

## Project Structure

```
app/
├── controllers/
│   ├── concerns/          # Shared controller logic
│   └── v1/               # API v1 controllers
├── models/               # ActiveRecord models
├── serializers/          # JSONAPI serializers
└── services/             # Business logic services
spec/
├── factories/            # FactoryBot factories
├── models/              # Model specs
├── requests/            # API request specs
└── services/            # Service specs
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### PostgreSQL Connection Issues

```bash
# Check if PostgreSQL is running
brew services list  # macOS with Homebrew
# or
sudo service postgresql status  # Linux

# Start PostgreSQL if needed
brew services start postgresql  # macOS
# or
sudo service postgresql start  # Linux
```

### Bundle Install Issues

```bash
# Clear bundler cache
bundle clean --force

# Reinstall gems
bundle install
```

### Database Issues

```bash
# Reset database (WARNING: This will delete all data)
rails db:drop db:create db:migrate db:seed
```

## License

This project is available as open source under the terms of the MIT License.

## Contact

Project Link: [https://github.com/Noxaewr/good-night-app](https://github.com/Noxaewr/good-night-app)
