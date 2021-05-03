# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :production do
  gem "faraday"
  gem "rugged"
  gem "sidekiq"
  gem "sidekiq-hierarchy", github: "igorrKurr/sidekiq-hierarchy"
  gem "sinatra"
end

group :development do
  gem "dotenv"
  gem "solargraph"
end

group :development, :test do
  gem "rspec"
end
