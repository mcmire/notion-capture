# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.0.2'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Address GHSA-jxhc-q857-3j6g
gem 'addressable', '>= 2.8.0'
gem 'dotenv'
gem 'http'
gem 'pry-byebug'
gem 'puma'
gem 'rugged'
gem 'selenium-webdriver'
gem 'sidekiq'
gem 'sinatra'
gem 'webdrivers'

group :development do
  gem 'climate_control'
  gem 'rspec'
  gem 'super_diff'
  gem 'vcr'
  gem 'webmock'
end
