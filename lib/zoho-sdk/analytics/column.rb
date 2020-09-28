module ZohoSdk::Analytics
  class Column
    DATA_TYPES = {
      "Auto" => :system,
      "Plain Text" => :plain,
      "E-Mail" => :email,
      "Multi Line Text" => :multi,
      "URL" => :url,
      "Number" => :number,
      "Auto Number" => :auto_number,
      "Positive Number" => :positive_number,
      "Decimal Number" => :decimal_number,
      "Currency" => :currency,
      "Percentage" => :percentage,
      "Date" => :date,
      "Yes/No Decision" => :boolean
    }.freeze

    attr_reader :name, :table

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
