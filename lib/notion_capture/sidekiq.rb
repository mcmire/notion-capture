require 'sidekiq-hierarchy'

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Hierarchy::Client::Middleware
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Hierarchy::Client::Middleware
  end
  config.server_middleware do |chain|
    chain.add Sidekiq::Hierarchy::Server::Middleware
  end
end
