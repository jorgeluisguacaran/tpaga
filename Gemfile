source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.9"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
# gem "rails", "~> 7.0.2", ">= 7.0.2.3"
gem "rails", "~> 8.0.2.1" # "~> 7.1"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma"



# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"
#

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'pry', '~> 0.14'
  gem 'pry-nav', '~> 1.0'

  # Testing gems
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'shoulda-matchers', '~> 5.0'

  # RuboCop gems for code quality
  gem 'rubocop', '~> 1.50'
  gem 'rubocop-rails', '~> 2.20'
  gem 'rubocop-rspec', '~> 2.20'
  gem 'rubocop-rspec_rails', '~> 2.20'
  gem 'rubocop-factory_bot', '~> 2.20'
  gem 'rubocop-capybara', '~> 2.20'
  gem 'rubocop-performance', '~> 1.20'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

gem 'faraday'

# Soporte para CORS en Rails (necesario para APIs y microservicios)
gem 'rack-cors', '~> 1.1'

gem 'psych', '~> 4.0.3'

# Geocoding and distance calculations
gem 'geocoder', '~> 1.8'

# Serializers para JSON
gem 'active_model_serializers', '~> 0.10'
