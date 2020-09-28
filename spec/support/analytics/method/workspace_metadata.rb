module ZohoSdk
  module TestService
    module Analytics
      class WorkspaceMetadata < Method
        def match?
          @params["ZOHO_ACTION"] == "DATABASEMETADATA" && @params["ZOHO_METADATA"] == "ZOHO_CATALOG_LIST"
        end
      end
    end
  end
end
