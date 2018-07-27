class Admin::CommitsController < ApplicationController
  
  def index
    from = (params[:from].presence.try(:to_date) || Date.today.beginning_of_month).beginning_of_day
    to = (params[:to].presence.try(:to_date) || Date.today).end_of_day

    @commits = Commit.all.in_range(from, to)
                       .search_by(params[:query])
    @sum = @commits.sum(:reward)
    @commits = @commits.page(params[:page])

  end
end
