# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.2'

gem 'bcrypt', '~> 3.1.7'
gem 'blacklight', '>= 7.0'
gem 'blacklight_dynamic_sitemap'
gem 'blacklight-marc', '>= 7.0.0.rc1', '< 8'
gem "blacklight_range_limit", '~> 8.2'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'bootstrap', '~> 4.0'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'faraday_middleware'
gem "health-monitor-rails"
gem 'honeybadger'
gem 'httparty'
gem 'jbuilder', '~> 2.7'
gem 'jquery-rails'
gem 'listen', '~> 3.3'
gem 'multi_xml'
gem 'net-ssh', '7.0.0.beta1'
gem "nokogiri", ">= 1.13.4"
gem 'oai'
gem 'pg'
gem 'plausible_api'
gem 'puma', '~> 5.6'
gem 'rails', '~> 6.1.7'
gem 'rinku'
gem 'rsolr', '>= 1.0', '< 3'
gem 'sass-rails', '>= 6'
gem 'strscan', '>= 3.1.0'
gem 'thor'
gem 'traject'
gem 'turbolinks', '~> 5'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'vite_rails'
gem 'whenever'

group :development, :test do
  gem 'bixby'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'coveralls_reborn', '~> 0.28', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec'
  gem 'rspec-rails', '~> 5.0.0'
  gem "rspec-retry"
  gem 'rspec-solr'
  gem 'rubocop-rspec'
  gem 'simplecov', '~> 0.22'
  gem 'yard'
end

group :development do
  gem "bcrypt_pbkdf"
  gem "capistrano", "3.16", "< 3.17", require: false
  gem "capistrano-passenger", require: false
  gem "capistrano-rails", "~> 1.4", require: false
  gem "ed25519"
  gem "foreman"
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'axe-core-rspec'
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  gem 'webmock'
end
