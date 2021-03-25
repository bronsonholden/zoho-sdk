require "sinatra/base"
require "support/analytics/method"

module ZohoSdk
  module TestService
    module Analytics
      class Service < Sinatra::Base
        get "/api/:email" do
          [WorkspaceMetadata, IsWorkspaceExist].each do |method|
            m = method.new(method_params)
            return json_response m.status, m.response.to_json if m.match?
          end

          status 404
        end

        get "/api/:email/:workspace" do
          [IsViewExist].each do |method|
            m = method.new(method_params)
            return json_response m.status, m.response.to_json if m.match?
          end

          status 404
        end

        get "/api/:email/:workspace/:table" do
          [IsColumnExist].each do |method|
            m = method.new(method_params)
            return json_response m.status, m.response.to_json if m.match?
          end

          status 404
        end

        def method_params
          params.reject do |key, value|
            %w[
              email
              workspace
              table
              ZOHO_API_VERSION
              ZOHO_OUTPUT_FORMAT
              ZOHO_ERROR_FORMAT
            ].include?(key)
          end
        end

        def json_response(status_code, json)
          content_type :json
          status status_code
          json
        end
      end
    end
  end
end
