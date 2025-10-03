# frozen_string_literal: true

class ErrorUnprocessableEntity < BaseError
  def initialize(message: "Unprocessable entity", data: {})
    super(
      code: "UNPROCESSABLE_ENTITY",
      message: message,
      data: data,
      http_status: :unprocessable_content
    )
  end
end
