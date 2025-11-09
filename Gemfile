source "https://rubygems.org"

gem "rails", "~> 8.1.1"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"

gem "phlex-rails", "~> 2.3"
gem "phlex-icons"

# gem "bcrypt", "~> 3.1.7"
# gem "omniauth-rails_csrf_protection"
# gem "omniauth-google-oauth2"

gem "tzinfo-data", platforms: %i[windows jruby]

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console"
  gem "rails_live_reload"

  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "guard-rspec", require: false
  gem "standard", ">= 1.35.1", require: false
  gem "standard-rails", require: false
  gem "standard-rspec", require: false
  gem "htmlbeautifier", require: false
  gem "annotaterb", require: false
  gem "ruby-lsp-rspec", "~> 0.1.28", require: false
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
end
