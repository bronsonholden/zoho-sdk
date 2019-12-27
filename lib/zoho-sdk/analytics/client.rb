require "faraday"
require "zoho-sdk/analytics/workspace"

module Zoho
  module Analytics
    API_HOSTNAME = "https://analyticsapi.zoho.com".freeze
    API_PATH = "api".freeze
    API_BASE_URL = "#{API_HOSTNAME}/#{API_PATH}".freeze

    class Client
      def initialize(email, auth_token)
        @email = email
        @auth_token = auth_token
      end

      def workspace_metadata
        get params: {
          "ZOHO_ACTION" => "DATABASEMETADATA",
          "ZOHO_METADATA" => "ZOHO_CATALOG_LIST"
        }
      end

      def workspace(name)
        Zoho::Analytics::Workspace.new(name, self)
      end

      def get(path: nil, params: {})
        parts = [API_BASE_URL, @email]
        if !path.nil?
          if path[0] == "/"
            path = path[1..-1]
          end
          parts << path
        end
        conn = Faraday.new(url: parts.join("/"))
        res = conn.get do |req|
          req.params["ZOHO_OUTPUT_FORMAT"] = "JSON"
          req.params["ZOHO_ERROR_FORMAT"] = "JSON"
          req.params["ZOHO_API_VERSION"] = "1.0"
          req.params["authtoken"] = @auth_token
          params.each { |key, value|
            req.params[key] = value
          }
        end
      end
    end
  end
end
