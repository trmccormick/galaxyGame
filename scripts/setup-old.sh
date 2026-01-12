#!/bin/bash

# Function to prepare the database for a given environment
prepare_database() {
  local env=$1
  echo "Preparing Database for $env environment"

  # Set the environment
  export RAILS_ENV=$env

  # Set the environment in the database metadata
  bin/rails db:environment:set RAILS_ENV=$env || { echo "Failed to set environment"; exit 1; }

  # Drop and create the database
  bin/rails db:drop 2>/dev/null || true
  bin/rails db:create || { echo "Failed to create database"; exit 1; }

  # Load schema or run migrations
  if [ -f "./db/schema.rb" ]; then
    bin/rails db:schema:load || { echo "Failed to load schema"; exit 1; }
  else
    bin/rails db:migrate || { echo "Failed to run migrations"; exit 1; }
  fi

  # Seed the database only for development environment
  if [ "$env" = "development" ]; then
    bin/rails db:seed || { echo "Failed to seed database"; exit 1; }
  fi
}

# Prepare development database
prepare_database "development"

# Prepare test database
prepare_database "test"

