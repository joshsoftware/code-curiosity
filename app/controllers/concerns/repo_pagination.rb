module RepoPagination
  def paginate(pages_count)
    @total_count = if params[:total_count].present?
                     params[:total_count].to_i
                   else
                     GITHUB.per_page * pages_count
                   end

    @pagination = Kaminari.paginate_array([], total_count: @total_count)
                          .page(params[:page])
                          .limit(GITHUB.per_page)

    @pagination.offset_value = params[:page].to_i > 0 ? GITHUB.per_page * (params[:page].to_i - 1) : 0
  end
end

