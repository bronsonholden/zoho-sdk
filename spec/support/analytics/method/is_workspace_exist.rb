module ZohoSdk
  module TestService
    module Analytics
      class IsWorkspaceExist < Method
        def match?
          @params["ZOHO_ACTION"] == "ISDBEXIST" && @params["ZOHO_DB_NAME"].is_a?(String)
        end

        def response
          m = @params["ZOHO_DB_NAME"].match(/(?i)Missing/)
          {
            "response" => {
              "uri" => "/api/name@email.com",
              "action" => "ISDBEXIST",
              "result" => {
                "isdbexist" => m.nil?.to_s
              }
            }
          }
        end
      end
    end
  end
end
