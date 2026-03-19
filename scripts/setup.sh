echo "Preparing Database"
bin/rails db:drop:_unsafe db:create

# if schema.rb exists load schema else run the migrations
FILE="/home/databases/db/schema.rb"
if [ -e $FILE ]; then
    bin/rails db:schema:load
else
    bin/rails db:migrate
fi

bin/rails db:seed

echo "Preparing Test Database"
RAILS_ENV=test bin/rails db:create
RAILS_ENV=test bin/rails db:schema:load