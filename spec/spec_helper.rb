require "simplecov"

SimpleCov.start

require "bundler/setup"
require "webmock/rspec"
require "support/analytics"
require "support/analytics/service"
require "zoho-sdk"

stub = ENV["SPEC_ZOHO_EMAIL"].nil? || ENV["SPEC_ZOHO_AUTHTOKEN"].nil?

if stub
  WebMock.disable_net_connect!(allow_localhost: true)
else
  WebMock.allow_net_connect!
end

module GlobalContext
  extend RSpec::SharedContext

  let(:email) { ENV["SPEC_ZOHO_EMAIL"] || "user@email.com" }
  let(:auth_token) { ENV["SPEC_ZOHO_AUTHTOKEN"] || "authtoken" }
  let(:client) { Zoho::Analytics::Client.new(email, auth_token) }
end

RSpec.configure do |config|
  config.include GlobalContext

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  if stub
    config.before(:each) do
      stub_request(:any, /#{Regexp.escape(Zoho::Analytics::API_HOSTNAME)}\/.*/).to_rack(Zoho::Support::Analytics::Service)
    end
  end
end
