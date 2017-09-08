module SponsorerDetailsHelper

  def active_tab(sponsorer_type)
    'active' if !session[:type].present? or (session[:type] and session[:type] == sponsorer_type)
  end
end
