# frozen_string_literal: true

Kaminari.configure do |config|
  # Default items per page
  config.default_per_page = 25
  
  # Maximum items per page (to prevent abuse)
  config.max_per_page = 100
  
  # Window for pagination links (not used in API but good to set)
  config.window = 4
  
  # Outer window for pagination links
  config.outer_window = 0
  
  # Left side of pagination links
  config.left = 0
  
  # Right side of pagination links  
  config.right = 0
  
  # Parameter name for page number
  config.param_name = :page
  
  # Parameter name for per_page
  config.max_pages = nil
end
