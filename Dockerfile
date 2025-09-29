# syntax=docker/dockerfile:1
# check=error=true

# Multi-environment Dockerfile for development, test, and production
# Usage:
# Development: docker build --build-arg RAILS_ENV=development -t good_night_app:dev .
# Test:        docker build --build-arg RAILS_ENV=test -t good_night_app:test .
# Production:  docker build --build-arg RAILS_ENV=production -t good_night_app:prod .

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.2.2
ARG RAILS_ENV=production
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set environment variables based on RAILS_ENV
ENV RAILS_ENV=$RAILS_ENV \
    BUNDLE_PATH="/usr/local/bundle"

# Configure bundle settings based on environment
RUN if [ "$RAILS_ENV" = "production" ]; then \
        echo 'BUNDLE_DEPLOYMENT="1"' >> /etc/environment && \
        echo 'BUNDLE_WITHOUT="development test"' >> /etc/environment; \
    elif [ "$RAILS_ENV" = "test" ]; then \
        echo 'BUNDLE_WITHOUT="development"' >> /etc/environment; \
    else \
        echo 'BUNDLE_WITHOUT=""' >> /etc/environment; \
    fi

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and additional dev tools for non-production
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    if [ "$RAILS_ENV" != "production" ]; then \
        apt-get install --no-install-recommends -y vim nano less; \
    fi && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems based on environment
COPY Gemfile Gemfile.lock ./
RUN if [ "$RAILS_ENV" = "production" ]; then \
        bundle config set --local deployment 'true' && \
        bundle config set --local without 'development test' && \
        bundle install; \
    elif [ "$RAILS_ENV" = "test" ]; then \
        bundle config set --local without 'development' && \
        bundle install; \
    else \
        bundle install; \
    fi && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets for production only
RUN if [ "$RAILS_ENV" = "production" ]; then \
        bundle exec rails assets:precompile; \
    fi

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose different ports based on environment
RUN if [ "$RAILS_ENV" = "production" ]; then \
        echo "EXPOSE 80" > /tmp/port; \
    else \
        echo "EXPOSE 3000" > /tmp/port; \
    fi

# Set default command based on environment
RUN if [ "$RAILS_ENV" = "production" ]; then \
        echo '["./bin/thrust", "./bin/rails", "server"]' > /tmp/cmd; \
    elif [ "$RAILS_ENV" = "test" ]; then \
        echo '["bundle", "exec", "rails", "test"]' > /tmp/cmd; \
    else \
        echo '["./bin/rails", "server", "-b", "0.0.0.0"]' > /tmp/cmd; \
    fi

# Apply port configuration
EXPOSE 3000 80

# Default command (can be overridden at runtime)
CMD ["sh", "-c", "if [ \"$RAILS_ENV\" = \"production\" ]; then exec ./bin/thrust ./bin/rails server; elif [ \"$RAILS_ENV\" = \"test\" ]; then exec bundle exec rails test; else exec ./bin/rails server -b 0.0.0.0; fi"]
