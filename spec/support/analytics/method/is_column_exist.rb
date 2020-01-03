module Zoho
  module Support
    module Analytics
      class IsColumnExist < Method
        def match?
          @params["ZOHO_ACTION"] == "ISCOLUMNEXIST" && @params["ZOHO_COLUMN_NAME"].is_a?(String)
        end

        def response
          m = @params["ZOHO_COLUMN_NAME"].match(/(?i)Missing/)
          {
            "response" => {
              "uri" => "/api/name@email.com",
              "action" => "ISCOLUMNEXIST",
              "result" => {
                "iscolumnexist" => m.nil?.to_s
              }
            }
          }
        end
      end
    end
  end
end
