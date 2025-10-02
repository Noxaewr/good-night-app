module JsonRendering
  extend ActiveSupport::Concern

  included do
    def render_unprocessable_entity_response(exception)
      render json: { errors: exception.record.errors }, status: :unprocessable_content
    end

    def render_ok(message = nil)
      render json: { message: message }, status: :ok
    end

    def render_unprocessable_entity(message = nil)
      render json: { message: message }, status: :unprocessable_content
    end

    def render_not_found_response
      render json: { error: "Record not found" }, status: :not_found
    end

    def render_unprocessable_entity_exception(error)
      render json: { error: error.errors }, status: :unprocessable_content
    end

    def render_internal_server_exception(error)
      render json: { error: error.message }, status: :internal_server_error
    end

    def render_not_found_exception(message = "Record not found")
      render json: { error: message }, status: :not_found
    end

    def render_forbidden
      render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
    end

    def render_unauthorized
      render json: { error: 'User not authenticated' }, status: :unauthorized
    end

    def render_conflict(message = "Record conflict")
      render json: { message: message }, status: :conflict
    end

    def render_created(message = "Record created")
      render json: { message: message }, status: :created
    end

    def render_json(serializer, obj, options = {})
      return render_collection(serializer, obj, options) if obj.respond_to?(:current_page)

      render_record(serializer, obj, options)
    end

    def render_collection(serializer, collection, options = {})
      options = meta_pagination(collection, options)
      render_record(serializer, collection, options)
    end

    def render_record(serializer, record, options = {})
      http_status = options[:status] || :ok
      render json: serializer.new(record, options), status: http_status
    end

    def render_json_error_validation(obj)
      render json: { errors: obj.errors, error_full_message: obj.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def meta_pagination(paginated_obj, options = {})
    options[:meta] = {} unless options.key?(:meta)
    meta_options = options[:meta].merge(generate_pagination(paginated_obj))
    options[:meta] = meta_options
    options
  end

  def generate_pagination(paginated_obj)
    {
      pagination: {
        current_page: paginated_obj.current_page,
        prev_page: paginated_obj.prev_page,
        next_page: paginated_obj.next_page,
        total_items: paginated_obj.total_count,
        total_pages: paginated_obj.total_pages
      }
    }
  end
end
