require "zoho-sdk/analytics/column"

module Zoho
  module Analytics
    class Table
      attr_reader :name
      attr_reader :workspace
      attr_reader :columns

      def initialize(name, workspace, client, columns: [])
        @name = name
        @workspace = workspace
        @client = client
        @columns = columns
        @exists
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

      def create(name:, folder: "", description: "")
        table_design = {
          "TABLENAME" => name,
          "TABLEDESCRIPTION" => description,
          "FOLDERNAME" => folder,
          "COLUMNS" => []
        }.to_json
        res = @client.get path: workspace.name, params: {
          "ZOHO_ACTION" => "CREATETABLE",
          "ZOHO_TABLE_DESIGN" => table_design
        }
        if res.success?
          data = JSON.parse(res.body)
        else
          # Raise
        end
      end

      def column(name)
        col = Zoho::Analytics::Column.new(name, self, @client)
        @columns << col
        col
      end

      def rows
      end

      def <<(row)
        params = { "ZOHO_ACTION" => "ADDROW" }
        @client.get path: "#{workspace.name}/#{name}", params: params
      end
    end
  end
end
