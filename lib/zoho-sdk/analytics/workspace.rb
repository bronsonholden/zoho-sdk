require "zoho-sdk/analytics/table"

module Zoho
  module Analytics
    class Workspace
      attr_reader :name

      def initialize(name, client)
        @name = name
        @client = client
        @metadata
        @exists
      end

      def metadata
        return @metadata if !@metadata.nil?
        load!
      end

      def load!
        res = @client.get path: name, params: {
          "ZOHO_ACTION" => "DATABASEMETADATA",
          "ZOHO_METADATA" => "ZOHO_CATALOG_INFO"
        }
        if res.success?
          data = JSON.parse(res.body)
          @metadata = data.dig("response", "result")
        else
          # Raise
        end
      end

      def exists?
        return @exists if !@exists.nil?
        res = @client.get params: {
          "ZOHO_ACTION" => "ISDBEXIST",
          "ZOHO_DB_NAME" => name
        }
        if res.success?
          data = JSON.parse(res.body)
          if data.dig("response", "result", "isdbexist") == "true"
            @exists = true
          else
            @exists = false
          end
        else
          # Raise
        end
      end

      def create(description: "")
        return if exists?
        res = @client.get params: {
          "ZOHO_ACTION" => "CREATEBLANKDB",
          "ZOHO_DATABASE_NAME" => name,
          "ZOHO_DATABASE_DESC" => description
        }
        if res.success?
          data = JSON.parse(res.body)
        else
          # Raise
        end
      end

      def delete
      end

      def table(name)
        if exists?
          Zoho::Analytics::Table.new(name, self, @client)
        else
          nil
        end
      end
    end
  end
end
