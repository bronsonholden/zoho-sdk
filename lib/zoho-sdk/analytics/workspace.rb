require "zoho-sdk/analytics/table"

module ZohoSdk::Analytics
  class Workspace
    attr_reader :client

    def initialize(workspace_name, client)
      @workspace_name = workspace_name
      @client = client
      @metadata = nil
    end

    def name
      @workspace_name
    end

    def metadata
      return @metadata if !@metadata.nil?
      metadata!
    end

    def metadata!
      res = client.get path: name, params: {
        "ZOHO_ACTION" => "DATABASEMETADATA",
        "ZOHO_METADATA" => "ZOHO_CATALOG_INFO"
      }
      if res.success?
        data = JSON.parse(res.body)
        @metadata = data.dig("response", "result")
        @metadata
      else
        nil
      end
    end

    def create_table(table_name, folder = nil, **opts)
      table_design = {
        "TABLENAME" => table_name,
        "TABLEDESCRIPTION" => opts[:description] || "",
        "COLUMNS" => []
      }
      table_design["FOLDERNAME"] = folder if !folder.nil?
      res = client.get path: name, params: {
        "ZOHO_ACTION" => "CREATETABLE",
        "ZOHO_TABLE_DESIGN" => table_design.to_json
      }
      if res.success?
        data = JSON.parse(res.body)
        Table.new(name, self, client)
      else
        nil
      end
    end

    def table(table_name)
      res = client.get path: name, params: {
        "ZOHO_ACTION" => "ISVIEWEXIST",
        "ZOHO_VIEW_NAME" => table_name
      }
      if res.success?
        data = JSON.parse(res.body)
        if data.dig("response", "result", "isviewexist") == "true"
          Table.new(table_name, self, client)
        else
          nil
        end
      else
        nil
      end
    end
  end
end
