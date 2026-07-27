#!/bin/bash
set -e  # Exit on any error

echo "Preparing Database"
bin/rails db:drop:_unsafe db:create

# if schema.rb exists load schema else run the migrations
FILE="/home/databases/db/schema.rb"
if [ -e "$FILE" ]; then
    echo "Loading schema..."
    bin/rails db:schema:load
else
    echo "Running migrations..."
    bin/rails db:migrate
fi

echo "Seeding database (timeout 30 min)..."
timeout 1800 bin/rails db:seed || {
    echo "ERROR: db:seed timed out after 30 minutes"
    exit 1
}

echo "Preparing Test Database"
RAILS_ENV=test bin/rails db:create
bin/rails db:environment:set RAILS_ENV=test
RAILS_ENV=test bin/rails db:schema:load

echo "Database setup complete."