module Zoho
  module Support
    module Analytics
      class IsWorkspaceExist < Method
        def match?(params)
          params["ZOHO_ACTION"] == "ISDBEXIST" && params["ZOHO_DB_NAME"].is_a?(String)
        end

        def response
          {
            "response" => {
              "uri" => "/api/name@email.com",
              "action" => "ISDBEXIST",
              "result" => {
                "isdbexist" => "true"
              }
            }
          }
        end
      end
    end
  end
end
