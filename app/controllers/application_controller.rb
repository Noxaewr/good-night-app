# frozen_string_literal: true

class ApplicationController < ActionController::API
  include JsonRendering
  include Paginatable

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response
  rescue_from ErrorNotFound, with: :render_not_found_exception
  rescue_from ErrorUnprocessableEntity, with: :render_unprocessable_entity_exception
  rescue_from BaseError, with: :render_base_error

  private

  def render_base_error(error)
    render json: {
      error: {
        code: error.code,
        message: error.message,
        data: error.data
      }
    }, status: error.http_status
  end
end
