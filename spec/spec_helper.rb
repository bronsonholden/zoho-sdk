require "simplecov"

SimpleCov.start

require "bundler/setup"
require "webmock/rspec"
require "support/analytics"
require "support/analytics/service"
require "zoho-sdk"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    stub_request(:any, /#{Regexp.escape(Zoho::Analytics::API_HOSTNAME)}\/.*/).to_rack(Zoho::Support::Analytics::Service)
  end
end
