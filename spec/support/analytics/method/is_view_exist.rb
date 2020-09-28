module ZohoSdk
  module TestService
    module Analytics
      class IsViewExist < Method
        def match?
          @params["ZOHO_ACTION"] == "ISVIEWEXIST" && @params["ZOHO_VIEW_NAME"].is_a?(String)
        end

        def response
          m = @params["ZOHO_VIEW_NAME"].match(/(?i)Missing/)
          {
            "response" => {
              "uri" => "/api/name@email.com",
              "action" => "ISVIEWEXIST",
              "result" => {
                "isviewexist" => m.nil?.to_s
              }
            }
          }
        end
      end
    end
  end
end
