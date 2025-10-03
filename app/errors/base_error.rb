# frozen_string_literal: true

class BaseError < StandardError
  attr_reader :code, :message, :data, :http_status

  def initialize(code: nil, message: nil, data: {}, http_status: :internal_server_error)
    @code = code
    @message = message || self.class.name
    @data = data
    @http_status = http_status
    super(@message)
  end
end
