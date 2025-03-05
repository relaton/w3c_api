# frozen_string_literal: true

require "w3c/api/version"
require "w3c/api/client"
require "w3c/api/cli"

# Load all model files
Dir[File.join(__dir__, "w3c", "api", "models", "*.rb")].sort.each do |file|
  require file
end

module W3c
  module Api
    class Error < StandardError; end
    class NotFoundError < Error; end
    class UnauthorizedError < Error; end
    class BadRequestError < Error; end
    class ServerError < Error; end
  end
end
