require "zoho-sdk/analytics/client"

module ZohoSdk::Analytics
  class Error < StandardError; end

  class ColumnAlreadyExistsError < Error
  end

  class TableAlreadyExistsError < Error
  end

  class WorkspaceAlreadyExistsError < Error
  end
end
