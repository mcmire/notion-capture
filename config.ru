require 'dotenv'
require 'securerandom'
require 'sidekiq/web'

Dotenv.load

map '/' do
  run(->(env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] })
end

map '/sidekiq' do
  if ENV.fetch('RACK_ENV') == 'production'
    correct_username_digest =
      Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_USERNAME'))
    correct_password_digest =
      Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_PASSWORD'))

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

  File.open('/tmp/session.key', 'w') { |f| f.write(SecureRandom.hex(32)) }
  use(
    Rack::Session::Cookie,
    secret: File.read('/tmp/session.key'),
    same_site: true,
    max_age: 86_400,
  )
  run Sidekiq::Web
end
