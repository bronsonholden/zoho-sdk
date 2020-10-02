require "zoho-sdk/analytics/column"
require "uri"

module ZohoSdk::Analytics
  class Table
    IMPORT_TYPES = {
      :append => "APPEND",
      :truncate_add => "TRUNCATEADD",
      :update_add => "UPDATEADD"
    }.freeze

    # @return [Workspace] The table's workspace
    attr_reader :workspace
    attr_reader :columns
    # @return [Client] Client object
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

    # Create a new column in the table
    # @param column_name [String] The new column's name
    # @param type [Symbol] Column data type. See {Column::DATA_TYPES}
    # @param opts [Hash] Optional arguments
    # @option opts [Boolean] :required Should the column be mandatory. Defaults to false.
    # @option opts [String] :description The column's description
    def create_column(column_name, type, **opts)
      if !Column::DATA_TYPES.values.include?(type)
        raise ArgumentError.new("Column type must be one of: #{Column::DATA_TYPES.values.join(', ')}")
      end
      @type = type
      @required = opts[:required] || false
      @description = opts[:description] || ""
      res = client.get path: "#{workspace.name}/#{name}", params: {
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

    # Retrieve a table column by name
    # @param name [String] The column name
    # @return [Column]
    def column(name)
      res = client.get path: "#{workspace.name}/#{name}", params: {
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

    # Import data into the table using one of three methods: :append,
    # :truncate_add, or :update_add. The :append option simply adds rows to
    # the end of the table. When using :truncate_add, all rows are first
    # removed and replaced by the new rows. If :update_add is selected,
    # the :matching option must be provided to match rows to be updated by
    # any imported row data.
    # @param import_type [Symbol] Import type. Must be one of: :append, :truncate_add, :update_add
    # @param data [Hash] The data to import. Must be a hash with column names as keys and cell contents as values.
    # @param opts [Hash] Optional arguments
    # @option opts [Array] :matching Array of column names to match when using :update_add
    # @raise [ArgumentError]
    def import(import_type, data, **opts)
      if !IMPORT_TYPES.keys.include?(import_type)
        raise ArgumentError.new("import_type must be one of: #{IMPORT_TYPES.keys.join(', ')}")
      end

      params = {
        "ZOHO_ACTION" => "IMPORT",
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

      res = client.post_json path: "#{workspace.name}/#{name}", io: StringIO.new(data.to_json), params: params
      if res.success?
        data = JSON.parse(res.body)
        data.dig("response", "result", "importSummary", "successRowCount")
      else
        nil
      end
    end

    # Safer delete option. Deletes rows from the table based on the given
    # criteria.
    # @param criteria [String] The row criteria to match when deleting rows.
    def delete(criteria)
      if criteria.nil?
        raise ArgumentError.new("Delete criteria must be specified")
      end

      delete!(criteria)
    end

    # Unsafe delete. Deletes rows based on the given criteria. If not
    # provided, all rows are deleted.
    # @param criteria [String] The row criteria to match when deleting rows.
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

    # Insert a single row into the table
    # @param row [Hash] Hash of row data. Column names are keys, and cell contents are values.
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
