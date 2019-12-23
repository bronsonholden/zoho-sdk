require "sinatra/base"
require "support/analytics/method"

module Zoho
  module Support
    module Analytics
      class Service < Sinatra::Base
        get "/:email" do
          [
            WorkspaceMetadata
          ].each { |method|
            m = method.new
            if m.match?(method_params) && false
              return json_response 200, {}.to_json # TODO: Method response
            end
          }

          status 404
        end

        def method_params
          params.reject { |key, value|
            %w(
              email workspace table ZOHO_API_VERSION ZOHO_OUTPUT_FORMAT
              ZOHO_ERROR_FORMAT authtoken
            ).include?(key)
          }
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
