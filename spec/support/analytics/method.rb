module Zoho
  module Support
    module Analytics
      class Method
        def match?(params)
          false
        end

        def status
          200
        end

        def response
          {
          }
        end
      end
    end
  end
end

require "support/analytics/method/workspace_metadata"
require "support/analytics/method/is_workspace_exist"
