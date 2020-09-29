require "zoho-sdk/analytics/column"
require "uri"

module ZohoSdk::Analytics
  class Table
    IMPORT_TYPES = {
      :append => "APPEND",
      :truncate_add => "TRUNCATEADD",
      :update_add => "UPDATEADD"
    }.freeze

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

    def create_column(column_name, type, **opts)
      if !Column::DATA_TYPES.values.include?(type)
        raise ArgumentError.new("Column type must be one of: #{Column::DATA_TYPES.values.join(', ')}")
      end
      @type = type
      @required = opts[:required] || false
      @description = opts[:description] || ""
      res = client.get path: "#{workspace.name}/#{URI.encode(name)}", params: {
        "ZOHO_ACTION" => "ADDCOLUMN",
        "ZOHO_COLUMNNAME" => column_name,
        "ZOHO_DATATYPE" => type.to_s.upcase
      }
      if res.success?
        data = JSON.parse(res.body)
        Column.new(column_name, self, client)
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
          col = Column.new(name, self, client)
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

    def import(import_type, data, **opts)
      if !IMPORT_TYPES.keys.include?(import_type)
        raise ArgumentError.new("import_type must be one of: #{IMPORT_TYPES.keys.join(', ')}")
      end

      params = {
        "ZOHO_ACTION" => "IMPORT",
        "ZOHO_IMPORT_DATA" => data.to_json,
        "ZOHO_IMPORT_TYPE" => IMPORT_TYPES[import_type],
        "ZOHO_IMPORT_FILETYPE" => "JSON",
        "ZOHO_ON_IMPORT_ERROR" => "ABORT",
        "ZOHO_CREATE_TABLE" => "false",
        "ZOHO_AUTO_IDENTIFY" => "false"
      }

      if import_type == :update_add
        matching = opts[:matching] || []
        if !matching.is_a?(Array) || matching.size < 1
          raise ArgumentError.new("Must pass at least one column in `matching` option for UPDATEADD")
        end

        params["ZOHO_MATCHING_COLUMNS"] = matching.join(',')
      end

      res = client.get path: "#{workspace.name}/#{name}", params: params
      if res.success?
        data = JSON.parse(res.body)
        data.dig("response", "result", "importSummary", "successRowCount")
      else
        nil
      end
    end

    def delete(criteria)
      if criteria.nil?
        raise ArgumentError.new("Delete criteria must be specified")
      end

      delete!(criteria)
    end

    def delete!(criteria = nil)
      params = {
        "ZOHO_ACTION" => "DELETE"
      }

      params["ZOHO_CRITERIA"] = criteria if !criteria.nil?

      res = client.get path: "#{workspace.name}/#{name}", params: params
      if res.success?
        data = JSON.parse(res.body)
        data.dig("response", "result", "deletedrows").to_i
      else
        nil
      end
    end

    def <<(row)
      params = { "ZOHO_ACTION" => "ADDROW" }
      restricted = %w(
        ZOHO_ACTION
        ZOHO_API_VERSION
        ZOHO_OUTPUT_FORMAT
        ZOHO_ERROR_FORMAT
        authtoken
      )

      params = row.reject { |key|
        !key.is_a?(String) || restricted.include?(key)
      }.merge(params)

      res = client.get path: "#{workspace.name}/#{name}", params: params
      if res.success?
        data = JSON.parse(res.body)
        columns = data.dig("response", "result", "column_order")
        values = data.dig("response", "result", "rows", 0)
        columns.zip(values).to_h
      else
        nil
      end
    end
  end
end
