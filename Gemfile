# Gemfile

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.5" # As per your project spec

# == Core Rails & Framework ==
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
gem "puma", ">= 5.0"
gem "bootsnap", require: false

# == Database ==
# Swapped sqlite3 for mysql2 to support MariaDB
gem "mysql2", "~> 0.5"

# == Security ==
gem "devise"                # For authentication (internal users and customers) [cite: 482]
gem "pundit"                # For authorization and managing permissions [cite: 500]
gem "bcrypt", "~> 3.1.7"     # For secure password hashing (required by Devise)

# == Core Functionality & Utilities ==
gem "sidekiq"               # For background jobs (e.g., interest accruals)
gem "phonelib", "~> 0.10"    # For parsing and formatting phone numbers [cite: 89, 1088]
gem "countries", "~> 5.1"     # For country and region data [cite: 1277]

# == Frontend & Assets ==
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"
# gem "tailwindcss-rails"     # Manages running the Tailwind CSS build process [cite: 3]

# == API (Optional) ==
# You can uncomment this later if you build a dedicated JSON API
# gem "jbuilder"

# == Rails Defaults ==
gem "tzinfo-data", platforms: %i[ windows jruby ]
# # Using Sidekiq, so solid_queue is not needed.
# # gem "solid_queue"
gem "solid_cache"
gem "solid_cable"

# == Deployment ==
gem "kamal", require: false
gem "thruster", require: false

# == Development & Testing Group ==
group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rspec-rails"           # Your chosen testing framework [cite: 484]
  gem "factory_bot_rails"     # For creating test data fixtures
  gem "faker"                 # For generating realistic fake data
  gem "simplecov", require: false # For measuring test coverage
end

# == Development Group ==
group :development do
  gem "web-console"
  gem "rubocop-rails-omakase", require: false
  gem "pry-rails"             # An enhanced Rails console for debugging
  gem "letter_opener_web"     # Allows you to preview emails in the browser
  gem "dotenv-rails"
  gem 'erb_lint'
end

# == Test Group ==
group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem "blind_index"
