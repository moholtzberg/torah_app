source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.3'
gem 'puma', '~> 3.0'
gem 'bootstrap-sass', '~> 3.3.6'
gem 'sass-rails', '~> 5.0'
# gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'redis', '~> 3.0'
gem 'devise'
gem 'devise_token_auth'
gem 'omniauth'
gem 'twilio-ruby'
gem 'dotenv-rails'
gem 'database_cleaner'
gem 'carrierwave', '~> 1.0'
gem 'pg'
gem 'jquery-timepicker-rails'
gem 'bootstrap-datepicker-rails'
gem 'momentjs-rails'
gem 'moment_timezone-rails'
gem 'factory_girl_rails', '~> 4.5', require: false
gem 'faker', '~> 1.6.1'
gem 'kaminari'
gem "webpush"
gem 'active_model_serializers'
gem 'public_activity'
gem 'has_friendship'

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails'
  gem 'capybara', '~> 2.5'
end

group :test do
  gem 'shoulda-matchers', require: false
  gem 'rails-controller-testing'
  gem 'simplecov', :require => false
end


group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
