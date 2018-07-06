class Admin::CommitsController < ApplicationController
  
  def index
    from = params[:from].presence.try(:to_date).try(:beginning_of_day) || Date.yesterday.beginning_of_day
    to = params[:to].presence.try(:to_date).try(:end_of_day) || Date.yesterday.end_of_day
    @commits = Commit.all
    @commits = @commits.in_range(from, to)
                       .search_by(params[:query])
                       .page(params[:page])
  end
end