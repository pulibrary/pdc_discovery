# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

gem 'bcrypt', '~> 3.1.7'
gem 'blacklight', '>= 7.0'
gem 'blacklight-marc', '>= 7.0.0.rc1', '< 8'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'bootstrap', '~> 4.0'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'jbuilder', '~> 2.7'
gem 'jquery-rails'
gem 'oai'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.4'
gem 'rsolr', '>= 1.0', '< 3'
gem 'sass-rails', '>= 6'
gem 'thor'
gem 'traject'
gem 'turbolinks', '~> 5'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'webpacker', '~> 5.0'

group :development, :test do
  gem 'bixby'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem "pry-byebug"
  gem 'pry-rails'
  gem 'rspec-rails', '~> 5.0.0'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'spring'
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'webmock'
end
