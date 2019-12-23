module Zoho
  module Support
    module Analytics
      class WorkspaceMetadata < Method
        def match?(params)
          super || (params["ZOHO_ACTION"] == "DATABASEMETADATA" && params["ZOHO_METADATA"] == "ZOHO_CATALOG_LIST")
        end
      end
    end
  end
end
