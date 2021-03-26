require "sinatra/base"
require "support/analytics/method"

module ZohoSdk
  module TestService
    module Analytics
      class AuthService < Sinatra::Base
        post "/oauth/v2/token" do
          # TODO: Verify response format & return code (should be 200 but YNK)
          content_type :json
          status 200
          { data: { access_token: "access_token" } }.to_json
        end
      end
    end
  end
end
