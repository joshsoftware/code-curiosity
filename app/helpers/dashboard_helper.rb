module DashboardHelper
  def check_if_active(cat)
    'active' if @category == cat
  end
end
