module ZohoSdk
  module TestService
    module Analytics
      class Method
        def initialize(params)
          @params = params
        end

        def match?
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
require "support/analytics/method/is_column_exist"
require "support/analytics/method/is_view_exist"
