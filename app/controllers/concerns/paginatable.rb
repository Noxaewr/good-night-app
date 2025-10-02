module Paginatable
  extend ActiveSupport::Concern

  private

  def paginate_collection(collection, per_page: 25)
    page = params[:page] || 1
    per_page = params[:per_page] || per_page
    
    # Limit per_page to prevent abuse
    per_page = [per_page.to_i, 100].min
    per_page = 25 if per_page <= 0
    
    collection.page(page).per(per_page)
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end
end
