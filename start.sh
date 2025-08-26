#! /bin/bash

echo 'Checking ruby dependencies...'
bundle check || bundle install  # && bundle binstubs bundler


echo 'Checking database...'
bundle exec rails db:prepare

echo 'Starting rails server...'

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# /bin/bash
bundle exec rails s -p 3000 -b '0.0.0.0'
