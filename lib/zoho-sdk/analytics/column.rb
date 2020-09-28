module ZohoSdk
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
