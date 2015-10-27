class TeamsController < ApplicationController
  before_action :set_team, except: [:index, :create]
  before_action :authenticate_user!, except: [:index]

  def index
    @teams = @current_round.teams.asc(:name)
    @devs  = Member.all.map(&:username)
    @repos = Repository.all.map(&:name)
  end

  def create
    @team = Team.create_with_members(params[:team], @current_round.id)
  end

  def update
    @team.add_repos(params[:repos])
    render nothing: true
  end

  def show
    @commits = @team.commits.for_round(@current_round.id).includes(:scores).desc(:commit_date)
    @activities = @team.activities.for_round(@current_round.id).includes(:scores).desc(:commented_on)
  end

  def destroy
    @team.destroy
  end

  def set_team
    @team = Team.find(params[:id])
  end
end
