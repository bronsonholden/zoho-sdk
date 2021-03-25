require "simplecov"

SimpleCov.start

require "bundler/setup"
require "webmock/rspec"
require "support/analytics"
require "support/analytics/service"
require "zoho-sdk"

stub =
  ENV["SPEC_ZOHO_EMAIL"].nil? || ENV["SPEC_ZOHO_CLIENT_ID"].nil? ||
    ENV["SPEC_ZOHO_CLIENT_SECRET"].nil? || ENV["SPEC_ZOHO_REFRESH_TOKEN"].nil?

if stub
  WebMock.disable_net_connect!(allow_localhost: true)
else
  WebMock.allow_net_connect!
end

module GlobalContext
  extend RSpec::SharedContext

  let(:email) { ENV["SPEC_ZOHO_EMAIL"] || "user@email.com" }
  let(:client_id) { ENV["SPEC_ZOHO_CLIENT_ID"] || "client_id" }
  let(:client_secret) { ENV["SPEC_ZOHO_CLIENT_SECRET"] || "client_secret" }
  let(:refresh_token) { ENV["SPEC_ZOHO_REFRESH_TOKEN"] || "refresh_token" }
  let(:client) do
    ZohoSdk::Analytics::Client.new(
      email,
      client_id,
      client_secret,
      refresh_token
    )
  end
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
      stub_request(
        :any,
        %r{#{Regexp.escape(ZohoSdk::Analytics::API_HOSTNAME)}\/.*}
      ).to_rack(ZohoSdk::TestService::Analytics::Service)
    end
  end
end
