module Zoho
  module Analytics
    class Column
      DATA_TYPES = %i[plain multi_line email number positive_number date url
                      decimal_number currency percent boolean auto_number].freeze

      attr_accessor :name

      def initialize(name, table, client)
        @name = name
        @table = table
        @client = client
      end

      def exists?
      end

      def create(type:, required: false, description: nil)
        if !DATA_TYPES.include?(type)
          raise ArgumentError.new("Column type must be one of: #{DATA_TYPES.join(', ')}")
        end
        @type = type
        @required = required
        @description = description
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
