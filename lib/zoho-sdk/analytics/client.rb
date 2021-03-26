require "faraday"
require "json"
require "uri"
require "zoho-sdk/analytics/workspace"

module ZohoSdk::Analytics
  API_HOSTNAME = "https://analyticsapi.zoho.com".freeze
  API_PATH = "api".freeze
  API_BASE_URL = "#{API_HOSTNAME}/#{API_PATH}".freeze

  # URL to retrieve access token
  API_AUTH_HOSTNAME = "https://accounts.zoho.com".freeze
  API_AUTH_PATH = "oauth/v2/token".freeze
  API_AUTH_BASE_URL = "#{API_AUTH_HOSTNAME}/#{API_AUTH_PATH}".freeze

  # Allows retrieving workspaces, metadata, and other general data not tied
  # to a specific resource.
  class Client
    def initialize(email, client_id, client_secret, refresh_token)
      @email = email
      @client_id = client_id
      @client_secret = client_secret
      @refresh_token = refresh_token

      # Retrieves access token to authenticate all API requests
      conn =
        Faraday.new(url: API_AUTH_BASE_URL) { |conn| conn.adapter :net_http }
      res =
        conn.post do |req|
          payload = {
            "client_id" => @client_id,
            "client_secret" => @client_secret,
            "refresh_token" => @refresh_token,
            "grant_type" => "refresh_token"
          }
          payload.each { |key, value| req.params[key] = value }
        end
      if res.success?
        data = JSON.parse(res.body)
        if data["access_token"]
          @access_token = data["access_token"]
        else
          nil
        end
      else
        nil
      end
    end

    def workspace_metadata
      get params: {
            "ZOHO_ACTION" => "DATABASEMETADATA",
            "ZOHO_METADATA" => "ZOHO_CATALOG_LIST"
          }
    end

    # Create a new Zoho Analytics workspace
    # @param name [String] Workspace name
    # @param opts [Hash] Optional arguments
    # @option opts [String] :description Workspace description
    # @return [Workspace] Newly created Workspace
    def create_workspace(name, **opts)
      res =
        get params: {
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

    # Retrieve a workspace by name
    # @param name [String] The workspace name
    # @return [Workspace]
    def workspace(name)
      res = get params: { "ZOHO_ACTION" => "ISDBEXIST", "ZOHO_DB_NAME" => name }
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

    # Wrapper for an HTTP GET request via Faraday
    # @param path [String] URL path component
    # @param params [Hash] Query parameters for the request
    # @return [Faraday::Response]
    def get(path: nil, params: {})
      conn =
        Faraday.new(url: url_for(path)) do |conn|
          conn.adapter :net_http
          conn.headers = {
            "Authorization" => "Zoho-oauthtoken #{@access_token}"
          }
        end
      res =
        conn.get do |req|
          req.params["ZOHO_OUTPUT_FORMAT"] = "JSON"
          req.params["ZOHO_ERROR_FORMAT"] = "JSON"
          req.params["ZOHO_API_VERSION"] = "1.0"
          params.each { |key, value| req.params[key] = value }
        end
    end

    # Wrapper for posting JSON via Faraday. Used primarily for IMPORT tasks.
    # @param path [String] URL path component
    # @param io [IO] A readable IO object
    # @param params [Hash] Query parameters for the request
    # @return [Faraday::Response]
    def post_json(path: nil, io:, params: {})
      conn =
        Faraday.new(url: url_for(path)) do |conn|
          conn.request :multipart
          conn.adapter :net_http
          conn.headers = {
            "Authorization" => "Zoho-oauthtoken #{@access_token}",
            "Content-Type" => "multipart/form-data"
          }
        end
      res =
        conn.post do |req|
          payload = {
            "ZOHO_OUTPUT_FORMAT" => "JSON",
            "ZOHO_ERROR_FORMAT" => "JSON",
            "ZOHO_API_VERSION" => "1.0"
          }
          params.merge(payload).each { |key, value| req.params[key] = value }
          req.body = {
            "ZOHO_FILE" =>
              Faraday::FilePart.new(io, "application/json", "ZOHO_FILE.json")
          }
        end
    end

    # Helper function to build a complete URL path that includes email ID
    # and encodes path elements.
    def url_for(path = nil)
      parts = [API_BASE_URL, @email]
      if !path.nil?
        path = path[1..-1] if path[0] == "/"
        parts << path
      end
      URI.encode(parts.join("/"))
    end
  end
end
