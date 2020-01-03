module Zoho
  module Analytics
    class Column
      DATA_TYPES = %i[plain multi_line email number positive_number date url
                      decimal_number currency percent boolean auto_number].freeze

      attr_accessor :name, :table

      def initialize(name, table, client)
        @name = name
        @table = table
        @client = client
        @exists
      end

      def exists?
        res = @client.get path: "#{table.workspace.name}/#{table.name}", params: {
          "ZOHO_ACTION" => "ISCOLUMNEXIST",
          "ZOHO_COLUMN_NAME" => name
        }
        if res.success?
          data = JSON.parse(res.body)
          if data.dig("response", "result", "iscolumnexist") == "true"
            @exists = true
          else
            @exists = false
          end
        else
          # Raise
          nil
        end
      end

      def create(*args)
        create!(*args) if !exists?
        self
      end

      def create!(type:, required: false, description: "")
        if !DATA_TYPES.include?(type)
          raise ArgumentError.new("Column type must be one of: #{DATA_TYPES.join(', ')}")
        end
        @type = type
        @required = required
        @description = description
        res = @client.get path: "#{table.workspace.name}/#{table.name}", params: {
          "ZOHO_ACTION" => "ADDCOLUMN",
          "ZOHO_COLUMNNAME" => name,
          "ZOHO_DATATYPE" => type.to_s.upcase
        }
        if res.success?
          data = JSON.parse(res.body)
        else
          # Raise
        end
      end

      def type
        if exists?
          @type
        else
          # GET column info
        end
      end

      def description
        if exists?
          @description
        else
          # GET column info
        end
      end

      def required?
        if exists?
          @required
        else
          # GET column info
        end
      end
    end
  end
end
