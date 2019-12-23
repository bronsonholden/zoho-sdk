require "faraday"

module Zoho
  module Analytics
    API_HOSTNAME = "https://analyticsapi.zoho.com".freeze
    API_PATH = "api".freeze

    class Client
      def initialize(email, auth_token)
        @email = email
        @auth_token = auth_token
      end

      def workspace_metadata
        conn = Faraday.new(url: "#{API_HOSTNAME}/#{API_PATH}")
        res = conn.get do |req|
          req.params["ZOHO_ACTION"] = "DATABASEMETADATA"
          req.params["ZOHO_METADATA"] = "ZOHO_CATALOG_LIST"
        end
      end
    end
  end
end
