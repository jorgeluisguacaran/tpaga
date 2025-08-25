#! /bin/bash

# Paso 1: Crear Gemfile básico si no existe
if [ ! -f Gemfile ]; then
    echo "Creating basic Gemfile for Rails installation..."
    cat > Gemfile << 'EOF'
source "https://rubygems.org"
gem "rails", "~> 8.0.2"
gem "pg", "~> 1.1"
gem 'psych', '~> 4.0.3'
EOF

    echo 'Installing Rails first...'
    bundle install
fi

if [ ! -d lib ] && [ ! -d app ] && [ ! -d tmp ]; then
    echo 'Creating new Rails API application...'
    bundle exec rails new my_app --api --skip-webpack-install --skip-bundle \
                --skip-webpack-install \
                --skip-solid-queue \
                --skip-solid-cache \
                --skip-asset-pipeline \
                --skip-javascript \
                --skip-hotwire \
                --skip-turbo \
                --skip-turbo-rails \
                --skip-turbo-rails-hotwire \
                --skip-turbo-rails-hotwire-stimulus \
                --skip-turbo-rails-hotwire-stimulus-hotwire \
                --skip-turbo-rails-hotwire-stimulus-hotwire-stimulus
fi

echo "El comando terminó con status $?"

if [ $? -eq 0 ]; then
  echo 'Rails application created successfully'
  mv my_app/{.,}* ./
  if [ $? -eq 0 ]; then
    echo 'Files moved to parent directory successfully'
    # cd ..
    # rm -rf my_app
  else
    echo 'Error moving files to parent directory'
    exit 1
  fi
else
  echo 'Error creating Rails application'
  exit 1
fi

if [ -f config/initializers/assets.rb ]; then
  echo 'Removing assets.rb initializer...
  En Rails 8, el sistema de assets ha cambiado y la configuración config.assets ya no está disponible
  por defecto,ya que Rails 8 usa import maps y otras alternativas modernas en lugar de Sprockets.'
  echo 'https://guides.rubyonrails.org/v8.0/upgrading_ruby_on_rails.html#config-assets'
  mv config/initializers/assets.rb config/initializers/assets.rb.old
fi

echo "Copying .initialize_env/Gemfile to Gemfile"
cp .initialize_env/Gemfile Gemfile

echo 'Checking ruby dependencies...'
bundle check || bundle install  # && bundle binstubs bundler

echo "Copying .initialize_env/.gitignore to .gitignore"
cp .initialize_env/.gitignore .gitignore

echo "Copying .initialize_env/database.yml to config/database.yml"
cp .initialize_env/database.yml config/database.yml

echo 'Checking database...'
bundle exec rails db:prepare

echo 'Starting rails server...'

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# /bin/bash
bundle exec rails s -p 3000 -b '0.0.0.0'
