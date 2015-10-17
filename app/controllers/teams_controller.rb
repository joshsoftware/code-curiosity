class TeamsController < ApplicationController
  before_action :set_team, except: [:index, :create]

  def index
    @teams = Team.all.asc(:name)
    @devs  = Member.all.map(&:username)
    @repos = Repository.all.map(&:name)
  end

  def create
    @team = Team.create_with_members(params[:team])
  end

  def update
    @team.add_repos(params[:repos])
    render nothing: true
  end

  def show
    @commits  = @team.commits.order("commit_data desc")
    @activities = @team.member_activities.order("created_at desc")
  end

  def destroy
    @team.destroy
  end

  def set_team
    @team = Team.find(params[:id])
  end
end
