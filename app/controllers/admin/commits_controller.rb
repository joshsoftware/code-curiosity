class Admin::CommitsController < ApplicationController
  
  def index
    from = (params[:from].presence.try(:to_date) || Date.yesterday).beginning_of_day
    to = (params[:to].presence.try(:to_date) || Date.yesterday).end_of_day

    @commits = Commit.all.in_range(from, to)
                       .search_by(params[:query])
                       .page(params[:page])
  end
end