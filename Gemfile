# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :production do
  gem "http"
  gem "rugged"
  gem "sidekiq"
  gem "sidekiq-hierarchy", github: "igorrKurr/sidekiq-hierarchy"
  gem "sinatra"
end

group :development do
  gem "climate_control"
  gem "dotenv"
  gem "super_diff", github: "mcmire/super_diff", branch: "add-diff-elisions"
  gem "rspec"
  gem "webmock"
  gem "vcr"
end
