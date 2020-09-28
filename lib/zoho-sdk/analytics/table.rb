require "zoho-sdk/analytics/column"
require "uri"

module ZohoSdk
  module Analytics
    class Table
      attr_reader :workspace
      attr_reader :columns
      attr_reader :client

      def initialize(table_name, workspace, client, columns: [])
        @table_name = table_name
        @workspace = workspace
        @client = client
        @columns = columns
        @exists
      end

      def name
        @table_name
      end

      def create_column(name, type, **opts)
        if !Column::DATA_TYPES.include?(type)
          raise ArgumentError.new("Column type must be one of: #{Column::DATA_TYPES.join(', ')}")
        end
        @type = type
        @required = opts[:required] || false
        @description = opts[:description] || ""
        res = client.get path: "#{workspace.name}/#{URI.encode(name)}", params: {
          "ZOHO_ACTION" => "ADDCOLUMN",
          "ZOHO_COLUMNNAME" => name,
          "ZOHO_DATATYPE" => type.to_s.upcase
        }
        if res.success?
          data = JSON.parse(res.body)
          ZohoSdk::Analytics::Column.new(name, self, client)
        else
          nil
        end
      end

      def column(name)
        res = client.get path: "#{workspace.name}/#{URI.encode(name)}", params: {
          "ZOHO_ACTION" => "ISCOLUMNEXIST",
          "ZOHO_COLUMN_NAME" => name
        }
        if res.success?
          data = JSON.parse(res.body)
          if data.dig("response", "result", "iscolumnexist") == "true"
            col = ZohoSdk::Analytics::Column.new(name, self, client)
            @columns << col
            col
          else
            nil
          end
        else
          nil
        end
      end

      def rows
        res = client.get path: "#{workspace.name}/#{name}", params: {
          "ZOHO_ACTION" => "EXPORT"
        }
      end

      def <<(row)
        params = { "ZOHO_ACTION" => "ADDROW" }
        # TODO: Reject ZOHO_ACTION, ZOHO_OUTPUT_FORMAT, etc.
        row.each { |key, value|
          params[key] = value
        }
        client.get path: "#{workspace.name}/#{name}", params: params
      end
    end
  end
end
