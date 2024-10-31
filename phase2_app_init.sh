#!/bin/bash

# Exit script on any error
set -e

# Variables
APP_NAME="EventPromoter"
RAILS_VERSION="7.0.4"
DB_USERNAME="postgres"
DB_PASSWORD="password0197edd0"
DB_HOST="localhost"
DB_PORT="5432"

# Install Rails
echo "Installing Rails $RAILS_VERSION..."
gem install rails -v $RAILS_VERSION

# Create new Rails application
echo "Creating new Rails application: $APP_NAME..."
rails _${RAILS_VERSION}_ new $APP_NAME --database=postgresql --javascript=esbuild --css=bootstrap

echo "Application created successfully."

# Change into the application directory
cd $APP_NAME

# Initialize Git repository
echo "Initializing Git repository..."
git init
git add .
git commit -m "Initial commit"

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
yarn install

# Configure database.yml to connect to Dockerized PostgreSQL
echo "Configuring database.yml..."
cat <<EOT > config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  host: $DB_HOST
  port: $DB_PORT
  username: $DB_USERNAME
  password: $DB_PASSWORD
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: ${APP_NAME}_development

test:
  <<: *default
  database: ${APP_NAME}_test

production:
  <<: *default
  database: ${APP_NAME}_production
EOT

# Create and setup the database
echo "Setting up the database..."
rails db:create

echo "Application and database initialization complete."