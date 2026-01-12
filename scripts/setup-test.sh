#!/bin/bash

set -e

bin/rails db:environment:set RAILS_ENV=test

echo "Preparing Database"
bin/rails db:drop db:create RAILS_ENV=test

# if schema.rb exists load schema else run the migrations
FILE="/home/galaxy_game/db/schema.rb"
if [ -e "$FILE" ]; then
    bin/rails db:schema:load RAILS_ENV=test
else
    bin/rails db:migrate RAILS_ENV=test
fi

bin/rails db:seed RAILS_ENV=test

