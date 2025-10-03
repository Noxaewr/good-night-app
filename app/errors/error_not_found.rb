# frozen_string_literal: true

class ErrorNotFound < BaseError
  def initialize(message: "Record not found", data: {})
    super(
      code: "NOT_FOUND",
      message: message,
      data: data,
      http_status: :not_found
    )
  end
end
