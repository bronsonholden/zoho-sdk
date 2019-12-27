require "zoho-sdk/analytics/table"

module Zoho
  module Analytics
    class Workspace
      def initialize(name, client)
        @name = name
        @client = client
      end

      def exists?
        if @dbid.nil?
          res = @client.get params: {
            "ZOHO_ACTION" => "ISDBEXIST",
            "ZOHO_DB_NAME" => @name
          }
          puts res.body
          if res.success?
            data = JSON.parse(res.body)
            data.dig("response", "result", "isdbexist")
          else
            # Raise
          end
        else
          true
        end
      end

      def create
        if exists?
          return
        end
      end

      def delete
      end

      def table(name)
        Zoho::Analytics::Table.new(name, self, @client)
      end
    end
  end
end
