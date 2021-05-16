require 'sidekiq/web'
require 'sidekiq/hierarchy/web'

map '/sidekiq' do
  if ENV['APP_ENV'] == 'production'
    correct_username_digest = Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'])
    correct_password_digest = Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD'])

    use Rack::Auth::Basic, 'Protected Area' do |username, password|
      given_username_digest = Digest::SHA256.hexdigest(username)
      given_password_digest = Digest::SHA256.hexdigest(password)

      username_comparison =
        Rack::Utils.secure_compare(
          given_username_digest,
          correct_username_digest,
        )
      password_comparison =
        Rack::Utils.secure_compare(
          given_password_digest,
          correct_password_digest,
        )

      username_comparison && password_comparison
    end
  end

  run Sidekiq::Web
end
