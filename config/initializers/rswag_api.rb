# frozen_string_literal: true

if defined?(Rswag::Api)
  Rswag::Api.configure do |c|
    # Location where rswag-api will look for generated Swagger files
    c.swagger_root = Rails.root.join('swagger').to_s

    # Optionally filter the swagger content per-request (e.g., auth-based filtering)
    # Leave as a passthrough for now
    c.swagger_filter = ->(swagger, _env) { swagger }
  end
end
