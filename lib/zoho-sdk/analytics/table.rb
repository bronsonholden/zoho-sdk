require "zoho-sdk/analytics/column"

module Zoho
  module Analytics
    class Table
      attr_reader :name

      def initialize(name, workspace, client)
        @name = name
        @workspace = workspace
        @client = client
      end

      def exists?
      end

      def create(name:, folder: nil, columns: [], description: "")
        if !columns.is_a?(Array)
          raise ArgumentError.new("Table columns must be provided as an Array")
        elsif columns.size < 1
          raise ArgumentError.new("Table must have at least one column")
        end
      end

      def column(name)
        Zoho::Analytics::Column.new(name, self, @client)
      end

      def rows
      end

      def <<(row)
      end
    end
  end
end
