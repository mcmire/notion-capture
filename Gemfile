# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'dotenv'
gem 'http'
gem 'puma'
gem 'rugged'
gem 'selenium-webdriver'
gem 'sidekiq'
gem 'sinatra'
gem 'webdrivers'

group :development do
  gem 'climate_control'
  gem 'pry-byebug'
  gem 'rspec'
  gem 'super_diff', github: 'mcmire/super_diff', branch: 'add-diff-elisions'
  gem 'vcr'
  gem 'webmock'
end
