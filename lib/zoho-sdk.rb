require "zoho-sdk/version"
require "zoho-sdk/analytics"

module Zoho
  class Error < StandardError; end

  class ColumnAlreadyExistsError < Error
  end

  class TableAlreadyExistsError < Error
  end

  class WorkspaceAlreadyExistsError < Error
  end
end
