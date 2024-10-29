require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.filter_sensitive_data('<STRIPE_API_KEY>') { ENV['STRIPE_SECRET_KEY'] }
end