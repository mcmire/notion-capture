VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.default_cassette_options = { record: :once }

  config.configure_rspec_metadata!
end
