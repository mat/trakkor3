source 'https://rubygems.org'

ruby '2.1.6'

gem 'rails', '3.2.21'

gem 'unicorn'
gem 'therubyracer'

gem 'dynamic_form'
gem 'pg'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem "nokogiri"
gem "thin"
gem "typhoeus"

gem "colorize"

group :production do
  gem 'newrelic_rpm'
end

group :development do
end

# Enable gzip/deflate on heroku
gem 'heroku-deflater', :group => :production

group :test do
 gem "fakeweb"
end
