require "faraday"
require "json"
require "uri"
require "zoho-sdk/analytics/workspace"

module ZohoSdk::Analytics
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

    def create_workspace(name, **opts)
      res = get params: {
        "ZOHO_ACTION" => "CREATEBLANKDB",
        "ZOHO_DATABASE_NAME" => name,
        "ZOHO_DATABASE_DESC" => opts[:description] || ""
      }
      if res.success?
        data = JSON.parse(res.body)
        Workspace.new(name, self)
      else
        nil
      end
    end

    def workspace(name)
      res = get params: {
        "ZOHO_ACTION" => "ISDBEXIST",
        "ZOHO_DB_NAME" => name
      }
      if res.success?
        data = JSON.parse(res.body)
        if data.dig("response", "result", "isdbexist") == "true"
          Workspace.new(name, self)
        else
          nil
        end
      else
        nil
      end
    end

    def get(path: nil, params: {})
      conn = Faraday.new(url: url_for(path))
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

    def post_json(path: nil, io:, params: {})
      conn = Faraday.new(url: url_for(path)) do |conn|
        conn.request :multipart
        conn.adapter :net_http
        conn.headers = {
          'Content-Type' => 'multipart/form-data'
        }
      end
      res = conn.post do |req|
        payload = {
          "ZOHO_OUTPUT_FORMAT" => "JSON",
          "ZOHO_ERROR_FORMAT" => "JSON",
          "ZOHO_API_VERSION" => "1.0",
          "authtoken" => @auth_token
        }
        params.merge(payload).each { |key, value|
          req.params[key] = value
        }
        req.body = {
          "ZOHO_FILE" => Faraday::FilePart.new(io, "application/json", "ZOHO_FILE.json")
        }
      end
    end

    def url_for(path = nil)
      parts = [API_BASE_URL, @email]
      if !path.nil?
        if path[0] == "/"
          path = path[1..-1]
        end
        parts << path
      end
      URI.encode(parts.join("/"))
    end
  end
end
